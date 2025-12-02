import XCTest
@testable import piq

final class SmartJamServiceTests: XCTestCase {
    func testSelectsPreferredStyleAndClosestBPM() {
        let service = SmartJamService(catalog: .v1Catalog())

        let config = service.makeConfig(
            targetKey: "Am",
            targetBPM: 92,
            preferredStyles: [.blues, .rock],
            category: .solo
        )

        XCTAssertEqual(config?.style, .blues)
        XCTAssertEqual(config?.familyID, "sj_blues_solo_90")
        XCTAssertEqual(config?.targetBPM, 92)
        XCTAssertEqual(config?.targetKey, "Am")
    }

    func testFallsBackWhenPreferredStyleMissing() {
        let catalog = SmartJamPatternCatalog(
            families: [
                SmartJamPatternFamily(
                    id: "rock_tech",
                    style: .rock,
                    category: .technique,
                    baseBPM: 80,
                    baseKey: nil,
                    assetName: "rock_asset"
                ),
                SmartJamPatternFamily(
                    id: "pop_tech",
                    style: .pop,
                    category: .technique,
                    baseBPM: 100,
                    baseKey: nil,
                    assetName: "pop_asset"
                )
            ]
        )

        let service = SmartJamService(catalog: catalog)
        let config = service.makeConfig(
            targetKey: nil,
            targetBPM: 95,
            preferredStyles: [.worship], // not present in catalog
            category: .technique
        )

        XCTAssertEqual(config?.familyID, "pop_tech")
        XCTAssertEqual(config?.style, .pop)
    }

    func testJamConfigsAttachToSoloAndTechniqueBlocks() {
        let now = Date()
        let warmup = PracticeItem(
            catalogID: "test_warmup",
            category: .warmup,
            title: "Warmup",
            srs: SRSState(nextDue: now)
        )
        let technique = PracticeItem(
            catalogID: "test_tech",
            category: .technique,
            title: "Technique",
            key: "Am",
            srs: SRSState(nextDue: now),
            tempo: TempoState(currentBPM: 80)
        )
        let solo = PracticeItem(
            catalogID: "test_solo",
            category: .soloing,
            title: "Solo",
            key: "Em",
            srs: SRSState(nextDue: now),
            tempo: TempoState(currentBPM: 100)
        )
        let fun = PracticeItem(
            catalogID: "test_fun",
            category: .repertoire,
            title: "Fun Ending",
            srs: SRSState(nextDue: now)
        )

        let engine = SpacedRepetitionEngine()
        [warmup, technique, solo, fun].forEach(engine.addItem)

        let session = engine.generateTodaySession(
            now: now,
            targetMinutes: 20,
            minBlocks: 4,
            maxBlocks: 4,
            preferredStyles: [.rock]
        )

        let techniqueBlocks = session.blocks.filter { $0.kind == .techniqueOrTheory }
        let soloBlocks = session.blocks.filter { $0.kind == .solo }
        let warmupBlocks = session.blocks.filter { $0.kind == .warmup }

        XCTAssertFalse(techniqueBlocks.isEmpty)
        XCTAssertFalse(soloBlocks.isEmpty)
        XCTAssertTrue(techniqueBlocks.allSatisfy { $0.smartJamConfig != nil })
        XCTAssertTrue(soloBlocks.allSatisfy { $0.smartJamConfig != nil })
        XCTAssertTrue(warmupBlocks.allSatisfy { $0.smartJamConfig == nil })
    }

    func testSmartJamCategoryMapper() {
        XCTAssertEqual(SmartJamCategoryMapper.category(for: .solo), .solo)
        XCTAssertEqual(SmartJamCategoryMapper.category(for: .techniqueOrTheory), .technique)
        XCTAssertEqual(SmartJamCategoryMapper.category(for: .song), .song)
        XCTAssertNil(SmartJamCategoryMapper.category(for: .warmup))
    }
}
