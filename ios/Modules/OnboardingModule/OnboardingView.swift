import SwiftUI

/// Main onboarding view that presents the multi-step onboarding flow.
/// Coordinates between step views based on current state.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    init(storage: PracticeStorage = PracticeStorage(), onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: OnboardingViewModel(storage: storage, onComplete: onComplete))
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator (hidden on welcome)
            if viewModel.currentStep != .welcome {
                ProgressView(value: viewModel.progress)
                    .tint(.accentColor)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
            }

            // Step content
            stepContent
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        }
        .background(Color(white: 0.96))
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomeStepView(onNext: viewModel.nextStep)
        case .level:
            LevelStepView(
                selectedLevel: $viewModel.selectedLevel,
                onNext: viewModel.nextStep,
                onBack: viewModel.previousStep
            )
        case .styles:
            StylesStepView(
                selectedStyles: viewModel.selectedStyles,
                onToggle: viewModel.toggleStyle,
                canProceed: viewModel.canProceed,
                onNext: viewModel.nextStep,
                onBack: viewModel.previousStep
            )
        case .cues:
            CuesStepView(
                selectedCue: $viewModel.selectedCuePreference,
                onNext: viewModel.nextStep,
                onBack: viewModel.previousStep
            )
        case .summary:
            OnboardingSummaryView(
                blocks: viewModel.previewBlocks,
                onStart: {
                    viewModel.nextStep()
                    onComplete()
                },
                onBack: viewModel.previousStep
            )
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView { }
}
