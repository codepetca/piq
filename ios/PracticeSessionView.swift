import SwiftUI

struct PracticeSessionView: View {
    @Environment(PracticeEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            switch engine.state {
            case .idle:
                Text("No session")
                    .onAppear { dismiss() }

            case .inBlock(_, let remainingSeconds):
                inBlockView(remainingSeconds: remainingSeconds)

            case .betweenBlocks(let lastIndex, _):
                betweenBlocksView(lastIndex: lastIndex)

            case .finished:
                finishedView()
            }
        }
    }

    // MARK: - In Block View

    @ViewBuilder
    private func inBlockView(remainingSeconds: Int) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Timer with progress rings
            if let block = engine.currentBlock {
                PracticeTimerView(
                    blockKind: block.kind.displayName,
                    title: block.title,
                    detail: block.detail,
                    timeText: formatTime(remainingSeconds),
                    blockProgress: engine.blockProgress,
                    sessionProgress: engine.sessionProgress,
                    isPaused: engine.isPaused,
                    onTogglePause: togglePause
                )
            }

            Spacer()

            // Control buttons
            HStack(spacing: 40) {
                Button(action: { engine.skipCurrentBlock() }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }

                Button(action: togglePause) {
                    Image(systemName: engine.isPaused ? "play.fill" : "pause.fill")
                        .font(.largeTitle)
                }

                Button(action: { engine.extendCurrentBlock(byExtraSeconds: 60) }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Between Blocks View

    @ViewBuilder
    private func betweenBlocksView(lastIndex: Int) -> some View {
        VStack {
            Spacer()

            FeedbackBar(
                onEasy: {
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .easy)
                    engine.startNextBlock()
                },
                onGood: {
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .good)
                    engine.startNextBlock()
                },
                onHard: {
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .hard)
                    engine.startNextBlock()
                }
            )

            Spacer()
        }
    }

    // MARK: - Finished View

    @ViewBuilder
    private func finishedView() -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Session Complete!")
                .font(.title)

            if let session = engine.session {
                Text("\(session.totalActualMinutes) minutes practiced")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func togglePause() {
        if engine.isPaused {
            engine.resume()
        } else {
            engine.pause()
        }
    }
}

#Preview {
    let engine = PracticeEngine()
    engine.startSession()

    return PracticeSessionView()
        .environment(engine)
}
