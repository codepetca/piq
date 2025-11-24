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
            nextDue: now.addingTimeInterval(intervalDays * 86_400)
        )

        items[index] = item
    }

    // MARK: - Session Generation

    func generateTodaySession(now: Date = Date()) -> PracticeSession {
        let ordered = prioritizedItems(asOf: now)
        let due = dueItems(asOf: now)

        var pool = due
        if pool.count < 4 {
            let remaining = ordered.filter { item in !pool.contains(where: { $0.id == item.id }) }
            pool.append(contentsOf: remaining)
        }

        let selected = selectInterleavedItems(from: pool, count: 4)
        let blocks = selected.map { item in
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
}
