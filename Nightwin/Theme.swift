import SwiftUI

/// Nightwin's identity: a midnight-indigo/warm-amber-candle palette —
/// evokes a bedside journal lit by a single warm light. Deliberately the
/// one DARK-mode app in this batch (fits the nightly-journal concept),
/// distinct from every sibling app's colors (no rust/asphalt, teal/mustard,
/// or plum/gold reused).
enum NWTheme {
    static let backdrop = Color(red: 0.075, green: 0.078, blue: 0.129)   // deep midnight-indigo
    static let surface = Color(red: 0.114, green: 0.118, blue: 0.180)
    static let surfaceRaised = Color(red: 0.145, green: 0.149, blue: 0.216)
    static let ink = Color(red: 0.925, green: 0.914, blue: 0.945)        // pale moonlight text
    static let inkFaded = Color(red: 0.925, green: 0.914, blue: 0.945).opacity(0.55)
    static let rule = Color.white.opacity(0.10)

    static let indigo = Color(red: 0.302, green: 0.302, blue: 0.596)    // midnight indigo accent
    static let amber = Color(red: 0.937, green: 0.706, blue: 0.286)     // candle-amber accent
    static let amberBright = Color(red: 0.976, green: 0.780, blue: 0.353)
    static let danger = Color(red: 0.847, green: 0.408, blue: 0.396)
    static let success = Color(red: 0.494, green: 0.729, blue: 0.518)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
