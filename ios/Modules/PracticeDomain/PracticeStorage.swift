import Foundation

/// Simple JSON file-based storage for practice data.
/// Stores sessions and items in separate JSON files with schema versioning.
final class PracticeStorage {

    // MARK: - Schema Version

    /// Current schema version for storage format.
    /// Increment this when making breaking changes to stored data structures.
    static let schemaVersion = 1

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

    private var sessionsURL: URL {
        directory.appendingPathComponent(sessionsFileName)
    }

    private var itemsURL: URL {
        directory.appendingPathComponent(itemsFileName)
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

    // MARK: - Session Storage

    /// Save sessions to storage (replaces all existing sessions)
    func saveSessions(_ sessions: [PracticeSession]) {
        do {
            let store = SessionsStore(sessions: sessions)
            let data = try encoder.encode(store)
            try data.write(to: sessionsURL, options: .atomic)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }

    /// Append a single session to storage
    func saveSession(_ session: PracticeSession) {
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
    }

    /// Load all sessions from storage
    func loadSessions() -> [PracticeSession] {
        guard FileManager.default.fileExists(atPath: sessionsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: sessionsURL)
            // Try to decode with schema wrapper first
            if let store = try? decoder.decode(SessionsStore.self, from: data) {
                return store.sessions
            }
            // Fall back to legacy format (array without wrapper)
            return try decoder.decode([PracticeSession].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
            return []
        }
    }

    // MARK: - Item Storage

    /// Save items to storage (replaces all existing items)
    func saveItems(_ items: [PracticeItem]) {
        do {
            let store = ItemsStore(items: items)
            let data = try encoder.encode(store)
            try data.write(to: itemsURL, options: .atomic)
        } catch {
            print("Failed to save items: \(error)")
        }
    }

    /// Load all items from storage
    func loadItems() -> [PracticeItem] {
        guard FileManager.default.fileExists(atPath: itemsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: itemsURL)
            // Try to decode with schema wrapper first
            if let store = try? decoder.decode(ItemsStore.self, from: data) {
                return store.items
            }
            // Fall back to legacy format (array without wrapper)
            return try decoder.decode([PracticeItem].self, from: data)
        } catch {
            print("Failed to load items: \(error)")
            return []
        }
    }

    /// Load practice items, merging stored SRS state with the seed catalog.
    /// On first run, returns default items from the catalog.
    /// On subsequent runs, updates catalog items with stored SRS state.
    func loadPracticeItems(now: Date = Date()) -> [PracticeItem] {
        let storedItems = loadItems()
        let catalogItems = PracticeItemCatalog.seedItems(now: now)

        // First run: no stored items, return catalog defaults
        if storedItems.isEmpty {
            return catalogItems
        }

        // Merge stored SRS state with catalog
        // This preserves catalog structure while keeping user's SRS progress
        let storedByTitle = Dictionary(storedItems.map { ($0.title, $0) }, uniquingKeysWith: { first, _ in first })

        return catalogItems.map { catalogItem in
            if let storedItem = storedByTitle[catalogItem.title] {
                var merged = catalogItem
                merged.srs = storedItem.srs
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
}
