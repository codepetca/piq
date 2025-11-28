import SwiftUI
import UniformTypeIdentifiers

/// TodayView displays today's practice blocks and allows starting a session.
///
/// Design decisions (per Issue #004 requirements):
/// - TodayView stays thin: it binds to TodayViewModel for all business logic.
/// - Session blocks are refreshed on appear to ensure fresh SRE state.
/// - Active session lifecycle: If a session is in progress, shows a resume option
///   instead of allowing a new session to be started (prevents duplicates).
/// - PracticeEngine remains the owner of session state.
struct TodayView: View {
    @Environment(SpacedRepetitionEngine.self) private var sre
    @Environment(PracticeEngine.self) private var engine
    @State private var viewModel: TodayViewModel?
    @State private var showingSession = false
    @State private var blocks: [PracticeBlock] = []
    @State private var draggingBlock: PracticeBlock?
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            List {
                // Active session indicator (if in progress)
                if let vm = viewModel, vm.hasActiveSession {
                    activeSessionBanner(statusText: vm.activeSessionStatusText)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                }

                ForEach(todayBlocks) { block in
                    BlockRow(block: block)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                removeBlock(block)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .onDrag {
                            draggingBlock = block
                            return NSItemProvider(object: block.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: BlockDropDelegate(
                                item: block,
                                items: $blocks,
                                dragging: $draggingBlock
                            )
                        )
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
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
                            Text("\(totalTargetMinutes) min")
                                .font(.callout.weight(.semibold))
                                .foregroundColor(.accentColor)
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
                    }
                }
            }
            .onAppear {
                initializeViewModelIfNeeded()
                viewModel?.refreshBlocks()
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

    // MARK: - Subviews

    @ViewBuilder
    private func activeSessionBanner(statusText: String?) -> some View {
        HStack {
            Image(systemName: "play.circle.fill")
                .foregroundColor(.accentColor)
            Text(statusText ?? "Session in progress")
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
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

            Text("\(block.targetMinutes) min")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Drop Delegate

private struct BlockDropDelegate: DropDelegate {
    let item: PracticeBlock
    @Binding var items: [PracticeBlock]
    @Binding var dragging: PracticeBlock?

    func dropEntered(info: DropInfo) {
        guard let dragging,
              dragging.id != item.id,
              let fromIndex = items.firstIndex(where: { $0.id == dragging.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }) else { return }

        withAnimation(.easeInOut(duration: 0.15)) {
            items.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }
}

#Preview {
    let sre = SpacedRepetitionEngine()
    sre.loadSeedCatalog()
    return TodayView()
        .environment(sre)
        .environment(PracticeEngine())
}
