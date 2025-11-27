import XCTest
@testable import piq

final class TempoEngineTests: XCTestCase {
    
    // MARK: - Suggested BPM Tests
    
    func testSuggestedBPMForNewItemUsesCurrentBPM() {
        // New item with no history uses currentBPM (which defaults to category default)
        let item = PracticeItem(
            catalogID: "test_warmup",
            category: .warmup,
            title: "Test Warmup"
        )
        
        let suggested = TempoEngine.suggestedBPM(for: item)
        
        // Warmup category default is 60 BPM
        XCTAssertEqual(suggested, 60)
    }
    
    func testSuggestedBPMForNewItemWithCustomCurrentBPM() {
        let item = PracticeItem(
            catalogID: "test_technique",
            category: .technique,
            title: "Test Technique",
            tempo: TempoState(currentBPM: 100)
        )
        
        let suggested = TempoEngine.suggestedBPM(for: item)
        
        // Should use the higher of currentBPM (100) or category default (70)
        XCTAssertEqual(suggested, 100)
    }
    
    func testSuggestedBPMWithHistoryUsesWeightedAverage() {
        // Create item with history
        let sessions = [
            TempoSession(date: Date().addingTimeInterval(-3600), startBPM: 60, endBPM: 65, adjustmentCount: 1, feedback: .good),
            TempoSession(date: Date().addingTimeInterval(-1800), startBPM: 65, endBPM: 70, adjustmentCount: 0, feedback: .good)
        ]
        
        let tempo = TempoState(
            currentBPM: 70,
            history: sessions,
            progressionRate: 1.0
        )
        
        let item = PracticeItem(
            catalogID: "test_warmup",
            category: .warmup,
            title: "Test Warmup",
            tempo: tempo
        )
        
        let suggested = TempoEngine.suggestedBPM(for: item)
        
        // Weighted average of 65 and 70 (with weights 1 and 2) = (65*1 + 70*2) / 3 = 68.33
        // Plus progression adjustment for "good" feedback = +5
        // Should be around 73
        XCTAssertEqual(suggested, 73)
    }
    
    func testSuggestedBPMRespectsTargetBPM() {
        // Create item with history and target BPM
        let sessions = [
            TempoSession(date: Date(), startBPM: 115, endBPM: 118, adjustmentCount: 0, feedback: .easy)
        ]
        
        let tempo = TempoState(
            currentBPM: 118,
            targetBPM: 120,
            history: sessions,
            progressionRate: 1.0
        )
        
        let item = PracticeItem(
            catalogID: "test_warmup",
            category: .warmup,
            title: "Test Warmup",
            tempo: tempo
        )
        
        let suggested = TempoEngine.suggestedBPM(for: item)
        
        // Easy feedback would add +10, but target caps it at 120
        XCTAssertEqual(suggested, 120)
    }
    
    func testSuggestedBPMClampsToValidRange() {
        // Test minimum clamping
        let lowTempo = TempoState(currentBPM: 30)
        let lowItem = PracticeItem(
            catalogID: "test_low",
            category: .warmup,
            title: "Test Low",
            tempo: lowTempo
        )
        
        let lowSuggested = TempoEngine.suggestedBPM(for: lowItem)
        XCTAssertGreaterThanOrEqual(lowSuggested, TempoEngine.minBPM)
        
        // Test maximum clamping
        let highTempo = TempoState(currentBPM: 250)
        let highItem = PracticeItem(
            catalogID: "test_high",
            category: .warmup,
            title: "Test High",
            tempo: highTempo
        )
        
        let highSuggested = TempoEngine.suggestedBPM(for: highItem)
        XCTAssertLessThanOrEqual(highSuggested, TempoEngine.maxBPM)
    }
    
    // MARK: - Update Tempo State Tests
    
    func testUpdateTempoStateAddsSession() {
        let initialState = TempoState()
        
        let updated = TempoEngine.updateTempoState(
            initialState,
            startBPM: 60,
            endBPM: 65,
            adjustmentCount: 2,
            feedback: .good
        )
        
        XCTAssertEqual(updated.history.count, 1)
        XCTAssertEqual(updated.history[0].startBPM, 60)
        XCTAssertEqual(updated.history[0].endBPM, 65)
        XCTAssertEqual(updated.history[0].adjustmentCount, 2)
        XCTAssertEqual(updated.history[0].feedback, .good)
    }
    
    func testUpdateTempoStateKeepsMaxHistoryCount() {
        var state = TempoState()
        
        // Add 15 sessions (more than max of 10)
        for i in 0..<15 {
            state = TempoEngine.updateTempoState(
                state,
                startBPM: 60 + i,
                endBPM: 65 + i,
                adjustmentCount: 0,
                feedback: .good
            )
        }
        
        XCTAssertEqual(state.history.count, TempoEngine.maxHistoryCount)
        // Should have kept the most recent ones
        XCTAssertEqual(state.history.first?.startBPM, 65) // Session #6 (0-indexed: 5)
        XCTAssertEqual(state.history.last?.startBPM, 74)  // Session #15 (0-indexed: 14)
    }
    
    func testUpdateTempoStateUpdatesCurrentBPMForEasy() {
        let initialState = TempoState(currentBPM: 60, progressionRate: 1.0)
        
        let updated = TempoEngine.updateTempoState(
            initialState,
            startBPM: 60,
            endBPM: 60,
            adjustmentCount: 0,
            feedback: .easy
        )
        
        // Easy feedback should increase by 10 * progressionRate
        XCTAssertEqual(updated.currentBPM, 70)
    }
    
    func testUpdateTempoStateUpdatesCurrentBPMForGood() {
        let initialState = TempoState(currentBPM: 60, progressionRate: 1.0)
        
        let updated = TempoEngine.updateTempoState(
            initialState,
            startBPM: 60,
            endBPM: 60,
            adjustmentCount: 0,
            feedback: .good
        )
        
        // Good feedback should increase by 5 * progressionRate
        XCTAssertEqual(updated.currentBPM, 65)
    }
    
    func testUpdateTempoStateUpdatesCurrentBPMForHard() {
        let initialState = TempoState(currentBPM: 70, progressionRate: 1.0)
        
        let updated = TempoEngine.updateTempoState(
            initialState,
            startBPM: 70,
            endBPM: 60, // User decreased BPM during practice
            adjustmentCount: 3,
            feedback: .hard
        )
        
        // Hard feedback should use user's adjusted tempo
        XCTAssertEqual(updated.currentBPM, 60)
    }
    
    func testUpdateTempoStateUpdatesLastPracticedBPM() {
        let initialState = TempoState()
        
        let updated = TempoEngine.updateTempoState(
            initialState,
            startBPM: 60,
            endBPM: 75,
            adjustmentCount: 0,
            feedback: .easy
        )
        
        XCTAssertEqual(updated.lastPracticedBPM, 75)
    }
    
    func testUpdateTempoStateRespectsTargetBPM() {
        let initialState = TempoState(currentBPM: 115, targetBPM: 120, progressionRate: 1.0)
        
        let updated = TempoEngine.updateTempoState(
            initialState,
            startBPM: 115,
            endBPM: 118,
            adjustmentCount: 0,
            feedback: .easy
        )
        
        // Easy would add 10, but target caps at 120
        XCTAssertEqual(updated.currentBPM, 120)
    }
    
    // MARK: - Weighted Average Tests
    
    func testWeightedAverageWithSingleSession() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 80, adjustmentCount: 0, feedback: .good)
        ]
        
        let average = TempoEngine.calculateWeightedAverageBPM(from: sessions)
        
        // Single session, should just return its endBPM
        XCTAssertEqual(average, 80)
    }
    
    func testWeightedAverageWithMultipleSessions() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 50, endBPM: 60, adjustmentCount: 0, feedback: .hard),  // weight 1
            TempoSession(date: Date(), startBPM: 60, endBPM: 70, adjustmentCount: 0, feedback: .good),  // weight 2
            TempoSession(date: Date(), startBPM: 70, endBPM: 80, adjustmentCount: 0, feedback: .easy)   // weight 3
        ]
        
        let average = TempoEngine.calculateWeightedAverageBPM(from: sessions)
        
        // (60*1 + 70*2 + 80*3) / (1+2+3) = (60 + 140 + 240) / 6 = 73.33 -> 73
        XCTAssertEqual(average, 73)
    }
    
    func testWeightedAverageWithEmptyHistory() {
        let average = TempoEngine.calculateWeightedAverageBPM(from: [])
        
        // Default fallback
        XCTAssertEqual(average, 60)
    }
    
    // MARK: - Progression Adjustment Tests
    
    func testProgressionAdjustmentForEasy() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 65, adjustmentCount: 0, feedback: .easy)
        ]
        
        let adjustment = TempoEngine.calculateProgressionAdjustment(history: sessions, progressionRate: 1.0)
        
        XCTAssertEqual(adjustment, 10.0, accuracy: 0.01)
    }
    
    func testProgressionAdjustmentForGood() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 65, adjustmentCount: 0, feedback: .good)
        ]
        
        let adjustment = TempoEngine.calculateProgressionAdjustment(history: sessions, progressionRate: 1.0)
        
        XCTAssertEqual(adjustment, 5.0, accuracy: 0.01)
    }
    
    func testProgressionAdjustmentForHard() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 55, adjustmentCount: 2, feedback: .hard)
        ]
        
        let adjustment = TempoEngine.calculateProgressionAdjustment(history: sessions, progressionRate: 1.0)
        
        XCTAssertEqual(adjustment, 0.0, accuracy: 0.01)
    }
    
    func testProgressionAdjustmentWithHighProgressionRate() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 65, adjustmentCount: 0, feedback: .easy)
        ]
        
        let adjustment = TempoEngine.calculateProgressionAdjustment(history: sessions, progressionRate: 2.0)
        
        // Easy adjustment is 10 * 2.0 = 20
        XCTAssertEqual(adjustment, 20.0, accuracy: 0.01)
    }
    
    func testProgressionAdjustmentWithLowProgressionRate() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 65, adjustmentCount: 0, feedback: .good)
        ]
        
        let adjustment = TempoEngine.calculateProgressionAdjustment(history: sessions, progressionRate: 0.5)
        
        // Good adjustment is 5 * 0.5 = 2.5
        XCTAssertEqual(adjustment, 2.5, accuracy: 0.01)
    }
    
    // MARK: - Progression Rate Adjustment Tests
    
    func testProgressionRateIncreasesForConsecutiveEasy() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 70, adjustmentCount: 0, feedback: .easy),
            TempoSession(date: Date(), startBPM: 70, endBPM: 80, adjustmentCount: 0, feedback: .easy)
        ]
        
        let newRate = TempoEngine.calculateProgressionRate(history: sessions, currentRate: 1.0)
        
        // Should increase by 20%
        XCTAssertEqual(newRate, 1.2, accuracy: 0.01)
    }
    
    func testProgressionRateDecreasesForConsecutiveHard() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 80, endBPM: 70, adjustmentCount: 3, feedback: .hard),
            TempoSession(date: Date(), startBPM: 70, endBPM: 60, adjustmentCount: 2, feedback: .hard)
        ]
        
        let newRate = TempoEngine.calculateProgressionRate(history: sessions, currentRate: 1.0)
        
        // Should decrease by 20%
        XCTAssertEqual(newRate, 0.8, accuracy: 0.01)
    }
    
    func testProgressionRateCapsAtMaximum() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 70, adjustmentCount: 0, feedback: .easy),
            TempoSession(date: Date(), startBPM: 70, endBPM: 80, adjustmentCount: 0, feedback: .easy)
        ]
        
        let newRate = TempoEngine.calculateProgressionRate(history: sessions, currentRate: 1.9)
        
        // Should cap at 2.0
        XCTAssertLessThanOrEqual(newRate, TempoEngine.maxProgressionRate)
    }
    
    func testProgressionRateCapsAtMinimum() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 80, endBPM: 70, adjustmentCount: 3, feedback: .hard),
            TempoSession(date: Date(), startBPM: 70, endBPM: 60, adjustmentCount: 2, feedback: .hard)
        ]
        
        let newRate = TempoEngine.calculateProgressionRate(history: sessions, currentRate: 0.6)
        
        // Should cap at 0.5
        XCTAssertGreaterThanOrEqual(newRate, TempoEngine.minProgressionRate)
    }
    
    func testProgressionRateGraduallyReturnsToBaseline() {
        let sessions = [
            TempoSession(date: Date(), startBPM: 60, endBPM: 65, adjustmentCount: 0, feedback: .good),
            TempoSession(date: Date(), startBPM: 65, endBPM: 70, adjustmentCount: 0, feedback: .easy)
        ]
        
        // Rate above baseline should gradually decrease
        let newRateHigh = TempoEngine.calculateProgressionRate(history: sessions, currentRate: 1.5)
        XCTAssertLessThan(newRateHigh, 1.5)
        XCTAssertGreaterThanOrEqual(newRateHigh, 1.0)
        
        // Rate below baseline should gradually increase
        let newRateLow = TempoEngine.calculateProgressionRate(history: sessions, currentRate: 0.7)
        XCTAssertGreaterThan(newRateLow, 0.7)
        XCTAssertLessThanOrEqual(newRateLow, 1.0)
    }
    
    // MARK: - Clamp BPM Tests
    
    func testClampBPMWithinRange() {
        XCTAssertEqual(TempoEngine.clampBPM(100), 100)
    }
    
    func testClampBPMBelowMin() {
        XCTAssertEqual(TempoEngine.clampBPM(20), TempoEngine.minBPM)
    }
    
    func testClampBPMAboveMax() {
        XCTAssertEqual(TempoEngine.clampBPM(300), TempoEngine.maxBPM)
    }
    
    // MARK: - Category Default BPM Tests
    
    func testCategoryDefaultBPMs() {
        XCTAssertEqual(PracticeItemCategory.warmup.defaultBPM, 60)
        XCTAssertEqual(PracticeItemCategory.fretboard.defaultBPM, 50)
        XCTAssertEqual(PracticeItemCategory.technique.defaultBPM, 70)
        XCTAssertEqual(PracticeItemCategory.rhythm.defaultBPM, 85)
        XCTAssertEqual(PracticeItemCategory.chords.defaultBPM, 80)
        XCTAssertEqual(PracticeItemCategory.repertoire.defaultBPM, 100)
        XCTAssertEqual(PracticeItemCategory.songwork.defaultBPM, 100)
    }
    
    // MARK: - Integration Tests
    
    func testTypicalUserJourney() {
        // Start with a new item
        var item = PracticeItem(
            catalogID: "test_chromatic",
            category: .warmup,
            title: "Chromatic Exercise"
        )
        
        // Session 1: User finds 60 BPM comfortable, marks Good
        var tempo = TempoEngine.updateTempoState(
            item.tempo,
            startBPM: 60,
            endBPM: 60,
            adjustmentCount: 0,
            feedback: .good
        )
        item.tempo = tempo
        
        // Session 2: Should suggest around 65 BPM
        var suggested = TempoEngine.suggestedBPM(for: item)
        XCTAssertEqual(suggested, 65)
        
        // User marks Easy at 65 BPM
        tempo = TempoEngine.updateTempoState(
            item.tempo,
            startBPM: 65,
            endBPM: 65,
            adjustmentCount: 0,
            feedback: .easy
        )
        item.tempo = tempo
        
        // Session 3: Should suggest around 75 BPM
        suggested = TempoEngine.suggestedBPM(for: item)
        XCTAssertGreaterThanOrEqual(suggested, 73)
        XCTAssertLessThanOrEqual(suggested, 77)
        
        // User struggles, decreases to 70, marks Hard
        tempo = TempoEngine.updateTempoState(
            item.tempo,
            startBPM: 75,
            endBPM: 70,
            adjustmentCount: 2,
            feedback: .hard
        )
        item.tempo = tempo
        
        // Session 4: Should suggest around 70 BPM (respects user's decrease)
        suggested = TempoEngine.suggestedBPM(for: item)
        XCTAssertLessThanOrEqual(suggested, 72) // Should not jump back up
    }
}
