import Foundation

/// A single block in a practice session.
struct PracticeBlock: Identifiable, Codable {
    let id: UUID
    let kind: PracticeBlockKind
    var title: String
    var detail: String
    var targetMinutes: Int
    var actualMinutes: Int?
    var key: String?
    var practiceItemID: UUID?
    var feedback: PracticeBlockFeedback?
    var referenceID: String?

    // Instructions to display during practice
    var instructions: [String]
    var focusCue: String?

    init(
        id: UUID = UUID(),
        kind: PracticeBlockKind,
        title: String,
        detail: String = "",
        targetMinutes: Int? = nil,
        actualMinutes: Int? = nil,
        key: String? = nil,
        practiceItemID: UUID? = nil,
        feedback: PracticeBlockFeedback? = nil,
        referenceID: String? = nil,
        instructions: [String] = [],
        focusCue: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.targetMinutes = targetMinutes ?? kind.defaultMinutes
        self.actualMinutes = actualMinutes
        self.key = key
        self.practiceItemID = practiceItemID
        self.feedback = feedback
        self.referenceID = referenceID
        self.instructions = instructions
        self.focusCue = focusCue
    }
}
