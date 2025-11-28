import Foundation
import Observation

/// ViewModel for the Today screen, handling session generation and active session state.
///
/// Design decisions (per Issue requirements):
/// - Session preview is generated on tab appear to display today's blocks.
///   Actual session is generated fresh when "Start session" is pressed to ensure up-to-date SRS state.
/// - TodayViewModel exposes today's blocks by asking the SRE for a session preview.
/// - PracticeEngine remains the owner of session state once started.
/// - Active session handling: If user returns to Today during an active session,
///   we show that there is an active session in progress and allow resuming.
///   This is the simplest MVP approach that prevents accidentally starting duplicate sessions.
@Observable
final class TodayViewModel {

    // MARK: - Dependencies

    private let sre: SpacedRepetitionEngine
    private let engine: PracticeEngine

    // MARK: - Properties

    /// Cached blocks for display on the Today screen.
    /// Generated on demand from SRE when requested.
    private(set) var todayBlocks: [PracticeBlock] = []

    /// Whether there's currently an active session in progress.
    var hasActiveSession: Bool {
        switch engine.state {
        case .idle, .finished:
            return false
        case .previewBlock, .inBlock, .betweenBlocks:
            return true
        }
    }

    /// Text describing the current active session state, if any.
    var activeSessionStatusText: String? {
        switch engine.state {
        case .idle, .finished:
            return nil
        case .previewBlock(let index, _):
            guard let session = engine.session,
                  index < session.blocks.count else {
                return "Session starting"
            }
            let block = session.blocks[index]
            let totalBlocks = session.blocks.count
            return "Starting block \(index + 1)/\(totalBlocks): \(block.kind.displayName)"
        case .inBlock(let index, _):
            guard let session = engine.session,
                  index < session.blocks.count else {
                return "Session in progress"
            }
            let block = session.blocks[index]
            let totalBlocks = session.blocks.count
            return "Block \(index + 1)/\(totalBlocks): \(block.kind.displayName)"
        case .betweenBlocks(let lastIndex, _):
            guard let session = engine.session else {
                return "Between blocks"
            }
            let totalBlocks = session.blocks.count
            return "After block \(lastIndex + 1)/\(totalBlocks)"
        }
    }

    // MARK: - Initialization

    init(sre: SpacedRepetitionEngine, engine: PracticeEngine) {
        self.sre = sre
        self.engine = engine
    }

    // MARK: - Actions

    /// Refresh the displayed blocks from the SRE.
    /// Called when Today screen appears to ensure fresh data.
    func refreshBlocks() {
        let session = sre.generateTodaySession()
        todayBlocks = session.blocks
    }

    /// Start a new practice session.
    /// This instantiates the session in PracticeEngine using SRE-generated blocks.
    func startSession(with blocks: [PracticeBlock]) {
        engine.startSession(with: blocks)
    }

    /// Resume the currently active session (no-op if there isn't one).
    /// Returns true if there was an active session to resume.
    @discardableResult
    func resumeSession() -> Bool {
        hasActiveSession
    }

    /// Replace the displayed blocks (used for manual reordering/removal in UI).
    func setTodayBlocks(_ blocks: [PracticeBlock]) {
        todayBlocks = blocks
    }
}
