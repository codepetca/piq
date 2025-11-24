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
}
