import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "guitars")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    RootView()
}
