import Foundation
import Observation

@Observable
final class SpacedRepetitionEngine {
    private(set) var items: [PracticeItem] = []

    // MARK: - Item Management

    func addItem(_ item: PracticeItem) {
        items.append(item)
    }

    func removeItem(withID id: UUID) {
        items.removeAll { $0.id == id }
    }

    func loadSeedCatalog(now: Date = Date()) {
        items = PracticeItemCatalog.seedItems(now: now)
    }

    // MARK: - Querying

    func dueItems(asOf date: Date = Date()) -> [PracticeItem] {
        items.filter { $0.srs.nextDue <= date }
    }

    func prioritizedItems(asOf date: Date = Date()) -> [PracticeItem] {
        items.sorted { lhs, rhs in
            if lhs.srs.nextDue == rhs.srs.nextDue {
                return lhs.srs.stability < rhs.srs.stability
            }
            return lhs.srs.nextDue < rhs.srs.nextDue
        }
    }

    // MARK: - Feedback Processing

    /// Apply feedback from multiple completed blocks to their associated PracticeItems.
    /// Blocks without practiceItemID or feedback are skipped. Items not found are ignored gracefully.
    func applyFeedback(for blocks: [PracticeBlock], now: Date = Date()) {
        for block in blocks {
            guard let itemID = block.practiceItemID,
                  let feedback = block.feedback else {
                continue
            }
            recordFeedback(forItemID: itemID, feedback: feedback, now: now)
        }
    }

    func recordFeedback(forItemID id: UUID, feedback: PracticeBlockFeedback, now: Date = Date()) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        var item = items[index]
        let stability = item.srs.stability

        let newStability: Double
        switch feedback {
        case .hard:
            newStability = max(1.0, stability * 0.6)
        case .good:
            newStability = max(1.2, stability * 1.15)
        case .easy:
            newStability = stability * 1.5 + 0.5
        }

        let intervalDays: Double
        switch feedback {
        case .hard:
            intervalDays = max(1.0, newStability * 0.8)
        case .good:
            intervalDays = max(1.5, newStability)
        case .easy:
            intervalDays = max(2.0, newStability * 1.25)
        }

        item.srs = SRSState(
            stability: newStability,
            lastPlayed: now,
            nextDue: now.addingTimeInterval(intervalDays * 86_400)
        )

        items[index] = item
    }

    // MARK: - Session Generation

    func generateTodaySession(
        now: Date = Date(),
        targetMinutes: Int = 35,
        minBlocks: Int = 6,
        maxBlocks: Int = 8
    ) -> PracticeSession {

        // 1. Get all available items (SRS prioritized)
        let allItems = prioritizedItems(asOf: now)
        guard !allItems.isEmpty else {
            return PracticeSession(blocks: [])
        }

        // 2. Reserve warmup (ALWAYS first)
        let warmupItem = selectWarmupItem(from: allItems)
        let warmupDuration = warmupItem?.targetMinutes ?? 3

        // 3. Reserve fun ending (ALWAYS last)
        let funItem = selectFunEndingItem(from: allItems, excluding: warmupItem)
        let funDuration = funItem?.targetMinutes ?? 6

        // 4. Calculate middle section budget
        let middleBudget = targetMinutes - warmupDuration - funDuration
        let middleCount = minBlocks - 2  // Reserve slots for warmup + fun

        // 5. Select middle blocks (interleaved, duration-aware)
        let middleItems = selectMiddleBlocks(
            from: allItems,
            excluding: [warmupItem, funItem].compactMap { $0 },
            targetMinutes: middleBudget,
            targetCount: middleCount
        )

        // 6. Assemble final session
        var sessionItems: [PracticeItem] = []
        if let warmup = warmupItem { sessionItems.append(warmup) }
        sessionItems.append(contentsOf: middleItems)
        if let fun = funItem { sessionItems.append(fun) }

        // 7. Convert to blocks
        let blocks = sessionItems.map { item in
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

        return PracticeSession(blocks: blocks)
    }

    private func selectInterleavedItems(from items: [PracticeItem], count: Int) -> [PracticeItem] {
        guard !items.isEmpty else { return [] }

        var result: [PracticeItem] = []
        var remaining = items

        while result.count < count {
            let previousCategory = result.last?.category
            if let nextIndex = remaining.firstIndex(where: { $0.category != previousCategory }) {
                result.append(remaining.remove(at: nextIndex))
            } else if let fallback = remaining.first {
                result.append(remaining.removeFirst())
                remaining.append(fallback) // allow reuse if still short
            }

            if remaining.isEmpty && result.count < count {
                remaining = items
            }
        }

        return Array(result.prefix(count))
    }

    private func selectWarmupItem(from items: [PracticeItem]) -> PracticeItem? {
        // Prefer warmup category, fallback to fretboard
        items.first { $0.category == .warmup }
            ?? items.first { $0.category == .fretboard }
    }

    private func selectFunEndingItem(
        from items: [PracticeItem],
        excluding: PracticeItem?
    ) -> PracticeItem? {
        // Prefer songwork (full songs), fallback to repertoire (licks/riffs)
        let candidates = items.filter { $0.id != excluding?.id }

        return candidates.first { $0.category == .songwork }
            ?? candidates.first { $0.category == .repertoire }
    }

    private func selectMiddleBlocks(
        from items: [PracticeItem],
        excluding: [PracticeItem],
        targetMinutes: Int,
        targetCount: Int
    ) -> [PracticeItem] {

        let excludedIDs = Set(excluding.map { $0.id })
        let pool = items.filter { !excludedIDs.contains($0.id) }

        var selected: [PracticeItem] = []
        var totalMinutes = 0
        var lastCategory: PracticeItemCategory?

        // Track which items we've used
        var remainingPool = pool

        while selected.count < targetCount && !remainingPool.isEmpty {
            // Try to find item from different category than last
            let candidates = remainingPool.filter { item in
                item.category != lastCategory
            }

            // Pick next item
            let nextItem: PracticeItem?
            if !candidates.isEmpty {
                nextItem = candidates.first
            } else {
                nextItem = remainingPool.first
            }

            guard let item = nextItem else { break }

            // Check if adding this would exceed target
            let projectedTotal = totalMinutes + item.targetMinutes
            let avgRemaining = targetMinutes - projectedTotal
            let slotsRemaining = targetCount - selected.count - 1

            // Only add if we can still fit remaining blocks
            if slotsRemaining == 0 || avgRemaining >= slotsRemaining * 3 {
                selected.append(item)
                totalMinutes += item.targetMinutes
                lastCategory = item.category
                remainingPool.removeAll { $0.id == item.id }
            } else {
                // Item too long, remove from pool and try next
                remainingPool.removeAll { $0.id == item.id }
            }

            // Stop if we're within acceptable range
            if totalMinutes >= targetMinutes - 5 && selected.count >= targetCount - 2 {
                break
            }
        }

        return selected
    }
}
