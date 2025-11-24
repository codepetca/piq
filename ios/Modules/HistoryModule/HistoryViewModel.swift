import Foundation
import Observation

/// ViewModel for managing practice history.
@Observable
final class HistoryViewModel {

    // MARK: - Properties

    private(set) var sessions: [PracticeSession] = []
    private let storage: PracticeStorage

    // MARK: - Initialization

    init(storage: PracticeStorage = PracticeStorage()) {
        self.storage = storage
    }

    // MARK: - Data Loading

    /// Load all sessions from storage.
    func loadSessions() {
        sessions = storage.loadSessions().sorted { $0.date > $1.date }
    }

    // MARK: - Session Management

    /// Add a completed session to history.
    func addSession(_ session: PracticeSession) {
        sessions.insert(session, at: 0)
        sessions.sort { $0.date > $1.date }
        storage.saveSessions(sessions)
    }

    /// Delete a session from history.
    func deleteSession(_ session: PracticeSession) {
        sessions.removeAll { $0.id == session.id }
        storage.saveSessions(sessions)
    }

    /// Delete sessions at the specified offsets.
    func deleteSessions(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        storage.saveSessions(sessions)
    }

    // MARK: - Statistics

    /// Total number of practice sessions.
    var totalSessions: Int {
        sessions.count
    }

    /// Total minutes practiced across all sessions.
    var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.totalActualMinutes }
    }

    /// Number of sessions completed this week.
    var sessionsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!

        return sessions.filter { $0.date >= startOfWeek }.count
    }

    /// Average session length in minutes.
    var averageSessionMinutes: Int {
        guard !sessions.isEmpty else { return 0 }
        return totalMinutes / sessions.count
    }

    // MARK: - Grouping

    /// Sessions grouped by date (for sectioned list display).
    var sessionsByDate: [(date: Date, sessions: [PracticeSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }

        return grouped
            .map { (date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    /// Sessions for a specific date.
    func sessions(for date: Date) -> [PracticeSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}
