import SwiftUI

struct PracticeSessionView: View {
    @Environment(PracticeEngine.self) private var engine
    @Environment(SpacedRepetitionEngine.self) private var sre
    @Environment(MetronomeService.self) private var metronome
    @Environment(HapticService.self) private var haptics
    @Environment(SettingsViewModel.self) private var settings
    @Environment(PracticeReferenceService.self) private var referenceService
    @Environment(TodayViewModel.self) private var todayViewModel
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
        VStack(spacing: 24) {
            if let session = engine.session,
               let currentIndex = engine.currentBlockIndex {
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        questionButton
                    }

                    blockPillRow(session: session, currentIndex: currentIndex)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }

            // Timer with progress rings and title/subtitle
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
                .padding(.top, 8)
                
                BlockInstructionsHeroCard(
                    instructions: block.instructions,
                    focusCue: block.focusCue,
                    namespace: heroNamespace,
                    heroID: heroID(for: block)
                )
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .transition(.opacity)
                .contentShape(Rectangle())
                .onTapGesture {
                    showingInstructionSheet = true
                }
            }

            Spacer(minLength: 0)

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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            questionButton
                        }

                        blockPillRow(session: session, currentIndex: currentIndex)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
            }
        }
    }

    // MARK: - Between Blocks View

    @ViewBuilder
    private func betweenBlocksView(lastIndex: Int) -> some View {
        if let block = block(at: lastIndex) {
            ZStack(alignment: .bottom) {
                VStack(spacing: 16) {
                    if let session = engine.session {
                        blockPillRow(session: session, currentIndex: lastIndex)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }

                    Spacer()

                    PracticeTimerView(
                        title: block.title,
                        detail: block.detail,
                        timeText: formatTime(0),
                        blockProgress: 1.0,
                        isPaused: true,
                        onTogglePause: {},
                        onAdjustTime: { _ in },
                        namespace: heroNamespace,
                        titleHeroID: heroTitleID(for: block),
                        detailHeroID: heroDetailID(for: block)
                    )
                    .allowsHitTesting(false)

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
                    .allowsHitTesting(false)

                    Spacer()

                    MetronomeBar(
                        isOn: metronome.isPlaying,
                        bpm: metronome.bpm,
                        onToggle: {},
                        onAdjustBPM: { _ in }
                    )
                    .padding(.horizontal)
                    .allowsHitTesting(false)
                    .opacity(0.2)
                }
                .padding(.bottom, 40)
                .opacity(0.18)
                .overlay(
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                )

                VStack(spacing: 12) {
                    FeedbackBar(
                        title: "How easy was that?",
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: 420)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
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

    private var questionButton: some View {
        Button {
            showingInteractionTips = true
        } label: {
            Image(systemName: "questionmark.circle")
                .font(.title2)
        }
    }

    private func block(at index: Int) -> PracticeBlock? {
        guard let session = engine.session,
              index < session.blocks.count else { return nil }
        return session.blocks[index]
    }

    @ViewBuilder
    private func blockPillRow(session: PracticeSession, currentIndex: Int) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(session.blocks.enumerated()), id: \.element.id) { index, block in
                Circle()
                    .fill(color(forBlockAt: index, currentIndex: currentIndex))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
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
            return Color.secondary.opacity(0.15)
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
        if let session = engine.session {
            SessionSummaryView(
                session: session,
                spacedRepetitionEngine: sre,
                onDone: {
                    // Haptic feedback for completion
                    haptics.success()

                    // Session persistence is handled automatically by PracticeEngine.onSessionFinished
                    // which saves to history, applies SRE feedback, and persists items.

                    // Signal completion to TodayViewModel to show "All done today!" state
                    todayViewModel.markSessionCompleted()

                    // Reset engine to idle state
                    engine.resetToIdle()

                    // Stop metronome and haptics when leaving
                    metronome.stop()
                    haptics.isEnabled = false

                    dismiss()
                }
            )
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
        .environment(sre)
        .environment(metronome)
        .environment(haptics)
        .environment(settings)
        .environment(referenceService)
}
