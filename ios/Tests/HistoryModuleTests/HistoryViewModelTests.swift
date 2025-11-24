import Foundation
import Testing
@testable import Piq

@Suite("HistoryViewModel Tests")
struct HistoryViewModelTests {

    // MARK: - Setup Helper

    func makeTestStorage() -> PracticeStorage {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        return PracticeStorage(directory: tempDir)
    }

    func makeSampleSession(date: Date = Date(), totalMinutes: Int = 40) -> PracticeSession {
        var session = PracticeSession.makeTodayDemo()
        session = PracticeSession(
            id: UUID(),
            date: date,
            blocks: session.blocks.map { block in
                var b = block
                b.actualMinutes = totalMinutes / 4
                b.feedback = .good
                return b
            }
        )
        return session
    }

    // MARK: - Loading Tests

    @Test("Loads sessions from storage")
    func loadsSessionsFromStorage() {
        let storage = makeTestStorage()
        let session1 = makeSampleSession()
        let session2 = makeSampleSession()
        storage.saveSessions([session1, session2])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        #expect(viewModel.sessions.count == 2)
    }

    @Test("Returns empty array when no sessions saved")
    func returnsEmptyWhenNoSessions() {
        let storage = makeTestStorage()
        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        #expect(viewModel.sessions.isEmpty)
    }

    @Test("Sessions sorted by date descending")
    func sessionsSortedByDateDescending() {
        let storage = makeTestStorage()
        let oldDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentDate = Date()

        let oldSession = makeSampleSession(date: oldDate)
        let recentSession = makeSampleSession(date: recentDate)

        storage.saveSessions([oldSession, recentSession])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        #expect(viewModel.sessions.first?.date == recentDate)
        #expect(viewModel.sessions.last?.date == oldDate)
    }

    // MARK: - Add Session Tests

    @Test("Add session saves to storage")
    func addSessionSavesToStorage() {
        let storage = makeTestStorage()
        let viewModel = HistoryViewModel(storage: storage)

        let session = makeSampleSession()
        viewModel.addSession(session)

        // Reload from storage to verify persistence
        let loadedSessions = storage.loadSessions()
        #expect(loadedSessions.count == 1)
        #expect(loadedSessions.first?.id == session.id)
    }

    @Test("Add session updates local sessions list")
    func addSessionUpdatesLocalList() {
        let storage = makeTestStorage()
        let viewModel = HistoryViewModel(storage: storage)

        let session = makeSampleSession()
        viewModel.addSession(session)

        #expect(viewModel.sessions.count == 1)
        #expect(viewModel.sessions.first?.id == session.id)
    }

    // MARK: - Delete Session Tests

    @Test("Delete session removes from storage")
    func deleteSessionRemovesFromStorage() {
        let storage = makeTestStorage()
        let session1 = makeSampleSession()
        let session2 = makeSampleSession()
        storage.saveSessions([session1, session2])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()
        viewModel.deleteSession(session1)

        let loadedSessions = storage.loadSessions()
        #expect(loadedSessions.count == 1)
        #expect(loadedSessions.first?.id == session2.id)
    }

    @Test("Delete session updates local list")
    func deleteSessionUpdatesLocalList() {
        let storage = makeTestStorage()
        let session = makeSampleSession()
        storage.saveSessions([session])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()
        viewModel.deleteSession(session)

        #expect(viewModel.sessions.isEmpty)
    }

    // MARK: - Statistics Tests

    @Test("Total sessions count")
    func totalSessionsCount() {
        let storage = makeTestStorage()
        let sessions = [makeSampleSession(), makeSampleSession(), makeSampleSession()]
        storage.saveSessions(sessions)

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        #expect(viewModel.totalSessions == 3)
    }

    @Test("Total minutes practiced")
    func totalMinutesPracticed() {
        let storage = makeTestStorage()
        let session1 = makeSampleSession(totalMinutes: 40)
        let session2 = makeSampleSession(totalMinutes: 20)
        storage.saveSessions([session1, session2])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        #expect(viewModel.totalMinutes == 60)
    }

    @Test("Sessions this week")
    func sessionsThisWeek() {
        let storage = makeTestStorage()
        let today = Date()
        let lastWeek = Calendar.current.date(byAdding: .day, value: -10, to: today)!

        let recentSession = makeSampleSession(date: today)
        let oldSession = makeSampleSession(date: lastWeek)
        storage.saveSessions([recentSession, oldSession])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        #expect(viewModel.sessionsThisWeek == 1)
    }

    // MARK: - Grouping Tests

    @Test("Sessions grouped by date")
    func sessionsGroupedByDate() {
        let storage = makeTestStorage()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let session1 = makeSampleSession(date: today)
        let session2 = makeSampleSession(date: today)
        let session3 = makeSampleSession(date: yesterday)
        storage.saveSessions([session1, session2, session3])

        let viewModel = HistoryViewModel(storage: storage)
        viewModel.loadSessions()

        let grouped = viewModel.sessionsByDate
        #expect(grouped.count == 2)
    }
}
