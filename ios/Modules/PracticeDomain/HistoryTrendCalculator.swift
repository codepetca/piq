import Foundation

/// A utility for computing simple trend statistics from practice sessions.
/// This helper keeps trend calculation logic separate from SwiftUI for testability.
struct HistoryTrendCalculator {

    /// The calendar used for date calculations.
    let calendar: Calendar

    /// The reference date used for "this week" and "last week" comparisons.
    let referenceDate: Date

    /// Creates a trend calculator.
    /// - Parameters:
    ///   - calendar: The calendar to use for date calculations (defaults to current).
    ///   - referenceDate: The reference date for week calculations (defaults to now).
    init(calendar: Calendar = .current, referenceDate: Date = Date()) {
        self.calendar = calendar
        self.referenceDate = referenceDate
    }

    // MARK: - Week Boundaries

    /// Returns the start of the current week.
    var startOfThisWeek: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate))!
    }

    /// Returns the start of last week.
    var startOfLastWeek: Date {
        calendar.date(byAdding: .day, value: -7, to: startOfThisWeek)!
    }

    // MARK: - Minutes Calculations

    /// Total minutes practiced this week.
    func minutesThisWeek(from sessions: [PracticeSession]) -> Int {
        sessions
            .filter { $0.date >= startOfThisWeek }
            .reduce(0) { $0 + $1.totalActualMinutes }
    }

    /// Total minutes practiced last week.
    func minutesLastWeek(from sessions: [PracticeSession]) -> Int {
        sessions
            .filter { $0.date >= startOfLastWeek && $0.date < startOfThisWeek }
            .reduce(0) { $0 + $1.totalActualMinutes }
    }

    // MARK: - Session Counts

    /// Number of sessions this week.
    func sessionsThisWeek(from sessions: [PracticeSession]) -> Int {
        sessions.filter { $0.date >= startOfThisWeek }.count
    }

    /// Number of unique days with sessions this week.
    func daysWithSessionsThisWeek(from sessions: [PracticeSession]) -> Int {
        let thisWeekSessions = sessions.filter { $0.date >= startOfThisWeek }
        let uniqueDays = Set(thisWeekSessions.map { calendar.startOfDay(for: $0.date) })
        return uniqueDays.count
    }

    // MARK: - Trend Text

    /// Formatted trend text comparing this week vs last week.
    /// Returns nil if no sessions exist.
    func weeklyTrendText(from sessions: [PracticeSession]) -> String? {
        guard !sessions.isEmpty else { return nil }

        let thisWeek = minutesThisWeek(from: sessions)
        let lastWeek = minutesLastWeek(from: sessions)

        if thisWeek == 0 && lastWeek == 0 {
            return nil
        }

        if lastWeek == 0 && thisWeek > 0 {
            return "\(thisWeek) min this week"
        }

        if thisWeek > lastWeek {
            let diff = thisWeek - lastWeek
            return "\(thisWeek) min this week (+\(diff))"
        } else if thisWeek < lastWeek {
            let diff = lastWeek - thisWeek
            return "\(thisWeek) min this week (-\(diff))"
        } else {
            return "\(thisWeek) min this week"
        }
    }

    /// Formatted practice days text for this week.
    /// Returns nil if no sessions this week.
    func practiceDaysText(from sessions: [PracticeSession]) -> String? {
        let days = daysWithSessionsThisWeek(from: sessions)
        guard days > 0 else { return nil }
        return days == 1 ? "Practiced 1 day this week" : "Practiced \(days) days this week"
    }
}
