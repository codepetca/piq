import SwiftUI

/// Displays a completed practice session summary with block feedback and stability hints.
struct SessionSummaryView: View {
    let session: PracticeSession
    let spacedRepetitionEngine: SpacedRepetitionEngine?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Completion icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Session complete")
                .font(.title2)
                .fontWeight(.semibold)

            // Block list with feedback and stability
            VStack(spacing: 12) {
                ForEach(session.blocks) { block in
                    blockRow(for: block)
                }
            }
            .padding(.vertical, 8)

            // Total time
            Text("Total: \(session.totalActualMinutes) min")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            // Tap instruction
            Text("Tap to finish")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onDone()
        }
    }

    @ViewBuilder
    private func blockRow(for block: PracticeBlock) -> some View {
        HStack(spacing: 8) {
            // Title
            Text(block.title)
                .font(.subheadline)
                .foregroundStyle(.primary)

            // Separator
            Text("·")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Feedback
            if let feedback = block.feedback {
                Text(feedback.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(feedbackColor(for: feedback))
            } else {
                Text("—")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Separator
            Text("·")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Actual minutes
            if let actualMinutes = block.actualMinutes {
                Text("\(actualMinutes) min")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("—")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Stability stars (optional)
            if let stars = stabilityStars(for: block) {
                Text("·")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(index < stars ? .yellow : .secondary.opacity(0.3))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Returns the number of stability stars (1-3) for a block, or nil if no SRS data available.
    private func stabilityStars(for block: PracticeBlock) -> Int? {
        guard let itemID = block.practiceItemID,
              let sre = spacedRepetitionEngine,
              let item = sre.item(withID: itemID) else {
            return nil
        }

        return item.stabilityStars
    }

    private func feedbackColor(for feedback: PracticeBlockFeedback) -> Color {
        switch feedback {
        case .easy:
            return .green
        case .good:
            return .blue
        case .hard:
            return .orange
        }
    }
}

#Preview("Completed Session") {
    let engine = PracticeEngine()
    let sre = SpacedRepetitionEngine()
    sre.loadSeedCatalog()
    engine.startSession(from: sre)

    // Simulate completed session
    if let session = engine.session {
        var completedSession = session
        for i in 0..<completedSession.blocks.count {
            completedSession.blocks[i].actualMinutes = completedSession.blocks[i].targetMinutes
            completedSession.blocks[i].feedback = i % 3 == 0 ? .hard : (i % 3 == 1 ? .good : .easy)
        }

        return SessionSummaryView(
            session: completedSession,
            spacedRepetitionEngine: sre,
            onDone: {}
        )
    }

    return Text("No session")
}

#Preview("No SRE Data") {
    var session = PracticeSession.makeTodayDemo()
    for i in 0..<session.blocks.count {
        session.blocks[i].actualMinutes = session.blocks[i].targetMinutes
        session.blocks[i].feedback = .good
        session.blocks[i].practiceItemID = nil  // No item ID = no stars
    }

    return SessionSummaryView(
        session: session,
        spacedRepetitionEngine: nil,
        onDone: {}
    )
}
