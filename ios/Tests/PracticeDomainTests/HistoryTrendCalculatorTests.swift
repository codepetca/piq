import Foundation
import XCTest
@testable import piq

final class HistoryTrendCalculatorTests: XCTestCase {

    // MARK: - Test Helpers

    /// Creates a sample session with the given date and total minutes.
    func makeSampleSession(date: Date, totalMinutes: Int = 40) -> PracticeSession {
        let minutesPerBlock = totalMinutes / 4
        let blocks = [
            PracticeBlock(kind: .warmup, title: "Warm-Up", targetMinutes: 10, actualMinutes: minutesPerBlock),
            PracticeBlock(kind: .song, title: "Song", targetMinutes: 10, actualMinutes: minutesPerBlock),
            PracticeBlock(kind: .solo, title: "Solo", targetMinutes: 10, actualMinutes: minutesPerBlock),
            PracticeBlock(kind: .techniqueOrTheory, title: "Technique", targetMinutes: 10, actualMinutes: minutesPerBlock)
        ]
        return PracticeSession(id: UUID(), date: date, blocks: blocks)
    }

    /// Creates a fixed reference date for testing.
    func makeReferenceDate() -> Date {
        // Wednesday, November 26, 2025, 12:00 PM
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 26
        components.hour = 12
        return Calendar.current.date(from: components)!
    }

    // MARK: - Minutes This Week Tests

    func testMinutesThisWeekCalculatesCorrectly() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfWeek = calculator.startOfThisWeek

        // Session during this week
        let inWeekDate = Calendar.current.date(byAdding: .day, value: 1, to: startOfWeek)!
        let session1 = makeSampleSession(date: inWeekDate, totalMinutes: 32)
        let session2 = makeSampleSession(date: referenceDate, totalMinutes: 20)

        let sessions = [session1, session2]
        let result = calculator.minutesThisWeek(from: sessions)

        XCTAssertEqual(result, 52)
    }

    func testMinutesThisWeekExcludesLastWeekSessions() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        // Session from last week
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -10, to: referenceDate)!
        let lastWeekSession = makeSampleSession(date: lastWeekDate, totalMinutes: 60)
        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 20)

        let sessions = [lastWeekSession, thisWeekSession]
        let result = calculator.minutesThisWeek(from: sessions)

        XCTAssertEqual(result, 20)
    }

    func testMinutesThisWeekReturnsZeroWithNoSessions() {
        let calculator = HistoryTrendCalculator(referenceDate: makeReferenceDate())
        let result = calculator.minutesThisWeek(from: [])
        XCTAssertEqual(result, 0)
    }

    // MARK: - Minutes Last Week Tests

    func testMinutesLastWeekCalculatesCorrectly() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfThisWeek = calculator.startOfThisWeek

        // Session from last week (before start of this week)
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -3, to: startOfThisWeek)!
        let lastWeekSession = makeSampleSession(date: lastWeekDate, totalMinutes: 60)
        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 20)

        let sessions = [thisWeekSession, lastWeekSession]
        let result = calculator.minutesLastWeek(from: sessions)

        XCTAssertEqual(result, 60)
    }

    func testMinutesLastWeekExcludesThisWeekSessions() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 40)

        let sessions = [thisWeekSession]
        let result = calculator.minutesLastWeek(from: sessions)

        XCTAssertEqual(result, 0)
    }

    func testMinutesLastWeekExcludesOlderSessions() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        // Session from two weeks ago
        let twoWeeksAgoDate = Calendar.current.date(byAdding: .day, value: -14, to: referenceDate)!
        let oldSession = makeSampleSession(date: twoWeeksAgoDate, totalMinutes: 100)

        let sessions = [oldSession]
        let result = calculator.minutesLastWeek(from: sessions)

        XCTAssertEqual(result, 0)
    }

    // MARK: - Days With Sessions Tests

    func testDaysWithSessionsThisWeekCountsUniqueDays() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfWeek = calculator.startOfThisWeek

        let dayOne = Calendar.current.date(byAdding: .day, value: 1, to: startOfWeek)!
        let dayTwo = Calendar.current.date(byAdding: .day, value: 2, to: startOfWeek)!

        // Two sessions on day one, one on day two
        let session1 = makeSampleSession(date: dayOne)
        let session2 = makeSampleSession(date: dayOne)
        let session3 = makeSampleSession(date: dayTwo)

        let sessions = [session1, session2, session3]
        let result = calculator.daysWithSessionsThisWeek(from: sessions)

        XCTAssertEqual(result, 2)
    }

    func testDaysWithSessionsThisWeekReturnsZeroWithNoSessions() {
        let calculator = HistoryTrendCalculator(referenceDate: makeReferenceDate())
        let result = calculator.daysWithSessionsThisWeek(from: [])
        XCTAssertEqual(result, 0)
    }

    func testDaysWithSessionsThisWeekExcludesLastWeekSessions() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        // Only sessions from last week
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -10, to: referenceDate)!
        let lastWeekSession = makeSampleSession(date: lastWeekDate)

        let sessions = [lastWeekSession]
        let result = calculator.daysWithSessionsThisWeek(from: sessions)

        XCTAssertEqual(result, 0)
    }

    // MARK: - Weekly Trend Text Tests

    func testWeeklyTrendTextShowsIncrease() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfThisWeek = calculator.startOfThisWeek
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -3, to: startOfThisWeek)!

        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 60)
        let lastWeekSession = makeSampleSession(date: lastWeekDate, totalMinutes: 40)

        let sessions = [thisWeekSession, lastWeekSession]
        let result = calculator.weeklyTrendText(from: sessions)

        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("60"))
        XCTAssertTrue(result!.contains("+20"))
    }

    func testWeeklyTrendTextShowsDecrease() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfThisWeek = calculator.startOfThisWeek
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -3, to: startOfThisWeek)!

        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 20)
        let lastWeekSession = makeSampleSession(date: lastWeekDate, totalMinutes: 60)

        let sessions = [thisWeekSession, lastWeekSession]
        let result = calculator.weeklyTrendText(from: sessions)

        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("20"))
        XCTAssertTrue(result!.contains("-40"))
    }

    func testWeeklyTrendTextShowsNoChangeWhenEqual() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfThisWeek = calculator.startOfThisWeek
        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -3, to: startOfThisWeek)!

        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 40)
        let lastWeekSession = makeSampleSession(date: lastWeekDate, totalMinutes: 40)

        let sessions = [thisWeekSession, lastWeekSession]
        let result = calculator.weeklyTrendText(from: sessions)

        XCTAssertNotNil(result)
        XCTAssertEqual(result, "40 min this week")
    }

    func testWeeklyTrendTextReturnsNilWithNoSessions() {
        let calculator = HistoryTrendCalculator(referenceDate: makeReferenceDate())
        let result = calculator.weeklyTrendText(from: [])
        XCTAssertNil(result)
    }

    func testWeeklyTrendTextShowsOnlyThisWeekWhenNoLastWeek() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        let thisWeekSession = makeSampleSession(date: referenceDate, totalMinutes: 32)

        let sessions = [thisWeekSession]
        let result = calculator.weeklyTrendText(from: sessions)

        XCTAssertNotNil(result)
        XCTAssertEqual(result, "32 min this week")
    }

    // MARK: - Practice Days Text Tests

    func testPracticeDaysTextReturnsNilWithNoSessions() {
        let calculator = HistoryTrendCalculator(referenceDate: makeReferenceDate())
        let result = calculator.practiceDaysText(from: [])
        XCTAssertNil(result)
    }

    func testPracticeDaysTextShowsSingularDay() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        let session = makeSampleSession(date: referenceDate)

        let sessions = [session]
        let result = calculator.practiceDaysText(from: sessions)

        XCTAssertEqual(result, "Practiced 1 day this week")
    }

    func testPracticeDaysTextShowsPluralDays() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)
        let startOfWeek = calculator.startOfThisWeek

        let dayOne = Calendar.current.date(byAdding: .day, value: 1, to: startOfWeek)!
        let dayTwo = Calendar.current.date(byAdding: .day, value: 2, to: startOfWeek)!
        let dayThree = Calendar.current.date(byAdding: .day, value: 3, to: startOfWeek)!

        let session1 = makeSampleSession(date: dayOne)
        let session2 = makeSampleSession(date: dayTwo)
        let session3 = makeSampleSession(date: dayThree)

        let sessions = [session1, session2, session3]
        let result = calculator.practiceDaysText(from: sessions)

        XCTAssertEqual(result, "Practiced 3 days this week")
    }

    func testPracticeDaysTextReturnsNilWhenOnlyLastWeekSessions() {
        let referenceDate = makeReferenceDate()
        let calculator = HistoryTrendCalculator(referenceDate: referenceDate)

        let lastWeekDate = Calendar.current.date(byAdding: .day, value: -10, to: referenceDate)!
        let lastWeekSession = makeSampleSession(date: lastWeekDate)

        let sessions = [lastWeekSession]
        let result = calculator.practiceDaysText(from: sessions)

        XCTAssertNil(result)
    }
}
