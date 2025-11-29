import SwiftUI

/// TodayView displays today's practice blocks (6-8 microblocks) and allows starting a session.
///
/// Design decisions:
/// - TodayView stays thin: it binds to TodayViewModel for all business logic.
/// - Session blocks are refreshed on appear only when no active session exists.
/// - Reordered/removed blocks are honored when starting a session.
/// - Active session lifecycle: If a session is in progress, shows a resume option
///   instead of allowing a new session to be started (prevents duplicates).
/// - PracticeEngine remains the owner of session state.
struct TodayView: View {
    @Environment(SpacedRepetitionEngine.self) private var sre
    @Environment(PracticeEngine.self) private var engine
    @State private var viewModel: TodayViewModel?
    @State private var showingSession = false
    @State private var blocks: [PracticeBlock] = []
    @State private var editMode: EditMode = .inactive
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            if todayBlocks.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(todayBlocks) { block in
                        BlockRow(block: block)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    removeBlock(block)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0.15, pressing: { isPressing in
                                withAnimation(.easeInOut(duration: 0.12)) {
                                    editMode = isPressing ? .active : .inactive
                                }
                            }, perform: {})
                    }
                    .onMove(perform: moveBlocks)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, $editMode)
            }
            .safeAreaInset(edge: .bottom) {
                // Start or resume session button (fixed at bottom)
                if let vm = viewModel {
                    ZStack {
                        if vm.hasActiveSession {
                            Button(action: resumeSession) {
                                Text("Resume")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 76, height: 76)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                    )
                                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                                    .offset(y: -4)
                            }
                        } else {
                            Button(action: startSession) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 76, height: 76)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                    )
                                    .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                                    .offset(y: -4)
                            }
                        }

                        HStack {
                            Spacer()
                            AlarmBadgeView(minutes: totalTargetMinutes, size: 48, tint: .primary)
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 36)
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .padding(.vertical, 6)
                    .padding(.bottom, 4)
                    .background(.regularMaterial)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onMenuTap?() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .regular))
                    }
                }
            }
            .onAppear {
                initializeViewModelIfNeeded()
                // Only refresh blocks if there's no active session
                // This prevents overwriting blocks when resuming
                if !(viewModel?.hasActiveSession ?? false) {
                    viewModel?.refreshBlocks()
                }
                blocks = viewModel?.todayBlocks ?? []
            }
            .fullScreenCover(isPresented: $showingSession) {
                PracticeSessionView()
            }
            .onChange(of: blocks) { _, newValue in
                viewModel?.setTodayBlocks(newValue)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "guitars")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No practice blocks")
                .font(.title3)
                .fontWeight(.medium)

            Text("Pull to refresh or check your settings")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var todayBlocks: [PracticeBlock] {
        blocks
    }

    private var totalTargetMinutes: Int {
        todayBlocks.reduce(0) { $0 + $1.targetMinutes }
    }

    // MARK: - Actions

    private func initializeViewModelIfNeeded() {
        if viewModel == nil {
            viewModel = TodayViewModel(sre: sre, engine: engine)
        }
    }

    private func startSession() {
        let blocksToUse = todayBlocks.isEmpty ? viewModel?.todayBlocks ?? [] : todayBlocks
        guard !blocksToUse.isEmpty else { return }
        viewModel?.startSession(with: blocksToUse)
        showingSession = true
    }

    private func resumeSession() {
        showingSession = true
    }

    private func removeBlock(_ block: PracticeBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks.remove(at: index)
    }

    private func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        viewModel?.setTodayBlocks(blocks)
        withAnimation(.easeInOut(duration: 0.15)) {
            editMode = .inactive
        }
    }
}

// MARK: - Block Row Component

struct BlockRow: View {
    let block: PracticeBlock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(block.title)
                    .font(.headline)
                if !block.detail.isEmpty {
                    Text(block.detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            AlarmBadgeView(minutes: block.targetMinutes, size: 32, tint: .primary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Alarm Badge Preview Helper

struct AlarmBadgeView: View {
    let minutes: Int
    var size: CGFloat = 48
    var tint: Color = .primary

    private var bellWidth: CGFloat { size * 0.24 }
    private var bellHeight: CGFloat { size * 0.1 }
    private var bellOffsetY: CGFloat { -size * 0.4 }
    private var footSize: CGFloat { size * 0.12 }
    private var footOffsetY: CGFloat { size * 0.42 }
    private var faceStrokeWidth: CGFloat { max(2, size * 0.05) }
    private var textSize: CGFloat { size * 0.35 }

    var body: some View {
        ZStack {
            // face
            Circle()
                .strokeBorder(tint, lineWidth: faceStrokeWidth)
                .background(Circle().fill(Color(.systemBackground)))
                .frame(width: size, height: size)

            // feet
            HStack(spacing: size * 0.4) {
                Rectangle().frame(width: footSize, height: footSize)
                Rectangle().frame(width: footSize, height: footSize)
            }
            .foregroundStyle(tint)
            .offset(y: footOffsetY)

            // minutes
            Text("\(minutes)")
                .font(.system(size: textSize, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Previews

private struct TodayPreviewContainer: View {
    private let sre: SpacedRepetitionEngine = {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog()
        return engine
    }()

    private let practiceEngine = PracticeEngine()

    var body: some View {
        VStack(spacing: 24) {
            TodayView()
                .environment(sre)
                .environment(practiceEngine)

            AlarmBadgeView(minutes: 10)
            AlarmBadgeView(minutes: 24)
                .foregroundStyle(Color.accentColor)
        }
        .padding()
    }
}

#Preview {
    TodayPreviewContainer()
}
