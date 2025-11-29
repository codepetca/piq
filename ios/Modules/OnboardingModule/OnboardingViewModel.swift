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
        let totalSteps = max(1, Step.allCases.count - 1)
        return Double(currentStep.rawValue) / Double(totalSteps)
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

    // MARK: - Preview Session Generation

    /// Generate a preview of today's session blocks based on user selections.
    /// Uses PracticeSession factory to generate realistic session preview.
    private func generatePreviewBlocks() -> [PracticeBlock] {
        let preferences = UserPreferences(
            level: selectedLevel,
            styles: Array(selectedStyles),
            cuePreference: selectedCuePreference
        )
        return PracticeSession.makeOnboardingPreview(for: preferences).blocks
    }
}
