import Foundation

/// Engine for calculating and tracking tempo progression for practice items.
/// Implements adaptive tempo learning based on user behavior and feedback.
enum TempoEngine {
    
    // MARK: - Constants
    
    /// Minimum allowed BPM
    static let minBPM = 40
    /// Maximum allowed BPM
    static let maxBPM = 240
    /// Maximum history entries to keep
    static let maxHistoryCount = 10
    /// Number of recent sessions to use for weighted average
    static let weightedAverageSessions = 5
    /// Minimum progression rate
    static let minProgressionRate = 0.5
    /// Maximum progression rate
    static let maxProgressionRate = 2.0
    /// Consecutive feedbacks needed to adjust progression rate
    static let consecutiveFeedbacksForRateChange = 2
    
    // MARK: - Suggested BPM Calculation
    
    /// Calculate suggested starting BPM for a practice item.
    /// - Parameters:
    ///   - item: The practice item to calculate BPM for
    ///   - categoryDefaults: Dictionary mapping categories to their default BPMs
    /// - Returns: Suggested BPM clamped to valid range
    static func suggestedBPM(
        for item: PracticeItem,
        categoryDefaults: [PracticeItemCategory: Int] = [:]
    ) -> Int {
        let tempo = item.tempo
        
        // If no history, use current BPM (which defaults to category default)
        if tempo.history.isEmpty {
            let categoryDefault = categoryDefaults[item.category] ?? item.category.defaultBPM
            return clampBPM(max(tempo.currentBPM, categoryDefault))
        }
        
        // Calculate weighted average from recent sessions
        let weightedAvg = calculateWeightedAverageBPM(from: tempo.history)
        
        // Apply progression based on last session's feedback
        let progressionAdjustment = calculateProgressionAdjustment(
            history: tempo.history,
            progressionRate: tempo.progressionRate
        )
        
        var suggested = Int(Double(weightedAvg) + progressionAdjustment)
        
        // Respect target BPM if set
        if let target = tempo.targetBPM {
            suggested = min(suggested, target)
        }
        
        return clampBPM(suggested)
    }
    
    // MARK: - Tempo State Updates
    
    /// Update tempo state after completing a practice block.
    /// - Parameters:
    ///   - state: Current tempo state
    ///   - startBPM: BPM at block start
    ///   - endBPM: BPM at block end
    ///   - adjustmentCount: Number of user adjustments during practice
    ///   - feedback: User feedback for the block
    /// - Returns: Updated tempo state
    static func updateTempoState(
        _ state: TempoState,
        startBPM: Int,
        endBPM: Int,
        adjustmentCount: Int,
        feedback: PracticeBlockFeedback
    ) -> TempoState {
        var updated = state
        
        // Create new session record
        let session = TempoSession(
            date: Date(),
            startBPM: startBPM,
            endBPM: endBPM,
            adjustmentCount: adjustmentCount,
            feedback: feedback
        )
        
        // Add to history, keeping only last N entries
        updated.history.append(session)
        if updated.history.count > maxHistoryCount {
            updated.history.removeFirst(updated.history.count - maxHistoryCount)
        }
        
        // Update current BPM based on feedback
        updated.currentBPM = calculateNewCurrentBPM(
            endBPM: endBPM,
            feedback: feedback,
            progressionRate: state.progressionRate,
            targetBPM: state.targetBPM
        )
        
        // Store last practiced BPM
        updated.lastPracticedBPM = endBPM
        
        // Adjust progression rate based on feedback patterns
        updated.progressionRate = calculateProgressionRate(
            history: updated.history,
            currentRate: state.progressionRate
        )
        
        return updated
    }
    
    // MARK: - Helper Calculations
    
    /// Calculate weighted average BPM from recent history.
    /// More recent sessions have higher weight.
    /// - Parameter history: Array of tempo sessions
    /// - Returns: Weighted average BPM
    static func calculateWeightedAverageBPM(from history: [TempoSession]) -> Int {
        guard !history.isEmpty else { return 60 }
        
        // Take only the last N sessions
        let recentSessions = Array(history.suffix(weightedAverageSessions))
        
        // Weight: more recent = higher weight
        // e.g., for 5 sessions: weights are 1, 2, 3, 4, 5
        var weightedSum = 0.0
        var totalWeight = 0.0
        
        for (index, session) in recentSessions.enumerated() {
            let weight = Double(index + 1)
            // Use end BPM as it represents user's comfortable tempo
            weightedSum += Double(session.endBPM) * weight
            totalWeight += weight
        }
        
        return totalWeight > 0 ? Int(weightedSum / totalWeight) : 60
    }
    
    /// Calculate progression adjustment based on last session's feedback.
    /// - Parameters:
    ///   - history: Session history
    ///   - progressionRate: Current progression rate multiplier
    /// - Returns: BPM adjustment amount
    static func calculateProgressionAdjustment(
        history: [TempoSession],
        progressionRate: Double
    ) -> Double {
        guard let lastSession = history.last else { return 0 }
        
        switch lastSession.feedback {
        case .easy:
            // Increase by 10 BPM scaled by progression rate
            return 10.0 * progressionRate
        case .good:
            // Increase by 5 BPM scaled by progression rate
            return 5.0 * progressionRate
        case .hard:
            // No increase; user struggled
            return 0
        }
    }
    
    /// Calculate new current BPM based on feedback.
    /// - Parameters:
    ///   - endBPM: BPM at end of practice
    ///   - feedback: User feedback
    ///   - progressionRate: Current progression rate
    ///   - targetBPM: Optional target BPM cap
    /// - Returns: New current BPM
    static func calculateNewCurrentBPM(
        endBPM: Int,
        feedback: PracticeBlockFeedback,
        progressionRate: Double,
        targetBPM: Int?
    ) -> Int {
        var newBPM: Int
        
        switch feedback {
        case .easy:
            // User found it easy, increase for next time
            newBPM = endBPM + Int(10.0 * progressionRate)
        case .good:
            // User did well, small increase
            newBPM = endBPM + Int(5.0 * progressionRate)
        case .hard:
            // User struggled, keep at user's adjusted tempo (or slightly lower)
            newBPM = endBPM
        }
        
        // Respect target if set
        if let target = targetBPM {
            newBPM = min(newBPM, target)
        }
        
        return clampBPM(newBPM)
    }
    
    /// Calculate progression rate based on feedback patterns.
    /// Increases rate for consecutive easy feedbacks, decreases for consecutive hard.
    /// - Parameters:
    ///   - history: Session history
    ///   - currentRate: Current progression rate
    /// - Returns: Adjusted progression rate
    static func calculateProgressionRate(
        history: [TempoSession],
        currentRate: Double
    ) -> Double {
        let recentCount = consecutiveFeedbacksForRateChange
        guard history.count >= recentCount else { return currentRate }
        
        let recentSessions = history.suffix(recentCount)
        
        // Check for consecutive easy feedbacks
        if recentSessions.allSatisfy({ $0.feedback == .easy }) {
            return min(currentRate * 1.2, maxProgressionRate)
        }
        
        // Check for consecutive hard feedbacks
        if recentSessions.allSatisfy({ $0.feedback == .hard }) {
            return max(currentRate * 0.8, minProgressionRate)
        }
        
        // Gradual return to baseline (1.0) for mixed feedback
        if currentRate > 1.0 {
            return max(1.0, currentRate * 0.95)
        } else if currentRate < 1.0 {
            return min(1.0, currentRate * 1.05)
        }
        
        return currentRate
    }
    
    /// Clamp BPM to valid range.
    /// - Parameter bpm: Input BPM
    /// - Returns: BPM clamped between minBPM and maxBPM
    static func clampBPM(_ bpm: Int) -> Int {
        max(minBPM, min(maxBPM, bpm))
    }
}
