import Foundation
import Observation

/// Engine state machine for managing practice sessions.
enum PracticeEngineState: Equatable {
    case idle
    case previewBlock(index: Int, secondsRemaining: Int)
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
        case .previewBlock(let index, _):
            return index
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

    /// Start a specific block by index.
    func startBlock(at index: Int) {
        guard let session = session,
              index < session.blocks.count else {
            return
        }

        // Start with preview state (4 seconds)
        state = .previewBlock(index: index, secondsRemaining: 4)
        isPaused = false
    }

    // MARK: - Timer Control

    /// Advance the timer by one second.
    func tick() {
        guard !isPaused else { return }

        switch state {
        case .previewBlock(let index, let secondsRemaining):
            if secondsRemaining <= 1 {
                // Preview countdown complete, transition to actual block
                transitionToInBlock(at: index)
            } else {
                state = .previewBlock(index: index, secondsRemaining: secondsRemaining - 1)
            }
            
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

    /// Skip the preview and immediately start the block.
    /// This is called when user taps during the preview countdown.
    func skipPreview() {
        guard case .previewBlock(let index, _) = state else {
            return
        }
        
        transitionToInBlock(at: index)
    }
    
    /// Skip the current block without completing it.
    func skipCurrentBlock() {
        switch state {
        case .previewBlock(let index, _):
            // If in preview, skip to next block without starting this one
            guard var session = session,
                  index < session.blocks.count else {
                return
            }
            session.blocks[index].actualMinutes = 0
            self.session = session
            transitionToBetweenBlocks(fromIndex: index)
            
        case .inBlock(let index, _):
            // If in block, mark as skipped and move to feedback
            guard var session = session,
                  index < session.blocks.count else {
                return
            }
            session.blocks[index].actualMinutes = 0
            self.session = session
            transitionToBetweenBlocks(fromIndex: index)
            
        default:
            return
        }
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
    
    // MARK: - Tempo Tracking
    
    /// Record the starting BPM for a block.
    /// - Parameters:
    ///   - index: Block index
    ///   - bpm: Starting BPM value
    func recordStartingBPM(forBlockAt index: Int, bpm: Int) {
        guard var session = session,
              index < session.blocks.count else {
            return
        }
        
        session.blocks[index].startingBPM = bpm
        self.session = session
    }
    
    /// Record the ending BPM for a block.
    /// - Parameters:
    ///   - index: Block index
    ///   - bpm: Ending BPM value
    func recordEndingBPM(forBlockAt index: Int, bpm: Int) {
        guard var session = session,
              index < session.blocks.count else {
            return
        }
        
        session.blocks[index].endingBPM = bpm
        self.session = session
    }
    
    /// Record a tempo adjustment made by the user.
    /// Call this when user taps +/- BPM buttons.
    func recordTempoAdjustment() {
        guard case .inBlock(let index, _) = state,
              var session = session,
              index < session.blocks.count else {
            return
        }
        
        session.blocks[index].tempoAdjustmentCount += 1
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
        // Auto-start timer when entering previewBlock or inBlock state
        switch newState {
        case .previewBlock, .inBlock:
            if case .previewBlock = oldState {
                // Already in preview, timer is running
            } else if case .inBlock = oldState {
                // Already in block, timer is running
            } else {
                startTimer()
            }
            
        default:
            // Stop timer when leaving previewBlock or inBlock state
            if case .previewBlock = oldState {
                stopTimer()
            } else if case .inBlock = oldState {
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

    private func transitionToInBlock(at index: Int) {
        guard let session = session,
              index < session.blocks.count else {
            return
        }
        
        let block = session.blocks[index]
        let seconds = block.targetMinutes * 60
        state = .inBlock(index: index, remainingSeconds: seconds)
    }
    
    private func transitionToBetweenBlocks(fromIndex index: Int) {
        guard let session = session else { return }

        let nextIndex = index + 1 < session.blocks.count ? index + 1 : nil
        state = .betweenBlocks(lastIndex: index, nextIndex: nextIndex)
    }
}
