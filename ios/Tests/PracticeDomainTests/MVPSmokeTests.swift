import XCTest
@testable import piq

/// Lightweight end-to-end smoke to validate the core MVP flow without UI.
/// Simulates start → preview → in-block → feedback → summary and ensures
/// persistence hooks run once.
final class MVPSmokeTests: XCTestCase {

    func test_endToEndSessionFlow() {
        // Use a temporary directory to avoid polluting real storage.
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("MVPSmoke-\(UUID().uuidString)")
        let storage = PracticeStorage(directory: tempDir)

        let engine = PracticeEngine()
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()

        var savedSessions: [PracticeSession] = []
        engine.onSessionFinished = { session in
            savedSessions.append(session)
            storage.saveSession(session)
            sre.applyFeedback(for: session.blocks)
            sre.applyTempoLearning(for: session.blocks)
            storage.saveItems(sre.items)
        }

        engine.startSession(from: sre)
        guard case .previewBlock = engine.state else {
            return XCTFail("Expected preview state after starting session")
        }

        engine.skipPreview()

        guard let totalBlocks = engine.session?.blocks.count else {
            return XCTFail("Session should be created")
        }
        XCTAssertGreaterThanOrEqual(totalBlocks, 6)
        XCTAssertLessThanOrEqual(totalBlocks, 8)

        for index in 0..<totalBlocks {
            guard case .inBlock = engine.state else {
                return XCTFail("Expected inBlock state at block \(index)")
            }

            // Finish the block immediately by zeroing out remaining time.
            engine.adjustCurrentBlockRemaining(by: -10_000)

            guard case .betweenBlocks = engine.state else {
                if case .finished = engine.state {
                    break
                }
                return XCTFail("Expected betweenBlocks after finishing block \(index)")
            }

            engine.recordFeedback(forBlockAt: index, feedback: .good)
            engine.startNextBlock()

            if index < totalBlocks - 1 {
                guard case .previewBlock = engine.state else {
                    return XCTFail("Expected preview for next block \(index + 1)")
                }
                engine.skipPreview()
            }
        }

        if case .finished = engine.state {
            // Success
        } else {
            XCTFail("Engine should end in finished state")
        }

        XCTAssertEqual(savedSessions.count, 1, "Session should be saved once")

        let storedSessions = storage.loadSessions()
        XCTAssertEqual(storedSessions.count, 1, "Storage should persist a single session")

        if let session = storedSessions.first {
            XCTAssertEqual(session.blocks.count, totalBlocks)
            XCTAssertTrue(session.blocks.allSatisfy { $0.feedback == .good }, "Feedback should be recorded on all blocks")
        } else {
            XCTFail("Stored session should exist")
        }

        // Best-effort cleanup; ignore errors so test does not fail on cleanup.
        try? FileManager.default.removeItem(at: tempDir)
    }
}
