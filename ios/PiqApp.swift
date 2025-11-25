import SwiftUI

@main
struct PiqApp: App {
    @State private var practiceEngine = PracticeEngine()
    @State private var spacedRepetitionEngine = SpacedRepetitionEngine()
    @State private var historyViewModel = HistoryViewModel()
    @State private var metronomeService = MetronomeService()
    @State private var hapticService = HapticService()
    @State private var settingsViewModel: SettingsViewModel?
    @State private var referenceService = PracticeReferenceService()

    private let storage = PracticeStorage()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(practiceEngine)
                .environment(spacedRepetitionEngine)
                .environment(historyViewModel)
                .environment(metronomeService)
                .environment(hapticService)
                .environment(settingsViewModel ?? SettingsViewModel())
                .environment(referenceService)
                .onAppear {
                    loadInitialData()
                    setupSessionCompletionHandler()
                    // Initialize settings with dependencies
                    settingsViewModel = SettingsViewModel(
                        historyViewModel: historyViewModel,
                        sre: spacedRepetitionEngine
                    )
                }
        }
    }

    private func loadInitialData() {
        // Load saved items or use demo items on first run
        let savedItems = storage.loadItems()
        if savedItems.isEmpty {
            spacedRepetitionEngine.loadSeedCatalog()
            storage.saveItems(spacedRepetitionEngine.items)
        } else {
            for item in savedItems {
                spacedRepetitionEngine.addItem(item)
            }
        }
    }

    /// Sets up automatic session persistence when a session completes.
    private func setupSessionCompletionHandler() {
        practiceEngine.onSessionFinished = { [self] session in
            // Save completed session to history
            historyViewModel.addSession(session)

            // Apply feedback from blocks to SRE
            spacedRepetitionEngine.applyFeedback(for: session.blocks)

            // Persist updated SRE items
            storage.saveItems(spacedRepetitionEngine.items)
        }
    }
}
