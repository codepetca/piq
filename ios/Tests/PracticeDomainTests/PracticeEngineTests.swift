import XCTest
@testable import piq

final class PracticeEngineTests: XCTestCase {

    // MARK: - Initial State Tests

    func testEngineStartsInIdleState() {
        let engine = PracticeEngine()

        if case .idle = engine.state {
            // Success
        } else {
            XCTFail("Engine should start in idle state")
        }
    }

    func testEngineStartsWithNoSession() {
        let engine = PracticeEngine()
        XCTAssertNil(engine.session)
    }

    // MARK: - Start Session Tests

    func testStartSessionCreatesSession() {
        let engine = PracticeEngine()
        engine.startSession()

        XCTAssertNotNil(engine.session)
        XCTAssertEqual(engine.session?.blocks.count, 4)
    }

    func testStartSessionMovesToFirstBlock() {
        let engine = PracticeEngine()
        engine.startSession()

        if case .inBlock(let index, _) = engine.state {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Engine should be in first block after starting session")
        }
    }

    func testStartSessionSetsCorrectRemainingSeconds() {
        let engine = PracticeEngine()
        engine.startSession()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // Default is 10 minutes = 600 seconds
            XCTAssertEqual(remainingSeconds, 600)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    // MARK: - Tick/Advance Tests

    func testTickDecrementsRemainingSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.tick()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            XCTAssertEqual(remainingSeconds, 599)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    func testTickDoesNothingWhenIdle() {
        let engine = PracticeEngine()
        engine.tick()

        if case .idle = engine.state {
            // Success - state unchanged
        } else {
            XCTFail("Engine should remain idle")
        }
    }

    func testMultipleTicksDecrementCorrectly() {
        let engine = PracticeEngine()
        engine.startSession()

        for _ in 0..<10 {
            engine.tick()
        }

        if case .inBlock(_, let remainingSeconds) = engine.state {
            XCTAssertEqual(remainingSeconds, 590)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    func testTickAtZeroTransitionsToBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()

        // Fast forward to 1 second remaining
        if case .inBlock(let index, _) = engine.state {
            engine.state = .inBlock(index: index, remainingSeconds: 1)
        }

        engine.tick()

        if case .betweenBlocks(let lastIndex, let nextIndex) = engine.state {
            XCTAssertEqual(lastIndex, 0)
            XCTAssertEqual(nextIndex, 1)
        } else {
            XCTFail("Engine should transition to between blocks")
        }
    }

    // MARK: - Finish Current Block Tests

    func testFinishCurrentBlockTransitionsToBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()

        if case .betweenBlocks(let lastIndex, let nextIndex) = engine.state {
            XCTAssertEqual(lastIndex, 0)
            XCTAssertEqual(nextIndex, 1)
        } else {
            XCTFail("Engine should be between blocks")
        }
    }

    func testFinishCurrentBlockRecordsActualMinutes() {
        let engine = PracticeEngine()
        engine.startSession()

        // Simulate 3 minutes (180 seconds) of practice
        if case .inBlock(let index, _) = engine.state {
            engine.state = .inBlock(index: index, remainingSeconds: 420) // 600 - 180
        }

        engine.finishCurrentBlock()

        XCTAssertEqual(engine.session?.blocks[0].actualMinutes, 3)
    }

    func testFinishLastBlockTransitionsToFinished() {
        let engine = PracticeEngine()
        engine.startSession()

        // Go to last block
        engine.state = .inBlock(index: 3, remainingSeconds: 100)
        engine.finishCurrentBlock()

        if case .finished = engine.state {
            // Success
        } else {
            XCTFail("Engine should be finished after last block")
        }
    }

    func testFinishBlockDoesNothingWhenIdle() {
        let engine = PracticeEngine()
        engine.finishCurrentBlock()

        if case .idle = engine.state {
            // Success
        } else {
            XCTFail("Engine should remain idle")
        }
    }

    // MARK: - Start Next Block Tests

    func testStartNextBlockFromBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()
        engine.startNextBlock()

        if case .inBlock(let index, _) = engine.state {
            XCTAssertEqual(index, 1)
        } else {
            XCTFail("Engine should be in second block")
        }
    }

    func testStartNextBlockSetsCorrectRemainingSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()
        engine.startNextBlock()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            XCTAssertEqual(remainingSeconds, 600)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    // MARK: - Skip Current Block Tests

    func testSkipCurrentBlockTransitionsToBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.skipCurrentBlock()

        if case .betweenBlocks(let lastIndex, let nextIndex) = engine.state {
            XCTAssertEqual(lastIndex, 0)
            XCTAssertEqual(nextIndex, 1)
        } else {
            XCTFail("Engine should be between blocks after skip")
        }
    }

    func testSkipCurrentBlockRecordsZeroActualMinutes() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.skipCurrentBlock()

        XCTAssertEqual(engine.session?.blocks[0].actualMinutes, 0)
    }

    func testSkipLastBlockTransitionsToFinished() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.state = .inBlock(index: 3, remainingSeconds: 600)
        engine.skipCurrentBlock()

        if case .finished = engine.state {
            // Success
        } else {
            XCTFail("Engine should be finished after skipping last block")
        }
    }

    // MARK: - Extend Current Block Tests

    func testExtendCurrentBlockAddsSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.extendCurrentBlock(byExtraSeconds: 60)

        if case .inBlock(_, let remainingSeconds) = engine.state {
            XCTAssertEqual(remainingSeconds, 660)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    func testExtendCurrentBlockByFiveMinutes() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.extendCurrentBlock(byExtraSeconds: 300) // 5 minutes

        if case .inBlock(_, let remainingSeconds) = engine.state {
            XCTAssertEqual(remainingSeconds, 900)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    func testExtendDoesNothingWhenNotInBlock() {
        let engine = PracticeEngine()
        engine.extendCurrentBlock(byExtraSeconds: 60)

        if case .idle = engine.state {
            // Success
        } else {
            XCTFail("Engine should remain idle")
        }
    }

    // MARK: - Record Feedback Tests

    func testRecordFeedbackForBlock() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()
        engine.recordFeedback(forBlockAt: 0, feedback: .good)

        XCTAssertEqual(engine.session?.blocks[0].feedback, .good)
    }

    func testRecordFeedbackEasy() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()
        engine.recordFeedback(forBlockAt: 0, feedback: .easy)

        XCTAssertEqual(engine.session?.blocks[0].feedback, .easy)
    }

    func testRecordFeedbackHard() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()
        engine.recordFeedback(forBlockAt: 0, feedback: .hard)

        XCTAssertEqual(engine.session?.blocks[0].feedback, .hard)
    }

    func testRecordFeedbackDoesNothingWithInvalidIndex() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.recordFeedback(forBlockAt: 10, feedback: .good)

        // Should not crash, just ignore
        XCTAssertNotNil(engine.session)
    }

    // MARK: - Pause/Resume Tests

    func testPauseStopsTimer() {
        let engine = PracticeEngine()
        engine.startSession()
        XCTAssertFalse(engine.isPaused)

        engine.pause()
        XCTAssertTrue(engine.isPaused)
    }

    func testResumeStartsTimer() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.pause()
        engine.resume()

        XCTAssertFalse(engine.isPaused)
    }

    func testTickDoesNothingWhenPaused() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.pause()
        engine.tick()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            XCTAssertEqual(remainingSeconds, 600) // Unchanged
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    // MARK: - Current Block Info Tests

    func testCurrentBlockIndexReturnsCorrectValue() {
        let engine = PracticeEngine()
        engine.startSession()

        XCTAssertEqual(engine.currentBlockIndex, 0)

        engine.finishCurrentBlock()
        engine.startNextBlock()

        XCTAssertEqual(engine.currentBlockIndex, 1)
    }

    func testCurrentBlockIndexNilWhenIdle() {
        let engine = PracticeEngine()
        XCTAssertNil(engine.currentBlockIndex)
    }

    func testCurrentBlockReturnsCorrectBlock() {
        let engine = PracticeEngine()
        engine.startSession()

        let currentBlock = engine.currentBlock
        XCTAssertEqual(currentBlock?.kind, .warmup)
    }

    func testCurrentBlockNilWhenIdle() {
        let engine = PracticeEngine()
        XCTAssertNil(engine.currentBlock)
    }

    // MARK: - Full Session Flow Tests

    func testCompleteSessionFlow() {
        let engine = PracticeEngine()
        engine.startSession()

        // Complete all 4 blocks
        for i in 0..<4 {
            if case .inBlock(let index, _) = engine.state {
                XCTAssertEqual(index, i)
            } else {
                XCTFail("Should be in block \(i)")
            }

            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)

            if i < 3 {
                engine.startNextBlock()
            }
        }

        if case .finished = engine.state {
            // Success
        } else {
            XCTFail("Engine should be finished")
        }

        // Verify all blocks have feedback
        for block in engine.session?.blocks ?? [] {
            XCTAssertEqual(block.feedback, .good)
        }
    }

    func testMixedFeedbackFlow() {
        let engine = PracticeEngine()
        engine.startSession()

        let feedbacks: [PracticeBlockFeedback] = [.easy, .good, .hard, .good]

        for i in 0..<4 {
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: feedbacks[i])

            if i < 3 {
                engine.startNextBlock()
            }
        }

        XCTAssertEqual(engine.session?.blocks[0].feedback, .easy)
        XCTAssertEqual(engine.session?.blocks[1].feedback, .good)
        XCTAssertEqual(engine.session?.blocks[2].feedback, .hard)
        XCTAssertEqual(engine.session?.blocks[3].feedback, .good)
    }

    // MARK: - Session Progress Tests

    func testSessionProgressZeroAtStart() {
        let engine = PracticeEngine()
        engine.startSession()

        XCTAssertEqual(engine.sessionProgress, 0.0, accuracy: 0.01)
    }

    func testSessionProgressAfterFirstBlock() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.finishCurrentBlock()

        XCTAssertEqual(engine.sessionProgress, 0.25, accuracy: 0.01)
    }

    func testSessionProgressAtEnd() {
        let engine = PracticeEngine()
        engine.startSession()

        for i in 0..<4 {
            engine.finishCurrentBlock()
            if i < 3 {
                engine.startNextBlock()
            }
        }

        XCTAssertEqual(engine.sessionProgress, 1.0, accuracy: 0.01)
    }

    func testBlockProgressZeroAtStart() {
        let engine = PracticeEngine()
        engine.startSession()

        XCTAssertEqual(engine.blockProgress, 0.0, accuracy: 0.01)
    }

    func testBlockProgressHalfway() {
        let engine = PracticeEngine()
        engine.startSession()

        // Simulate halfway through block
        if case .inBlock(let index, _) = engine.state {
            engine.state = .inBlock(index: index, remainingSeconds: 300)
        }

        XCTAssertEqual(engine.blockProgress, 0.5, accuracy: 0.01)
    }
}
