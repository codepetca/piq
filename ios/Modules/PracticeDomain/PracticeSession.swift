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
    /// Generates 6-8 microblocks (~30–40 min) with warmup first, interleaved middle, fun ending.
    static func makeTodayDemo() -> PracticeSession {
        let items = PracticeItemCatalog.seedItems()
        let smartJamService = SmartJamService()
        let targetTotalMinutes = 35
        let minTotalMinutes = 30
        let maxTotalMinutes = 40
        let minBlocks = 6
        let maxBlocks = 8
        var blocks: [PracticeBlock] = []

        // Select warmup first (single warmup block)
        let warmupItem = items.first { $0.blockKind == .warmup }

        // Select fun ending (songwork or repertoire)
        let funItem = items.first { $0.category == .songwork }
            ?? items.first { $0.category == .repertoire }

        // Select middle items (interleaved categories, excluding warmup-kind and fun ending)
        let excludedIDs = Set([warmupItem?.id, funItem?.id].compactMap { $0 })
        var middlePool = items.filter {
            !excludedIDs.contains($0.id) && $0.blockKind != .warmup
        }

        var middleItems: [PracticeItem] = []
        var lastCategory: PracticeItemCategory?
        var currentTotal = (warmupItem?.targetMinutes ?? 0) + (funItem?.targetMinutes ?? 0)
        let minMiddleCount = max(minBlocks - 2, 0)
        let maxMiddleCount = maxBlocks - 2

        while !middlePool.isEmpty && middleItems.count < maxMiddleCount {
            // Pick an item that interleaves categories when possible
            let nextIndex = middlePool.firstIndex { $0.category != lastCategory } ?? middlePool.startIndex
            let candidate = middlePool.remove(at: nextIndex)

            let projectedTotal = currentTotal + candidate.targetMinutes
            // If adding this would exceed max total and we already satisfy min middle count, stop
            if projectedTotal > maxTotalMinutes && middleItems.count >= minMiddleCount {
                break
            }

            middleItems.append(candidate)
            lastCategory = candidate.category
            currentTotal = projectedTotal

            // Stop early if we hit budget and minimum count
            if currentTotal >= targetTotalMinutes && middleItems.count >= minMiddleCount {
                break
            }
        }

        // If we're still under minimum time, add more items (even if same category) until we reach bounds or max count
        while currentTotal < minTotalMinutes,
              middleItems.count < maxMiddleCount,
              let candidate = middlePool.first {
            middlePool.removeFirst()
            let projectedTotal = currentTotal + candidate.targetMinutes
            if projectedTotal > maxTotalMinutes { break }
            middleItems.append(candidate)
            currentTotal = projectedTotal
        }

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
                smartJamConfig: SmartJamCategoryMapper.category(for: item.blockKind).flatMap {
                    smartJamService.makeConfig(
                        targetKey: item.key,
                        targetBPM: TempoEngine.suggestedBPM(for: item),
                        preferredStyles: [],
                        category: $0
                    )
                },
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
        let smartJamService = SmartJamService()

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
                smartJamConfig: SmartJamCategoryMapper.category(for: item.blockKind).flatMap {
                    smartJamService.makeConfig(
                        targetKey: item.key,
                        targetBPM: TempoEngine.suggestedBPM(for: item),
                        preferredStyles: preferences.styles,
                        category: $0
                    )
                },
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
