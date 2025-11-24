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
        let storage = PracticeStorage()
        let savedItems = storage.loadItems()
        if savedItems.isEmpty {
            spacedRepetitionEngine.loadDemoItems()
            storage.saveItems(spacedRepetitionEngine.items)
        } else {
            for item in savedItems {
                spacedRepetitionEngine.addItem(item)
            }
        }
    }
}
