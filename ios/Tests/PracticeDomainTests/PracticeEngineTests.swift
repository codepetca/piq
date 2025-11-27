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

    func testStartSessionMovesToPreviewBlock() {
        let engine = PracticeEngine()
        engine.startSession()

        if case .previewBlock(let index) = engine.state {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Engine should be in first block preview after starting session")
        }
    }

    func testStartCurrentBlockSetsCorrectRemainingSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // First block is warmup category (3 minutes = 180 seconds)
            XCTAssertEqual(remainingSeconds, 180)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    // MARK: - Tick/Advance Tests

    func testTickDecrementsRemainingSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.tick()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // First block is warmup category (3 minutes = 180 seconds), minus 1 tick
            XCTAssertEqual(remainingSeconds, 179)
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
        engine.startCurrentBlock()

        for _ in 0..<10 {
            engine.tick()
        }

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // First block is warmup category (3 minutes = 180 seconds), minus 10 ticks
            XCTAssertEqual(remainingSeconds, 170)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    func testTickAtZeroTransitionsToBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()

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
        engine.startCurrentBlock()
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
        engine.startCurrentBlock()

        // Simulate 1 minute (60 seconds) of practice on warmup block (180 total)
        // Set remaining to 120 seconds -> elapsed = 180 - 120 = 60 seconds = 1 minute
        if case .inBlock(let index, _) = engine.state {
            engine.state = .inBlock(index: index, remainingSeconds: 120)
        }

        engine.finishCurrentBlock()

        XCTAssertEqual(engine.session?.blocks[0].actualMinutes, 1)
    }

    func testFinishLastBlockTransitionsToFinished() {
        let engine = PracticeEngine()
        engine.startSession()

        // Go to last block
        engine.state = .inBlock(index: 3, remainingSeconds: 100)
        engine.finishCurrentBlock()

        // After finishing last block, engine should be in betweenBlocks with no next
        if case .betweenBlocks(let lastIndex, let nextIndex) = engine.state {
            XCTAssertEqual(lastIndex, 3)
            XCTAssertNil(nextIndex)
        } else {
            XCTFail("Engine should be between blocks after finishing last block")
        }

        // startNextBlock with no next block should transition to finished
        engine.startNextBlock()

        if case .finished = engine.state {
            // Success
        } else {
            XCTFail("Engine should be finished after startNextBlock with no next block")
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
        engine.startCurrentBlock()
        engine.finishCurrentBlock()
        engine.startNextBlock()  // This goes to previewBlock for next block

        if case .previewBlock(let index) = engine.state {
            XCTAssertEqual(index, 1)
        } else {
            XCTFail("Engine should be in second block preview")
        }
    }

    func testStartNextBlockThenStartCurrentBlockSetsCorrectRemainingSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.finishCurrentBlock()
        engine.startNextBlock()
        engine.startCurrentBlock()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // Second block (songwork/solo depending on SRS = 6/5 minutes = 360/300 seconds)
            XCTAssert(remainingSeconds >= 180, "Second block should have reasonable duration")
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    // MARK: - Skip Current Block Tests

    func testSkipCurrentBlockTransitionsToBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
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
        engine.startCurrentBlock()
        engine.skipCurrentBlock()

        XCTAssertEqual(engine.session?.blocks[0].actualMinutes, 0)
    }

    func testSkipDuringPreviewBlockTransitionsToBetweenBlocks() {
        let engine = PracticeEngine()
        engine.startSession()
        // Skip during preview (before startCurrentBlock)
        engine.skipCurrentBlock()

        if case .betweenBlocks(let lastIndex, let nextIndex) = engine.state {
            XCTAssertEqual(lastIndex, 0)
            XCTAssertEqual(nextIndex, 1)
        } else {
            XCTFail("Engine should be between blocks after skip during preview")
        }
    }

    func testSkipLastBlockTransitionsToFinished() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.state = .inBlock(index: 3, remainingSeconds: 360)
        engine.skipCurrentBlock()

        // After skipping last block, engine should be in betweenBlocks with no next
        if case .betweenBlocks(let lastIndex, let nextIndex) = engine.state {
            XCTAssertEqual(lastIndex, 3)
            XCTAssertNil(nextIndex)
        } else {
            XCTFail("Engine should be between blocks after skipping last block")
        }

        // startNextBlock should transition to finished
        engine.startNextBlock()

        if case .finished = engine.state {
            // Success
        } else {
            XCTFail("Engine should be finished after startNextBlock with no next block")
        }
    }

    // MARK: - Extend Current Block Tests

    func testExtendCurrentBlockAddsSeconds() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.extendCurrentBlock(byExtraSeconds: 60)

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // First block is warmup (180 seconds) + 60 = 240 seconds
            XCTAssertEqual(remainingSeconds, 240)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    func testExtendCurrentBlockByFiveMinutes() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.extendCurrentBlock(byExtraSeconds: 300) // 5 minutes

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // First block is warmup (180 seconds) + 300 = 480 seconds
            XCTAssertEqual(remainingSeconds, 480)
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
        engine.startCurrentBlock()
        engine.finishCurrentBlock()
        engine.recordFeedback(forBlockAt: 0, feedback: .good)

        XCTAssertEqual(engine.session?.blocks[0].feedback, .good)
    }

    func testRecordFeedbackEasy() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.finishCurrentBlock()
        engine.recordFeedback(forBlockAt: 0, feedback: .easy)

        XCTAssertEqual(engine.session?.blocks[0].feedback, .easy)
    }

    func testRecordFeedbackHard() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
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
        engine.startCurrentBlock()
        XCTAssertFalse(engine.isPaused)

        engine.pause()
        XCTAssertTrue(engine.isPaused)
    }

    func testResumeStartsTimer() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.pause()
        engine.resume()

        XCTAssertFalse(engine.isPaused)
    }

    func testTickDoesNothingWhenPaused() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.pause()
        engine.tick()

        if case .inBlock(_, let remainingSeconds) = engine.state {
            // First block is warmup (180 seconds), unchanged after paused tick
            XCTAssertEqual(remainingSeconds, 180)
        } else {
            XCTFail("Engine should be in block state")
        }
    }

    // MARK: - Current Block Info Tests

    func testCurrentBlockIndexReturnsCorrectValue() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()

        XCTAssertEqual(engine.currentBlockIndex, 0)

        engine.finishCurrentBlock()
        engine.startNextBlock()
        engine.startCurrentBlock()

        XCTAssertEqual(engine.currentBlockIndex, 1)
    }

    func testCurrentBlockIndexNilWhenIdle() {
        let engine = PracticeEngine()
        XCTAssertNil(engine.currentBlockIndex)
    }

    func testCurrentBlockIndexNilDuringPreview() {
        let engine = PracticeEngine()
        engine.startSession()
        // In preview state, currentBlockIndex should be nil (metronome won't start)
        XCTAssertNil(engine.currentBlockIndex)
    }

    func testCurrentBlockReturnsCorrectBlock() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()

        let currentBlock = engine.currentBlock
        XCTAssertEqual(currentBlock?.kind, .warmup)
    }

    func testCurrentBlockReturnsBlockDuringPreview() {
        let engine = PracticeEngine()
        engine.startSession()
        // currentBlock should return the block being previewed
        let currentBlock = engine.currentBlock
        XCTAssertNotNil(currentBlock)
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

        // Complete all 4 blocks (preview -> inBlock -> betweenBlocks -> preview -> ...)
        for i in 0..<4 {
            // Start from preview
            if case .previewBlock(let index) = engine.state {
                XCTAssertEqual(index, i)
            } else {
                XCTFail("Should be in preview for block \(i)")
            }

            engine.startCurrentBlock()

            if case .inBlock(let index, _) = engine.state {
                XCTAssertEqual(index, i)
            } else {
                XCTFail("Should be in block \(i)")
            }

            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()  // For last block, this transitions to .finished
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
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: feedbacks[i])
            engine.startNextBlock()  // For last block, this transitions to .finished
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
        engine.startCurrentBlock()

        XCTAssertEqual(engine.sessionProgress, 0.0, accuracy: 0.01)
    }

    func testSessionProgressAfterFirstBlock() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()
        engine.finishCurrentBlock()

        XCTAssertEqual(engine.sessionProgress, 0.25, accuracy: 0.01)
    }

    func testSessionProgressAtEnd() {
        let engine = PracticeEngine()
        engine.startSession()

        for _ in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        XCTAssertEqual(engine.sessionProgress, 1.0, accuracy: 0.01)
    }

    func testBlockProgressZeroAtStart() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()

        XCTAssertEqual(engine.blockProgress, 0.0, accuracy: 0.01)
    }

    func testBlockProgressHalfway() {
        let engine = PracticeEngine()
        engine.startSession()
        engine.startCurrentBlock()

        // Simulate halfway through warmup block (180 seconds total)
        // Halfway = 90 seconds remaining
        if case .inBlock(let index, _) = engine.state {
            engine.state = .inBlock(index: index, remainingSeconds: 90)
        }

        XCTAssertEqual(engine.blockProgress, 0.5, accuracy: 0.01)
    }

    // MARK: - Session Completion Callback Tests

    func testOnSessionFinishedCalledWhenSessionFinishes() {
        let engine = PracticeEngine()
        var callbackSession: PracticeSession?
        var callbackCount = 0

        engine.onSessionFinished = { session in
            callbackSession = session
            callbackCount += 1
        }

        engine.startSession()

        // Complete all 4 blocks (always call startCurrentBlock then startNextBlock after feedback)
        for i in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        // Callback should have been called exactly once
        XCTAssertEqual(callbackCount, 1)
        XCTAssertNotNil(callbackSession)
        XCTAssertEqual(callbackSession?.blocks.count, 4)
    }

    func testOnSessionFinishedReceivesSessionWithFeedback() {
        let engine = PracticeEngine()
        var callbackSession: PracticeSession?

        engine.onSessionFinished = { session in
            callbackSession = session
        }

        engine.startSession()

        let feedbacks: [PracticeBlockFeedback] = [.easy, .good, .hard, .good]

        for i in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: feedbacks[i])
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        XCTAssertNotNil(callbackSession)
        XCTAssertEqual(callbackSession?.blocks[0].feedback, .easy)
        XCTAssertEqual(callbackSession?.blocks[1].feedback, .good)
        XCTAssertEqual(callbackSession?.blocks[2].feedback, .hard)
        XCTAssertEqual(callbackSession?.blocks[3].feedback, .good)
    }

    func testOnSessionFinishedNotCalledWhenNotFinished() {
        let engine = PracticeEngine()
        var callbackCount = 0

        engine.onSessionFinished = { _ in
            callbackCount += 1
        }

        engine.startSession()

        // Complete only 2 blocks
        for i in 0..<2 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()
        }

        // Callback should not have been called
        XCTAssertEqual(callbackCount, 0)
    }

    func testOnSessionFinishedNotCalledMultipleTimes() {
        let engine = PracticeEngine()
        var callbackCount = 0

        engine.onSessionFinished = { _ in
            callbackCount += 1
        }

        engine.startSession()

        // Complete all blocks to finish session
        for i in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        // Setting state to finished again should not trigger callback
        engine.state = .finished

        XCTAssertEqual(callbackCount, 1)
    }

    func testOnSessionFinishedResetsForNewSession() {
        let engine = PracticeEngine()
        var callbackCount = 0

        engine.onSessionFinished = { _ in
            callbackCount += 1
        }

        // First session
        engine.startSession()
        for i in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        XCTAssertEqual(callbackCount, 1)

        // Second session
        engine.startSession()
        for i in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        XCTAssertEqual(callbackCount, 2)
    }

    func testOnSessionFinishedWithSkippedBlocks() {
        let engine = PracticeEngine()
        var callbackSession: PracticeSession?

        engine.onSessionFinished = { session in
            callbackSession = session
        }

        engine.startSession()

        // Skip first block during preview
        engine.skipCurrentBlock()
        engine.recordFeedback(forBlockAt: 0, feedback: .hard)
        engine.startNextBlock()

        // Complete remaining blocks normally
        for i in 1..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            engine.recordFeedback(forBlockAt: i, feedback: .good)
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        XCTAssertNotNil(callbackSession)
        XCTAssertEqual(callbackSession?.blocks[0].actualMinutes, 0)
        XCTAssertEqual(callbackSession?.blocks[0].feedback, .hard)
    }

    func testOnSessionFinishedWithPartialFeedback() {
        let engine = PracticeEngine()
        var callbackSession: PracticeSession?

        engine.onSessionFinished = { session in
            callbackSession = session
        }

        engine.startSession()

        // Complete blocks but only provide feedback for some
        for i in 0..<4 {
            engine.startCurrentBlock()
            engine.finishCurrentBlock()
            // Only provide feedback for first two blocks
            if i < 2 {
                engine.recordFeedback(forBlockAt: i, feedback: .good)
            }
            engine.startNextBlock()  // For last block, this transitions to .finished
        }

        XCTAssertNotNil(callbackSession)
        XCTAssertEqual(callbackSession?.blocks[0].feedback, .good)
        XCTAssertEqual(callbackSession?.blocks[1].feedback, .good)
        XCTAssertNil(callbackSession?.blocks[2].feedback)
        XCTAssertNil(callbackSession?.blocks[3].feedback)
    }
}
