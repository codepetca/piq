import Foundation

/// A complete practice session containing multiple blocks.
struct PracticeSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    var blocks: [PracticeBlock]

    /// Total target minutes for all blocks.
    var totalTargetMinutes: Int {
        blocks.reduce(0) { $0 + $1.targetMinutes }
    }

    /// Total actual minutes practiced (only counts completed blocks).
    var totalActualMinutes: Int {
        blocks.compactMap { $0.actualMinutes }.reduce(0, +)
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        blocks: [PracticeBlock]
    ) {
        self.id = id
        self.date = date
        self.blocks = blocks
    }
}

// MARK: - Factory Methods

extension PracticeSession {
    /// Creates a demo session for today with the standard 4 blocks.
    static func makeTodayDemo() -> PracticeSession {
        let blocks = [
            PracticeBlock(
                kind: .warmup,
                title: "Am pentatonic",
                detail: "Position 1",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos1"
            ),
            PracticeBlock(
                kind: .song,
                title: "Wonderwall",
                detail: "Verse"
            ),
            PracticeBlock(
                kind: .solo,
                title: "Improvise in Am",
                key: "Am"
            ),
            PracticeBlock(
                kind: .techniqueOrTheory,
                title: "Bends",
                referenceID: "tech_bends_basic"
            )
        ]

        return PracticeSession(blocks: blocks)
    }

    /// Standard block order for a session.
    static let standardBlockOrder: [PracticeBlockKind] = [
        .warmup,
        .song,
        .solo,
        .techniqueOrTheory
    ]
}
