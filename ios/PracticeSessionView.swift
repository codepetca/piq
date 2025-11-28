import SwiftUI

struct PracticeSessionView: View {
    @Environment(PracticeEngine.self) private var engine
    @Environment(MetronomeService.self) private var metronome
    @Environment(HapticService.self) private var haptics
    @Environment(SettingsViewModel.self) private var settings
    @Environment(PracticeReferenceService.self) private var referenceService
    @Environment(\.dismiss) private var dismiss

    @State private var showingInstructionSheet = false
    @State private var showingInteractionTips = false
    @Namespace private var heroNamespace

    var body: some View {
        VStack {
            switch engine.state {
            case .idle:
                Text("No session")
                    .onAppear { dismiss() }

            case .previewBlock(_, let secondsRemaining):
                previewBlockView(secondsRemaining: secondsRemaining)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .inBlock(_, let remainingSeconds):
                inBlockView(remainingSeconds: remainingSeconds)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .betweenBlocks(let lastIndex, _):
                betweenBlocksView(lastIndex: lastIndex)

            case .finished:
                finishedView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: engine.state)
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
        .overlay(alignment: .topTrailing) {
            Button {
                showingInteractionTips = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .padding(16)
            }
        }
        .sheet(isPresented: $showingInteractionTips) {
            InteractionTipsSheet {
                showingInteractionTips = false
            }
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
            
            // Only start metronome if we're in the actual block, not the preview
            if case .inBlock = engine.state {
                metronome.start()
            }
        } else {
            metronome.stop()
        }
    }

    // MARK: - In Block View

    @ViewBuilder
    private func inBlockView(remainingSeconds: Int) -> some View {
        VStack(spacing: 16) {
            if let session = engine.session,
               let currentIndex = engine.currentBlockIndex {
                blockPillRow(session: session, currentIndex: currentIndex)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            Spacer()

            // Timer with progress rings
            if let block = engine.currentBlock {
                PracticeTimerView(
                    title: block.title,
                    detail: block.detail,
                    timeText: formatTime(remainingSeconds),
                    blockProgress: engine.blockProgress,
                    isPaused: engine.isPaused,
                    onTogglePause: togglePause,
                    onAdjustTime: adjustRemainingTime(by:),
                    namespace: heroNamespace,
                    titleHeroID: heroTitleID(for: block),
                    detailHeroID: heroDetailID(for: block)
                )
                
                BlockInstructionsHeroCard(
                    instructions: block.instructions,
                    focusCue: block.focusCue,
                    namespace: heroNamespace,
                    heroID: heroID(for: block)
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .transition(.opacity)
                .contentShape(Rectangle())
                .onTapGesture {
                    showingInstructionSheet = true
                }
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
                onAdjustBPM: { delta in
                    metronome.setBPM(metronome.bpm + delta)
                    engine.recordTempoAdjustment()
                }
            )
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingInstructionSheet) {
            instructionSheet
        }
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private var instructionSheet: some View {
        if let block = engine.currentBlock {
            InstructionDetailSheet(
                block: block,
                reference: block.referenceID.flatMap { referenceService.reference(for: $0) },
                onDismiss: { showingInstructionSheet = false }
            )
        }
    }

    // MARK: - Preview Block View

    @ViewBuilder
    private func previewBlockView(secondsRemaining: Int) -> some View {
        if let block = engine.currentBlock {
            BlockPreviewView(
                title: block.title,
                detail: block.detail,
                focusCue: block.focusCue,
                instructions: block.instructions,
                secondsRemaining: secondsRemaining,
                onTapToStart: {
                    engine.skipPreview()
                },
                namespace: heroNamespace,
                heroID: heroID(for: block),
                titleHeroID: heroTitleID(for: block),
                detailHeroID: heroDetailID(for: block)
            )
            .overlay(alignment: .top) {
                if let session = engine.session,
                   let currentIndex = engine.currentBlockIndex {
                    blockPillRow(session: session, currentIndex: currentIndex)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
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
    
    private func heroID(for block: PracticeBlock) -> String {
        "instructions-\(block.id.uuidString)"
    }
    
    private func heroTitleID(for block: PracticeBlock) -> String {
        "title-\(block.id.uuidString)"
    }
    
    private func heroDetailID(for block: PracticeBlock) -> String {
        "detail-\(block.id.uuidString)"
    }

    @ViewBuilder
    private func blockPillRow(session: PracticeSession, currentIndex: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(session.blocks.enumerated()), id: \.element.id) { index, block in
                Capsule()
                    .fill(color(forBlockAt: index, currentIndex: currentIndex))
                    .frame(height: 10)
                    .overlay(
                        Capsule()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    .accessibilityLabel("\(block.title)")
            }
        }
    }

    private func color(forBlockAt index: Int, currentIndex: Int) -> Color {
        if index < currentIndex {
            return Color.accentColor.opacity(0.4)
        } else if index == currentIndex {
            return Color.accentColor
        } else {
            return Color.secondary.opacity(0.2)
        }
    }

    // MARK: - Instruction Detail Sheet

    private struct InstructionDetailSheet: View {
        let block: PracticeBlock
        let reference: PracticeReference?
        let onDismiss: () -> Void

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(block.title)
                            .font(.title2)
                            .fontWeight(.semibold)

                        if !block.detail.isEmpty {
                            Text(block.detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let focus = block.focusCue, !focus.isEmpty {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.tint)
                                Text(focus)
                                    .italic()
                            }
                        }

                        if !block.instructions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(block.instructions.indices, id: \.self) { idx in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 5))
                                            .foregroundStyle(.secondary)
                                            .padding(.top, 7)
                                        Text(block.instructions[idx])
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }

                        if let reference {
                            Image(reference.assetName)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }

    private struct InteractionTipsSheet: View {
        let onDismiss: () -> Void

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        TipRow(
                            title: "Adjust time",
                            detail: "Swipe up/down/left/right on the timer to change remaining time.",
                            systemImage: "timer"
                        )
                        TipRow(
                            title: "See instructions",
                            detail: "Tap the instruction card to open details and diagrams.",
                            systemImage: "text.badge.plus"
                        )
                        TipRow(
                            title: "Tune metronome",
                            detail: "Swipe on the triangle to change BPM. Tap to toggle sound.",
                            systemImage: "metronome.fill"
                        )
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }

    private struct TipRow: View {
        let title: String
        let detail: String
        let systemImage: String

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private func adjustRemainingTime(by deltaSeconds: Int) {
        engine.adjustCurrentBlockRemaining(by: deltaSeconds)
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
