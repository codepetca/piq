import SwiftUI

/// Main onboarding view that presents the multi-step onboarding flow.
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
        .background(Color(.systemBackground))
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

// MARK: - Welcome Step

struct WelcomeStepView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon / logo area
            Image(systemName: "guitars")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("piq")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Guitar practice")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onNext) {
                Text("Get started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Level Step

struct LevelStepView: View {
    @Binding var selectedLevel: UserLevel
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Your level")
                .font(.title)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ForEach(UserLevel.allCases, id: \.self) { level in
                    Button {
                        selectedLevel = level
                    } label: {
                        HStack {
                            Text(level.displayName)
                                .font(.headline)
                            Spacer()
                            if selectedLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedLevel == level ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedLevel == level ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 48, height: 48)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Button(action: onNext) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Styles Step

struct StylesStepView: View {
    let selectedStyles: Set<MusicStyle>
    let onToggle: (MusicStyle) -> Void
    let canProceed: Bool
    let onNext: () -> Void
    let onBack: () -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Your styles")
                .font(.title)
                .fontWeight(.semibold)

            Text("Pick at least one")
                .font(.subheadline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(MusicStyle.allCases, id: \.self) { style in
                    let isSelected = selectedStyles.contains(style)
                    Button {
                        onToggle(style)
                    } label: {
                        Text(style.displayName)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 48, height: 48)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Button(action: onNext) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canProceed ? Color.accentColor : Color.gray)
                        .cornerRadius(14)
                }
                .disabled(!canProceed)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Cues Step

struct CuesStepView: View {
    @Binding var selectedCue: CuePreference
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Practice cues")
                .font(.title)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ForEach(CuePreference.allCases, id: \.self) { cue in
                    Button {
                        selectedCue = cue
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cue.displayName)
                                    .font(.headline)
                                Text(cueDescription(for: cue))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedCue == cue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCue == cue ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedCue == cue ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 48, height: 48)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Button(action: onNext) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func cueDescription(for cue: CuePreference) -> String {
        switch cue {
        case .soundAndVibration:
            return "Metronome clicks and haptic feedback"
        case .vibrationOnly:
            return "Silent metronome with haptics"
        case .silent:
            return "Visual cues only"
        }
    }
}

// MARK: - Summary Step

struct OnboardingSummaryView: View {
    let blocks: [PracticeBlock]
    let onStart: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Your first session")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 24)

            // Block list
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(blocks) { block in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(block.title)
                                    .font(.headline)
                                if !block.detail.isEmpty {
                                    Text(block.detail)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text("\(block.targetMinutes) min")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Total time
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("\(totalMinutes) min")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)

            // Navigation buttons
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 48, height: 48)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Button(action: onStart) {
                    Text("Start session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private var totalMinutes: Int {
        blocks.reduce(0) { $0 + $1.targetMinutes }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView { }
}

#Preview("Welcome") {
    WelcomeStepView { }
}

#Preview("Level") {
    struct PreviewWrapper: View {
        @State var level: UserLevel = .beginner
        var body: some View {
            LevelStepView(selectedLevel: $level, onNext: {}, onBack: {})
        }
    }
    return PreviewWrapper()
}

#Preview("Styles") {
    StylesStepView(selectedStyles: [.rock, .blues], onToggle: { _ in }, canProceed: true, onNext: {}, onBack: {})
}

#Preview("Cues") {
    struct PreviewWrapper: View {
        @State var cue: CuePreference = .soundAndVibration
        var body: some View {
            CuesStepView(selectedCue: $cue, onNext: {}, onBack: {})
        }
    }
    return PreviewWrapper()
}

#Preview("Summary") {
    OnboardingSummaryView(
        blocks: [
            PracticeBlock(kind: .warmup, title: "Chromatic Warm-Up", detail: "1-2-3-4 pattern", targetMinutes: 3),
            PracticeBlock(kind: .techniqueOrTheory, title: "Alternate Picking", detail: "String crossing", targetMinutes: 4),
            PracticeBlock(kind: .solo, title: "Am Pentatonic", detail: "Position 1", targetMinutes: 5),
            PracticeBlock(kind: .song, title: "Song Practice", detail: "Your favorite tune", targetMinutes: 6)
        ],
        onStart: {},
        onBack: {}
    )
}
