import Foundation

// MARK: - Tempo Tracking

/// Records a single tempo practice session for learning purposes.
struct TempoSession: Codable, Equatable {
    let date: Date
    let startBPM: Int                // BPM at block start
    let endBPM: Int                  // BPM at block end
    let adjustmentCount: Int         // Number of user adjustments
    let feedback: PracticeBlockFeedback
}

/// Tracks tempo learning state for a practice item.
struct TempoState: Codable, Equatable {
    var currentBPM: Int              // Current working tempo
    var targetBPM: Int?              // Optional goal tempo (nil = unlimited)
    var history: [TempoSession]      // Last 10 sessions
    var lastPracticedBPM: Int?       // Previous session's BPM
    var progressionRate: Double      // Learning speed multiplier (0.5-2.0)
    
    init(
        currentBPM: Int = 60,
        targetBPM: Int? = nil,
        history: [TempoSession] = [],
        lastPracticedBPM: Int? = nil,
        progressionRate: Double = 1.0
    ) {
        self.currentBPM = currentBPM
        self.targetBPM = targetBPM
        self.history = history
        self.lastPracticedBPM = lastPracticedBPM
        self.progressionRate = progressionRate
    }
}

// MARK: - Spaced Repetition State

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
    var tempo: TempoState

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
        tempo: TempoState? = nil,
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
        self.tempo = tempo ?? TempoState(currentBPM: category.defaultBPM)
        self.coreInstructions = coreInstructions
        self.bonusTips = bonusTips
        self.focusCues = focusCues
    }
    
    // MARK: - Codable (backward compatible decoding)
    
    enum CodingKeys: String, CodingKey {
        case id, catalogID, category, title, detail, key, referenceID
        case targetMinutes, srs, tempo
        case coreInstructions, bonusTips, focusCues
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        catalogID = try container.decode(String.self, forKey: .catalogID)
        category = try container.decode(PracticeItemCategory.self, forKey: .category)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
        key = try container.decodeIfPresent(String.self, forKey: .key)
        referenceID = try container.decodeIfPresent(String.self, forKey: .referenceID)
        targetMinutes = try container.decodeIfPresent(Int.self, forKey: .targetMinutes) ?? category.defaultMinutes
        srs = try container.decodeIfPresent(SRSState.self, forKey: .srs) ?? SRSState()
        // For v1 items without tempo, use default based on category
        tempo = try container.decodeIfPresent(TempoState.self, forKey: .tempo) ?? TempoState(currentBPM: category.defaultBPM)
        coreInstructions = try container.decodeIfPresent([String].self, forKey: .coreInstructions) ?? []
        bonusTips = try container.decodeIfPresent([String].self, forKey: .bonusTips) ?? []
        focusCues = try container.decodeIfPresent([String].self, forKey: .focusCues) ?? []
    }

    var blockKind: PracticeBlockKind { category.blockKind }

    /// Returns the number of stars (1-3) representing current stability level.
    /// 1 star: stability 1.0-2.5 (New/Learning)
    /// 2 stars: stability 2.5-5.0 (Comfortable)
    /// 3 stars: stability 5.0+ (Solid/Mastered)
    var stabilityStars: Int {
        switch srs.stability {
        case ..<2.5: return 1
        case 2.5..<5.0: return 2
        default: return 3
        }
    }

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
