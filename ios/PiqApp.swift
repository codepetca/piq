import SwiftUI

@main
struct PiqApp: App {
    @State private var practiceEngine = PracticeEngine()
    @State private var spacedRepetitionEngine = SpacedRepetitionEngine()
    @State private var historyViewModel = HistoryViewModel()
    @State private var metronomeService = MetronomeService()
    @State private var hapticService = HapticService()
    @State private var settingsViewModel: SettingsViewModel?
    @State private var todayViewModel: TodayViewModel?
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
                .environment(todayViewModel ?? TodayViewModel(sre: spacedRepetitionEngine, engine: practiceEngine))
                .environment(referenceService)
                .onAppear {
                    loadInitialData()
                    applyUserPreferences()
                    setupSessionCompletionHandler()
                    // Initialize settings and today view models with dependencies
                    settingsViewModel = SettingsViewModel(
                        historyViewModel: historyViewModel,
                        sre: spacedRepetitionEngine
                    )
                    todayViewModel = TodayViewModel(
                        sre: spacedRepetitionEngine,
                        engine: practiceEngine
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

    /// Apply user preferences from onboarding to services.
    private func applyUserPreferences() {
        let preferences = storage.loadPreferences()

        // Apply haptic preference - directly controls haptic feedback
        hapticService.isEnabled = preferences.cuePreference.hapticEnabled

        // Note: Metronome preference (metronomeEnabled) is applied at the UI level
        // when starting practice blocks, not as a global service setting.
        // The MetronomeService is started/stopped per-block based on user interaction.
    }

    /// Sets up automatic session persistence when a session completes.
    private func setupSessionCompletionHandler() {
        practiceEngine.onSessionFinished = { [self] session in
            // Save completed session to history
            historyViewModel.addSession(session)

            // Apply feedback from blocks to SRE
            spacedRepetitionEngine.applyFeedback(for: session.blocks)

            // Apply tempo learning from completed blocks
            spacedRepetitionEngine.applyTempoLearning(for: session.blocks)

            // Persist updated SRE items (includes both SRS and tempo state)
            storage.saveItems(spacedRepetitionEngine.items)
        }
    }
}
