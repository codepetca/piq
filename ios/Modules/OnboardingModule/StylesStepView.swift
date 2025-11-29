import SwiftUI

/// Music styles selection step view for onboarding.
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
                ForEach(Array(MusicStyle.allCases), id: \.self) { style in
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
                                    .fill(isSelected ? Color.accentColor : Color(white: 0.96))
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

// MARK: - Preview

#Preview("Styles") {
    StylesStepView(
        selectedStyles: [.rock, .blues],
        onToggle: { _ in },
        canProceed: true,
        onNext: {},
        onBack: {}
    )
}
