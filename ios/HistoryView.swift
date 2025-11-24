import SwiftUI

struct HistoryView: View {
    @Environment(HistoryViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionListView
                }
            }
            .navigationTitle("History")
            .onAppear {
                viewModel.loadSessions()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Practice History")
                .font(.title3)
                .fontWeight(.medium)

            Text("Complete your first session to see it here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Session List

    private var sessionListView: some View {
        List {
            // Stats section
            Section {
                statsRow
            }

            // Sessions grouped by date
            ForEach(viewModel.sessionsByDate, id: \.date) { group in
                Section(header: Text(formatSectionDate(group.date))) {
                    ForEach(group.sessions) { session in
                        NavigationLink(destination: SessionDetailView(session: session)) {
                            SessionRowView(session: session)
                        }
                    }
                    .onDelete { offsets in
                        deleteSessionsInGroup(group.sessions, at: offsets)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 24) {
            StatItem(
                title: "Total",
                value: "\(viewModel.totalSessions)",
                subtitle: "sessions"
            )

            Divider()

            StatItem(
                title: "This Week",
                value: "\(viewModel.sessionsThisWeek)",
                subtitle: "sessions"
            )

            Divider()

            StatItem(
                title: "Minutes",
                value: "\(viewModel.totalMinutes)",
                subtitle: "practiced"
            )
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }

    private func deleteSessionsInGroup(_ groupSessions: [PracticeSession], at offsets: IndexSet) {
        for index in offsets {
            let session = groupSessions[index]
            viewModel.deleteSession(session)
        }
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Row

private struct SessionRowView: View {
    let session: PracticeSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatTime(session.date))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(session.blocks.count) blocks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(session.totalActualMinutes) min")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Feedback summary
            feedbackIndicators
        }
        .padding(.vertical, 4)
    }

    private var feedbackIndicators: some View {
        HStack(spacing: 2) {
            ForEach(session.blocks) { block in
                Circle()
                    .fill(feedbackColor(block.feedback))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func feedbackColor(_ feedback: PracticeBlockFeedback?) -> Color {
        switch feedback {
        case .easy: return .green
        case .good: return .blue
        case .hard: return .orange
        case nil: return .gray
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview("With Sessions") {
    let viewModel = HistoryViewModel()
    return HistoryView()
        .environment(viewModel)
}

#Preview("Empty") {
    let storage = PracticeStorage(
        directory: FileManager.default.temporaryDirectory.appendingPathComponent("empty")
    )
    let viewModel = HistoryViewModel(storage: storage)
    return HistoryView()
        .environment(viewModel)
}
