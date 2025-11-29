import SwiftUI

/// Session summary preview step view for onboarding.
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
                        .background(Color(white: 0.96))
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
                        .background(Color(white: 0.96))
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
