import Foundation
import Observation

/// ViewModel for managing the onboarding flow.
/// Tracks the current step and stores user selections.
@Observable
final class OnboardingViewModel {

    // MARK: - Onboarding Steps

    enum Step: Int, CaseIterable {
        case welcome = 0
        case level = 1
        case styles = 2
        case cues = 3
        case summary = 4

        var isFirstStep: Bool { self == .welcome }
        var isLastStep: Bool { self == .summary }
    }

    // MARK: - Dependencies

    private let storage: PracticeStorage
    private let onComplete: (() -> Void)?

    // MARK: - Published State

    /// Current step in the onboarding flow.
    private(set) var currentStep: Step = .welcome

    /// User's selected level.
    var selectedLevel: UserLevel = .beginner

    /// User's selected music styles.
    var selectedStyles: Set<MusicStyle> = []

    /// User's selected cue preference.
    var selectedCuePreference: CuePreference = .soundAndVibration

    /// Preview blocks for the summary screen.
    private(set) var previewBlocks: [PracticeBlock] = []

    // MARK: - Computed Properties

    /// Whether the current step allows proceeding to the next step.
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .level:
            return true // Always has a selection
        case .styles:
            return !selectedStyles.isEmpty
        case .cues:
            return true // Always has a selection
        case .summary:
            return true
        }
    }

    /// Progress through onboarding (0.0 to 1.0).
    var progress: Double {
        Double(currentStep.rawValue) / Double(Step.allCases.count - 1)
    }

    // MARK: - Initialization

    init(storage: PracticeStorage = PracticeStorage(), onComplete: (() -> Void)? = nil) {
        self.storage = storage
        self.onComplete = onComplete
    }

    // MARK: - Navigation

    /// Move to the next step.
    func nextStep() {
        guard canProceed else { return }

        switch currentStep {
        case .welcome:
            currentStep = .level
        case .level:
            currentStep = .styles
        case .styles:
            currentStep = .cues
        case .cues:
            // Generate preview blocks before showing summary
            previewBlocks = generatePreviewBlocks()
            currentStep = .summary
        case .summary:
            completeOnboarding()
        }
    }

    /// Move to the previous step.
    func previousStep() {
        switch currentStep {
        case .welcome:
            break // Can't go back from welcome
        case .level:
            currentStep = .welcome
        case .styles:
            currentStep = .level
        case .cues:
            currentStep = .styles
        case .summary:
            currentStep = .cues
        }
    }

    /// Skip onboarding (use defaults).
    func skip() {
        completeOnboarding()
    }

    // MARK: - Style Selection

    /// Toggle selection of a music style.
    func toggleStyle(_ style: MusicStyle) {
        if selectedStyles.contains(style) {
            selectedStyles.remove(style)
        } else {
            selectedStyles.insert(style)
        }
    }

    // MARK: - Completion

    /// Complete onboarding and persist preferences.
    private func completeOnboarding() {
        let preferences = UserPreferences(
            level: selectedLevel,
            styles: Array(selectedStyles),
            cuePreference: selectedCuePreference,
            hasCompletedOnboarding: true
        )
        storage.savePreferences(preferences)
        onComplete?()
    }

    /// Get the saved preferences (for applying to services).
    func getSavedPreferences() -> UserPreferences {
        storage.loadPreferences()
    }

    // MARK: - Preview Session Generation

    /// Generate a preview of today's session blocks based on user selections.
    private func generatePreviewBlocks() -> [PracticeBlock] {
        // Create a simple preview based on level
        // In a full implementation, this would use the SRE with user preferences
        let blockCount: Int
        switch selectedLevel {
        case .beginner:
            blockCount = 6
        case .intermediate:
            blockCount = 7
        case .advanced:
            blockCount = 8
        }

        // Generate sample blocks for preview
        var blocks: [PracticeBlock] = []

        // Always start with warmup
        blocks.append(PracticeBlock(
            kind: .warmup,
            title: "Chromatic Warm-Up",
            detail: "1-2-3-4 pattern",
            targetMinutes: 3
        ))

        // Add varied middle blocks based on level
        let middleBlocks: [(kind: PracticeBlockKind, title: String, detail: String, minutes: Int)] = [
            (.techniqueOrTheory, "Alternate Picking", "String crossing drill", 4),
            (.techniqueOrTheory, "Chord Changes", "Open chord transitions", 4),
            (.solo, "Am Pentatonic", "Position 1 improvisation", 5),
            (.techniqueOrTheory, "Bends & Vibrato", "Basic control", 4),
            (.techniqueOrTheory, "Rhythm Patterns", "8th note strumming", 4),
            (.solo, "Blues Licks", "Classic phrases", 4)
        ]

        let middleCount = blockCount - 2 // Reserve for warmup and fun ending
        for i in 0..<min(middleCount, middleBlocks.count) {
            let info = middleBlocks[i]
            blocks.append(PracticeBlock(
                kind: info.kind,
                title: info.title,
                detail: info.detail,
                targetMinutes: info.minutes
            ))
        }

        // Fun ending block
        blocks.append(PracticeBlock(
            kind: .song,
            title: "Song Practice",
            detail: "Play your favorite tune",
            targetMinutes: 6
        ))

        return blocks
    }
}
