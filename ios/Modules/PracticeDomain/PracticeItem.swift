import Foundation

struct SRSState: Codable, Equatable {
    var stability: Double
    var lastPlayed: Date?
    var nextDue: Date
    var lastBonusTipIndex: Int
    var lastFocusCueIndex: Int

    init(stability: Double = 1.0, lastPlayed: Date? = nil, nextDue: Date = Date(), lastBonusTipIndex: Int = -1, lastFocusCueIndex: Int = -1) {
        self.stability = stability
        self.lastPlayed = lastPlayed
        self.nextDue = nextDue
        self.lastBonusTipIndex = lastBonusTipIndex
        self.lastFocusCueIndex = lastFocusCueIndex
    }
}

/// Represents a single item that can be scheduled for practice using spaced repetition.
struct PracticeItem: Identifiable, Codable, Equatable {
    let id: UUID
    let catalogID: String
    let category: PracticeItemCategory
    let title: String
    let detail: String
    let key: String?
    let referenceID: String?
    var targetMinutes: Int
    var srs: SRSState

    // Practice instructions
    let coreInstructions: [String]
    let bonusTips: [String]
    let focusCues: [String]

    init(
        id: UUID = UUID(),
        catalogID: String,
        category: PracticeItemCategory,
        title: String,
        detail: String = "",
        key: String? = nil,
        referenceID: String? = nil,
        targetMinutes: Int? = nil,
        srs: SRSState = SRSState(),
        coreInstructions: [String] = [],
        bonusTips: [String] = [],
        focusCues: [String] = []
    ) {
        self.id = id
        self.catalogID = catalogID
        self.category = category
        self.title = title
        self.detail = detail
        self.key = key
        self.referenceID = referenceID
        self.targetMinutes = targetMinutes ?? category.defaultMinutes
        self.srs = srs
        self.coreInstructions = coreInstructions
        self.bonusTips = bonusTips
        self.focusCues = focusCues
    }

    var blockKind: PracticeBlockKind { category.blockKind }

    /// Selects instructions to display, rotating through bonus tips and focus cues.
    /// Returns updated SRS state with new rotation indices.
    func selectInstructionsForDisplay() -> (instructions: [String], focusCue: String?, updatedSRS: SRSState) {
        var selectedInstructions = coreInstructions

        // Select next bonus tip (rotating through pool)
        if !bonusTips.isEmpty {
            let nextTipIndex = (srs.lastBonusTipIndex + 1) % bonusTips.count
            selectedInstructions.append(bonusTips[nextTipIndex])
        }

        // Select next focus cue (rotating through pool)
        var selectedFocusCue: String?
        var nextCueIndex = srs.lastFocusCueIndex
        if !focusCues.isEmpty {
            nextCueIndex = (srs.lastFocusCueIndex + 1) % focusCues.count
            selectedFocusCue = focusCues[nextCueIndex]
        }

        // Update SRS state with new indices
        var updatedSRS = srs
        if !bonusTips.isEmpty {
            updatedSRS.lastBonusTipIndex = (srs.lastBonusTipIndex + 1) % bonusTips.count
        }
        if !focusCues.isEmpty {
            updatedSRS.lastFocusCueIndex = (srs.lastFocusCueIndex + 1) % focusCues.count
        }

        return (selectedInstructions, selectedFocusCue, updatedSRS)
    }
}
