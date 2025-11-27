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
    
    // Tempo tracking
    var startingBPM: Int?
    var endingBPM: Int?
    var tempoAdjustmentCount: Int

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
        focusCue: String? = nil,
        startingBPM: Int? = nil,
        endingBPM: Int? = nil,
        tempoAdjustmentCount: Int = 0
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
        self.startingBPM = startingBPM
        self.endingBPM = endingBPM
        self.tempoAdjustmentCount = tempoAdjustmentCount
    }
    
    // MARK: - Codable (backward compatible decoding)
    
    enum CodingKeys: String, CodingKey {
        case id, kind, title, detail, targetMinutes, actualMinutes, key
        case practiceItemID, feedback, referenceID
        case instructions, focusCue
        case startingBPM, endingBPM, tempoAdjustmentCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        kind = try container.decode(PracticeBlockKind.self, forKey: .kind)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
        targetMinutes = try container.decodeIfPresent(Int.self, forKey: .targetMinutes) ?? kind.defaultMinutes
        actualMinutes = try container.decodeIfPresent(Int.self, forKey: .actualMinutes)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        practiceItemID = try container.decodeIfPresent(UUID.self, forKey: .practiceItemID)
        feedback = try container.decodeIfPresent(PracticeBlockFeedback.self, forKey: .feedback)
        referenceID = try container.decodeIfPresent(String.self, forKey: .referenceID)
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
        focusCue = try container.decodeIfPresent(String.self, forKey: .focusCue)
        // For v1 blocks without tempo fields, use defaults
        startingBPM = try container.decodeIfPresent(Int.self, forKey: .startingBPM)
        endingBPM = try container.decodeIfPresent(Int.self, forKey: .endingBPM)
        tempoAdjustmentCount = try container.decodeIfPresent(Int.self, forKey: .tempoAdjustmentCount) ?? 0
    }
}
