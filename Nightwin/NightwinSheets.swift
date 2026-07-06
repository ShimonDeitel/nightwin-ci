import SwiftUI

enum NightwinSheet: Identifiable {
    case logWin
    case paywall

    var id: String {
        switch self {
        case .logWin: return "logWin"
        case .paywall: return "paywall"
        }
    }
}

struct LogWinFormView: View {
    @EnvironmentObject private var store: NightwinStore
    @Environment(\.dismiss) private var dismiss

    @State private var text: String

    init() {
        _text = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tonight's Win") {
                    TextField("One line about today", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityIdentifier("winTextField")
                }
            }
            .scrollContentBackground(.hidden)
            .background(NWTheme.backdrop)
            .dismissKeyboardOnTap()
            .navigationTitle("Log Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(.plain)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _ = store.logWin(text: text)
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("saveWinButton")
                }
            }
            .onAppear {
                if let today = store.todayEntry {
                    text = today.text
                }
            }
        }
    }
}
