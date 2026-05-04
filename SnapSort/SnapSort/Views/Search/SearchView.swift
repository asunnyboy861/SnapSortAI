import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allScreenshots: [ScreenshotItem]
    @State private var searchText = ""
    @State private var selectedScreenshot: ScreenshotItem?
    @State private var isSearching = false

    private var searchResults: [ScreenshotItem] {
        if searchText.isEmpty {
            return []
        }
        return allScreenshots.filter { item in
            item.extractedText.localizedCaseInsensitiveContains(searchText) ||
            item.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    searchSuggestions
                } else if searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsGrid
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search by text or category")
        }
    }

    private var searchSuggestions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Search Categories")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(ScreenshotCategory.allCases, id: \.self) { category in
                        Button {
                            searchText = category.rawValue
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: category.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color(hex: category.color) ?? .blue)
                                Text(category.rawValue)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var noResultsView: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("No screenshots matching \"\(searchText)\" found.")
        )
    }

    private var searchResultsGrid: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(searchResults) { item in
                        ScreenshotGridItem(item: item)
                            .onTapGesture {
                                selectedScreenshot = item
                            }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .sheet(item: $selectedScreenshot) { item in
            ScreenshotDetailView(item: item)
        }
    }
}
