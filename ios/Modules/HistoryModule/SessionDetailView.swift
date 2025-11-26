import SwiftUI

/// Displays details of a completed practice session.
struct SessionDetailView: View {
    let session: PracticeSession

    var body: some View {
        List {
            // Summary section
            Section {
                summaryRow
            }

            // Blocks section
            Section("Blocks") {
                ForEach(session.blocks) { block in
                    BlockDetailRow(block: block)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(formatDate(session.date))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(session.totalActualMinutes) min")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Blocks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(session.blocks.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            Divider()

            // Feedback distribution
            HStack(spacing: 16) {
                FeedbackCount(
                    label: PracticeBlockFeedback.easy.displayName,
                    count: feedbackCount(.easy),
                    color: PracticeBlockFeedback.easy.color
                )
                FeedbackCount(
                    label: PracticeBlockFeedback.good.displayName,
                    count: feedbackCount(.good),
                    color: PracticeBlockFeedback.good.color
                )
                FeedbackCount(
                    label: PracticeBlockFeedback.hard.displayName,
                    count: feedbackCount(.hard),
                    color: PracticeBlockFeedback.hard.color
                )
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func feedbackCount(_ feedback: PracticeBlockFeedback) -> Int {
        session.blocks.filter { $0.feedback == feedback }.count
    }
}

// MARK: - Block Detail Row

private struct BlockDetailRow: View {
    let block: PracticeBlock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(block.kind.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    if let feedback = block.feedback {
                        feedbackBadge(feedback)
                    }
                }

                Text(block.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !block.detail.isEmpty {
                    Text(block.detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let actual = block.actualMinutes {
                    Text("\(actual) min")
                        .font(.subheadline)
                } else {
                    Text("—")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func feedbackBadge(_ feedback: PracticeBlockFeedback) -> some View {
        Text(feedback.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(feedback.color)
            .cornerRadius(4)
    }
}

// MARK: - Feedback Count

private struct FeedbackCount: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.headline)
                .foregroundColor(count > 0 ? color : .secondary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: PracticeSession.makeTodayDemo())
    }
}
