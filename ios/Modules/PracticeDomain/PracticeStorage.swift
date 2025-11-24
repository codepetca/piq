import Foundation

/// Simple JSON file-based storage for practice data.
/// Stores sessions and items in separate JSON files.
final class PracticeStorage {

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
            let data = try encoder.encode(sessions)
            try data.write(to: sessionsURL, options: .atomic)
        } catch {
            // In production, we might want to log this error
            print("Failed to save sessions: \(error)")
        }
    }

    /// Load all sessions from storage
    func loadSessions() -> [PracticeSession] {
        guard FileManager.default.fileExists(atPath: sessionsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: sessionsURL)
            return try decoder.decode([PracticeSession].self, from: data)
        } catch {
            // Return empty on decode failure (corrupted file)
            print("Failed to load sessions: \(error)")
            return []
        }
    }

    // MARK: - Item Storage

    /// Save items to storage (replaces all existing items)
    func saveItems(_ items: [PracticeItem]) {
        do {
            let data = try encoder.encode(items)
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
            return try decoder.decode([PracticeItem].self, from: data)
        } catch {
            print("Failed to load items: \(error)")
            return []
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
