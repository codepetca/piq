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
    /// Creates a demo session for today using the seed catalog.
    static func makeTodayDemo() -> PracticeSession {
        let items = PracticeItemCatalog.seedItems()
        let blocks = items.prefix(4).map { item in
            PracticeBlock(
                kind: item.blockKind,
                title: item.title,
                detail: item.detail,
                targetMinutes: item.targetMinutes,
                key: item.key,
                practiceItemID: item.id,
                referenceID: item.referenceID
            )
        }

        return PracticeSession(blocks: Array(blocks))
    }

    /// Standard block order for a session.
    static let standardBlockOrder: [PracticeBlockKind] = [
        .warmup,
        .song,
        .solo,
        .techniqueOrTheory
    ]
}
