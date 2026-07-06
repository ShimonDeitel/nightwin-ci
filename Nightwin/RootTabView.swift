import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NightwinHomeView()
                .tabItem {
                    Label("Tonight", systemImage: "moon.stars.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(NWTheme.amber)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(NWTheme.surface)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(NightwinStore())
        .environmentObject(PurchaseManager())
}
