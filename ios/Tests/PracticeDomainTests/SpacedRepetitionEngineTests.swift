import XCTest
@testable import piq

final class SpacedRepetitionEngineTests: XCTestCase {
    func testSeedCatalogLoadsItems() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog(now: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(engine.items.count, 20)
        XCTAssertEqual(engine.items.filter { $0.category == .warmup }.count, 2)
    }

    func testDueItemsUsesNextDue() {
        let engine = SpacedRepetitionEngine()
        let past = PracticeItem(category: .warmup, title: "Past", srs: SRSState(stability: 1, nextDue: .distantPast))
        let future = PracticeItem(category: .warmup, title: "Future", srs: SRSState(stability: 1, nextDue: .distantFuture))
        engine.addItem(past)
        engine.addItem(future)

        XCTAssertEqual(engine.dueItems(asOf: Date()).count, 1)
        XCTAssertEqual(engine.dueItems(asOf: Date()).first?.id, past.id)
    }

    func testFeedbackAdjustsStabilityAndNextDue() {
        let now = Date(timeIntervalSince1970: 1000)
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(category: .technique, title: "Test", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .hard, now: now)
        let hardItem = engine.items.first!

        engine.recordFeedback(forItemID: item.id, feedback: .good, now: now)
        let goodItem = engine.items.first!

        engine.recordFeedback(forItemID: item.id, feedback: .easy, now: now)
        let easyItem = engine.items.first!

        XCTAssertLessThan(hardItem.srs.stability, goodItem.srs.stability)
        XCTAssertLessThan(goodItem.srs.stability, easyItem.srs.stability)
        XCTAssertLessThan(hardItem.srs.nextDue, goodItem.srs.nextDue)
        XCTAssertLessThan(goodItem.srs.nextDue, easyItem.srs.nextDue)
    }

    func testGenerateTodaySessionReturnsFourBlocks() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog(now: Date())

        let session = engine.generateTodaySession()
        XCTAssertEqual(session.blocks.count, 4)
        XCTAssertTrue(session.blocks.allSatisfy { $0.practiceItemID != nil })
    }

    func testGenerateTodaySessionInterleavesCategoriesWhenPossible() {
        let now = Date()
        let warmupA = PracticeItem(category: .warmup, title: "Warm A", srs: SRSState(nextDue: now))
        let warmupB = PracticeItem(category: .warmup, title: "Warm B", srs: SRSState(nextDue: now))
        let solo = PracticeItem(category: .soloing, title: "Solo", srs: SRSState(nextDue: now))
        let technique = PracticeItem(category: .technique, title: "Tech", srs: SRSState(nextDue: now))

        let engine = SpacedRepetitionEngine()
        [warmupA, warmupB, solo, technique].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)
        let categories = session.blocks.compactMap { block in
            engine.items.first(where: { $0.id == block.practiceItemID })?.category
        }

        for pair in zip(categories, categories.dropFirst()) {
            XCTAssertNotEqual(pair.0, pair.1, "Should interleave categories when possible")
        }
    }

    func testGenerateTodaySessionWithFewItemsStillProducesBlocks() {
        let now = Date()
        let warmup = PracticeItem(category: .warmup, title: "Warm", srs: SRSState(nextDue: now))
        let solo = PracticeItem(category: .soloing, title: "Solo", srs: SRSState(nextDue: now))

        let engine = SpacedRepetitionEngine()
        [warmup, solo].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)
        XCTAssertEqual(session.blocks.count, 4)
    }

    // MARK: - Batch Feedback Tests

    func testApplyFeedbackUpdatesMultipleItems() {
        let now = Date(timeIntervalSince1970: 10000)
        let engine = SpacedRepetitionEngine()

        let item1 = PracticeItem(category: .warmup, title: "Item 1", srs: SRSState(stability: 2.0, nextDue: now))
        let item2 = PracticeItem(category: .technique, title: "Item 2", srs: SRSState(stability: 3.0, nextDue: now))
        engine.addItem(item1)
        engine.addItem(item2)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Block 1", practiceItemID: item1.id, feedback: .hard),
            PracticeBlock(kind: .techniqueOrTheory, title: "Block 2", practiceItemID: item2.id, feedback: .easy)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updatedItem1 = engine.items.first { $0.id == item1.id }!
        let updatedItem2 = engine.items.first { $0.id == item2.id }!

        // Item 1 received Hard feedback → lower stability, sooner nextDue
        XCTAssertLessThan(updatedItem1.srs.stability, 2.0)
        XCTAssertGreaterThan(updatedItem1.srs.nextDue, now)
        XCTAssertLessThan(updatedItem1.srs.nextDue, now.addingTimeInterval(2 * 86_400))

        // Item 2 received Easy feedback → higher stability, later nextDue
        XCTAssertGreaterThan(updatedItem2.srs.stability, 3.0)
        XCTAssertGreaterThan(updatedItem2.srs.nextDue, now.addingTimeInterval(2 * 86_400))
    }

    func testApplyFeedbackWithHardDecreasesStability() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(category: .technique, title: "Tech", srs: SRSState(stability: 3.0, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .techniqueOrTheory, title: "Block", practiceItemID: item.id, feedback: .hard)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updated = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(updated.srs.stability, max(1.0, 3.0 * 0.6))
        XCTAssertLessThan(updated.srs.nextDue, now.addingTimeInterval(2 * 86_400))
    }

    func testApplyFeedbackWithGoodIncreasesStabilityModerately() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(category: .soloing, title: "Solo", srs: SRSState(stability: 2.5, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .solo, title: "Block", practiceItemID: item.id, feedback: .good)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updated = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(updated.srs.stability, max(1.2, 2.5 * 1.15))
        XCTAssertGreaterThan(updated.srs.nextDue, now.addingTimeInterval(1 * 86_400))
        XCTAssertLessThan(updated.srs.nextDue, now.addingTimeInterval(4 * 86_400))
    }

    func testApplyFeedbackWithEasyIncreasesStabilitySignificantly() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(category: .fretboard, title: "Fret", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Block", practiceItemID: item.id, feedback: .easy)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updated = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(updated.srs.stability, 2.0 * 1.5 + 0.5)
        XCTAssertGreaterThan(updated.srs.nextDue, now.addingTimeInterval(2 * 86_400))
    }

    func testApplyFeedbackSkipsBlocksWithoutPracticeItemID() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(category: .warmup, title: "Warm", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Block without ID", practiceItemID: nil, feedback: .hard)
        ]

        engine.applyFeedback(for: blocks, now: now)

        // Item should remain unchanged
        let unchanged = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(unchanged.srs.stability, 2.0)
        XCTAssertEqual(unchanged.srs.nextDue, now)
    }

    func testApplyFeedbackSkipsBlocksWithoutFeedback() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(category: .technique, title: "Tech", srs: SRSState(stability: 2.5, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .techniqueOrTheory, title: "Block no feedback", practiceItemID: item.id, feedback: nil)
        ]

        engine.applyFeedback(for: blocks, now: now)

        // Item should remain unchanged
        let unchanged = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(unchanged.srs.stability, 2.5)
        XCTAssertEqual(unchanged.srs.nextDue, now)
    }

    func testApplyFeedbackIgnoresMissingItemsGracefully() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let existingItem = PracticeItem(category: .warmup, title: "Exists", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(existingItem)

        let nonExistentID = UUID()
        let blocks = [
            PracticeBlock(kind: .warmup, title: "Ghost Block", practiceItemID: nonExistentID, feedback: .good),
            PracticeBlock(kind: .warmup, title: "Real Block", practiceItemID: existingItem.id, feedback: .easy)
        ]

        // Should not crash
        engine.applyFeedback(for: blocks, now: now)

        // Existing item should be updated
        let updated = engine.items.first { $0.id == existingItem.id }!
        XCTAssertGreaterThan(updated.srs.stability, 2.0)
    }

    func testApplyFeedbackWithMixedBlockStates() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item1 = PracticeItem(category: .warmup, title: "Item 1", srs: SRSState(stability: 2.0, nextDue: now))
        let item2 = PracticeItem(category: .technique, title: "Item 2", srs: SRSState(stability: 3.0, nextDue: now))
        engine.addItem(item1)
        engine.addItem(item2)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Valid", practiceItemID: item1.id, feedback: .good),
            PracticeBlock(kind: .song, title: "No ID", practiceItemID: nil, feedback: .easy),
            PracticeBlock(kind: .techniqueOrTheory, title: "No Feedback", practiceItemID: item2.id, feedback: nil),
            PracticeBlock(kind: .solo, title: "Ghost", practiceItemID: UUID(), feedback: .hard)
        ]

        engine.applyFeedback(for: blocks, now: now)

        // Only item1 should be updated
        let updated1 = engine.items.first { $0.id == item1.id }!
        XCTAssertGreaterThan(updated1.srs.stability, 2.0)

        // item2 should remain unchanged
        let unchanged2 = engine.items.first { $0.id == item2.id }!
        XCTAssertEqual(unchanged2.srs.stability, 3.0)
        XCTAssertEqual(unchanged2.srs.nextDue, now)
    }
}
