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
    static func makeTodayDemo() -> PracticeSession {
        let items = PracticeItemCatalog.seedItems()
        var blocks: [PracticeBlock] = []

        for item in items.prefix(4) {
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

    /// Creates a preview session for onboarding based on user preferences.
    /// Demonstrates the session structure and adapts block count based on level.
    static func makeOnboardingPreview(for preferences: UserPreferences) -> PracticeSession {
        let items = PracticeItemCatalog.seedItems()

        // Determine block count based on level
        let blockCount: Int
        switch preferences.level {
        case .beginner: blockCount = 6
        case .intermediate: blockCount = 7
        case .advanced: blockCount = 8
        }

        // Select items, ensuring warmup first and varied middle
        var blocks: [PracticeBlock] = []
        let selectedItems = Array(items.prefix(blockCount))

        for item in selectedItems {
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

    /// Standard block order for a session.
    static let standardBlockOrder: [PracticeBlockKind] = [
        .warmup,
        .song,
        .solo,
        .techniqueOrTheory
    ]
}
