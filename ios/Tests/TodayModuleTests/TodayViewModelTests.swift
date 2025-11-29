import XCTest
@testable import piq

final class TodayViewModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func testViewModelInitializesWithEmptyBlocks() {
        let sre = SpacedRepetitionEngine()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        XCTAssertTrue(viewModel.todayBlocks.isEmpty, "Initial blocks should be empty until refreshed")
    }

    func testViewModelHasNoActiveSessionInitially() {
        let sre = SpacedRepetitionEngine()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        XCTAssertFalse(viewModel.hasActiveSession, "Should not have active session initially")
    }

    // MARK: - Refresh Blocks Tests

    func testRefreshBlocksPopulatesTodayBlocks() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        viewModel.refreshBlocks()

        XCTAssertGreaterThanOrEqual(viewModel.todayBlocks.count, 6, "Should have at least 6 blocks after refresh")
        XCTAssertLessThanOrEqual(viewModel.todayBlocks.count, 8, "Should have at most 8 blocks after refresh")
        XCTAssertTrue(viewModel.todayBlocks.allSatisfy { $0.practiceItemID != nil }, "All blocks should have practiceItemID")
    }

    func testRefreshBlocksUseSREGeneratedSession() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        viewModel.refreshBlocks()
        let viewModelBlocks = viewModel.todayBlocks

        // Generate session directly to compare
        let directSession = sre.generateTodaySession()

        // Both should have 6-8 blocks with practiceItemIDs from the same pool
        XCTAssertEqual(viewModelBlocks.count, directSession.blocks.count)
    }

    // MARK: - Start Session Tests

    func testStartSessionMovesEngineToInBlockState() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        XCTAssertEqual(engine.state, .idle, "Engine should start idle")

        viewModel.refreshBlocks()
        viewModel.startSession(with: viewModel.todayBlocks)

        if case .previewBlock(let index, _) = engine.state {
            XCTAssertEqual(index, 0, "Should start at first block (in preview state)")
        } else if case .inBlock(let index, _) = engine.state {
            XCTAssertEqual(index, 0, "Should start at first block (in block state)")
        } else {
            XCTFail("Engine should be in previewBlock or inBlock state after starting session")
        }
    }

    func testStartSessionCreatesSessionInEngine() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        XCTAssertNil(engine.session, "Engine should have no session initially")

        viewModel.refreshBlocks()
        viewModel.startSession(with: viewModel.todayBlocks)

        XCTAssertNotNil(engine.session, "Engine should have session after start")
        XCTAssertGreaterThanOrEqual(engine.session?.blocks.count ?? 0, 6, "Session should have at least 6 blocks")
        XCTAssertLessThanOrEqual(engine.session?.blocks.count ?? 0, 8, "Session should have at most 8 blocks")
    }

    // MARK: - Active Session Detection Tests

    func testHasActiveSessionReturnsTrueWhenInBlock() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        engine.startSession(from: sre)

        XCTAssertTrue(viewModel.hasActiveSession, "Should have active session when in block")
    }

    func testHasActiveSessionReturnsTrueWhenBetweenBlocks() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        engine.startSession(from: sre)
        engine.skipPreview()  // Get to inBlock state
        engine.finishCurrentBlock()

        if case .betweenBlocks = engine.state {
            XCTAssertTrue(viewModel.hasActiveSession, "Should have active session when between blocks")
        } else {
            XCTFail("Engine should be in betweenBlocks state")
        }
    }

    func testHasActiveSessionReturnsFalseWhenFinished() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        engine.startSession(from: sre)

        // Fast forward to finished state
        engine.state = .finished

        XCTAssertFalse(viewModel.hasActiveSession, "Should not have active session when finished")
    }

    // MARK: - Resume Session Tests

    func testResumeSessionReturnsTrueWhenActiveSession() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        engine.startSession(from: sre)

        XCTAssertTrue(viewModel.resumeSession(), "Should return true when there's an active session")
    }

    func testResumeSessionReturnsFalseWhenNoActiveSession() {
        let sre = SpacedRepetitionEngine()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        XCTAssertFalse(viewModel.resumeSession(), "Should return false when there's no active session")
    }

    // MARK: - Integration Tests

    func testFullWorkflow_RefreshStartAndDetectActiveSession() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()
        let engine = PracticeEngine()
        let viewModel = TodayViewModel(sre: sre, engine: engine)

        // Step 1: Refresh blocks
        viewModel.refreshBlocks()
        XCTAssertGreaterThanOrEqual(viewModel.todayBlocks.count, 6)
        XCTAssertLessThanOrEqual(viewModel.todayBlocks.count, 8)
        XCTAssertFalse(viewModel.hasActiveSession)

        // Step 2: Start session
        viewModel.startSession(with: viewModel.todayBlocks)
        XCTAssertTrue(viewModel.hasActiveSession)

        // Step 3: Engine state is correct (either previewBlock or inBlock)
        switch engine.state {
        case .previewBlock(let index, _):
            XCTAssertEqual(index, 0)
        case .inBlock(let index, _):
            XCTAssertEqual(index, 0)
        default:
            XCTFail("Should be in first block (preview or in-block state)")
        }
    }
}
