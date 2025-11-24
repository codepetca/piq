import UIKit
import Observation

/// Service for haptic feedback throughout the app.
@Observable
final class HapticService {

    // MARK: - Properties

    var isEnabled: Bool = true

    // MARK: - Feedback Generators

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    // MARK: - Initialization

    init() {
        // Prepare generators for lower latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    // MARK: - Haptic Methods

    /// Light impact for button taps
    func tap() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }

    /// Medium impact for significant actions
    func impact() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
    }

    /// Heavy impact for important events
    func heavyImpact() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }

    /// Success notification (session complete, etc.)
    func success() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }

    /// Warning notification
    func warning() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    /// Error notification
    func error() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }

    /// Selection changed feedback
    func selectionChanged() {
        guard isEnabled else { return }
        selection.selectionChanged()
    }

    // MARK: - Convenience Methods

    /// Feedback for Easy rating
    func feedbackEasy() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }

    /// Feedback for Good rating
    func feedbackGood() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
    }

    /// Feedback for Hard rating
    func feedbackHard() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }
}
