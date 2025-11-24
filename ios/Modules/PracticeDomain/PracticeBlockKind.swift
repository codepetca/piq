import Foundation

/// The four block types in a piq practice session.
enum PracticeBlockKind: String, CaseIterable, Codable {
    case warmup
    case song
    case solo
    case techniqueOrTheory

    /// Short display name for UI.
    var displayName: String {
        switch self {
        case .warmup:
            return "Warm-Up"
        case .song:
            return "Song"
        case .solo:
            return "Solo"
        case .techniqueOrTheory:
            return "Technique"
        }
    }

    /// Default duration in minutes for this block type.
    var defaultMinutes: Int {
        switch self {
        case .warmup:
            return 10
        case .song:
            return 10
        case .solo:
            return 10
        case .techniqueOrTheory:
            return 10
        }
    }

    /// Whether metronome should be on by default for this block type.
    var defaultMetronomeOn: Bool {
        switch self {
        case .warmup:
            return true
        case .song:
            return false
        case .solo:
            return false
        case .techniqueOrTheory:
            return true
        }
    }
}
