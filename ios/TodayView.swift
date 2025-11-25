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

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Active session indicator (if in progress)
                if let vm = viewModel, vm.hasActiveSession {
                    activeSessionBanner(statusText: vm.activeSessionStatusText)
                }

                // Block list
                VStack(spacing: 12) {
                    ForEach(todayBlocks) { block in
                        BlockRow(block: block)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Start or resume session button
                if let vm = viewModel {
                    if vm.hasActiveSession {
                        Button(action: resumeSession) {
                            Text("Resume Session")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    } else {
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
                }
            }
            .padding(.top)
            .navigationTitle("Today")
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
