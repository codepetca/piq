import SwiftUI

struct PracticeSessionView: View {
    @Environment(PracticeEngine.self) private var engine
    @Environment(MetronomeService.self) private var metronome
    @Environment(HapticService.self) private var haptics
    @Environment(SettingsViewModel.self) private var settings
    @Environment(PracticeReferenceService.self) private var referenceService
    @Environment(\.dismiss) private var dismiss

    @State private var showingReference = false
    @State private var showSessionPrompt = true

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
            // Set block-specific tempo and start metronome for first block if needed
            handleMetronomeForBlock(at: engine.currentBlockIndex)
        }
        .onChange(of: engine.currentBlockIndex) { _, newIndex in
            // Auto-start/stop metronome and set tempo based on block
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
        // Tempo learning is only tracked for blocks whose metronome is on by default.
        if block.kind.defaultMetronomeOn {
            // Use block's suggested BPM if available, otherwise use settings default
            let bpmToUse = block.startingBPM ?? settings.defaultBPM
            metronome.setBPM(bpmToUse)
            // Record the starting BPM for tempo learning
            engine.recordStartingBPM(forBlockAt: index, bpm: bpmToUse)
            metronome.start()
        } else {
            metronome.stop()
        }
    }

    // MARK: - In Block View

    @ViewBuilder
    private func inBlockView(remainingSeconds: Int) -> some View {
        VStack(spacing: 16) {
            // Session prompt (first block only)
            if showSessionPrompt && engine.currentBlockIndex == 0,
               let session = engine.session {
                HStack {
                    Text(session.sessionPrompt)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        withAnimation {
                            showSessionPrompt = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Spacer()

            // Block instructions (if available)
            if let block = engine.currentBlock,
               !block.instructions.isEmpty || block.focusCue != nil {
                BlockInstructionView(
                    instructions: block.instructions,
                    focusCue: block.focusCue
                )
            }

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
                onIncreaseBPM: {
                    metronome.increaseBPM()
                    engine.recordTempoAdjustment()
                },
                onDecreaseBPM: {
                    metronome.decreaseBPM()
                    engine.recordTempoAdjustment()
                }
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
                referenceSheet
            }
        }
    }

    @ViewBuilder
    private var referenceSheet: some View {
        if let block = engine.currentBlock,
           let refID = block.referenceID,
           let reference = referenceService.reference(for: refID) {
            PracticeReferenceView(
                reference: reference,
                onDismiss: { showingReference = false }
            )
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
                    recordEndingBPMIfNeeded(forBlockAt: lastIndex)
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .easy)
                    engine.startNextBlock()
                },
                onGood: {
                    haptics.feedbackGood()
                    recordEndingBPMIfNeeded(forBlockAt: lastIndex)
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .good)
                    engine.startNextBlock()
                },
                onHard: {
                    haptics.feedbackHard()
                    recordEndingBPMIfNeeded(forBlockAt: lastIndex)
                    engine.recordFeedback(forBlockAt: lastIndex, feedback: .hard)
                    engine.startNextBlock()
                }
            )

            Spacer()
        }
    }
    
    /// Record the ending BPM for tempo learning (only for blocks with metronome).
    private func recordEndingBPMIfNeeded(forBlockAt index: Int) {
        guard let session = engine.session,
              index < session.blocks.count else { return }
        
        let block = session.blocks[index]
        // Only track tempo for blocks that default to metronome-on; optional metronome
        // usage in Song/Solo blocks is intentionally excluded from tempo learning.
        if block.kind.defaultMetronomeOn {
            engine.recordEndingBPM(forBlockAt: index, bpm: metronome.bpm)
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
    let _ = {
        sre.loadSeedCatalog()
        engine.startSession(from: sre)
    }()
    let metronome = MetronomeService()
    let haptics = HapticService()
    let settings = SettingsViewModel()
    let referenceService = PracticeReferenceService()

    PracticeSessionView()
        .environment(engine)
        .environment(metronome)
        .environment(haptics)
        .environment(settings)
        .environment(referenceService)
}
