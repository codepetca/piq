import XCTest
@testable import piq

final class PracticeSessionTests: XCTestCase {

    // MARK: - Session Structure Tests

    func testMakeTodayDemoHasFourBlocks() {
        let session = PracticeSession.makeTodayDemo()
        XCTAssertEqual(session.blocks.count, 4)
    }

    func testMakeTodayDemoBlocksInCorrectOrder() {
        let session = PracticeSession.makeTodayDemo()
        let expectedOrder: [PracticeBlockKind] = [.warmup, .song, .solo, .techniqueOrTheory]

        let actualOrder = session.blocks.map { $0.kind }
        XCTAssertEqual(actualOrder, expectedOrder)
    }

    func testStandardBlockOrderMatchesDemoOrder() {
        let session = PracticeSession.makeTodayDemo()
        let actualOrder = session.blocks.map { $0.kind }

        XCTAssertEqual(actualOrder, PracticeSession.standardBlockOrder)
    }

    // MARK: - Total Minutes Tests

    func testTotalTargetMinutesComputedCorrectly() {
        let session = PracticeSession.makeTodayDemo()

        // Default is 10 minutes per block, 4 blocks = 40 minutes
        XCTAssertEqual(session.totalTargetMinutes, 40)
    }

    func testTotalTargetMinutesWithCustomDurations() {
        let blocks = [
            PracticeBlock(kind: .warmup, title: "Test", targetMinutes: 5),
            PracticeBlock(kind: .song, title: "Test", targetMinutes: 15),
            PracticeBlock(kind: .solo, title: "Test", targetMinutes: 10),
            PracticeBlock(kind: .techniqueOrTheory, title: "Test", targetMinutes: 20)
        ]
        let session = PracticeSession(blocks: blocks)

        XCTAssertEqual(session.totalTargetMinutes, 50)
    }

    func testTotalActualMinutesWithNoCompletion() {
        let session = PracticeSession.makeTodayDemo()

        XCTAssertEqual(session.totalActualMinutes, 0)
    }

    func testTotalActualMinutesWithPartialCompletion() {
        var session = PracticeSession.makeTodayDemo()
        session.blocks[0].actualMinutes = 8
        session.blocks[1].actualMinutes = 12

        XCTAssertEqual(session.totalActualMinutes, 20)
    }

    func testTotalActualMinutesWithAllCompleted() {
        var session = PracticeSession.makeTodayDemo()
        session.blocks[0].actualMinutes = 10
        session.blocks[1].actualMinutes = 10
        session.blocks[2].actualMinutes = 10
        session.blocks[3].actualMinutes = 10

        XCTAssertEqual(session.totalActualMinutes, 40)
    }

    // MARK: - Block Properties Tests

    func testBlockKindDisplayNames() {
        XCTAssertEqual(PracticeBlockKind.warmup.displayName, "Warm-Up")
        XCTAssertEqual(PracticeBlockKind.song.displayName, "Song")
        XCTAssertEqual(PracticeBlockKind.solo.displayName, "Solo")
        XCTAssertEqual(PracticeBlockKind.techniqueOrTheory.displayName, "Technique")
    }

    func testBlockKindDefaultMinutes() {
        XCTAssertEqual(PracticeBlockKind.warmup.defaultMinutes, 10)
        XCTAssertEqual(PracticeBlockKind.song.defaultMinutes, 10)
        XCTAssertEqual(PracticeBlockKind.solo.defaultMinutes, 10)
        XCTAssertEqual(PracticeBlockKind.techniqueOrTheory.defaultMinutes, 10)
    }

    func testBlockKindDefaultMetronome() {
        XCTAssertTrue(PracticeBlockKind.warmup.defaultMetronomeOn)
        XCTAssertFalse(PracticeBlockKind.song.defaultMetronomeOn)
        XCTAssertFalse(PracticeBlockKind.solo.defaultMetronomeOn)
        XCTAssertTrue(PracticeBlockKind.techniqueOrTheory.defaultMetronomeOn)
    }

    func testBlockUsesDefaultMinutesWhenNotSpecified() {
        let block = PracticeBlock(kind: .warmup, title: "Test")
        XCTAssertEqual(block.targetMinutes, 10)
    }

    func testBlockUsesCustomMinutesWhenSpecified() {
        let block = PracticeBlock(kind: .warmup, title: "Test", targetMinutes: 15)
        XCTAssertEqual(block.targetMinutes, 15)
    }

    // MARK: - Feedback Tests

    func testFeedbackDisplayNames() {
        XCTAssertEqual(PracticeBlockFeedback.easy.displayName, "Easy")
        XCTAssertEqual(PracticeBlockFeedback.good.displayName, "Good")
        XCTAssertEqual(PracticeBlockFeedback.hard.displayName, "Hard")
    }

    func testBlockFeedbackInitiallyNil() {
        let block = PracticeBlock(kind: .warmup, title: "Test")
        XCTAssertNil(block.feedback)
    }

    func testBlockFeedbackCanBeSet() {
        var block = PracticeBlock(kind: .warmup, title: "Test")
        block.feedback = .good
        XCTAssertEqual(block.feedback, .good)
    }

    // MARK: - Codable Tests

    func testPracticeBlockRoundTrip() throws {
        let original = PracticeBlock(
            kind: .warmup,
            title: "Test Block",
            detail: "Details",
            targetMinutes: 15,
            actualMinutes: 12,
            key: "Am",
            feedback: .good,
            referenceID: "scale_am_pentatonic_pos1"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PracticeBlock.self, from: encoded)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.kind, original.kind)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.detail, original.detail)
        XCTAssertEqual(decoded.targetMinutes, original.targetMinutes)
        XCTAssertEqual(decoded.actualMinutes, original.actualMinutes)
        XCTAssertEqual(decoded.key, original.key)
        XCTAssertEqual(decoded.feedback, original.feedback)
        XCTAssertEqual(decoded.referenceID, original.referenceID)
    }

    func testPracticeSessionRoundTrip() throws {
        var original = PracticeSession.makeTodayDemo()
        original.blocks[0].feedback = .easy
        original.blocks[0].actualMinutes = 10

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PracticeSession.self, from: encoded)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.blocks.count, original.blocks.count)
        XCTAssertEqual(decoded.blocks[0].feedback, .easy)
        XCTAssertEqual(decoded.blocks[0].actualMinutes, 10)
    }

    func testPracticeBlockFeedbackRoundTrip() throws {
        for feedback in PracticeBlockFeedback.allCases {
            let encoded = try JSONEncoder().encode(feedback)
            let decoded = try JSONDecoder().decode(PracticeBlockFeedback.self, from: encoded)
            XCTAssertEqual(decoded, feedback)
        }
    }

    func testPracticeBlockKindRoundTrip() throws {
        for kind in PracticeBlockKind.allCases {
            let encoded = try JSONEncoder().encode(kind)
            let decoded = try JSONDecoder().decode(PracticeBlockKind.self, from: encoded)
            XCTAssertEqual(decoded, kind)
        }
    }

    // MARK: - Demo Session Content Tests

    func testDemoSessionWarmupBlock() {
        let session = PracticeSession.makeTodayDemo()
        let warmup = session.blocks[0]

        XCTAssertEqual(warmup.kind, .warmup)
        XCTAssertEqual(warmup.title, "Am pentatonic")
        XCTAssertEqual(warmup.key, "Am")
        XCTAssertNotNil(warmup.referenceID)
    }

    func testDemoSessionSongBlock() {
        let session = PracticeSession.makeTodayDemo()
        let song = session.blocks[1]

        XCTAssertEqual(song.kind, .song)
        XCTAssertFalse(song.title.isEmpty)
    }

    func testDemoSessionSoloBlock() {
        let session = PracticeSession.makeTodayDemo()
        let solo = session.blocks[2]

        XCTAssertEqual(solo.kind, .solo)
        XCTAssertNotNil(solo.key)
    }

    func testDemoSessionTechniqueBlock() {
        let session = PracticeSession.makeTodayDemo()
        let technique = session.blocks[3]

        XCTAssertEqual(technique.kind, .techniqueOrTheory)
        XCTAssertNotNil(technique.referenceID)
    }

    // MARK: - Identity Tests

    func testBlocksHaveUniqueIDs() {
        let session = PracticeSession.makeTodayDemo()
        let ids = session.blocks.map { $0.id }
        let uniqueIDs = Set(ids)

        XCTAssertEqual(ids.count, uniqueIDs.count)
    }

    func testSessionHasUniqueID() {
        let session1 = PracticeSession.makeTodayDemo()
        let session2 = PracticeSession.makeTodayDemo()

        XCTAssertNotEqual(session1.id, session2.id)
    }
}
