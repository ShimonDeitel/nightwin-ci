import SwiftUI

struct NightwinHomeView: View {
    @EnvironmentObject private var store: NightwinStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var activeSheet: NightwinSheet?

    var body: some View {
        NavigationStack {
            ZStack {
                NWTheme.backdrop.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Nightwin")
                                .font(NWTheme.titleFont)
                                .foregroundStyle(NWTheme.ink)
                            Spacer()
                            Button {
                                activeSheet = .logWin
                            } label: {
                                Image(systemName: store.todayEntry == nil ? "plus.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(NWTheme.amber)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("logWinButton")
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 8)

                        constellationCard

                        if let today = store.todayEntry {
                            tonightCard(today)
                        }

                        if store.visibleEntries.isEmpty == false {
                            historyList
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .logWin:
                    LogWinFormView(initialText: store.todayEntry?.text ?? "")
                case .paywall:
                    PaywallView()
                }
            }
        }
    }

    /// Quirky signature feature: a "Constellation" — one star lights up
    /// per day with a logged win, forming a small growing night-sky streak
    /// visual instead of a plain numeric counter.
    private var constellationCard: some View {
        let result = store.constellation
        return VStack(spacing: 12) {
            Text("YOUR CONSTELLATION")
                .font(.caption2.weight(.bold))
                .foregroundStyle(NWTheme.inkFaded)
                .tracking(1.0)

            ConstellationView(litCount: result.currentStreak)
                .frame(height: 90)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("constellationView")
                .accessibilityValue("\(result.currentStreak) stars lit")

            Text("\(result.currentStreak) night\(result.currentStreak == 1 ? "" : "s") in a row")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(NWTheme.amberBright)

            Text("Best ever: \(result.bestStreak)")
                .font(.caption)
                .foregroundStyle(NWTheme.inkFaded)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(NWTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(NWTheme.rule, lineWidth: 1))
        .padding(.horizontal, 18)
    }

    private func tonightCard(_ entry: WinEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TONIGHT")
                .font(.caption2.weight(.bold))
                .foregroundStyle(NWTheme.inkFaded)
                .tracking(1.0)
            Text(entry.text)
                .font(NWTheme.headlineFont)
                .foregroundStyle(NWTheme.ink)
                .accessibilityIdentifier("tonightWinText")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(NWTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(NWTheme.rule, lineWidth: 1))
        .padding(.horizontal, 18)
    }

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PAST WINS")
                .font(.caption2.weight(.bold))
                .foregroundStyle(NWTheme.inkFaded)
                .tracking(1.0)
                .padding(.horizontal, 18)

            ForEach(store.visibleEntries) { entry in
                HistoryRow(entry: entry, onDelete: { store.deleteEntry(entry.id) })
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundStyle(NWTheme.inkFaded)
            Text("No wins logged yet")
                .font(NWTheme.headlineFont)
                .foregroundStyle(NWTheme.ink)
        }
        .padding(.top, 24)
        .padding(.horizontal, 18)
    }
}

/// A small horizontal row of star glyphs — lit (amber, filled) for each
/// day in the current streak, dim (outline) beyond it, capped at 7 visible
/// slots with an overflow count for longer streaks.
struct ConstellationView: View {
    let litCount: Int

    private var visibleSlots: Int { min(max(litCount, 1), 7) }
    private var overflow: Int { max(litCount - 7, 0) }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<visibleSlots, id: \.self) { index in
                Image(systemName: index < litCount ? "star.fill" : "star")
                    .font(.system(size: 26))
                    .foregroundStyle(index < litCount ? NWTheme.amberBright : NWTheme.inkFaded)
            }
            if overflow > 0 {
                Text("+\(overflow)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(NWTheme.amberBright)
            }
        }
    }
}

struct HistoryRow: View {
    let entry: WinEntry
    var onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(NWTheme.inkFaded)
                Text(entry.text)
                    .font(.subheadline)
                    .foregroundStyle(NWTheme.ink)
            }
            Spacer()
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(NWTheme.danger)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("deleteWin_\(entry.text)")
        }
        .padding(12)
        .background(NWTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(NWTheme.rule, lineWidth: 1))
        .padding(.horizontal, 18)
    }
}

#Preview {
    NightwinHomeView()
        .environmentObject(NightwinStore())
        .environmentObject(PurchaseManager())
}
