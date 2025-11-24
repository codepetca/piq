import Foundation

struct SRSState: Codable, Equatable {
    var stability: Double
    var nextDue: Date

    init(stability: Double = 1.0, nextDue: Date = Date()) {
        self.stability = stability
        self.nextDue = nextDue
    }
}

/// Represents a single item that can be scheduled for practice using spaced repetition.
struct PracticeItem: Identifiable, Codable, Equatable {
    let id: UUID
    let category: PracticeItemCategory
    let title: String
    let detail: String
    let key: String?
    let referenceID: String?
    var targetMinutes: Int
    var srs: SRSState

    init(
        id: UUID = UUID(),
        category: PracticeItemCategory,
        title: String,
        detail: String = "",
        key: String? = nil,
        referenceID: String? = nil,
        targetMinutes: Int? = nil,
        srs: SRSState = SRSState()
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.detail = detail
        self.key = key
        self.referenceID = referenceID
        self.targetMinutes = targetMinutes ?? category.defaultMinutes
        self.srs = srs
    }

    var blockKind: PracticeBlockKind { category.blockKind }
}
