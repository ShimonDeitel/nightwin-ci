import Foundation
import Combine

@MainActor
final class NightwinStore: ObservableObject {
    @Published private(set) var entries: [WinEntry] = []

    static let freeHistoryLimit = 7

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("nightwin_data.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
        }
        load()
        if entries.isEmpty {
            seedDefaults()
        }
    }

    private func seedDefaults() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        entries = [
            WinEntry(text: "Finally fixed that annoying bug", date: yesterday),
            WinEntry(text: "Went for a walk before it got dark", date: now)
        ]
        save()
    }

    var todayEntry: WinEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.first { $0.day == today }
    }

    /// Free tier still lets you log every day (the core habit loop is
    /// never paywalled) — the limit only applies to how much PAST history
    /// is visible/browsable in the list.
    func canViewFullHistory(isPro: Bool) -> Bool {
        isPro || entries.count <= Self.freeHistoryLimit
    }

    var visibleEntries: [WinEntry] {
        entries.sorted { $0.date > $1.date }
    }

    @discardableResult
    func logWin(text: String, date: Date = Date()) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let day = Calendar.current.startOfDay(for: date)
        if let idx = entries.firstIndex(where: { $0.day == day }) {
            entries[idx].text = trimmed
        } else {
            entries.append(WinEntry(text: trimmed, date: date))
        }
        save()
        return true
    }

    func deleteEntry(_ id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        entries = []
        seedDefaults()
    }

    var constellation: ConstellationResult {
        ConstellationCalculator.compute(entries: entries)
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([WinEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
