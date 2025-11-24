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

    // MARK: - First Run Tests

    func testFirstRun_loadsEmpty() {
        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }

    func testFirstRun_loadPracticeItemsReturnsCatalogDefaults() {
        let items = storage.loadPracticeItems()
        let catalogItems = PracticeItemCatalog.seedItems()

        XCTAssertEqual(items.count, catalogItems.count)
        XCTAssertTrue(items.allSatisfy { $0.srs.stability == 1.5 })
    }

    func testFirstRun_isFirstRunReturnsTrue() {
        XCTAssertTrue(storage.isFirstRun)
    }

    func testAfterSavingData_isFirstRunReturnsFalse() {
        storage.saveSessions([PracticeSession.makeTodayDemo()])
        XCTAssertFalse(storage.isFirstRun)
    }

    // MARK: - Session Round Trip Tests

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

    func testSaveSessionAppendsToExisting() {
        let session1 = PracticeSession.makeTodayDemo()
        storage.saveSessions([session1])

        let session2 = PracticeSession.makeTodayDemo()
        storage.saveSession(session2)

        let loaded = storage.loadSessions()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].id, session1.id)
        XCTAssertEqual(loaded[1].id, session2.id)
    }

    func testSaveSessionOnEmptyStorageCreatesFirst() {
        let session = PracticeSession.makeTodayDemo()
        storage.saveSession(session)

        let loaded = storage.loadSessions()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, session.id)
    }

    // MARK: - Items Round Trip Tests

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

    func testItemsRoundTripPreservesLastPlayed() {
        let lastPlayed = Date().addingTimeInterval(-86_400) // Yesterday
        let nextDue = Date().addingTimeInterval(86_400 * 2)
        let item = PracticeItem(
            category: .technique,
            title: "Test Last Played",
            srs: SRSState(stability: 2.5, lastPlayed: lastPlayed, nextDue: nextDue)
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertNotNil(loaded.srs.lastPlayed)
        XCTAssertEqual(loaded.srs.lastPlayed!.timeIntervalSince1970, lastPlayed.timeIntervalSince1970, accuracy: 1.0)
    }

    func testItemsRoundTripHandlesNilLastPlayed() {
        let item = PracticeItem(
            category: .warmup,
            title: "Test No Last Played",
            srs: SRSState(stability: 1.0, lastPlayed: nil, nextDue: Date())
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertNil(loaded.srs.lastPlayed)
    }

    // MARK: - Catalog Merge Tests

    func testLoadPracticeItemsMergesSRSStateFromStorage() {
        let now = Date()
        let catalogItems = PracticeItemCatalog.seedItems(now: now)
        let firstCatalogItem = catalogItems.first!

        // Create a modified item with custom SRS state
        let customSRS = SRSState(stability: 5.0, lastPlayed: now, nextDue: now.addingTimeInterval(86_400 * 5))
        var modifiedItem = firstCatalogItem
        modifiedItem.srs = customSRS
        storage.saveItems([modifiedItem])

        // Load merged items
        let mergedItems = storage.loadPracticeItems(now: now)

        // Find the merged item
        let mergedItem = mergedItems.first { $0.title == firstCatalogItem.title }!

        // Should have catalog structure but stored SRS state
        XCTAssertEqual(mergedItem.category, firstCatalogItem.category)
        XCTAssertEqual(mergedItem.srs.stability, 5.0, accuracy: 0.001)
        XCTAssertNotNil(mergedItem.srs.lastPlayed)
    }

    func testLoadPracticeItemsPreservesCatalogItemsWithoutStoredState() {
        let now = Date()
        let catalogItems = PracticeItemCatalog.seedItems(now: now)

        // Store only one item
        let singleItem = catalogItems.first!
        storage.saveItems([singleItem])

        // Load merged items
        let mergedItems = storage.loadPracticeItems(now: now)

        // Should return all catalog items, not just the stored one
        XCTAssertEqual(mergedItems.count, catalogItems.count)
    }

    // MARK: - Clear and Empty Tests

    func testSaveEmptyCollectionsClearsData() {
        storage.saveSessions([PracticeSession.makeTodayDemo()])
        storage.saveItems(PracticeItemCatalog.seedItems())

        storage.saveSessions([])
        storage.saveItems([])

        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }

    func testClearAllRemovesAllData() {
        storage.saveSessions([PracticeSession.makeTodayDemo()])
        storage.saveItems(PracticeItemCatalog.seedItems())

        storage.clearAll()

        XCTAssertTrue(storage.isFirstRun)
        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }

    // MARK: - Corruption Handling Tests

    func testHandlesCorruptedFilesGracefully() {
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        try? "oops".write(to: sessionsURL, atomically: true, encoding: .utf8)
        try? "oops".write(to: itemsURL, atomically: true, encoding: .utf8)

        XCTAssertTrue(storage.loadSessions().isEmpty)
        XCTAssertTrue(storage.loadItems().isEmpty)
    }

    func testHandlesPartiallyCorruptedSessionsFile() {
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        // Write valid JSON but invalid schema
        try? "{\"invalid\": true}".write(to: sessionsURL, atomically: true, encoding: .utf8)

        let loaded = storage.loadSessions()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testHandlesPartiallyCorruptedItemsFile() {
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        // Write valid JSON but invalid schema
        try? "{\"invalid\": true}".write(to: itemsURL, atomically: true, encoding: .utf8)

        let loaded = storage.loadItems()
        XCTAssertTrue(loaded.isEmpty)
    }

    // MARK: - Schema Version Tests

    func testSchemaVersionIsIncludedInStorage() {
        storage.saveSessions([PracticeSession.makeTodayDemo()])

        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        let data = try! Data(contentsOf: sessionsURL)
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["schemaVersion"] as? Int, PracticeStorage.schemaVersion)
    }

    func testSchemaVersionIsIncludedInItemsStorage() {
        storage.saveItems([PracticeItem(category: .warmup, title: "Test")])

        let itemsURL = testDirectory.appendingPathComponent("items.json")
        let data = try! Data(contentsOf: itemsURL)
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["schemaVersion"] as? Int, PracticeStorage.schemaVersion)
    }
}
