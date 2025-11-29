import SwiftUI

/// Practice cues selection step view for onboarding.
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
                                Text(cue.description)
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
                                .fill(selectedCue == cue ? Color.accentColor.opacity(0.1) : Color(white: 0.96))
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
                        .background(Color(white: 0.96))
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
}

// MARK: - Preview

#Preview("Cues") {
    struct PreviewWrapper: View {
        @State var cue: CuePreference = .soundAndVibration
        var body: some View {
            CuesStepView(selectedCue: $cue, onNext: {}, onBack: {})
        }
    }
    return PreviewWrapper()
}
