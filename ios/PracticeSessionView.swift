import SwiftUI

struct PracticeSessionView: View {
    @Environment(PracticeEngine.self) private var engine
    @Environment(MetronomeService.self) private var metronome
    @Environment(HapticService.self) private var haptics
    @Environment(SettingsViewModel.self) private var settings
    @Environment(PracticeReferenceService.self) private var referenceService
    @Environment(\.dismiss) private var dismiss

    @State private var showingReference = false

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
        .onAppear {
            // Set metronome to default BPM from settings
            metronome.setBPM(settings.defaultBPM)
            // Set haptics enabled from settings
            haptics.isEnabled = settings.hapticFeedbackEnabled
            // Start metronome for first block if needed
            handleMetronomeForBlock(at: engine.currentBlockIndex)
        }
        .onChange(of: engine.currentBlockIndex) { _, newIndex in
            // Auto-start/stop metronome based on block kind
            handleMetronomeForBlock(at: newIndex)
        }
    }

    // MARK: - Metronome Control

    private func handleMetronomeForBlock(at index: Int?) {
        guard let index = index,
              let session = engine.session,
              index < session.blocks.count else {
            metronome.stop()
            return
        }

        let block = session.blocks[index]
        if block.kind.defaultMetronomeOn {
            metronome.start()
        } else {
            metronome.stop()
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

            // Metronome controls
            MetronomeBar(
                isOn: metronome.isPlaying,
                bpm: metronome.bpm,
                onToggle: {
                    if metronome.isPlaying {
                        metronome.stop()
                    } else {
                        metronome.start()
                    }
                },
                onIncreaseBPM: { metronome.increaseBPM() },
                onDecreaseBPM: { metronome.decreaseBPM() }
            )
            .padding(.horizontal)

            // Control buttons
            HStack(spacing: 32) {
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

                // Reference button (only if block has a reference)
                if let block = engine.currentBlock,
                   let refID = block.referenceID,
                   referenceService.reference(for: refID) != nil {
                    Button(action: { showingReference = true }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                    }
                }
            }
            .padding(.bottom, 40)
            .sheet(isPresented: $showingReference) {
                if let block = engine.currentBlock,
                   let refID = block.referenceID,
                   let reference = referenceService.reference(for: refID) {
                    PracticeReferenceView(
                        reference: reference,
                        onDismiss: { showingReference = false }
                    )
                }
            }
        }
    }

    // MARK: - Between Blocks View

    @ViewBuilder
    private func betweenBlocksView(lastIndex: Int) -> some View {
        VStack {
            Spacer()

            FeedbackBar(
                onEasy: {
                    haptics.feedbackEasy()
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .easy)
                    engine.startNextBlock()
                },
                onGood: {
                    haptics.feedbackGood()
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .good)
                    engine.startNextBlock()
                },
                onHard: {
                    haptics.feedbackHard()
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

            // Block list with feedback
            if let session = engine.session {
                VStack(spacing: 8) {
                    ForEach(session.blocks) { block in
                        HStack {
                            Text(block.kind.displayName)
                                .font(.subheadline)
                            Text(":")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(block.feedback?.displayName ?? "—")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.vertical, 8)

                Text("Total: \(session.totalActualMinutes) min")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Done") {
                // Haptic feedback for completion
                haptics.success()

                // Session persistence is handled automatically by PracticeEngine.onSessionFinished
                // which saves to history, applies SRE feedback, and persists items.

                // Stop metronome when leaving
                metronome.stop()
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
    let sre = SpacedRepetitionEngine()
    sre.loadDemoItems()
    engine.startSession(from: sre)
    let metronome = MetronomeService()
    let haptics = HapticService()
    let settings = SettingsViewModel()
    let referenceService = PracticeReferenceService()

    return PracticeSessionView()
        .environment(engine)
        .environment(metronome)
        .environment(haptics)
        .environment(settings)
        .environment(referenceService)
}
