import Foundation

enum PracticeItemCategory: String, CaseIterable, Codable {
    case warmup
    case fretboard
    case repertoire
    case songwork
    case soloing
    case technique
    case theory
    case rhythm
    case chords
    case ear_training
    case musicality

    var displayName: String {
        switch self {
        case .warmup: return "Warm-Up"
        case .fretboard: return "Fretboard"
        case .repertoire: return "Repertoire"
        case .songwork: return "Song"
        case .soloing: return "Soloing"
        case .technique: return "Technique"
        case .theory: return "Theory"
        case .rhythm: return "Rhythm"
        case .chords: return "Chords"
        case .ear_training: return "Ear Training"
        case .musicality: return "Musicality"
        }
    }

    var blockKind: PracticeBlockKind {
        switch self {
        case .warmup, .fretboard, .ear_training:
            return .warmup
        case .songwork, .repertoire:
            return .song
        case .soloing, .musicality:
            return .solo
        case .technique, .theory, .rhythm, .chords:
            return .techniqueOrTheory
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .warmup: return 3
        case .fretboard: return 3
        case .repertoire: return 6
        case .songwork: return 6
        case .soloing: return 5
        case .technique: return 4
        case .theory: return 4
        case .rhythm: return 4
        case .chords: return 4
        case .ear_training: return 3
        case .musicality: return 5
        }
    }
    
    /// Default starting BPM for new items in this category.
    /// Conservative starting points for gradual tempo progression.
    var defaultBPM: Int {
        switch self {
        case .warmup: return 60
        case .fretboard: return 50
        case .repertoire: return 100
        case .songwork: return 100
        case .soloing: return 80
        case .technique: return 70
        case .theory: return 60
        case .rhythm: return 85
        case .chords: return 80
        case .ear_training: return 60
        case .musicality: return 80
        }
    }
}
