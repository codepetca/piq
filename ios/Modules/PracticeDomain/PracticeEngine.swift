import Foundation
import Observation

/// Engine state machine for managing practice sessions.
enum PracticeEngineState: Equatable {
    case idle
    case inBlock(index: Int, remainingSeconds: Int)
    case betweenBlocks(lastIndex: Int, nextIndex: Int?)
    case finished
}

/// Manages the practice session flow, timing, and state transitions.
@Observable
final class PracticeEngine {

    // MARK: - Public Properties

    var state: PracticeEngineState = .idle
    var session: PracticeSession?
    var isPaused: Bool = false

    /// Current block index, or nil if not in a block.
    var currentBlockIndex: Int? {
        switch state {
        case .inBlock(let index, _):
            return index
        case .betweenBlocks(_, let nextIndex):
            return nextIndex
        default:
            return nil
        }
    }

    /// Current block being practiced, or nil if not in a block.
    var currentBlock: PracticeBlock? {
        guard let index = currentBlockIndex,
              let session = session,
              index < session.blocks.count else {
            return nil
        }
        return session.blocks[index]
    }

    /// Progress through the entire session (0.0 to 1.0).
    var sessionProgress: Double {
        guard let session = session else { return 0.0 }

        let completedBlocks = session.blocks.filter { $0.actualMinutes != nil }.count
        return Double(completedBlocks) / Double(session.blocks.count)
    }

    /// Progress through the current block (0.0 to 1.0).
    var blockProgress: Double {
        guard case .inBlock(let index, let remainingSeconds) = state,
              let session = session,
              index < session.blocks.count else {
            return 0.0
        }

        let totalSeconds = session.blocks[index].targetMinutes * 60
        let elapsed = totalSeconds - remainingSeconds
        return Double(elapsed) / Double(totalSeconds)
    }

    // MARK: - Session Management

    /// Start a new practice session with default blocks.
    func startSession() {
        session = PracticeSession.makeTodayDemo()
        startBlock(at: 0)
    }

    /// Start a specific block by index.
    func startBlock(at index: Int) {
        guard let session = session,
              index < session.blocks.count else {
            return
        }

        let block = session.blocks[index]
        let seconds = block.targetMinutes * 60
        state = .inBlock(index: index, remainingSeconds: seconds)
        isPaused = false
    }

    // MARK: - Timer Control

    /// Advance the timer by one second.
    func tick() {
        guard !isPaused else { return }

        switch state {
        case .inBlock(let index, let remainingSeconds):
            if remainingSeconds <= 1 {
                transitionToBetweenBlocks(fromIndex: index)
            } else {
                state = .inBlock(index: index, remainingSeconds: remainingSeconds - 1)
            }
        default:
            break
        }
    }

    /// Pause the timer.
    func pause() {
        isPaused = true
    }

    /// Resume the timer.
    func resume() {
        isPaused = false
    }

    // MARK: - Block Transitions

    /// Finish the current block and record actual time spent.
    func finishCurrentBlock() {
        guard case .inBlock(let index, let remainingSeconds) = state,
              var session = session,
              index < session.blocks.count else {
            return
        }

        // Calculate actual minutes practiced
        let targetSeconds = session.blocks[index].targetMinutes * 60
        let elapsedSeconds = targetSeconds - remainingSeconds
        let actualMinutes = elapsedSeconds / 60

        session.blocks[index].actualMinutes = actualMinutes
        self.session = session

        transitionToBetweenBlocks(fromIndex: index)
    }

    /// Start the next block after being in betweenBlocks state.
    func startNextBlock() {
        guard case .betweenBlocks(_, let nextIndex) = state,
              let nextIndex = nextIndex else {
            return
        }

        startBlock(at: nextIndex)
    }

    /// Skip the current block without completing it.
    func skipCurrentBlock() {
        guard case .inBlock(let index, _) = state,
              var session = session,
              index < session.blocks.count else {
            return
        }

        session.blocks[index].actualMinutes = 0
        self.session = session

        transitionToBetweenBlocks(fromIndex: index)
    }

    /// Extend the current block by additional seconds.
    func extendCurrentBlock(byExtraSeconds seconds: Int) {
        guard case .inBlock(let index, let remainingSeconds) = state else {
            return
        }

        state = .inBlock(index: index, remainingSeconds: remainingSeconds + seconds)
    }

    // MARK: - Feedback

    /// Record feedback for a completed block.
    func recordFeedback(forBlockAt index: Int, feedback: PracticeBlockFeedback) {
        guard var session = session,
              index < session.blocks.count else {
            return
        }

        session.blocks[index].feedback = feedback
        self.session = session
    }

    // MARK: - Private Helpers

    private func transitionToBetweenBlocks(fromIndex index: Int) {
        guard let session = session else { return }

        let nextIndex = index + 1 < session.blocks.count ? index + 1 : nil

        if nextIndex == nil {
            state = .finished
        } else {
            state = .betweenBlocks(lastIndex: index, nextIndex: nextIndex)
        }
    }
}
