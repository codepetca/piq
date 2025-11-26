import SwiftUI

/// Displays practice instructions for a block with collapsible detail.
struct BlockInstructionView: View {
    let instructions: [String]
    let focusCue: String?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let focusCue {
                // Always show focus cue (collapsed state)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.tint)

                        Text(focusCue)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.tint)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }

            // Expanded instructions (only shown when tapped)
            if isExpanded && !instructions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundStyle(.secondary)
                                .padding(.top, 6)

                            Text(instructions[index])
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.leading, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxHeight: isExpanded ? 100 : nil)
    }
}

#Preview("Collapsed") {
    BlockInstructionView(
        instructions: [
            "1–2–3–4 pattern, one finger per fret",
            "Use strict alternate picking"
        ],
        focusCue: "Super slow, perfect tone"
    )
}

#Preview("Expanded") {
    BlockInstructionView(
        instructions: [
            "1–2–3–4 pattern, one finger per fret",
            "Use strict alternate picking",
            "Check every note rings clearly"
        ],
        focusCue: "Super slow, perfect tone"
    )
    .onAppear {
        // Force expanded state for preview
    }
}

#Preview("No Focus Cue") {
    BlockInstructionView(
        instructions: [
            "1–2–3–4 pattern, one finger per fret",
            "Use strict alternate picking"
        ],
        focusCue: nil
    )
}
