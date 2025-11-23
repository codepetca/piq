import Foundation

/// User feedback after completing a practice block.
/// Used for spaced repetition scheduling.
enum PracticeBlockFeedback: String, Codable, CaseIterable {
    case easy
    case good
    case hard

    /// Display name for UI.
    var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .good:
            return "Good"
        case .hard:
            return "Hard"
        }
    }
}
