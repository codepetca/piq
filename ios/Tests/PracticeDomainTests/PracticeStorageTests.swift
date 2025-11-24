import XCTest
@testable import piq

final class PracticeStorageTests: XCTestCase {
    var storage: PracticeStorage!
    var testDirectory: URL!

    override func setUp() {
        super.setUp()
        testDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        storage = PracticeStorage(directory: testDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testDirectory)
        super.tearDown()
    }

    func testFirstRun_loadsEmpty() {
        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }

    func testSessionRoundTrip() {
        var session = PracticeSession.makeTodayDemo()
        session.blocks[0].actualMinutes = 8
        session.blocks[0].feedback = .good

        storage.saveSessions([session])
        let loaded = storage.loadSessions().first!

        XCTAssertEqual(loaded.blocks.count, 4)
        XCTAssertEqual(loaded.blocks[0].actualMinutes, 8)
        XCTAssertEqual(loaded.blocks[0].feedback, .good)
    }

    func testItemsRoundTripPreservesSRS() {
        let dueDate = Date().addingTimeInterval(86_400 * 2)
        let item = PracticeItem(
            category: .soloing,
            title: "Test",
            targetMinutes: 9,
            srs: SRSState(stability: 3.2, nextDue: dueDate)
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertEqual(loaded.id, item.id)
        XCTAssertEqual(loaded.category, item.category)
        XCTAssertEqual(loaded.title, item.title)
        XCTAssertEqual(loaded.targetMinutes, 9)
        XCTAssertEqual(loaded.srs.stability, 3.2, accuracy: 0.001)
        XCTAssertEqual(loaded.srs.nextDue.timeIntervalSince1970, dueDate.timeIntervalSince1970, accuracy: 1.0)
    }

    func testSaveEmptyCollectionsClearsData() {
        storage.saveSessions([PracticeSession.makeTodayDemo()])
        storage.saveItems(PracticeItemCatalog.seedItems())

        storage.saveSessions([])
        storage.saveItems([])

        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }

    func testHandlesCorruptedFilesGracefully() {
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        try? "oops".write(to: sessionsURL, atomically: true, encoding: .utf8)
        try? "oops".write(to: itemsURL, atomically: true, encoding: .utf8)

        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }
}
