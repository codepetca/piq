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
        }
    }

    var blockKind: PracticeBlockKind {
        switch self {
        case .warmup, .fretboard:
            return .warmup
        case .songwork, .repertoire:
            return .song
        case .soloing:
            return .solo
        case .technique, .theory, .rhythm, .chords:
            return .techniqueOrTheory
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .warmup: return 4
        case .fretboard: return 3
        case .repertoire: return 12
        case .songwork: return 15
        case .soloing: return 10
        case .technique: return 5
        case .theory: return 6
        case .rhythm: return 6
        case .chords: return 5
        }
    }
}
