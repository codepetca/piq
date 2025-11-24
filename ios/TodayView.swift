import SwiftUI

struct TodayView: View {
    @Environment(SpacedRepetitionEngine.self) private var sre
    @Environment(PracticeEngine.self) private var engine
    @State private var showingSession = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Block list
                VStack(spacing: 12) {
                    ForEach(todayBlocks) { block in
                        BlockRow(block: block)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Start session button
                Button(action: startSession) {
                    Text("Start Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
            .navigationTitle("Today")
            .fullScreenCover(isPresented: $showingSession) {
                PracticeSessionView()
            }
        }
    }

    private var todayBlocks: [PracticeBlock] {
        sre.generateTodaySession().blocks
    }

    private func startSession() {
        engine.startSession(from: sre)
        showingSession = true
    }
}

// MARK: - Block Row Component

struct BlockRow: View {
    let block: PracticeBlock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(block.kind.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(block.title)
                    .font(.headline)
                if !block.detail.isEmpty {
                    Text(block.detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(block.targetMinutes) min")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    TodayView()
        .environment(SpacedRepetitionEngine())
        .environment(PracticeEngine())
}
