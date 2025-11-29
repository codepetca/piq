import XCTest
@testable import piq

final class PracticeSessionTests: XCTestCase {
    func testMakeTodayDemoHas6to8BlocksAndMetadata() {
        let session = PracticeSession.makeTodayDemo()
        XCTAssertGreaterThanOrEqual(session.blocks.count, 6, "Should have at least 6 blocks")
        XCTAssertLessThanOrEqual(session.blocks.count, 8, "Should have at most 8 blocks")
        XCTAssertTrue(session.blocks.allSatisfy { $0.practiceItemID != nil })
    }

    func testMakeTodayDemoStartsWithSingleWarmup() {
        let session = PracticeSession.makeTodayDemo()
        XCTAssertEqual(session.blocks.first?.kind, .warmup, "First block should be warmup")
        XCTAssertEqual(session.blocks.filter { $0.kind == .warmup }.count, 1, "Warmup should appear only once")
    }

    func testMakeTodayDemoEndsWithFunActivity() {
        let session = PracticeSession.makeTodayDemo()
        XCTAssertEqual(session.blocks.last?.kind, .song, "Last block should be song (fun ending)")
    }

    func testMakeTodayDemoDurationWithinBounds() {
        let session = PracticeSession.makeTodayDemo()
        let total = session.totalTargetMinutes
        XCTAssertGreaterThanOrEqual(total, 30, "Session should be at least 30 minutes")
        XCTAssertLessThanOrEqual(total, 40, "Session should not exceed 40 minutes")
    }

    func testTotalMinutesComputed() {
        let blocks = [
            PracticeBlock(kind: .warmup, title: "A", targetMinutes: 5),
            PracticeBlock(kind: .song, title: "B", targetMinutes: 12)
        ]
        let session = PracticeSession(blocks: blocks)
        XCTAssertEqual(session.totalTargetMinutes, 17)
    }

    func testActualMinutesComputed() {
        var session = PracticeSession(blocks: [
            PracticeBlock(kind: .warmup, title: "A", targetMinutes: 5, actualMinutes: 4),
            PracticeBlock(kind: .song, title: "B", targetMinutes: 12, actualMinutes: 10)
        ])
        XCTAssertEqual(session.totalActualMinutes, 14)

        session.blocks[0].actualMinutes = nil
        XCTAssertEqual(session.totalActualMinutes, 10)
    }

    func testBlockKindPropertiesRemainStable() {
        XCTAssertEqual(PracticeBlockKind.warmup.displayName, "Warm-Up")
        XCTAssertEqual(PracticeBlockKind.techniqueOrTheory.defaultMetronomeOn, true)
    }
}
