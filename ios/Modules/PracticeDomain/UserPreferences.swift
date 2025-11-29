import Foundation

// MARK: - User Level

/// User's skill level for practice difficulty.
enum UserLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var displayName: String {
        switch self {
        case .beginner: return "Beginner+"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

// MARK: - Music Style

/// Music styles the user is interested in practicing.
enum MusicStyle: String, CaseIterable, Codable {
    case rock = "rock"
    case pop = "pop"
    case blues = "blues"
    case rnb = "rnb"
    case worship = "worship"

    var displayName: String {
        switch self {
        case .rock: return "Rock"
        case .pop: return "Pop"
        case .blues: return "Blues"
        case .rnb: return "R&B"
        case .worship: return "Worship"
        }
    }
}

// MARK: - Cue Preference

/// User's preference for feedback cues during practice.
enum CuePreference: String, CaseIterable, Codable {
    case soundAndVibration = "soundAndVibration"
    case vibrationOnly = "vibrationOnly"
    case silent = "silent"

    var displayName: String {
        switch self {
        case .soundAndVibration: return "Sound + Vibration"
        case .vibrationOnly: return "Vibration only"
        case .silent: return "Silent"
        }
    }

    /// Descriptive text explaining what this cue preference means.
    var description: String {
        switch self {
        case .soundAndVibration: return "Metronome clicks and haptic feedback"
        case .vibrationOnly: return "Silent metronome with haptics"
        case .silent: return "Visual cues only"
        }
    }

    /// Whether metronome sound should be enabled by default.
    var metronomeEnabled: Bool {
        switch self {
        case .soundAndVibration: return true
        case .vibrationOnly: return false
        case .silent: return false
        }
    }

    /// Whether haptic feedback should be enabled.
    var hapticEnabled: Bool {
        switch self {
        case .soundAndVibration: return true
        case .vibrationOnly: return true
        case .silent: return false
        }
    }
}

// MARK: - User Preferences

/// User preferences collected during onboarding and stored for session generation.
struct UserPreferences: Codable, Equatable {
    var level: UserLevel
    var styles: [MusicStyle]
    var cuePreference: CuePreference
    var hasCompletedOnboarding: Bool

    init(
        level: UserLevel = .beginner,
        styles: [MusicStyle] = [],
        cuePreference: CuePreference = .soundAndVibration,
        hasCompletedOnboarding: Bool = false
    ) {
        self.level = level
        self.styles = styles
        self.cuePreference = cuePreference
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    /// Default preferences for a first-time user.
    static let `default` = UserPreferences()
}
