import Foundation

/// Supported SmartJam styles. Mirrors onboarding music styles with a small curated set.
enum SmartJamStyle: String, CaseIterable, Codable {
    case rock
    case pop
    case blues
    case rnb
    case worship
    case lofi

    static var defaultPreferenceOrder: [SmartJamStyle] {
        [.rock, .blues, .pop, .rnb, .worship, .lofi]
    }

    init?(musicStyle: MusicStyle) {
        switch musicStyle {
        case .rock: self = .rock
        case .pop: self = .pop
        case .blues: self = .blues
        case .rnb: self = .rnb
        case .worship: self = .worship
        }
    }
}

/// High-level SmartJam categories the selection service understands.
enum SmartJamCategory: String, Codable {
    case solo
    case technique
    case song
}

/// Describes a reusable jam pattern family shipped with the app.
struct SmartJamPatternFamily: Codable, Equatable {
    let id: String
    let style: SmartJamStyle
    let category: SmartJamCategory
    let baseBPM: Int
    let baseKey: String?
    let assetName: String
}

/// A concrete jam assignment for a block.
struct SmartJamConfig: Codable, Equatable {
    let familyID: String
    let assetName: String
    let targetKey: String?
    let targetBPM: Int?
    let baseBPM: Int
    let style: SmartJamStyle
    let category: SmartJamCategory
}

/// Catalog of pattern families used for deterministic selection.
struct SmartJamPatternCatalog {
    let families: [SmartJamPatternFamily]

    static func v1Catalog() -> SmartJamPatternCatalog {
        SmartJamPatternCatalog(
            families: [
                SmartJamPatternFamily(
                    id: "sj_blues_solo_90",
                    style: .blues,
                    category: .solo,
                    baseBPM: 90,
                    baseKey: "Am",
                    assetName: "sj_blues_solo_90_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_blues_solo_110",
                    style: .blues,
                    category: .solo,
                    baseBPM: 110,
                    baseKey: "Em",
                    assetName: "sj_blues_solo_110_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_rock_solo_100",
                    style: .rock,
                    category: .solo,
                    baseBPM: 100,
                    baseKey: "Am",
                    assetName: "sj_rock_solo_100_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_rock_solo_120",
                    style: .rock,
                    category: .solo,
                    baseBPM: 120,
                    baseKey: "Em",
                    assetName: "sj_rock_solo_120_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_pop_solo_95",
                    style: .pop,
                    category: .solo,
                    baseBPM: 95,
                    baseKey: "C",
                    assetName: "sj_pop_solo_95_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_worship_solo_72",
                    style: .worship,
                    category: .solo,
                    baseBPM: 72,
                    baseKey: "G",
                    assetName: "sj_worship_solo_72_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_rnb_solo_94",
                    style: .rnb,
                    category: .solo,
                    baseBPM: 94,
                    baseKey: "Am",
                    assetName: "sj_rnb_solo_94_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_rock_tech_80",
                    style: .rock,
                    category: .technique,
                    baseBPM: 80,
                    baseKey: "Am",
                    assetName: "sj_rock_tech_80_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_blues_tech_70",
                    style: .blues,
                    category: .technique,
                    baseBPM: 70,
                    baseKey: "Am",
                    assetName: "sj_blues_tech_70_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_pop_tech_92",
                    style: .pop,
                    category: .technique,
                    baseBPM: 92,
                    baseKey: "C",
                    assetName: "sj_pop_tech_92_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_rnb_tech_85",
                    style: .rnb,
                    category: .technique,
                    baseBPM: 85,
                    baseKey: "Em",
                    assetName: "sj_rnb_tech_85_full"
                ),
                SmartJamPatternFamily(
                    id: "sj_worship_tech_68",
                    style: .worship,
                    category: .technique,
                    baseBPM: 68,
                    baseKey: "G",
                    assetName: "sj_worship_tech_68_full"
                )
            ]
        )
    }
}

// MARK: - Mappers

enum SmartJamCategoryMapper {
    static func category(for blockKind: PracticeBlockKind) -> SmartJamCategory? {
        switch blockKind {
        case .solo:
            return .solo
        case .techniqueOrTheory:
            return .technique
        case .song:
            return .song
        case .warmup:
            return nil
        }
    }
}
