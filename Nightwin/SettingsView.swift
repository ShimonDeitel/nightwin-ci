import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: NightwinStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("nightwin_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("nightwin_reminder_enabled") private var reminderEnabled: Bool = false
    @State private var activeSheet: NightwinSheet?
    @State private var showResetConfirm = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Haptic feedback", isOn: $hapticsEnabled)
                        .accessibilityIdentifier("hapticsToggle")
                    Toggle("Nightly reminder", isOn: $reminderEnabled)
                        .accessibilityIdentifier("reminderToggle")
                }

                Section("Stats") {
                    HStack {
                        Text("Total Wins")
                        Spacer()
                        Text("\(store.constellation.totalWins)")
                            .foregroundStyle(NWTheme.inkFaded)
                    }
                    HStack {
                        Text("Current Streak")
                        Spacer()
                        Text("\(store.constellation.currentStreak)")
                            .foregroundStyle(NWTheme.inkFaded)
                    }
                    HStack {
                        Text("Best Streak")
                        Spacer()
                        Text("\(store.constellation.bestStreak)")
                            .foregroundStyle(NWTheme.inkFaded)
                    }
                }

                Section("Nightwin Pro") {
                    if purchases.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(NWTheme.amber)
                    } else {
                        Button("Upgrade to Pro") {
                            activeSheet = .paywall
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("upgradeProButton")
                    }
                    Button("Restore Purchases") {
                        Task {
                            await purchases.restore()
                            restoreMessage = purchases.isPro ? "Purchases restored." : "No purchases found."
                        }
                    }
                    .buttonStyle(.plain)
                    if let restoreMessage {
                        Text(restoreMessage)
                            .font(.caption)
                            .foregroundStyle(NWTheme.inkFaded)
                    }
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/nightwin-site/privacy.html")!)
                    Link("Contact Support", destination: URL(string: "mailto:s0533495227@gmail.com")!)
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(NWTheme.inkFaded)
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirm = true
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
            .background(NWTheme.backdrop)
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all wins?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .paywall:
                    PaywallView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NightwinStore())
        .environmentObject(PurchaseManager())
}
