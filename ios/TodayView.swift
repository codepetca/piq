import SwiftUI

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
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Active session indicator (if in progress)
                    if let vm = viewModel, vm.hasActiveSession {
                        activeSessionBanner(statusText: vm.activeSessionStatusText)
                    }

                    // Block list
                    VStack(spacing: 8) {
                        ForEach(todayBlocks) { block in
                            BlockRow(block: block)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
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
                                    .frame(width: 64, height: 64)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                    )
                                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                            }
                        } else {
                            Button(action: startSession) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 64, height: 64)
                                    .background(
                                        Circle()
                                            .fill(Color.accentColor)
                                    )
                                    .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
                            }
                        }

                        HStack {
                            Spacer()
                            Text("\(totalTargetMinutes) min")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.accentColor)
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .padding(.vertical, 8)
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
            }
            .fullScreenCover(isPresented: $showingSession) {
                PracticeSessionView()
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
        viewModel?.todayBlocks ?? []
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
        viewModel?.startSession()
        showingSession = true
    }

    private func resumeSession() {
        showingSession = true
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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let sre = SpacedRepetitionEngine()
    sre.loadSeedCatalog()
    return TodayView()
        .environment(sre)
        .environment(PracticeEngine())
}
