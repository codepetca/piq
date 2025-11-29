import SwiftUI

/// Level selection step view for onboarding.
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
                                .fill(selectedLevel == level ? Color.accentColor.opacity(0.1) : Color(white: 0.96))
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
                        .background(Color(white: 0.96))
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

// MARK: - Preview

#Preview("Level") {
    struct PreviewWrapper: View {
        @State var level: UserLevel = .beginner
        var body: some View {
            LevelStepView(selectedLevel: $level, onNext: {}, onBack: {})
        }
    }
    return PreviewWrapper()
}
