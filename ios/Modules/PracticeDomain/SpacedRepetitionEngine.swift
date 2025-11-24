import Foundation
import Observation

/// Engine that schedules practice items using a spaced repetition algorithm.
/// Based on SM-2 algorithm principles with simplifications for music practice.
@Observable
final class SpacedRepetitionEngine {

    // MARK: - Properties

    /// All practice items managed by this engine
    private(set) var items: [PracticeItem] = []

    // MARK: - Item Management

    /// Add a new item to the engine
    func addItem(_ item: PracticeItem) {
        items.append(item)
    }

    /// Remove an item by ID
    func removeItem(withID id: UUID) {
        items.removeAll { $0.id == id }
    }

    /// Load the default demo items
    func loadDemoItems() {
        items = PracticeItem.makeDemoItems()
    }

    // MARK: - Querying Items

    /// Get all items that are due for practice (due date is now or earlier)
    func dueItems() -> [PracticeItem] {
        let now = Date()
        return items.filter { $0.dueDate <= now }
    }

    /// Get items filtered by kind
    func items(forKind kind: PracticeBlockKind) -> [PracticeItem] {
        items.filter { $0.kind == kind }
    }

    /// Get items for a kind, prioritized for practice selection.
    /// Priority: most overdue first, then new items, then by due date
    func prioritizedItems(forKind kind: PracticeBlockKind) -> [PracticeItem] {
        let kindItems = items(forKind: kind)
        let now = Date()

        // Threshold for "significantly overdue" - 1 day
        let significantOverdueThreshold: TimeInterval = 86400

        return kindItems.sorted { a, b in
            let aOverdue = now.timeIntervalSince(a.dueDate)
            let bOverdue = now.timeIntervalSince(b.dueDate)

            let aSignificantlyOverdue = aOverdue >= significantOverdueThreshold
            let bSignificantlyOverdue = bOverdue >= significantOverdueThreshold

            // Significantly overdue items come first, sorted by how overdue
            if aSignificantlyOverdue && bSignificantlyOverdue {
                return aOverdue > bOverdue
            }
            if aSignificantlyOverdue && !bSignificantlyOverdue {
                return true
            }
            if bSignificantlyOverdue && !aSignificantlyOverdue {
                return false
            }

            // Next priority: new items
            if a.isNew && !b.isNew {
                return true
            }
            if b.isNew && !a.isNew {
                return false
            }

            // Both overdue (but not significantly): more overdue first
            if aOverdue > 0 && bOverdue > 0 {
                return aOverdue > bOverdue
            }

            // One overdue, one not: overdue first
            if aOverdue > 0 && bOverdue <= 0 {
                return true
            }
            if bOverdue > 0 && aOverdue <= 0 {
                return false
            }

            // Both same newness and not overdue: earlier due date first
            return a.dueDate < b.dueDate
        }
    }

    // MARK: - Feedback Processing

    /// Record feedback for an item and update its scheduling parameters
    func recordFeedback(forItemID id: UUID, feedback: PracticeBlockFeedback) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        var item = items[index]

        // Update review count
        item.reviewCount += 1

        // Calculate new scheduling based on feedback
        switch feedback {
        case .easy:
            item = applyEasyFeedback(to: item)
        case .good:
            item = applyGoodFeedback(to: item)
        case .hard:
            item = applyHardFeedback(to: item)
        }

        // Update due date based on new interval
        item.dueDate = Date().addingTimeInterval(item.intervalDays * 86400)

        items[index] = item
    }

    // MARK: - Session Generation

    /// Generate a practice session for today with 4 blocks in standard order
    func generateTodaySession() -> PracticeSession {
        let blocks = PracticeSession.standardBlockOrder.map { kind -> PracticeBlock in
            let prioritized = prioritizedItems(forKind: kind)

            if let topItem = prioritized.first {
                return PracticeBlock(
                    kind: kind,
                    title: topItem.title,
                    detail: topItem.detail,
                    targetMinutes: topItem.targetMinutes,
                    key: topItem.key,
                    practiceItemID: topItem.id,
                    referenceID: topItem.referenceID
                )
            } else {
                // Fallback placeholder when no items exist for this kind
                return PracticeBlock(
                    kind: kind,
                    title: kind.displayName,
                    detail: "Add items in Settings"
                )
            }
        }

        return PracticeSession(blocks: blocks)
    }

    // MARK: - Private Scheduling Logic

    /// Apply easy feedback: increase interval significantly, boost ease factor
    private func applyEasyFeedback(to item: PracticeItem) -> PracticeItem {
        var updated = item

        // Increase ease factor (bonus for easy)
        updated.easeFactor = min(updated.easeFactor + 0.15, 3.0)

        // Calculate new interval
        if updated.reviewCount == 1 {
            // First review: start with 1 day
            updated.intervalDays = 1.0
        } else if updated.reviewCount == 2 {
            // Second review: 6 days
            updated.intervalDays = 6.0
        } else {
            // Subsequent reviews: multiply by ease factor with bonus
            updated.intervalDays = updated.intervalDays * updated.easeFactor * 1.3
        }

        updated.consecutiveCorrect += 1

        return updated
    }

    /// Apply good feedback: increase interval normally, maintain ease factor
    private func applyGoodFeedback(to item: PracticeItem) -> PracticeItem {
        var updated = item

        // Ease factor stays the same for "good"

        // Calculate new interval
        if updated.reviewCount == 1 {
            // First review: start with 1 day
            updated.intervalDays = 1.0
        } else if updated.reviewCount == 2 {
            // Second review: 6 days
            updated.intervalDays = 6.0
        } else {
            // Subsequent reviews: multiply by ease factor
            updated.intervalDays = updated.intervalDays * updated.easeFactor
        }

        updated.consecutiveCorrect += 1

        return updated
    }

    /// Apply hard feedback: reduce interval, decrease ease factor, reset streak
    private func applyHardFeedback(to item: PracticeItem) -> PracticeItem {
        var updated = item

        // Decrease ease factor (but never below 1.3)
        updated.easeFactor = max(updated.easeFactor - 0.2, 1.3)

        // Reset to short interval (1-3 days depending on how well known)
        if updated.consecutiveCorrect > 3 {
            updated.intervalDays = 3.0
        } else {
            updated.intervalDays = 1.0
        }

        // Reset consecutive correct streak
        updated.consecutiveCorrect = 0

        return updated
    }
}
