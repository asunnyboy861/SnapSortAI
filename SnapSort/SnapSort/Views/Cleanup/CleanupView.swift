import SwiftUI
import SwiftData
import Photos

struct CleanupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ScreenshotItem> { $0.isTemporary == true },
           sort: \ScreenshotItem.createdAt,
           order: .reverse) private var temporaryScreenshots: [ScreenshotItem]
    @State private var selectedItems: Set<String> = []
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false

    private var groupedByCategory: [(ScreenshotCategory, [ScreenshotItem])] {
        let grouped = Dictionary(grouping: temporaryScreenshots) { $0.category }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }

    var body: some View {
        NavigationStack {
            Group {
                if temporaryScreenshots.isEmpty {
                    cleanStateView
                } else {
                    temporaryList
                }
            }
            .navigationTitle("Cleanup")
            .toolbar {
                if !temporaryScreenshots.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(selectedItems.count == temporaryScreenshots.count ? "Deselect All" : "Select All") {
                            toggleSelectAll()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if !selectedItems.isEmpty {
                            Button("Delete Selected", role: .destructive) {
                                showDeleteConfirmation = true
                            }
                        }
                    }
                }
            }
            .alert("Delete Selected Screenshots", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) { deleteSelected() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete \(selectedItems.count) screenshot\(selectedItems.count == 1 ? "" : "s") from your Photos library.")
            }
        }
    }

    private var cleanStateView: some View {
        ContentUnavailableView(
            "All Clean!",
            systemImage: "checkmark.circle",
            description: Text("No temporary screenshots need cleanup. We'll notify you when new ones arrive.")
        )
    }

    private var temporaryList: some View {
        List {
            ForEach(groupedByCategory, id: \.0) { category, items in
                Section {
                    ForEach(items) { item in
                        TemporaryScreenshotRow(
                            item: item,
                            isSelected: selectedItems.contains(item.assetIdentifier)
                        )
                        .onTapGesture {
                            toggleSelection(item.assetIdentifier)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(Color(hex: category.color) ?? .blue)
                        Text(category.rawValue)
                        Spacer()
                        Text("\(items.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func toggleSelection(_ id: String) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }

    private func toggleSelectAll() {
        if selectedItems.count == temporaryScreenshots.count {
            selectedItems.removeAll()
        } else {
            selectedItems = Set(temporaryScreenshots.map { $0.assetIdentifier })
        }
    }

    private func deleteSelected() {
        let itemsToDelete = temporaryScreenshots.filter { selectedItems.contains($0.assetIdentifier) }
        let assetIds = itemsToDelete.map { $0.assetIdentifier }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIds, options: nil)
        var assetList: [PHAsset] = []
        assets.enumerateObjects { asset, _, _ in
            assetList.append(asset)
        }

        Task {
            isDeleting = true
            let photoKitService = PhotoKitService()
            try? await photoKitService.deleteAssets(assetList)

            for item in itemsToDelete {
                modelContext.delete(item)
            }
            try? modelContext.save()
            selectedItems.removeAll()
            isDeleting = false
        }
    }
}

struct TemporaryScreenshotRow: View {
    let item: ScreenshotItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .blue : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                if !item.extractedText.isEmpty {
                    Text(item.extractedText.prefix(80))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
