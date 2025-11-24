import XCTest
@testable import piq

final class PracticeStorageTests: XCTestCase {

    var storage: PracticeStorage!
    var testDirectory: URL!

    override func setUp() {
        super.setUp()
        // Use a unique temp directory for each test
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        storage = PracticeStorage(directory: testDirectory)
    }

    override func tearDown() {
        // Clean up test directory
        try? FileManager.default.removeItem(at: testDirectory)
        super.tearDown()
    }

    // MARK: - First Run Tests

    func testFirstRun_loadSessionsReturnsEmpty() {
        let sessions = storage.loadSessions()
        XCTAssertTrue(sessions.isEmpty)
    }

    func testFirstRun_loadItemsReturnsEmpty() {
        let items = storage.loadItems()
        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - Session Persistence Tests

    func testSaveSessions_persistsToStorage() {
        let session = PracticeSession.makeTodayDemo()
        storage.saveSessions([session])

        let loaded = storage.loadSessions()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, session.id)
    }

    func testSaveMultipleSessions_persistsAll() {
        let session1 = PracticeSession.makeTodayDemo()
        let session2 = PracticeSession.makeTodayDemo()
        storage.saveSessions([session1, session2])

        let loaded = storage.loadSessions()
        XCTAssertEqual(loaded.count, 2)
    }

    func testSessionRoundTrip_preservesAllData() {
        var session = PracticeSession.makeTodayDemo()
        // Set some actual minutes and feedback
        session.blocks[0].actualMinutes = 8
        session.blocks[0].feedback = .good
        session.blocks[1].actualMinutes = 12
        session.blocks[1].feedback = .hard

        storage.saveSessions([session])
        let loaded = storage.loadSessions().first!

        XCTAssertEqual(loaded.id, session.id)
        XCTAssertEqual(loaded.blocks.count, session.blocks.count)
        XCTAssertEqual(loaded.blocks[0].actualMinutes, 8)
        XCTAssertEqual(loaded.blocks[0].feedback, .good)
        XCTAssertEqual(loaded.blocks[1].actualMinutes, 12)
        XCTAssertEqual(loaded.blocks[1].feedback, .hard)
    }

    func testSaveSessions_overwritesPrevious() {
        let session1 = PracticeSession.makeTodayDemo()
        storage.saveSessions([session1])

        let session2 = PracticeSession.makeTodayDemo()
        storage.saveSessions([session2])

        let loaded = storage.loadSessions()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, session2.id)
    }

    // MARK: - Item Persistence Tests

    func testSaveItems_persistsToStorage() {
        let item = PracticeItem(kind: .warmup, title: "Test Item")
        storage.saveItems([item])

        let loaded = storage.loadItems()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, item.id)
    }

    func testSaveMultipleItems_persistsAll() {
        let items = PracticeItem.makeDemoItems()
        storage.saveItems(items)

        let loaded = storage.loadItems()
        XCTAssertEqual(loaded.count, items.count)
    }

    func testItemRoundTrip_preservesAllData() {
        let item = PracticeItem(
            kind: .solo,
            title: "Am Pentatonic",
            detail: "Position 1",
            key: "Am",
            referenceID: "scale_am_pentatonic_pos1",
            targetMinutes: 15,
            dueDate: Date().addingTimeInterval(86400),
            intervalDays: 3.5,
            easeFactor: 2.3,
            reviewCount: 5,
            consecutiveCorrect: 3
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertEqual(loaded.id, item.id)
        XCTAssertEqual(loaded.kind, item.kind)
        XCTAssertEqual(loaded.title, item.title)
        XCTAssertEqual(loaded.detail, item.detail)
        XCTAssertEqual(loaded.key, item.key)
        XCTAssertEqual(loaded.referenceID, item.referenceID)
        XCTAssertEqual(loaded.targetMinutes, item.targetMinutes)
        XCTAssertEqual(loaded.intervalDays, item.intervalDays, accuracy: 0.001)
        XCTAssertEqual(loaded.easeFactor, item.easeFactor, accuracy: 0.001)
        XCTAssertEqual(loaded.reviewCount, item.reviewCount)
        XCTAssertEqual(loaded.consecutiveCorrect, item.consecutiveCorrect)
    }

    func testSaveItems_overwritesPrevious() {
        let item1 = PracticeItem(kind: .warmup, title: "First")
        storage.saveItems([item1])

        let item2 = PracticeItem(kind: .warmup, title: "Second")
        storage.saveItems([item2])

        let loaded = storage.loadItems()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.title, "Second")
    }

    // MARK: - Independent Storage Tests

    func testSessionsAndItems_storedIndependently() {
        let session = PracticeSession.makeTodayDemo()
        let item = PracticeItem(kind: .warmup, title: "Test")

        storage.saveSessions([session])
        storage.saveItems([item])

        let loadedSessions = storage.loadSessions()
        let loadedItems = storage.loadItems()

        XCTAssertEqual(loadedSessions.count, 1)
        XCTAssertEqual(loadedItems.count, 1)
    }

    // MARK: - Empty Save Tests

    func testSaveEmptySessions_clearsStorage() {
        let session = PracticeSession.makeTodayDemo()
        storage.saveSessions([session])
        storage.saveSessions([])

        let loaded = storage.loadSessions()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testSaveEmptyItems_clearsStorage() {
        let item = PracticeItem(kind: .warmup, title: "Test")
        storage.saveItems([item])
        storage.saveItems([])

        let loaded = storage.loadItems()
        XCTAssertTrue(loaded.isEmpty)
    }

    // MARK: - Corruption Handling Tests

    func testLoadSessions_withCorruptedFile_returnsEmpty() {
        // Write invalid JSON to the sessions file
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        try? "not valid json".write(to: sessionsURL, atomically: true, encoding: .utf8)

        let loaded = storage.loadSessions()
        XCTAssertTrue(loaded.isEmpty, "Should return empty array on corrupted data")
    }

    func testLoadItems_withCorruptedFile_returnsEmpty() {
        // Write invalid JSON to the items file
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        try? "not valid json".write(to: itemsURL, atomically: true, encoding: .utf8)

        let loaded = storage.loadItems()
        XCTAssertTrue(loaded.isEmpty, "Should return empty array on corrupted data")
    }

    // MARK: - Date Precision Tests

    func testSessionDate_preservedWithReasonablePrecision() {
        let session = PracticeSession(blocks: [
            PracticeBlock(kind: .warmup, title: "Test")
        ])
        let originalDate = session.date

        storage.saveSessions([session])
        let loaded = storage.loadSessions().first!

        // Allow 1 second tolerance for date serialization
        XCTAssertEqual(
            loaded.date.timeIntervalSince1970,
            originalDate.timeIntervalSince1970,
            accuracy: 1.0
        )
    }

    func testItemDueDate_preservedWithReasonablePrecision() {
        let dueDate = Date().addingTimeInterval(86400 * 7)
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: dueDate
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertEqual(
            loaded.dueDate.timeIntervalSince1970,
            dueDate.timeIntervalSince1970,
            accuracy: 1.0
        )
    }
}
