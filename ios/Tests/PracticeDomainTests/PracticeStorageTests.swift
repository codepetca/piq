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

        XCTAssertGreaterThanOrEqual(loaded.blocks.count, 6)
        XCTAssertLessThanOrEqual(loaded.blocks.count, 8)
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

    func testSessionRoundTripPersistsTempoFields() {
        let block = PracticeBlock(
            kind: .techniqueOrTheory,
            title: "Tempo Block",
            targetMinutes: 2,
            actualMinutes: 1,
            instructions: [],
            startingBPM: 72,
            endingBPM: 80,
            tempoAdjustmentCount: 3
        )
        let session = PracticeSession(blocks: [block])

        storage.saveSessions([session])
        let loaded = storage.loadSessions().first!

        let loadedBlock = loaded.blocks.first!
        XCTAssertEqual(loadedBlock.startingBPM, 72)
        XCTAssertEqual(loadedBlock.endingBPM, 80)
        XCTAssertEqual(loadedBlock.tempoAdjustmentCount, 3)
    }

    // MARK: - Items Round Trip Tests

    func testItemsRoundTripPreservesSRS() {
        let dueDate = Date().addingTimeInterval(86_400 * 2)
        let item = PracticeItem(
            catalogID: "test_round_trip",
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
            catalogID: "test_last_played",
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
            catalogID: "test_nil_last_played",
            category: .warmup,
            title: "Test No Last Played",
            srs: SRSState(stability: 1.0, lastPlayed: nil, nextDue: Date())
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertNil(loaded.srs.lastPlayed)
    }

    func testItemsRoundTripPersistsTempoState() {
        let history = [
            TempoSession(date: Date(timeIntervalSince1970: 1_000), startBPM: 70, endBPM: 75, adjustmentCount: 1, feedback: .good)
        ]
        let tempo = TempoState(
            currentBPM: 80,
            targetBPM: 120,
            history: history,
            lastPracticedBPM: 75,
            progressionRate: 1.2
        )
        let item = PracticeItem(
            catalogID: "test_tempo_round_trip",
            category: .technique,
            title: "Tempo Item",
            tempo: tempo
        )

        storage.saveItems([item])
        let loaded = storage.loadItems().first!

        XCTAssertEqual(loaded.tempo.currentBPM, 80)
        XCTAssertEqual(loaded.tempo.targetBPM, 120)
        XCTAssertEqual(loaded.tempo.lastPracticedBPM, 75)
        XCTAssertEqual(loaded.tempo.progressionRate, 1.2, accuracy: 0.001)
        XCTAssertEqual(loaded.tempo.history.count, 1)
        XCTAssertEqual(loaded.tempo.history.first?.startBPM, 70)
        XCTAssertEqual(loaded.tempo.history.first?.endBPM, 75)
        XCTAssertEqual(loaded.tempo.history.first?.feedback, .good)
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

    func testLoadPracticeItemsMergesTempoStateFromStorage() {
        let now = Date()
        let catalogItems = PracticeItemCatalog.seedItems(now: now)
        let firstCatalogItem = catalogItems.first!

        var storedItem = firstCatalogItem
        storedItem.tempo = TempoState(
            currentBPM: 95,
            targetBPM: 120,
            history: [
                TempoSession(date: now, startBPM: 90, endBPM: 95, adjustmentCount: 2, feedback: .good)
            ],
            lastPracticedBPM: 95,
            progressionRate: 1.1
        )

        storage.saveItems([storedItem])

        let mergedItems = storage.loadPracticeItems(now: now)
        let mergedItem = mergedItems.first { $0.catalogID == firstCatalogItem.catalogID }!

        XCTAssertEqual(mergedItem.tempo.currentBPM, 95)
        XCTAssertEqual(mergedItem.tempo.lastPracticedBPM, 95)
        XCTAssertEqual(mergedItem.tempo.history.count, 1)
        XCTAssertEqual(mergedItem.tempo.history.first?.endBPM, 95)
        XCTAssertEqual(mergedItem.tempo.progressionRate, 1.1, accuracy: 0.001)
        XCTAssertEqual(mergedItem.targetMinutes, firstCatalogItem.targetMinutes)
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
        storage.saveItems([PracticeItem(catalogID: "test_schema", category: .warmup, title: "Test")])

        let itemsURL = testDirectory.appendingPathComponent("items.json")
        let data = try! Data(contentsOf: itemsURL)
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["schemaVersion"] as? Int, PracticeStorage.schemaVersion)
    }

    // MARK: - Migration Tests

    func testLoadSessionsFromLegacyFormat() {
        // Create a session and manually write it in legacy format (unwrapped array)
        let session = PracticeSession.makeTodayDemo()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let legacyData = try! encoder.encode([session])
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        try! legacyData.write(to: sessionsURL)

        // Load should automatically migrate from legacy format
        let loaded = storage.loadSessions()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, session.id)
        XCTAssertGreaterThanOrEqual(loaded.first?.blocks.count ?? 0, 6)
        XCTAssertLessThanOrEqual(loaded.first?.blocks.count ?? 0, 8)
    }

    func testLoadItemsFromLegacyFormat() {
        // Create items and manually write them in legacy format (unwrapped array)
        let item = PracticeItem(
            catalogID: "test_legacy",
            category: .technique,
            title: "Legacy Item",
            srs: SRSState(stability: 2.5, nextDue: Date())
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let legacyData = try! encoder.encode([item])
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        try! legacyData.write(to: itemsURL)

        // Load should automatically migrate from legacy format
        let loaded = storage.loadItems()

        XCTAssertEqual(loaded.count, 1)
        let loadedItem = loaded.first!
        XCTAssertEqual(loadedItem.id, item.id)
        XCTAssertEqual(loadedItem.catalogID, "test_legacy")
        XCTAssertEqual(loadedItem.srs.stability, 2.5, accuracy: 0.001)
    }

    func testLoadItemsFromSchemaV1AddsTempoDefaults() {
        let now = Date()
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        let formatter = ISO8601DateFormatter()

        let legacyStore: [String: Any] = [
            "schemaVersion": 1,
            "items": [[
                "id": UUID().uuidString,
                "catalogID": "legacy_item",
                "category": "warmup",
                "title": "Legacy Item",
                "detail": "",
                "targetMinutes": 3,
                "srs": [
                    "stability": 1.0,
                    "nextDue": formatter.string(from: now),
                    "lastBonusTipIndex": -1,
                    "lastFocusCueIndex": -1
                ]
            ]]
        ]

        let data = try! JSONSerialization.data(withJSONObject: legacyStore)
        try! data.write(to: itemsURL)

        let loaded = storage.loadItems()
        XCTAssertEqual(loaded.count, 1)

        let loadedItem = loaded.first!
        XCTAssertEqual(loadedItem.catalogID, "legacy_item")
        XCTAssertEqual(loadedItem.tempo.currentBPM, PracticeItemCategory.warmup.defaultBPM)
        XCTAssertTrue(loadedItem.tempo.history.isEmpty)
    }

    func testLoadSessionsFromFutureVersionReturnsEmpty() {
        // Create a session store with a future schema version
        let futureVersion = PracticeStorage.schemaVersion + 10
        let session = PracticeSession.makeTodayDemo()

        let futureStore: [String: Any] = [
            "schemaVersion": futureVersion,
            "sessions": [[
                "id": session.id.uuidString,
                "date": ISO8601DateFormatter().string(from: session.date),
                "blocks": []
            ]]
        ]

        let data = try! JSONSerialization.data(withJSONObject: futureStore)
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        try! data.write(to: sessionsURL)

        // Should return empty for unknown future version
        let loaded = storage.loadSessions()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testLoadItemsFromFutureVersionReturnsEmpty() {
        // Create an items store with a future schema version
        let futureVersion = PracticeStorage.schemaVersion + 10

        let futureStore: [String: Any] = [
            "schemaVersion": futureVersion,
            "items": [[
                "id": UUID().uuidString,
                "catalogID": "future_item",
                "category": "warmup",
                "title": "Future Item",
                "detail": "",
                "targetMinutes": 3,
                "srs": [
                    "stability": 1.0,
                    "nextDue": ISO8601DateFormatter().string(from: Date())
                ]
            ]]
        ]

        let data = try! JSONSerialization.data(withJSONObject: futureStore)
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        try! data.write(to: itemsURL)

        // Should return empty for unknown future version
        let loaded = storage.loadItems()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testMigrationPreservesAllSessionData() {
        // Create a detailed session with feedback and actual minutes
        var session = PracticeSession.makeTodayDemo()
        session.blocks[0].actualMinutes = 8
        session.blocks[0].feedback = .good
        session.blocks[1].actualMinutes = 12
        session.blocks[1].feedback = .hard

        // Save in legacy format
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let legacyData = try! encoder.encode([session])
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        try! legacyData.write(to: sessionsURL)

        // Load and verify all data is preserved after migration
        let loaded = storage.loadSessions().first!

        XCTAssertEqual(loaded.id, session.id)
        XCTAssertGreaterThanOrEqual(loaded.blocks.count, 6)
        XCTAssertLessThanOrEqual(loaded.blocks.count, 8)
        XCTAssertEqual(loaded.blocks[0].actualMinutes, 8)
        XCTAssertEqual(loaded.blocks[0].feedback, .good)
        XCTAssertEqual(loaded.blocks[1].actualMinutes, 12)
        XCTAssertEqual(loaded.blocks[1].feedback, .hard)
    }

    func testMigrationPreservesAllItemData() {
        // Create a detailed item with full SRS state
        let lastPlayed = Date().addingTimeInterval(-86_400)
        let nextDue = Date().addingTimeInterval(86_400 * 3)
        let item = PracticeItem(
            catalogID: "test_migration_detail",
            category: .soloing,
            title: "Detailed Item",
            detail: "Some detail",
            key: "Am",
            referenceID: "scale_am_pentatonic_pos1",
            targetMinutes: 5,
            srs: SRSState(stability: 3.7, lastPlayed: lastPlayed, nextDue: nextDue)
        )

        // Save in legacy format
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let legacyData = try! encoder.encode([item])
        let itemsURL = testDirectory.appendingPathComponent("items.json")
        try! legacyData.write(to: itemsURL)

        // Load and verify all data is preserved after migration
        let loaded = storage.loadItems().first!

        XCTAssertEqual(loaded.id, item.id)
        XCTAssertEqual(loaded.catalogID, "test_migration_detail")
        XCTAssertEqual(loaded.category, .soloing)
        XCTAssertEqual(loaded.title, "Detailed Item")
        XCTAssertEqual(loaded.detail, "Some detail")
        XCTAssertEqual(loaded.key, "Am")
        XCTAssertEqual(loaded.referenceID, "scale_am_pentatonic_pos1")
        XCTAssertEqual(loaded.targetMinutes, 5)
        XCTAssertEqual(loaded.srs.stability, 3.7, accuracy: 0.001)
        XCTAssertNotNil(loaded.srs.lastPlayed)
        XCTAssertEqual(loaded.srs.lastPlayed!.timeIntervalSince1970, lastPlayed.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(loaded.srs.nextDue.timeIntervalSince1970, nextDue.timeIntervalSince1970, accuracy: 1.0)
    }

    func testLoadSessionsFromSchemaV1WithoutTempoFields() {
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        let formatter = ISO8601DateFormatter()

        let legacyStore: [String: Any] = [
            "schemaVersion": 1,
            "sessions": [[
                "id": UUID().uuidString,
                "date": formatter.string(from: Date()),
                "blocks": [[
                    "id": UUID().uuidString,
                    "kind": "warmup",
                    "title": "Legacy Block",
                    "detail": "",
                    "targetMinutes": 3,
                    "actualMinutes": 2
                ]]
            ]]
        ]

        let data = try! JSONSerialization.data(withJSONObject: legacyStore)
        try! data.write(to: sessionsURL)

        let loaded = storage.loadSessions()

        XCTAssertEqual(loaded.count, 1)
        let loadedBlock = loaded.first!.blocks.first!
        XCTAssertNil(loadedBlock.startingBPM)
        XCTAssertNil(loadedBlock.endingBPM)
        XCTAssertEqual(loadedBlock.tempoAdjustmentCount, 0)
        XCTAssertEqual(loadedBlock.actualMinutes, 2)
    }

    func testCurrentVersionLoadsWithoutMigration() {
        // Save in current version format
        let session = PracticeSession.makeTodayDemo()
        storage.saveSessions([session])

        // Load should work without any migration needed
        let loaded = storage.loadSessions()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, session.id)

        // Verify the file is in v1 format
        let sessionsURL = testDirectory.appendingPathComponent("sessions.json")
        let data = try! Data(contentsOf: sessionsURL)
        let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["schemaVersion"] as? Int, PracticeStorage.schemaVersion)
    }
}
