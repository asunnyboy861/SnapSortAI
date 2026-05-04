import SwiftUI
import SwiftData
import Photos

struct ScreenshotDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let item: ScreenshotItem
    @State private var showDeleteConfirmation = false
    @State private var isFavorite = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    screenshotPreview
                    categoryBadge
                    metadataSection
                    if !item.extractedText.isEmpty {
                        extractedTextSection
                    }
                }
                .padding()
            }
            .navigationTitle("Screenshot Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        favoriteButton
                        changeCategoryButton
                        deleteButton
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Screenshot", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) { deleteScreenshot() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the screenshot from your Photos library.")
            }
            .onAppear {
                isFavorite = item.isFavorite
            }
        }
    }

    private var screenshotPreview: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .aspectRatio(9/16, contentMode: .fit)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Color(hex: item.category.color) ?? .blue)
                    Text(item.category.rawValue)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
    }

    private var categoryBadge: some View {
        HStack {
            Image(systemName: item.category.icon)
                .foregroundStyle(.white)
                .font(.caption)
            Text(item.category.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            if item.isTemporary {
                Text("TEMP")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: item.category.color) ?? .blue)
        .clipShape(Capsule())
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(item.createdAt.formatted(date: .long, time: .shortened), systemImage: "calendar")
            Label(ByteCountFormatter.string(fromByteCount: Int64(item.fileSize), countStyle: .file), systemImage: "doc")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var extractedTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Extracted Text")
                .font(.headline)
            Text(item.extractedText)
                .font(.body)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }

    private var favoriteButton: some View {
        Button {
            item.isFavorite.toggle()
            isFavorite = item.isFavorite
            try? modelContext.save()
        } label: {
            Label(
                isFavorite ? "Unfavorite" : "Favorite",
                systemImage: isFavorite ? "heart.slash" : "heart"
            )
        }
    }

    private var changeCategoryButton: some View {
        Menu {
            ForEach(ScreenshotCategory.allCases, id: \.self) { category in
                Button {
                    item.category = category
                    item.isTemporary = category.isTemporary
                    try? modelContext.save()
                } label: {
                    Label(category.rawValue, systemImage: category.icon)
                }
            }
        } label: {
            Label("Change Category", systemImage: "folder")
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Delete Screenshot", systemImage: "trash")
        }
    }

    private func deleteScreenshot() {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
        var assetList: [PHAsset] = []
        assets.enumerateObjects { asset, _, _ in
            assetList.append(asset)
        }

        Task {
            let photoKitService = PhotoKitService()
            try? await photoKitService.deleteAssets(assetList)
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 else { return nil }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
