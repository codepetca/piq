import XCTest
@testable import piq

final class SpacedRepetitionEngineTests: XCTestCase {

    // MARK: - Initial State Tests

    func testInitialState_hasNoItems() {
        let engine = SpacedRepetitionEngine()
        XCTAssertTrue(engine.items.isEmpty)
    }

    func testInitialState_canAddItems() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(kind: .warmup, title: "Test")
        engine.addItem(item)
        XCTAssertEqual(engine.items.count, 1)
        XCTAssertEqual(engine.items.first?.id, item.id)
    }

    func testInitialState_canLoadDemoItems() {
        let engine = SpacedRepetitionEngine()
        engine.loadDemoItems()
        XCTAssertEqual(engine.items.count, 8)
    }

    // MARK: - Due Item Tests

    func testDueItems_returnsItemsDueToday() {
        let engine = SpacedRepetitionEngine()
        let pastDue = PracticeItem(
            kind: .warmup,
            title: "Past Due",
            dueDate: Date().addingTimeInterval(-86400) // Yesterday
        )
        let futureDue = PracticeItem(
            kind: .warmup,
            title: "Future",
            dueDate: Date().addingTimeInterval(86400) // Tomorrow
        )
        engine.addItem(pastDue)
        engine.addItem(futureDue)

        let dueItems = engine.dueItems()
        XCTAssertEqual(dueItems.count, 1)
        XCTAssertEqual(dueItems.first?.id, pastDue.id)
    }

    func testDueItems_includesItemsDueNow() {
        let engine = SpacedRepetitionEngine()
        let dueNow = PracticeItem(
            kind: .solo,
            title: "Due Now",
            dueDate: Date()
        )
        engine.addItem(dueNow)

        let dueItems = engine.dueItems()
        XCTAssertEqual(dueItems.count, 1)
    }

    // MARK: - New Item Priority Tests

    func testNewItems_appearMoreOften() {
        let engine = SpacedRepetitionEngine()

        // New item (reviewCount = 0)
        let newItem = PracticeItem(
            kind: .warmup,
            title: "New",
            dueDate: Date(),
            reviewCount: 0
        )

        // Reviewed item with same due date
        let reviewedItem = PracticeItem(
            kind: .warmup,
            title: "Reviewed",
            dueDate: Date(),
            reviewCount: 5,
            consecutiveCorrect: 5
        )

        engine.addItem(reviewedItem)
        engine.addItem(newItem)

        let prioritized = engine.prioritizedItems(forKind: .warmup)
        XCTAssertEqual(prioritized.first?.id, newItem.id, "New items should appear first")
    }

    // MARK: - Feedback Processing Tests

    func testRecordFeedback_easy_increasesInterval() {
        let engine = SpacedRepetitionEngine()
        var item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            intervalDays: 1.0,
            easeFactor: 2.5,
            reviewCount: 1
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .easy)

        let updated = engine.items.first!
        XCTAssertGreaterThan(updated.intervalDays, 1.0, "Easy feedback should increase interval")
        XCTAssertGreaterThan(updated.easeFactor, 2.5, "Easy feedback should increase ease factor")
        XCTAssertEqual(updated.reviewCount, 2)
    }

    func testRecordFeedback_good_increasesInterval() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            intervalDays: 1.0,
            easeFactor: 2.5,
            reviewCount: 1
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .good)

        let updated = engine.items.first!
        XCTAssertGreaterThan(updated.intervalDays, 1.0, "Good feedback should increase interval")
        XCTAssertEqual(updated.easeFactor, 2.5, "Good feedback should maintain ease factor")
    }

    func testRecordFeedback_hard_resetsOrReducesInterval() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            intervalDays: 10.0,
            easeFactor: 2.5,
            reviewCount: 5,
            consecutiveCorrect: 5
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .hard)

        let updated = engine.items.first!
        XCTAssertLessThan(updated.intervalDays, 10.0, "Hard feedback should reduce interval")
        XCTAssertLessThan(updated.easeFactor, 2.5, "Hard feedback should reduce ease factor")
        XCTAssertEqual(updated.consecutiveCorrect, 0, "Hard feedback should reset consecutive correct")
    }

    func testRecordFeedback_easy_itemsAppearLessFrequently() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            intervalDays: 1.0
        )
        engine.addItem(item)

        // Record easy feedback multiple times
        engine.recordFeedback(forItemID: item.id, feedback: .easy)
        let afterFirst = engine.items.first!.intervalDays

        engine.recordFeedback(forItemID: item.id, feedback: .easy)
        let afterSecond = engine.items.first!.intervalDays

        XCTAssertGreaterThan(afterSecond, afterFirst, "Consecutive easy should keep increasing interval")
    }

    func testRecordFeedback_hard_itemsAppearMoreFrequently() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            intervalDays: 30.0, // Long interval
            easeFactor: 2.5
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .hard)

        let updated = engine.items.first!
        // Item should now be due much sooner
        XCTAssertLessThanOrEqual(updated.intervalDays, 3.0, "Hard items should have short interval")
    }

    // MARK: - Ease Factor Bounds Tests

    func testEaseFactor_neverGoesBelow1_3() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            easeFactor: 1.4 // Already low
        )
        engine.addItem(item)

        // Record multiple hard feedbacks
        engine.recordFeedback(forItemID: item.id, feedback: .hard)
        engine.recordFeedback(forItemID: item.id, feedback: .hard)
        engine.recordFeedback(forItemID: item.id, feedback: .hard)

        let updated = engine.items.first!
        XCTAssertGreaterThanOrEqual(updated.easeFactor, 1.3, "Ease factor should not go below 1.3")
    }

    // MARK: - Due Date Update Tests

    func testRecordFeedback_updatesDueDate() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            dueDate: Date(),
            intervalDays: 1.0
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .good)

        let updated = engine.items.first!
        XCTAssertGreaterThan(updated.dueDate, Date(), "Due date should be in the future after feedback")
    }

    // MARK: - Generate Today Session Tests

    func testGenerateTodaySession_returns4Blocks() {
        let engine = SpacedRepetitionEngine()
        engine.loadDemoItems()

        let session = engine.generateTodaySession()

        XCTAssertEqual(session.blocks.count, 4)
    }

    func testGenerateTodaySession_hasCorrectBlockOrder() {
        let engine = SpacedRepetitionEngine()
        engine.loadDemoItems()

        let session = engine.generateTodaySession()

        XCTAssertEqual(session.blocks[0].kind, .warmup)
        XCTAssertEqual(session.blocks[1].kind, .song)
        XCTAssertEqual(session.blocks[2].kind, .solo)
        XCTAssertEqual(session.blocks[3].kind, .techniqueOrTheory)
    }

    func testGenerateTodaySession_linksPracticeItemIDs() {
        let engine = SpacedRepetitionEngine()
        engine.loadDemoItems()

        let session = engine.generateTodaySession()

        // Each block should have a practiceItemID linking to an item
        for block in session.blocks {
            XCTAssertNotNil(block.practiceItemID, "Block should link to practice item")

            // Verify the item exists
            let item = engine.items.first { $0.id == block.practiceItemID }
            XCTAssertNotNil(item, "Linked item should exist")
            XCTAssertEqual(item?.kind, block.kind, "Item kind should match block kind")
        }
    }

    func testGenerateTodaySession_copiesItemDataToBlock() {
        let engine = SpacedRepetitionEngine()
        engine.loadDemoItems()

        let session = engine.generateTodaySession()

        for block in session.blocks {
            let item = engine.items.first { $0.id == block.practiceItemID }!
            XCTAssertEqual(block.title, item.title)
            XCTAssertEqual(block.detail, item.detail)
            XCTAssertEqual(block.key, item.key)
            XCTAssertEqual(block.referenceID, item.referenceID)
            XCTAssertEqual(block.targetMinutes, item.targetMinutes)
        }
    }

    func testGenerateTodaySession_prioritizesDueItems() {
        let engine = SpacedRepetitionEngine()

        // Add two warmup items: one due, one not due
        let dueItem = PracticeItem(
            kind: .warmup,
            title: "Due Item",
            dueDate: Date().addingTimeInterval(-86400)
        )
        let notDueItem = PracticeItem(
            kind: .warmup,
            title: "Not Due",
            dueDate: Date().addingTimeInterval(86400 * 7)
        )
        engine.addItem(notDueItem)
        engine.addItem(dueItem)

        // Add items for other kinds so session can be generated
        engine.addItem(PracticeItem(kind: .song, title: "Song"))
        engine.addItem(PracticeItem(kind: .solo, title: "Solo"))
        engine.addItem(PracticeItem(kind: .techniqueOrTheory, title: "Technique"))

        let session = engine.generateTodaySession()
        let warmupBlock = session.blocks[0]

        XCTAssertEqual(warmupBlock.practiceItemID, dueItem.id, "Should prioritize due item")
    }

    func testGenerateTodaySession_withNoItems_returnsEmptyBlocks() {
        let engine = SpacedRepetitionEngine()

        let session = engine.generateTodaySession()

        // Should still return 4 blocks, but with placeholder content
        XCTAssertEqual(session.blocks.count, 4)
    }

    // MARK: - Prioritization Tests

    func testPrioritizedItems_ordersByDueDateThenNewness() {
        let engine = SpacedRepetitionEngine()

        let oldDue = PracticeItem(
            kind: .warmup,
            title: "Old Due",
            dueDate: Date().addingTimeInterval(-86400 * 2),
            reviewCount: 3
        )
        let recentDue = PracticeItem(
            kind: .warmup,
            title: "Recent Due",
            dueDate: Date().addingTimeInterval(-3600),
            reviewCount: 3
        )
        let newItem = PracticeItem(
            kind: .warmup,
            title: "New",
            dueDate: Date(),
            reviewCount: 0
        )

        engine.addItem(recentDue)
        engine.addItem(newItem)
        engine.addItem(oldDue)

        let prioritized = engine.prioritizedItems(forKind: .warmup)

        // Most overdue first, then new items
        XCTAssertEqual(prioritized[0].id, oldDue.id)
        XCTAssertEqual(prioritized[1].id, newItem.id)
        XCTAssertEqual(prioritized[2].id, recentDue.id)
    }

    // MARK: - First Review Tests

    func testFirstReview_setsInitialInterval() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "New Item",
            reviewCount: 0
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .good)

        let updated = engine.items.first!
        XCTAssertEqual(updated.reviewCount, 1)
        XCTAssertGreaterThan(updated.intervalDays, 0)
    }

    // MARK: - Consecutive Correct Tests

    func testConsecutiveCorrect_incrementsOnGoodOrEasy() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            kind: .warmup,
            title: "Test",
            consecutiveCorrect: 0
        )
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .good)
        XCTAssertEqual(engine.items.first!.consecutiveCorrect, 1)

        engine.recordFeedback(forItemID: item.id, feedback: .easy)
        XCTAssertEqual(engine.items.first!.consecutiveCorrect, 2)
    }

    // MARK: - Item Removal Tests

    func testRemoveItem_removesFromList() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(kind: .warmup, title: "Test")
        engine.addItem(item)

        engine.removeItem(withID: item.id)

        XCTAssertTrue(engine.items.isEmpty)
    }

    // MARK: - Items By Kind Tests

    func testItemsByKind_filtersCorrectly() {
        let engine = SpacedRepetitionEngine()
        engine.loadDemoItems()

        let warmups = engine.items(forKind: .warmup)
        let songs = engine.items(forKind: .song)
        let solos = engine.items(forKind: .solo)
        let techniques = engine.items(forKind: .techniqueOrTheory)

        XCTAssertEqual(warmups.count, 2)
        XCTAssertEqual(songs.count, 2)
        XCTAssertEqual(solos.count, 2)
        XCTAssertEqual(techniques.count, 2)

        XCTAssertTrue(warmups.allSatisfy { $0.kind == .warmup })
    }
}
