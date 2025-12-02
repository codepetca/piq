import XCTest
@testable import piq

final class SpacedRepetitionEngineTests: XCTestCase {
    func testSeedCatalogLoadsItems() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog(now: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(engine.items.count, 38)
        XCTAssertEqual(engine.items.filter { $0.category == .warmup }.count, 2)
        XCTAssertEqual(engine.items.filter { $0.category == .ear_training }.count, 4)
        XCTAssertEqual(engine.items.filter { $0.category == .musicality }.count, 4)
    }

    func testDueItemsUsesNextDue() {
        let engine = SpacedRepetitionEngine()
        let past = PracticeItem(catalogID: "test_past", category: .warmup, title: "Past", srs: SRSState(stability: 1, nextDue: .distantPast))
        let future = PracticeItem(catalogID: "test_future", category: .warmup, title: "Future", srs: SRSState(stability: 1, nextDue: .distantFuture))
        engine.addItem(past)
        engine.addItem(future)

        XCTAssertEqual(engine.dueItems(asOf: Date()).count, 1)
        XCTAssertEqual(engine.dueItems(asOf: Date()).first?.id, past.id)
    }

    func testGenerateBlockUsesNextDueItemOfRequestedKind() {
        let now = Date(timeIntervalSince1970: 10_000)
        let late = PracticeItem(
            catalogID: "tech_late",
            category: .technique,
            title: "Later",
            srs: SRSState(stability: 2.0, nextDue: now.addingTimeInterval(1 * 86_400))
        )
        let early = PracticeItem(
            catalogID: "tech_early",
            category: .technique,
            title: "Earlier",
            srs: SRSState(stability: 1.0, nextDue: now.addingTimeInterval(-1 * 86_400)),
            coreInstructions: ["Core"],
            bonusTips: ["Bonus"],
            focusCues: ["Cue"]
        )

        let engine = SpacedRepetitionEngine()
        engine.addItem(late)
        engine.addItem(early)

        let block = engine.generateBlock(for: .techniqueOrTheory, now: now)

        XCTAssertEqual(block?.practiceItemID, early.id)
        XCTAssertEqual(block?.kind, .techniqueOrTheory)
        XCTAssertEqual(block?.title, early.title)
        XCTAssertEqual(block?.instructions.count, 2, "Should include core instruction and rotating bonus tip")
        XCTAssertEqual(block?.focusCue, "Cue")
        XCTAssertNotNil(block?.startingBPM, "Technique blocks should include suggested BPM")
    }

    func testGenerateBlockReturnsNilWhenKindMissing() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog()

        // Remove all solo-kind items (soloing + musicality) to simulate missing category
        let soloIDs = engine.items.filter { $0.blockKind == .solo }.map(\.id)
        soloIDs.forEach { engine.removeItem(withID: $0) }

        let block = engine.generateBlock(for: .solo)
        XCTAssertNil(block)
    }

    func testFeedbackAdjustsStabilityAndNextDue() {
        let now = Date(timeIntervalSince1970: 1000)
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(catalogID: "test_feedback", category: .technique, title: "Test", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(item)

        engine.recordFeedback(forItemID: item.id, feedback: .hard, now: now)
        let hardItem = engine.items.first!

        engine.recordFeedback(forItemID: item.id, feedback: .good, now: now)
        let goodItem = engine.items.first!

        engine.recordFeedback(forItemID: item.id, feedback: .easy, now: now)
        let easyItem = engine.items.first!

        XCTAssertLessThan(hardItem.srs.stability, goodItem.srs.stability)
        XCTAssertLessThan(goodItem.srs.stability, easyItem.srs.stability)
        XCTAssertLessThan(hardItem.srs.nextDue, goodItem.srs.nextDue)
        XCTAssertLessThan(goodItem.srs.nextDue, easyItem.srs.nextDue)
    }

    func testFeedbackSetsLastPlayed() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(catalogID: "test_last_played_sre", category: .technique, title: "Test", srs: SRSState(stability: 2.0, lastPlayed: nil, nextDue: now))
        engine.addItem(item)

        XCTAssertNil(engine.items.first!.srs.lastPlayed)

        engine.recordFeedback(forItemID: item.id, feedback: .good, now: now)

        let updated = engine.items.first!
        XCTAssertNotNil(updated.srs.lastPlayed)
        XCTAssertEqual(updated.srs.lastPlayed!.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 0.1)
    }

    func testGenerateTodaySessionReturns6to8Blocks() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog(now: Date())

        let session = engine.generateTodaySession()
        XCTAssertGreaterThanOrEqual(session.blocks.count, 6, "Should have at least 6 blocks")
        XCTAssertLessThanOrEqual(session.blocks.count, 8, "Should have at most 8 blocks")
        XCTAssertTrue(session.blocks.allSatisfy { $0.practiceItemID != nil })

        // Verify duration is within acceptable range
        let total = session.totalTargetMinutes
        XCTAssertGreaterThanOrEqual(total, 20, "Session should be at least 20 minutes")
        XCTAssertLessThanOrEqual(total, 45, "Session should not exceed 45 minutes")
    }

    func testGenerateTodaySessionInterleavesCategoriesWhenPossible() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog(now: Date())

        let session = engine.generateTodaySession()
        let categories = session.blocks.compactMap { block in
            engine.items.first(where: { $0.id == block.practiceItemID })?.category
        }

        // Check middle blocks (excluding first warmup and last fun ending)
        // for variety
        if categories.count >= 4 {
            let middleCategories = Array(categories[1..<categories.count-1])
            var hasSomeVariety = false
            for pair in zip(middleCategories, middleCategories.dropFirst()) {
                if pair.0 != pair.1 {
                    hasSomeVariety = true
                    break
                }
            }
            XCTAssertTrue(hasSomeVariety, "Middle blocks should have some category variety")
        }
    }

    func testGenerateTodaySessionWithFewItemsStillProducesBlocks() {
        let now = Date()
        let warmup = PracticeItem(catalogID: "test_warm_few", category: .warmup, title: "Warm", srs: SRSState(nextDue: now))
        let song = PracticeItem(catalogID: "test_song_few", category: .songwork, title: "Song", srs: SRSState(nextDue: now))
        let solo = PracticeItem(catalogID: "test_solo_few", category: .soloing, title: "Solo", srs: SRSState(nextDue: now))

        let engine = SpacedRepetitionEngine()
        [warmup, song, solo].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)
        // With limited items, can reuse to reach min blocks
        XCTAssertGreaterThanOrEqual(session.blocks.count, 3, "Should have at least 3 blocks")
        XCTAssertLessThanOrEqual(session.blocks.count, 8, "Should have at most 8 blocks")
    }

    func testGenerateTodaySessionWhenNoItemsReturnsEmptySession() {
        let engine = SpacedRepetitionEngine()

        let session = engine.generateTodaySession()

        XCTAssertTrue(session.blocks.isEmpty, "Should return an empty session when no items are available")
    }

    func testGenerateTodaySessionInterleavesMiddleWhenVarietyExists() {
        let now = Date()
        let warmup = PracticeItem(catalogID: "test_interleave_warm", category: .warmup, title: "Warmup", srs: SRSState(nextDue: now))
        let technique = PracticeItem(catalogID: "test_interleave_tech", category: .technique, title: "Technique", srs: SRSState(nextDue: now))
        let solo = PracticeItem(catalogID: "test_interleave_solo", category: .soloing, title: "Solo", srs: SRSState(nextDue: now))
        let rhythm = PracticeItem(catalogID: "test_interleave_rhythm", category: .rhythm, title: "Rhythm", srs: SRSState(nextDue: now))
        let fun = PracticeItem(catalogID: "test_interleave_fun", category: .repertoire, title: "Fun Ending", srs: SRSState(nextDue: now))

        let engine = SpacedRepetitionEngine()
        [warmup, technique, solo, rhythm, fun].forEach(engine.addItem)

        let session = engine.generateTodaySession(
            now: now,
            targetMinutes: 20,
            minBlocks: 4,
            maxBlocks: 4
        )

        let kinds = session.blocks.map(\.kind)
        XCTAssertEqual(kinds.first, .warmup)
        XCTAssertEqual(kinds.last, .song)

        let middleKinds = Array(kinds.dropFirst().dropLast())
        XCTAssertEqual(middleKinds.count, 2)
        XCTAssertNotEqual(middleKinds[0], middleKinds[1], "Middle blocks should interleave when different categories exist")
    }

    // MARK: - Batch Feedback Tests

    func testApplyFeedbackUpdatesMultipleItems() {
        let now = Date(timeIntervalSince1970: 10000)
        let engine = SpacedRepetitionEngine()

        let item1 = PracticeItem(catalogID: "test_item_1", category: .warmup, title: "Item 1", srs: SRSState(stability: 2.0, nextDue: now))
        let item2 = PracticeItem(catalogID: "test_item_2", category: .technique, title: "Item 2", srs: SRSState(stability: 3.0, nextDue: now))
        engine.addItem(item1)
        engine.addItem(item2)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Block 1", practiceItemID: item1.id, feedback: .hard),
            PracticeBlock(kind: .techniqueOrTheory, title: "Block 2", practiceItemID: item2.id, feedback: .easy)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updatedItem1 = engine.items.first { $0.id == item1.id }!
        let updatedItem2 = engine.items.first { $0.id == item2.id }!

        // Item 1 received Hard feedback → lower stability, sooner nextDue
        XCTAssertLessThan(updatedItem1.srs.stability, 2.0)
        XCTAssertGreaterThan(updatedItem1.srs.nextDue, now)
        XCTAssertLessThan(updatedItem1.srs.nextDue, now.addingTimeInterval(2 * 86_400))

        // Item 2 received Easy feedback → higher stability, later nextDue
        XCTAssertGreaterThan(updatedItem2.srs.stability, 3.0)
        XCTAssertGreaterThan(updatedItem2.srs.nextDue, now.addingTimeInterval(2 * 86_400))
    }

    func testApplyFeedbackWithHardDecreasesStability() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(catalogID: "test_tech_item", category: .technique, title: "Tech", srs: SRSState(stability: 3.0, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .techniqueOrTheory, title: "Block", practiceItemID: item.id, feedback: .hard)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updated = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(updated.srs.stability, max(1.0, 3.0 * 0.6))
        XCTAssertLessThan(updated.srs.nextDue, now.addingTimeInterval(2 * 86_400))
    }

    func testApplyFeedbackWithGoodIncreasesStabilityModerately() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(catalogID: "test_solo_item", category: .soloing, title: "Solo", srs: SRSState(stability: 2.5, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .solo, title: "Block", practiceItemID: item.id, feedback: .good)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updated = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(updated.srs.stability, max(1.2, 2.5 * 1.15))
        XCTAssertGreaterThan(updated.srs.nextDue, now.addingTimeInterval(1 * 86_400))
        XCTAssertLessThan(updated.srs.nextDue, now.addingTimeInterval(4 * 86_400))
    }

    func testApplyFeedbackWithEasyIncreasesStabilitySignificantly() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(catalogID: "test_fret_item", category: .fretboard, title: "Fret", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Block", practiceItemID: item.id, feedback: .easy)
        ]

        engine.applyFeedback(for: blocks, now: now)

        let updated = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(updated.srs.stability, 2.0 * 1.5 + 0.5)
        XCTAssertGreaterThan(updated.srs.nextDue, now.addingTimeInterval(2 * 86_400))
    }

    func testApplyFeedbackSkipsBlocksWithoutPracticeItemID() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(catalogID: "test_warm_item", category: .warmup, title: "Warm", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Block without ID", practiceItemID: nil, feedback: .hard)
        ]

        engine.applyFeedback(for: blocks, now: now)

        // Item should remain unchanged
        let unchanged = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(unchanged.srs.stability, 2.0)
        XCTAssertEqual(unchanged.srs.nextDue, now)
    }

    func testApplyFeedbackSkipsBlocksWithoutFeedback() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item = PracticeItem(catalogID: "test_tech_no_feedback", category: .technique, title: "Tech", srs: SRSState(stability: 2.5, nextDue: now))
        engine.addItem(item)

        let blocks = [
            PracticeBlock(kind: .techniqueOrTheory, title: "Block no feedback", practiceItemID: item.id, feedback: nil)
        ]

        engine.applyFeedback(for: blocks, now: now)

        // Item should remain unchanged
        let unchanged = engine.items.first { $0.id == item.id }!
        XCTAssertEqual(unchanged.srs.stability, 2.5)
        XCTAssertEqual(unchanged.srs.nextDue, now)
    }

    func testApplyFeedbackIgnoresMissingItemsGracefully() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let existingItem = PracticeItem(catalogID: "test_existing", category: .warmup, title: "Exists", srs: SRSState(stability: 2.0, nextDue: now))
        engine.addItem(existingItem)

        let nonExistentID = UUID()
        let blocks = [
            PracticeBlock(kind: .warmup, title: "Ghost Block", practiceItemID: nonExistentID, feedback: .good),
            PracticeBlock(kind: .warmup, title: "Real Block", practiceItemID: existingItem.id, feedback: .easy)
        ]

        // Should not crash
        engine.applyFeedback(for: blocks, now: now)

        // Existing item should be updated
        let updated = engine.items.first { $0.id == existingItem.id }!
        XCTAssertGreaterThan(updated.srs.stability, 2.0)
    }

    func testApplyFeedbackWithMixedBlockStates() {
        let now = Date(timeIntervalSince1970: 5000)
        let engine = SpacedRepetitionEngine()

        let item1 = PracticeItem(catalogID: "test_item_1", category: .warmup, title: "Item 1", srs: SRSState(stability: 2.0, nextDue: now))
        let item2 = PracticeItem(catalogID: "test_item_2", category: .technique, title: "Item 2", srs: SRSState(stability: 3.0, nextDue: now))
        engine.addItem(item1)
        engine.addItem(item2)

        let blocks = [
            PracticeBlock(kind: .warmup, title: "Valid", practiceItemID: item1.id, feedback: .good),
            PracticeBlock(kind: .song, title: "No ID", practiceItemID: nil, feedback: .easy),
            PracticeBlock(kind: .techniqueOrTheory, title: "No Feedback", practiceItemID: item2.id, feedback: nil),
            PracticeBlock(kind: .solo, title: "Ghost", practiceItemID: UUID(), feedback: .hard)
        ]

        engine.applyFeedback(for: blocks, now: now)

        // Only item1 should be updated
        let updated1 = engine.items.first { $0.id == item1.id }!
        XCTAssertGreaterThan(updated1.srs.stability, 2.0)

        // item2 should remain unchanged
        let unchanged2 = engine.items.first { $0.id == item2.id }!
        XCTAssertEqual(unchanged2.srs.stability, 3.0)
        XCTAssertEqual(unchanged2.srs.nextDue, now)
    }

    // MARK: - Session Generation Tests (Issue #5 Requirements)

    func testGenerateTodaySessionSelectsItemsByNextDueAndStability() {
        let now = Date(timeIntervalSince1970: 10000)
        let engine = SpacedRepetitionEngine()

        // Create items with different due dates and stabilities
        let mostDue = PracticeItem(catalogID: "test_most_due", category: .warmup, title: "Most Due", srs: SRSState(stability: 2.0, nextDue: now.addingTimeInterval(-2 * 86_400)))
        let sameDueLowStability = PracticeItem(catalogID: "test_same_due_low", category: .technique, title: "Same Due Low", srs: SRSState(stability: 1.0, nextDue: now.addingTimeInterval(-1 * 86_400)))
        let sameDueHighStability = PracticeItem(catalogID: "test_same_due_high", category: .soloing, title: "Same Due High", srs: SRSState(stability: 5.0, nextDue: now.addingTimeInterval(-1 * 86_400)))
        let lessDue = PracticeItem(catalogID: "test_less_due", category: .songwork, title: "Less Due", srs: SRSState(stability: 3.0, nextDue: now))

        [mostDue, sameDueLowStability, sameDueHighStability, lessDue].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)

        // Extract item IDs from generated blocks
        let blockItemIDs = session.blocks.compactMap { $0.practiceItemID }

        // Should select items in priority order: earliest nextDue first, then lowest stability
        XCTAssertTrue(blockItemIDs.contains(mostDue.id), "Should include earliest due item")
        XCTAssertTrue(blockItemIDs.contains(sameDueLowStability.id), "Should prefer lower stability when nextDue is equal")

        // Verify low stability is preferred over high stability for same due date
        let sameDueLowIndex = blockItemIDs.firstIndex(of: sameDueLowStability.id)
        let sameDueHighIndex = blockItemIDs.firstIndex(of: sameDueHighStability.id)

        if let lowIndex = sameDueLowIndex, let highIndex = sameDueHighIndex {
            XCTAssertLessThan(lowIndex, highIndex, "Lower stability item should be selected before higher stability item with same due date")
        }
    }

    func testGenerateTodaySessionWhenNoItemsDueUsesLowestStability() {
        let now = Date(timeIntervalSince1970: 10000)
        let future = now.addingTimeInterval(5 * 86_400)
        let engine = SpacedRepetitionEngine()

        // All items due in the future
        let lowStability = PracticeItem(catalogID: "test_low_stab", category: .warmup, title: "Low", srs: SRSState(stability: 1.0, nextDue: future))
        let medStability = PracticeItem(catalogID: "test_med_stab", category: .technique, title: "Med", srs: SRSState(stability: 3.0, nextDue: future))
        let highStability = PracticeItem(catalogID: "test_high_stab", category: .soloing, title: "High", srs: SRSState(stability: 5.0, nextDue: future))
        let veryHigh = PracticeItem(catalogID: "test_very_high_stab", category: .songwork, title: "Very High", srs: SRSState(stability: 8.0, nextDue: future))

        [lowStability, medStability, highStability, veryHigh].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)

        // Should still produce blocks even though nothing is strictly due
        // With only 4 items, may not reach 6 blocks
        XCTAssertGreaterThanOrEqual(session.blocks.count, 3)
        XCTAssertLessThanOrEqual(session.blocks.count, 8)

        let blockItemIDs = session.blocks.compactMap { $0.practiceItemID }

        // Should select items with lowest stability
        XCTAssertTrue(blockItemIDs.contains(lowStability.id), "Should include lowest stability item")
        XCTAssertTrue(blockItemIDs.contains(medStability.id), "Should include medium stability item")
    }

    func testGenerateTodaySessionBlocksMapCorrectKindFromCategory() {
        let now = Date(timeIntervalSince1970: 10000)
        let engine = SpacedRepetitionEngine()

        // Create items with different categories
        let warmupItem = PracticeItem(catalogID: "test_warmup_cat", category: .warmup, title: "Warmup", srs: SRSState(nextDue: now))
        let fretboardItem = PracticeItem(catalogID: "test_fretboard_cat", category: .fretboard, title: "Fretboard", srs: SRSState(nextDue: now))
        let songItem = PracticeItem(catalogID: "test_song_cat", category: .songwork, title: "Song", srs: SRSState(nextDue: now))
        let soloItem = PracticeItem(catalogID: "test_solo_cat", category: .soloing, title: "Solo", srs: SRSState(nextDue: now))
        let techniqueItem = PracticeItem(catalogID: "test_tech_cat", category: .technique, title: "Tech", srs: SRSState(nextDue: now))
        let rhythmItem = PracticeItem(catalogID: "test_rhythm_cat", category: .rhythm, title: "Rhythm", srs: SRSState(nextDue: now))

        [warmupItem, fretboardItem, songItem, soloItem, techniqueItem, rhythmItem].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)

        // Verify each block has correct kind based on its item's category
        for block in session.blocks {
            guard let itemID = block.practiceItemID,
                  let item = engine.items.first(where: { $0.id == itemID }) else {
                XCTFail("Block should have valid practiceItemID")
                continue
            }

            XCTAssertEqual(block.kind, item.blockKind, "Block kind should match item's blockKind")

            // Verify specific mappings
            switch item.category {
            case .warmup, .fretboard, .ear_training:
                XCTAssertEqual(block.kind, .warmup)
            case .songwork, .repertoire:
                XCTAssertEqual(block.kind, .song)
            case .soloing, .musicality:
                XCTAssertEqual(block.kind, .solo)
            case .technique, .theory, .rhythm, .chords:
                XCTAssertEqual(block.kind, .techniqueOrTheory)
            }
        }
    }

    func testGenerateTodaySessionPropagatesReferenceID() {
        let now = Date(timeIntervalSince1970: 10000)
        let engine = SpacedRepetitionEngine()

        // Create items with referenceIDs
        let itemWithRef = PracticeItem(
            catalogID: "test_am_pent",
            category: .fretboard,
            title: "Am Pentatonic",
            referenceID: "scale_am_pentatonic_pos1",
            srs: SRSState(nextDue: now)
        )
        let itemWithoutRef = PracticeItem(
            catalogID: "test_bends",
            category: .technique,
            title: "Bends",
            referenceID: nil,
            srs: SRSState(nextDue: now)
        )
        let itemWithRef2 = PracticeItem(
            catalogID: "test_blues_licks",
            category: .soloing,
            title: "Blues Licks",
            referenceID: "licks_blues_box1",
            srs: SRSState(nextDue: now)
        )
        let itemWithRef3 = PracticeItem(
            catalogID: "test_chromatic",
            category: .warmup,
            title: "Chromatic",
            referenceID: "warmup_chromatic",
            srs: SRSState(nextDue: now)
        )

        [itemWithRef, itemWithoutRef, itemWithRef2, itemWithRef3].forEach(engine.addItem)

        let session = engine.generateTodaySession(now: now)

        // Verify referenceID is correctly propagated to blocks
        for block in session.blocks {
            guard let itemID = block.practiceItemID,
                  let item = engine.items.first(where: { $0.id == itemID }) else {
                XCTFail("Block should have valid practiceItemID")
                continue
            }

            XCTAssertEqual(block.referenceID, item.referenceID, "Block referenceID should match item's referenceID")
        }

        // Verify at least one block has a referenceID
        let blocksWithRef = session.blocks.filter { $0.referenceID != nil }
        XCTAssertGreaterThan(blocksWithRef.count, 0, "Should have at least one block with a referenceID")
    }

    // MARK: - Session Structure Tests (6-8 Block Requirements)

    func testGenerateTodaySession_alwaysStartsWithWarmup() {
        // Given: Engine with mixed items
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()

        // When: Generate multiple sessions
        for _ in 0..<10 {
            let session = sre.generateTodaySession()

            // Then: First block should always be warmup
            let firstBlock = session.blocks.first
            XCTAssertEqual(firstBlock?.kind, .warmup,
                "First block must be warmup")
            XCTAssertLessThanOrEqual(firstBlock?.targetMinutes ?? 0, 3,
                "Warmup should be 2-3 minutes")
        }
    }

    func testGenerateTodaySession_alwaysEndsWithFunActivity() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()

        let session = sre.generateTodaySession()

        let lastBlock = session.blocks.last
        XCTAssertEqual(lastBlock?.kind, .song,
            "Last block should be a song/fun activity")
        XCTAssertGreaterThanOrEqual(lastBlock?.targetMinutes ?? 0, 5,
            "Fun ending should be at least 5 minutes")
    }

    func testGenerateTodaySession_respectsDurationTarget() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()

        let session = sre.generateTodaySession(targetMinutes: 35)

        let total = session.totalTargetMinutes
        XCTAssertGreaterThanOrEqual(total, 20,
            "Session should be at least 20 minutes")
        XCTAssertLessThanOrEqual(total, 45,
            "Session should not exceed 45 minutes")
    }

    func testGenerateTodaySession_generates6to8Blocks() {
        let sre = SpacedRepetitionEngine()
        sre.loadSeedCatalog()

        let session = sre.generateTodaySession()

        XCTAssertGreaterThanOrEqual(session.blocks.count, 6,
            "Should have at least 6 blocks")
        XCTAssertLessThanOrEqual(session.blocks.count, 8,
            "Should have at most 8 blocks")
    }
    
    // MARK: - Tempo Learning Tests
    
    func testApplyTempoLearningUpdatesItemTempo() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            catalogID: "test_tempo",
            category: .warmup,
            title: "Test Warmup",
            tempo: TempoState(currentBPM: 60)
        )
        engine.addItem(item)
        
        // Create a block with tempo data
        let block = PracticeBlock(
            kind: .warmup,
            title: "Test Warmup",
            practiceItemID: item.id,
            feedback: .good,
            startingBPM: 60,
            endingBPM: 65,
            tempoAdjustmentCount: 1
        )
        
        engine.applyTempoLearning(for: [block])
        
        // Verify item tempo was updated
        let updatedItem = engine.item(withID: item.id)
        XCTAssertNotNil(updatedItem)
        XCTAssertEqual(updatedItem?.tempo.history.count, 1)
        XCTAssertEqual(updatedItem?.tempo.history.first?.startBPM, 60)
        XCTAssertEqual(updatedItem?.tempo.history.first?.endBPM, 65)
        XCTAssertEqual(updatedItem?.tempo.history.first?.adjustmentCount, 1)
        XCTAssertEqual(updatedItem?.tempo.history.first?.feedback, .good)
        // Good feedback should increase currentBPM by 5
        XCTAssertEqual(updatedItem?.tempo.currentBPM, 70)
    }
    
    func testApplyTempoLearningSkipsBlocksWithoutTempoData() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            catalogID: "test_tempo_skip",
            category: .warmup,
            title: "Test Warmup",
            tempo: TempoState(currentBPM: 60)
        )
        engine.addItem(item)
        
        // Create a block without tempo data (like a song block)
        let block = PracticeBlock(
            kind: .song,
            title: "Test Song",
            practiceItemID: item.id,
            feedback: .good
            // No startingBPM or endingBPM
        )
        
        engine.applyTempoLearning(for: [block])
        
        // Verify item tempo was NOT updated (no history)
        let updatedItem = engine.item(withID: item.id)
        XCTAssertEqual(updatedItem?.tempo.history.count, 0)
        XCTAssertEqual(updatedItem?.tempo.currentBPM, 60)
    }
    
    func testApplyTempoLearningIgnoresMissingItems() {
        let engine = SpacedRepetitionEngine()
        
        // Create a block with an unknown item ID
        let block = PracticeBlock(
            kind: .warmup,
            title: "Unknown",
            practiceItemID: UUID(), // Random ID not in engine
            feedback: .good,
            startingBPM: 60,
            endingBPM: 70
        )
        
        // Should not crash
        engine.applyTempoLearning(for: [block])
    }
    
    func testGenerateTodaySessionSetsStartingBPM() {
        let engine = SpacedRepetitionEngine()
        engine.loadSeedCatalog()
        
        let session = engine.generateTodaySession()
        
        // Check that warmup blocks have startingBPM set
        for block in session.blocks {
            if block.kind.defaultMetronomeOn {
                XCTAssertNotNil(block.startingBPM, "\(block.kind) block should have startingBPM")
            } else {
                XCTAssertNil(block.startingBPM, "\(block.kind) block should NOT have startingBPM")
            }
        }
    }

    func testApplyFeedbackAndTempoLearningTogether() {
        let now = Date(timeIntervalSince1970: 12_345)
        let item = PracticeItem(
            catalogID: "test_combo",
            category: .technique,
            title: "Combo Item",
            srs: SRSState(stability: 1.5, nextDue: now),
            tempo: TempoState(currentBPM: 70)
        )

        let engine = SpacedRepetitionEngine()
        engine.addItem(item)

        let blocks = [
            PracticeBlock(
                kind: .techniqueOrTheory,
                title: "Block",
                practiceItemID: item.id,
                feedback: .good,
                startingBPM: 70,
                endingBPM: 75,
                tempoAdjustmentCount: 2
            )
        ]

        engine.applyFeedback(for: blocks, now: now)
        engine.applyTempoLearning(for: blocks)

        guard let updated = engine.item(withID: item.id) else {
            return XCTFail("Item should still exist after updates")
        }

        XCTAssertNotNil(updated.srs.lastPlayed)
        XCTAssertGreaterThan(updated.srs.stability, item.srs.stability)
        XCTAssertEqual(updated.tempo.history.first?.adjustmentCount, 2)
        XCTAssertGreaterThan(updated.tempo.currentBPM, item.tempo.currentBPM)
    }
    
    func testItemLookup() {
        let engine = SpacedRepetitionEngine()
        let item = PracticeItem(
            catalogID: "test_lookup",
            category: .warmup,
            title: "Test Lookup"
        )
        engine.addItem(item)
        
        // Find by ID
        let found = engine.item(withID: item.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.id, item.id)
        
        // Non-existent ID returns nil
        let notFound = engine.item(withID: UUID())
        XCTAssertNil(notFound)
    }
}
