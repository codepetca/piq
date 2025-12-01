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
    @Environment(TodayViewModel.self) private var viewModel
    @State private var showingSession = false
    @State private var blocks: [PracticeBlock] = []
    @State private var editMode: EditMode = .inactive
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                content
                bottomActionBar
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
                    // Only refresh blocks if there's no active session and not in completion state
                    // This prevents overwriting blocks when resuming or showing completion
                    if !viewModel.hasActiveSession && !viewModel.sessionJustCompleted {
                        viewModel.refreshBlocks()
                    }
                    blocks = viewModel.todayBlocks
                }
                .fullScreenCover(isPresented: $showingSession) {
                    PracticeSessionView()
                }
                .onChange(of: blocks) { _, newValue in
                    viewModel.setTodayBlocks(newValue)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.sessionJustCompleted {
            completionStateView
        } else if todayBlocks.isEmpty {
            emptyStateView
        } else {
            blockList
        }
    }

    private var completionStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("All done today!")
                .font(.title)
                .fontWeight(.medium)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var blockList: some View {
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

    @ViewBuilder
    private var bottomActionBar: some View {
        // Start, resume, or generate new session button (fixed at bottom)
        ZStack {
            if viewModel.hasActiveSession {
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
            } else if viewModel.sessionJustCompleted {
                Button(action: generateNewSession) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 76, height: 76)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                        .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 4)
                        .offset(y: -4)
                        .modifier(ShimmerEffect())
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

            // Hide alarm badge in completion state
            if !viewModel.sessionJustCompleted {
                HStack {
                    Spacer()
                    AlarmBadgeView(minutes: totalTargetMinutes, size: 48, tint: .primary)
                }
                .padding(.leading, 16)
                .padding(.trailing, 36)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(.vertical, 6)
        .padding(.bottom, 4)
        .background(.regularMaterial)
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

    private func startSession() {
        let blocksToUse = todayBlocks.isEmpty ? viewModel.todayBlocks : todayBlocks
        guard !blocksToUse.isEmpty else { return }
        viewModel.startSession(with: blocksToUse)
        showingSession = true
    }

    private func resumeSession() {
        showingSession = true
    }

    private func generateNewSession() {
        viewModel.generateNewSession()
        blocks = viewModel.todayBlocks
    }

    private func removeBlock(_ block: PracticeBlock) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks.remove(at: index)
    }

    private func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        viewModel.setTodayBlocks(blocks)
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

    private var faceStrokeWidth: CGFloat { max(2, size * 0.05) }
    private var textSize: CGFloat { size * 0.35 }
    private var topCapSize: CGSize { CGSize(width: size * 0.24, height: size * 0.06) }
    private var topStemSize: CGSize { CGSize(width: size * 0.12, height: size * 0.08) }
    private var topOffsetY: CGFloat { -size * 0.56 }
    private var sideNubSize: CGFloat { size * 0.12 }
    private var sideNubOffset: CGSize { CGSize(width: size * 0.42, height: -size * 0.36) }

    var body: some View {
        ZStack {
            // face
            Circle()
                .strokeBorder(tint, lineWidth: faceStrokeWidth)
                .background(Circle().fill(Color(.systemBackground)))
                .frame(width: size, height: size)

            // top stem and cap to mimic a stopwatch
            VStack(spacing: size * 0.02) {
                RoundedRectangle(cornerRadius: size * 0.02)
                    .frame(width: topCapSize.width, height: topCapSize.height)
                RoundedRectangle(cornerRadius: size * 0.02)
                    .frame(width: topStemSize.width, height: topStemSize.height)
            }
            .foregroundStyle(tint)
            .offset(y: topOffsetY)

            // side nub (start/stop button) at ~1 o'clock, outside the circle
            Circle()
                .fill(tint)
                .frame(width: sideNubSize, height: sideNubSize)
                .offset(x: sideNubOffset.width, y: sideNubOffset.height)

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

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .opacity(0.8 + 0.2 * CGFloat(sin(phase)))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    phase = .pi * 2
                }
            }
    }
}

#Preview {
    TodayPreviewContainer()
}
