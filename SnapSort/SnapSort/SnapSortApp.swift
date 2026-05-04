import SwiftUI
import SwiftData

@main
struct SnapSortApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [ScreenshotItem.self, AppSettings.self])
    }
}
