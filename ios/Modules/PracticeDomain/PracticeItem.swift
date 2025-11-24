import Foundation

/// Represents a single item that can be scheduled for practice using spaced repetition.
/// Examples: a specific scale, chord progression, song section, or technique exercise.
struct PracticeItem: Identifiable, Codable, Equatable {
    let id: UUID

    /// The type of block this item belongs to
    let kind: PracticeBlockKind

    /// Short title for the item (e.g., "Am Pentatonic")
    let title: String

    /// Optional detail (e.g., "Position 1")
    let detail: String

    /// Musical key if applicable (e.g., "Am")
    let key: String?

    /// Reference ID for diagram/media (e.g., "scale_am_pentatonic_pos1")
    let referenceID: String?

    /// Target practice duration in minutes
    let targetMinutes: Int

    // MARK: - Spaced Repetition State

    /// Next date this item is due for practice
    var dueDate: Date

    /// Current interval in days between reviews (starts at 1)
    var intervalDays: Double

    /// Ease factor for SM-2 algorithm (starts at 2.5, min 1.3)
    var easeFactor: Double

    /// Number of times this item has been reviewed
    var reviewCount: Int

    /// Number of consecutive correct reviews (resets on Hard)
    var consecutiveCorrect: Int

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        kind: PracticeBlockKind,
        title: String,
        detail: String = "",
        key: String? = nil,
        referenceID: String? = nil,
        targetMinutes: Int? = nil,
        dueDate: Date = Date(),
        intervalDays: Double = 1.0,
        easeFactor: Double = 2.5,
        reviewCount: Int = 0,
        consecutiveCorrect: Int = 0
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.key = key
        self.referenceID = referenceID
        self.targetMinutes = targetMinutes ?? kind.defaultMinutes
        self.dueDate = dueDate
        self.intervalDays = intervalDays
        self.easeFactor = easeFactor
        self.reviewCount = reviewCount
        self.consecutiveCorrect = consecutiveCorrect
    }

    // MARK: - Computed Properties

    /// Whether this item is due for practice (due date is today or earlier)
    var isDue: Bool {
        dueDate <= Date()
    }

    /// Whether this item is new (never reviewed)
    var isNew: Bool {
        reviewCount == 0
    }
}

// MARK: - Factory Methods

extension PracticeItem {
    /// Creates a demo set of practice items for testing
    static func makeDemoItems() -> [PracticeItem] {
        [
            // Warmup items
            PracticeItem(
                kind: .warmup,
                title: "Chromatic Warm-Up",
                detail: "All positions",
                referenceID: "warmup_chromatic"
            ),
            PracticeItem(
                kind: .warmup,
                title: "Spider Exercise",
                detail: "Frets 1-4",
                referenceID: "warmup_spider"
            ),

            // Song items
            PracticeItem(
                kind: .song,
                title: "Nothing Else Matters",
                detail: "Intro & Verse",
                key: "Em"
            ),
            PracticeItem(
                kind: .song,
                title: "Wonderwall",
                detail: "Full song",
                key: "Em"
            ),

            // Solo items
            PracticeItem(
                kind: .solo,
                title: "Am Pentatonic",
                detail: "Position 1",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos1"
            ),
            PracticeItem(
                kind: .solo,
                title: "Blues Licks",
                detail: "Box 1",
                key: "Am",
                referenceID: "licks_blues_box1"
            ),

            // Technique items
            PracticeItem(
                kind: .techniqueOrTheory,
                title: "Alternate Picking",
                detail: "16th notes",
                referenceID: "technique_alt_picking"
            ),
            PracticeItem(
                kind: .techniqueOrTheory,
                title: "Chord Transitions",
                detail: "Am-G-C-D",
                referenceID: "technique_chord_transitions"
            )
        ]
    }
}
