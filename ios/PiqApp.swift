import SwiftUI

@main
struct PiqApp: App {
    @State private var practiceEngine = PracticeEngine()
    @State private var spacedRepetitionEngine = SpacedRepetitionEngine()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(practiceEngine)
                .environment(spacedRepetitionEngine)
                .onAppear {
                    loadInitialData()
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
