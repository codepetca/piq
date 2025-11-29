import Foundation
import Observation

/// ViewModel for managing app settings and user preferences.
@Observable
final class SettingsViewModel {

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let defaultBPM = "settings.defaultBPM"
        static let hapticFeedback = "settings.hapticFeedback"
    }

    // MARK: - Properties

    /// Default BPM for metronome (40-240)
    var defaultBPM: Int {
        didSet {
            let clamped = max(40, min(240, defaultBPM))
            UserDefaults.standard.set(clamped, forKey: Keys.defaultBPM)
        }
    }

    /// Whether haptic feedback is enabled
    var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedback)
        }
    }

    // MARK: - Computed Properties

    /// App version string
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Dependencies

    private let storage: PracticeStorage
    private let historyViewModel: HistoryViewModel?
    private let sre: SpacedRepetitionEngine?

    // MARK: - Initialization

    init(
        storage: PracticeStorage = PracticeStorage(),
        historyViewModel: HistoryViewModel? = nil,
        sre: SpacedRepetitionEngine? = nil
    ) {
        self.storage = storage
        self.historyViewModel = historyViewModel
        self.sre = sre

        // Load saved preferences or use defaults
        let savedBPM = UserDefaults.standard.integer(forKey: Keys.defaultBPM)
        self.defaultBPM = savedBPM > 0 ? savedBPM : 120

        self.hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: Keys.hapticFeedback)

        // Default haptic to true if not set
        if !UserDefaults.standard.bool(forKey: Keys.hapticFeedback) &&
           UserDefaults.standard.object(forKey: Keys.hapticFeedback) == nil {
            self.hapticFeedbackEnabled = true
        }
    }

    // MARK: - Actions

    /// Clear all practice history
    func clearHistory() {
        storage.saveSessions([])
        historyViewModel?.loadSessions()
    }

    /// Reset all SRE items to initial state
    func resetProgress() {
        sre?.loadSeedCatalog()
        if let items = sre?.items {
            storage.saveItems(items)
        }
    }

    /// Clear all data (history + progress)
    func clearAllData() {
        storage.clearAll()
        sre?.loadSeedCatalog()
        historyViewModel?.loadSessions()
    }

    /// Reset onboarding state to show the onboarding flow again.
    func resetOnboarding() {
        storage.resetOnboarding()
    }

    /// Total practice sessions count
    var totalSessions: Int {
        storage.loadSessions().count
    }

    /// Total practice items count
    var totalItems: Int {
        storage.loadItems().count
    }
}
