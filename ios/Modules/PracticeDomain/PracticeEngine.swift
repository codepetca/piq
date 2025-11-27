import Foundation
import Observation

/// Engine state machine for managing practice sessions.
enum PracticeEngineState: Equatable {
    case idle
    case previewBlock(index: Int)
    case inBlock(index: Int, remainingSeconds: Int)
    case betweenBlocks(lastIndex: Int, nextIndex: Int?)
    case finished
}

/// Manages the practice session flow, timing, and state transitions.
@Observable
final class PracticeEngine {

    // MARK: - Public Properties

    var state: PracticeEngineState = .idle {
        didSet {
            handleStateChange(from: oldValue, to: state)
        }
    }
    var session: PracticeSession?
    var isPaused: Bool = false

    /// Callback invoked when session transitions to `.finished` state.
    /// Set this to handle session completion (e.g., persistence, SRE updates).
    var onSessionFinished: ((PracticeSession) -> Void)?

    // MARK: - Private Properties

    private var timer: Timer?
    private var sessionSaved: Bool = false

    /// Current block index, or nil if not in a block.
    var currentBlockIndex: Int? {
        switch state {
        case .inBlock(let index, _):
            return index
        case .betweenBlocks(_, let nextIndex):
            return nextIndex
        case .previewBlock:
            return nil  // Metronome won't start during preview
        default:
            return nil
        }
    }

    /// Current block being practiced, or nil if not in a block.
    var currentBlock: PracticeBlock? {
        // Check preview state first
        if case .previewBlock(let index) = state,
           let session = session,
           index < session.blocks.count {
            return session.blocks[index]
        }

        // Then check active block
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
        sessionSaved = false
        session = PracticeSession.makeTodayDemo()
        startBlock(at: 0)
    }

    /// Start a new practice session generated from the spaced repetition engine.
    func startSession(from sre: SpacedRepetitionEngine) {
        sessionSaved = false
        session = sre.generateTodaySession()
        startBlock(at: 0)
    }

    /// Start a specific block by index (shows preview first).
    func startBlock(at index: Int) {
        guard let session = session,
              index < session.blocks.count else {
            return
        }

        state = .previewBlock(index: index)
    }

    /// Transition from preview to active practice for current block.
    func startCurrentBlock() {
        guard case .previewBlock(let index) = state,
              let session = session,
              index < session.blocks.count else {
            return
        }

        let block = session.blocks[index]
        let seconds = block.targetMinutes * 60
        isPaused = false
        state = .inBlock(index: index, remainingSeconds: seconds)
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
    /// If there's no next block (last block was completed), transitions to finished state.
    func startNextBlock() {
        guard case .betweenBlocks(_, let nextIndex) = state else {
            return
        }

        if let nextIndex = nextIndex {
            startBlock(at: nextIndex)
        } else {
            // No next block - session is complete
            state = .finished
        }
    }

    /// Skip the current block without completing it.
    func skipCurrentBlock() {
        let index: Int

        switch state {
        case .inBlock(let idx, _):
            index = idx
        case .previewBlock(let idx):
            index = idx
        default:
            return
        }

        guard var session = session,
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

    // MARK: - Timer Management

    /// Start the internal timer for automatic ticking.
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// Stop the internal timer.
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private Helpers

    private func handleStateChange(from oldState: PracticeEngineState, to newState: PracticeEngineState) {
        // Auto-start timer when entering inBlock state
        if case .inBlock = newState {
            if case .inBlock = oldState {
                // Already in a block, timer is running
            } else {
                startTimer()
            }
        } else {
            // Stop timer when leaving inBlock state
            if case .inBlock = oldState {
                stopTimer()
            }
        }

        // Invoke completion callback when transitioning to finished state (not when already finished)
        if case .finished = newState, !(oldState == .finished) {
            if let session = session, !sessionSaved {
                sessionSaved = true
                onSessionFinished?(session)
            }
        }
    }

    private func transitionToBetweenBlocks(fromIndex index: Int) {
        guard let session = session else { return }

        let nextIndex = index + 1 < session.blocks.count ? index + 1 : nil
        state = .betweenBlocks(lastIndex: index, nextIndex: nextIndex)
    }
}
