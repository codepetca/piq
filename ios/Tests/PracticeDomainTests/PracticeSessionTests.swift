import XCTest
@testable import piq

final class PracticeSessionTests: XCTestCase {
    func testMakeTodayDemoHasBlocksAndMetadata() {
        let session = PracticeSession.makeTodayDemo()
        XCTAssertEqual(session.blocks.count, 4)
        XCTAssertTrue(session.blocks.allSatisfy { $0.practiceItemID != nil })
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
