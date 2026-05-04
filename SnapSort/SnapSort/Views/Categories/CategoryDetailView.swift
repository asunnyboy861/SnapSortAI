import SwiftUI
import SwiftData
import Photos

struct CategoryDetailView: View {
    let category: ScreenshotCategory
    @Environment(\.modelContext) private var modelContext
    @Query private var allScreenshots: [ScreenshotItem]
    @State private var selectedScreenshot: ScreenshotItem?

    private var screenshots: [ScreenshotItem] {
        allScreenshots.filter { $0.category == category }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if screenshots.isEmpty {
                    ContentUnavailableView(
                        "No \(category.rawValue) Screenshots",
                        systemImage: category.icon,
                        description: Text("Screenshots categorized as \(category.rawValue.lowercased()) will appear here.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(screenshots) { item in
                                ScreenshotGridItem(item: item)
                                    .onTapGesture {
                                        selectedScreenshot = item
                                    }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
            .navigationTitle(category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedScreenshot) { item in
                ScreenshotDetailView(item: item)
            }
        }
    }
}
