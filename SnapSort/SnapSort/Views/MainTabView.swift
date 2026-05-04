import SwiftUI

struct MainTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    LibraryView()
                        .tabItem {
                            Label("Library", systemImage: "photo.on.rectangle.angled")
                        }
                        .tag(0)

                    CategoryListView()
                        .tabItem {
                            Label("Categories", systemImage: "folder.fill")
                        }
                        .tag(1)

                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(2)

                    CleanupView()
                        .tabItem {
                            Label("Cleanup", systemImage: "trash.circle")
                        }
                        .tag(3)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(4)
                }
            }
        }
    }
}
