import XCTest
@testable import Nightwin

final class NightwinTests: XCTestCase {
    var store: NightwinStore!

    @MainActor
    override func setUp() {
        super.setUp()
        store = NightwinStore()
        store.deleteAllData()
        for e in store.entries { store.deleteEntry(e.id) }
    }

    @MainActor
    func testLogWinCreatesEntry() {
        let ok = store.logWin(text: "Learned something new")
        XCTAssertTrue(ok)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries[0].text, "Learned something new")
    }

    @MainActor
    func testLogWinRejectsEmptyText() {
        let ok = store.logWin(text: "   ")
        XCTAssertFalse(ok)
        XCTAssertTrue(store.entries.isEmpty)
    }

    @MainActor
    func testLogWinSameDayUpdatesNotDuplicates() {
        let today = Date()
        _ = store.logWin(text: "First version", date: today)
        _ = store.logWin(text: "Edited version", date: today)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries[0].text, "Edited version")
    }

    @MainActor
    func testLogWinDifferentDaysCreatesSeparateEntries() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        _ = store.logWin(text: "Yesterday's win", date: yesterday)
        _ = store.logWin(text: "Today's win", date: today)
        XCTAssertEqual(store.entries.count, 2)
    }

    @MainActor
    func testTodayEntryReturnsCorrectEntry() {
        _ = store.logWin(text: "Today's win")
        XCTAssertEqual(store.todayEntry?.text, "Today's win")
    }

    @MainActor
    func testDeleteEntry() {
        _ = store.logWin(text: "Temp win")
        let id = store.entries[0].id
        store.deleteEntry(id)
        XCTAssertTrue(store.entries.isEmpty)
    }

    // MARK: - Constellation math

    func testCurrentStreakCountsConsecutiveDaysEndingToday() {
        let calendar = Calendar.current
        let today = Date()
        let entries = (0..<3).map { offset in
            WinEntry(text: "Win \(offset)", date: calendar.date(byAdding: .day, value: -offset, to: today)!)
        }
        let result = ConstellationCalculator.compute(entries: entries, today: today)
        XCTAssertEqual(result.currentStreak, 3)
    }

    func testCurrentStreakZeroWhenGapBeforeToday() {
        let calendar = Calendar.current
        let today = Date()
        let entries = [
            WinEntry(text: "Old win", date: calendar.date(byAdding: .day, value: -3, to: today)!)
        ]
        let result = ConstellationCalculator.compute(entries: entries, today: today)
        XCTAssertEqual(result.currentStreak, 0)
    }

    func testCurrentStreakToleratesMissingTodayIfYesterdayLogged() {
        // If today hasn't been logged yet, the streak should still count
        // from yesterday backwards (so logging late at night doesn't zero
        // out an otherwise-intact streak before the user has a chance).
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBefore = calendar.date(byAdding: .day, value: -2, to: today)!
        let entries = [
            WinEntry(text: "A", date: dayBefore),
            WinEntry(text: "B", date: yesterday)
        ]
        let result = ConstellationCalculator.compute(entries: entries, today: today)
        XCTAssertEqual(result.currentStreak, 2)
    }

    func testBestStreakFindsLongestHistoricalRun() {
        let calendar = Calendar.current
        let today = Date()
        // Two separate runs: a 2-day run far in the past, then a 4-day
        // gap, then a 4-day run ending today.
        var entries: [WinEntry] = []
        for offset in [10, 9] {
            entries.append(WinEntry(text: "old\(offset)", date: calendar.date(byAdding: .day, value: -offset, to: today)!))
        }
        for offset in [3, 2, 1, 0] {
            entries.append(WinEntry(text: "recent\(offset)", date: calendar.date(byAdding: .day, value: -offset, to: today)!))
        }
        let result = ConstellationCalculator.compute(entries: entries, today: today)
        XCTAssertEqual(result.bestStreak, 4)
        XCTAssertEqual(result.currentStreak, 4)
    }

    func testTotalWinsMatchesEntryCount() {
        let entries = [
            WinEntry(text: "A"),
            WinEntry(text: "B"),
            WinEntry(text: "C")
        ]
        let result = ConstellationCalculator.compute(entries: entries)
        XCTAssertEqual(result.totalWins, 3)
    }

    func testEmptyEntriesResultsInZeroStreaks() {
        let result = ConstellationCalculator.compute(entries: [])
        XCTAssertEqual(result.currentStreak, 0)
        XCTAssertEqual(result.bestStreak, 0)
        XCTAssertEqual(result.totalWins, 0)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        _ = store.logWin(text: "Extra win")
        store.deleteAllData()
        XCTAssertFalse(store.entries.isEmpty)
    }
}
