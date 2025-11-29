import Foundation

/// Simple JSON file-based storage for practice data.
/// Stores sessions and items in separate JSON files with schema versioning.
///
/// # Migration Strategy
///
/// This storage layer uses a simple schema versioning approach:
///
/// - **Current version**: Stored in `PracticeStorage.schemaVersion`
/// - **Legacy format**: Unwrapped arrays (pre-versioning, treated as v0)
/// - **Migration**: Automatic and transparent when loading data
///
/// ## How to Add a New Schema Version
///
/// 1. Increment `PracticeStorage.schemaVersion`
/// 2. Update domain models as needed (PracticeSession, PracticeItem, etc.)
/// 3. Add migration logic in `migrate*` methods for the previous version
/// 4. Add tests in `PracticeStorageTests` to verify migration from old version
/// 5. Ensure new version can still fall back to legacy format if needed
///
/// ## Error Handling
///
/// Storage failures are logged but not propagated (graceful degradation):
/// - **Corrupted data**: Returns empty array, logs "corrupted file"
/// - **Unknown version**: Returns empty array, logs "unknown schema version"
/// - **Legacy format**: Migrates automatically from unwrapped array format
/// - **Save failures**: Logs error, does not crash app
///
final class PracticeStorage {

    // MARK: - Schema Version

    /// Current schema version for storage format.
    /// Increment this when making breaking changes to stored data structures.
    ///
    /// Version history:
    /// - v0: Legacy format (unwrapped arrays, no version field)
    /// - v1: Added SessionsStore/ItemsStore wrappers with schemaVersion field
    /// - v2: Added TempoState to PracticeItem, tempo tracking fields to PracticeBlock
    static let schemaVersion = 2

    // MARK: - Storage Wrappers

    /// Wrapper that includes schema version for sessions storage.
    private struct SessionsStore: Codable {
        let schemaVersion: Int
        let sessions: [PracticeSession]

        init(sessions: [PracticeSession]) {
            self.schemaVersion = PracticeStorage.schemaVersion
            self.sessions = sessions
        }
    }

    /// Wrapper that includes schema version for items storage.
    private struct ItemsStore: Codable {
        let schemaVersion: Int
        let items: [PracticeItem]

        init(items: [PracticeItem]) {
            self.schemaVersion = PracticeStorage.schemaVersion
            self.items = items
        }
    }

    // MARK: - Properties

    private let directory: URL
    private let sessionsFileName = "sessions.json"
    private let itemsFileName = "items.json"
    private let preferencesFileName = "preferences.json"

    private var sessionsURL: URL {
        directory.appendingPathComponent(sessionsFileName)
    }

    private var itemsURL: URL {
        directory.appendingPathComponent(itemsFileName)
    }

    private var preferencesURL: URL {
        directory.appendingPathComponent(preferencesFileName)
    }

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /// Initialize with a custom directory (useful for testing)
    init(directory: URL) {
        self.directory = directory
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()

        // Use ISO8601 for consistent date formatting
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        // Ensure directory exists
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    /// Initialize with default app documents directory
    convenience init() {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("piq")

        self.init(directory: documents)
    }

    // MARK: - Internal Error Handling

    /// Internal enum to categorize load failures for better logging.
    private enum LoadError: Error {
        case corruptedData(underlying: Error)
        case unknownSchemaVersion(Int)
        case fileReadError(underlying: Error)
    }

    /// Log a load error with context about the error type.
    private func logLoadError(_ error: LoadError, context: String) {
        switch error {
        case .corruptedData(let underlying):
            print("⚠️ PracticeStorage: Corrupted \(context) file - returning empty. Error: \(underlying)")
        case .unknownSchemaVersion(let version):
            print("⚠️ PracticeStorage: Unknown schema version \(version) in \(context) - returning empty. Current version: \(Self.schemaVersion)")
        case .fileReadError(let underlying):
            print("⚠️ PracticeStorage: Failed to read \(context) file - returning empty. Error: \(underlying)")
        }
    }

    // MARK: - Session Storage

    /// Save sessions to storage (replaces all existing sessions)
    func saveSessions(_ sessions: [PracticeSession]) {
        do {
            let store = SessionsStore(sessions: sessions)
            let data = try encoder.encode(store)
            try data.write(to: sessionsURL, options: .atomic)
        } catch {
            print("⚠️ PracticeStorage: Failed to save sessions: \(error)")
        }
    }

    /// Append a single session to storage
    func saveSession(_ session: PracticeSession) {
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
    }

    /// Load all sessions from storage with automatic migration.
    ///
    /// Handles multiple schema versions:
    /// - v1 (current): SessionsStore wrapper with schemaVersion
    /// - v0 (legacy): Unwrapped array format
    ///
    /// Returns empty array on any load failure (corrupted data, unknown version, etc.)
    func loadSessions() -> [PracticeSession] {
        guard FileManager.default.fileExists(atPath: sessionsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: sessionsURL)
            return try loadSessionsWithMigration(from: data)
        } catch let error as LoadError {
            logLoadError(error, context: "sessions")
            return []
        } catch {
            logLoadError(.fileReadError(underlying: error), context: "sessions")
            return []
        }
    }

    /// Internal method to load and migrate sessions data.
    private func loadSessionsWithMigration(from data: Data) throws -> [PracticeSession] {
        // Try to decode as current version (v1)
        if let store = try? decoder.decode(SessionsStore.self, from: data) {
            // Check if this is a known version
            if store.schemaVersion > Self.schemaVersion {
                throw LoadError.unknownSchemaVersion(store.schemaVersion)
            }
            // Currently only v1 exists, return as-is
            // Future: Add migration logic here for older versions
            return store.sessions
        }

        // Try legacy format (v0): unwrapped array
        if let sessions = try? decoder.decode([PracticeSession].self, from: data) {
            return migrateLegacySessionsToV1(sessions)
        }

        // Unable to decode as any known format
        throw LoadError.corruptedData(underlying: DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "Not a valid SessionsStore or legacy array")
        ))
    }

    /// Migrate sessions from legacy format (v0) to current format.
    private func migrateLegacySessionsToV1(_ sessions: [PracticeSession]) -> [PracticeSession] {
        // v0 -> v1: No structural changes to PracticeSession itself,
        // just the addition of the wrapper. Return as-is.
        return sessions
    }

    // MARK: - Item Storage

    /// Save items to storage (replaces all existing items)
    func saveItems(_ items: [PracticeItem]) {
        do {
            let store = ItemsStore(items: items)
            let data = try encoder.encode(store)
            try data.write(to: itemsURL, options: .atomic)
        } catch {
            print("⚠️ PracticeStorage: Failed to save items: \(error)")
        }
    }

    /// Load all items from storage with automatic migration.
    ///
    /// Handles multiple schema versions:
    /// - v1 (current): ItemsStore wrapper with schemaVersion
    /// - v0 (legacy): Unwrapped array format
    ///
    /// Returns empty array on any load failure (corrupted data, unknown version, etc.)
    func loadItems() -> [PracticeItem] {
        guard FileManager.default.fileExists(atPath: itemsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: itemsURL)
            return try loadItemsWithMigration(from: data)
        } catch let error as LoadError {
            logLoadError(error, context: "items")
            return []
        } catch {
            logLoadError(.fileReadError(underlying: error), context: "items")
            return []
        }
    }

    /// Internal method to load and migrate items data.
    private func loadItemsWithMigration(from data: Data) throws -> [PracticeItem] {
        // Try to decode as current version (v1)
        if let store = try? decoder.decode(ItemsStore.self, from: data) {
            // Check if this is a known version
            if store.schemaVersion > Self.schemaVersion {
                throw LoadError.unknownSchemaVersion(store.schemaVersion)
            }
            // Currently only v1 exists, return as-is
            // Future: Add migration logic here for older versions
            return store.items
        }

        // Try legacy format (v0): unwrapped array
        if let items = try? decoder.decode([PracticeItem].self, from: data) {
            return migrateLegacyItemsToV1(items)
        }

        // Unable to decode as any known format
        throw LoadError.corruptedData(underlying: DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "Not a valid ItemsStore or legacy array")
        ))
    }

    /// Migrate items from legacy format (v0) to current format.
    private func migrateLegacyItemsToV1(_ items: [PracticeItem]) -> [PracticeItem] {
        // v0 -> v1: No structural changes to PracticeItem itself,
        // just the addition of the wrapper. Return as-is.
        return items
    }

    /// Load practice items, merging stored SRS state with the seed catalog.
    ///
    /// Merge strategy: Uses stable `catalogID` as the key. This ensures that
    /// catalog title or detail changes don't cause loss of stored SRS state.
    ///
    /// On first run, returns default items from the catalog.
    /// On subsequent runs, updates catalog items with stored SRS and tempo state.
    func loadPracticeItems(now: Date = Date()) -> [PracticeItem] {
        let storedItems = loadItems()
        let catalogItems = PracticeItemCatalog.seedItems(now: now)

        // First run: no stored items, return catalog defaults
        if storedItems.isEmpty {
            return catalogItems
        }

        // Merge stored SRS and tempo state with catalog using stable catalogID
        let storedByCatalogID = Dictionary(
            storedItems.map { ($0.catalogID, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        return catalogItems.map { catalogItem in
            if let storedItem = storedByCatalogID[catalogItem.catalogID] {
                var merged = catalogItem
                merged.srs = storedItem.srs
                merged.tempo = storedItem.tempo
                return merged
            }
            return catalogItem
        }
    }

    // MARK: - Utility

    /// Check if this is a first run (no saved data)
    var isFirstRun: Bool {
        !FileManager.default.fileExists(atPath: sessionsURL.path) &&
        !FileManager.default.fileExists(atPath: itemsURL.path)
    }

    /// Clear all stored data
    func clearAll() {
        try? FileManager.default.removeItem(at: sessionsURL)
        try? FileManager.default.removeItem(at: itemsURL)
    }

    // MARK: - User Preferences Storage

    /// Save user preferences to storage.
    func savePreferences(_ preferences: UserPreferences) {
        do {
            let data = try encoder.encode(preferences)
            try data.write(to: preferencesURL, options: .atomic)
        } catch {
            print("⚠️ PracticeStorage: Failed to save preferences: \(error)")
        }
    }

    /// Load user preferences from storage.
    /// Returns default preferences if none are saved.
    func loadPreferences() -> UserPreferences {
        guard FileManager.default.fileExists(atPath: preferencesURL.path) else {
            return .default
        }

        do {
            let data = try Data(contentsOf: preferencesURL)
            return try decoder.decode(UserPreferences.self, from: data)
        } catch {
            print("⚠️ PracticeStorage: Failed to load preferences: \(error)")
            return .default
        }
    }

    /// Check if user has completed onboarding.
    var hasCompletedOnboarding: Bool {
        loadPreferences().hasCompletedOnboarding
    }

    /// Reset onboarding to fresh state.
    /// Resets preferences to defaults but preserves session history.
    func resetOnboarding() {
        savePreferences(.default)
    }

    /// Clear all data including preferences.
    func clearAllIncludingPreferences() {
        clearAll()
        try? FileManager.default.removeItem(at: preferencesURL)
    }
}
