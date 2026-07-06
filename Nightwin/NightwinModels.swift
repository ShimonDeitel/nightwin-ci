import Foundation

/// A single one-line nightly journal entry: "today's win".
struct WinEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var date: Date

    init(id: UUID = UUID(), text: String, date: Date = Date()) {
        self.id = id
        self.text = text
        self.date = date
    }

    /// Calendar day this entry belongs to, used for streak/dedup logic.
    var day: Date {
        Calendar.current.startOfDay(for: date)
    }
}

/// Aggregate stats for the quirky "Constellation" feature: a running
/// streak of consecutive days with a logged win, each represented as one
/// lit star, plus the longest streak ever achieved.
struct ConstellationResult {
    let currentStreak: Int
    let bestStreak: Int
    let totalWins: Int
}

enum ConstellationCalculator {
    /// Computes the current consecutive-day streak (counting back from
    /// today or yesterday, so a single missed day doesn't retroactively
    /// invalidate an in-progress streak check performed later the same
    /// day) and the best streak ever recorded across all entries.
    static func compute(entries: [WinEntry], today: Date = Date()) -> ConstellationResult {
        guard !entries.isEmpty else {
            return ConstellationResult(currentStreak: 0, bestStreak: 0, totalWins: 0)
        }
        let calendar = Calendar.current
        let days = Set(entries.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = days.sorted(by: >)

        // Current streak: start from today (or yesterday if today has no
        // entry yet) and count backwards while consecutive days exist.
        var streak = 0
        var cursor = calendar.startOfDay(for: today)
        if !days.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        while days.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }

        // Best streak ever: scan all days for the longest consecutive run.
        var best = 0
        var running = 0
        var previous: Date?
        for day in sortedDays.reversed() {
            if let previous, calendar.date(byAdding: .day, value: 1, to: previous) == day {
                running += 1
            } else {
                running = 1
            }
            best = max(best, running)
            previous = day
        }

        return ConstellationResult(currentStreak: streak, bestStreak: best, totalWins: entries.count)
    }
}
