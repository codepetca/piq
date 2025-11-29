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

    /// Motivational prompt for the session.
    var sessionPrompt: String {
        let prompts = [
            "Short bursts beat long grinds. Keep moving.",
            "Perfect practice > long practice. Quality over duration.",
            "All sections max 5 minutes. Rotate quickly, stay focused.",
            "Tension kills speed. Stay relaxed.",
            "Every note matters. Super slow, perfect tone."
        ]

        // Use session ID hash to deterministically select a prompt
        let index = abs(id.hashValue) % prompts.count
        return prompts[index]
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
    /// Generates 6-8 microblocks (~25–45 min) with warmup first, interleaved middle, fun ending.
    static func makeTodayDemo() -> PracticeSession {
        let items = PracticeItemCatalog.seedItems()
        var blocks: [PracticeBlock] = []

        // Select warmup first
        let warmupItem = items.first { $0.category == .warmup }
        // Select fun ending (songwork or repertoire)
        let funItem = items.first { $0.category == .songwork }
            ?? items.first { $0.category == .repertoire }
        // Select middle items (interleaved categories, excluding warmup and fun ending)
        let excludedIDs = Set([warmupItem?.id, funItem?.id].compactMap { $0 })
        let middlePool = items.filter { !excludedIDs.contains($0.id) }
        var middleItems: [PracticeItem] = []
        var lastCategory: PracticeItemCategory?
        for item in middlePool {
            if middleItems.count >= 4 { break } // 4 middle blocks
            if item.category != lastCategory {
                middleItems.append(item)
                lastCategory = item.category
            }
        }
        // Fill remaining slots if needed
        for item in middlePool where middleItems.count < 4 && !middleItems.contains(where: { $0.id == item.id }) {
            middleItems.append(item)
        }

        // Assemble session: warmup + middle + fun ending = 6 blocks minimum
        var sessionItems: [PracticeItem] = []
        if let warmup = warmupItem { sessionItems.append(warmup) }
        sessionItems.append(contentsOf: middleItems)
        if let fun = funItem { sessionItems.append(fun) }

        for item in sessionItems {
            let (instructions, focusCue, _) = item.selectInstructionsForDisplay()

            let block = PracticeBlock(
                kind: item.blockKind,
                title: item.title,
                detail: item.detail,
                targetMinutes: item.targetMinutes,
                key: item.key,
                practiceItemID: item.id,
                referenceID: item.referenceID,
                instructions: instructions,
                focusCue: focusCue
            )
            blocks.append(block)
        }

        return PracticeSession(blocks: blocks)
    }

    /// Standard block order for a 6-8 block session.
    /// Structure: warmup first, interleaved middle (technique, solo, song, etc.), fun ending last.
    static let standardBlockOrder: [PracticeBlockKind] = [
        .warmup,
        .techniqueOrTheory,
        .solo,
        .song,
        .techniqueOrTheory,
        .song  // fun ending
    ]
}
