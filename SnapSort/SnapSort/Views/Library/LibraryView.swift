import SwiftUI
import SwiftData
import Photos

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScreenshotItem.createdAt, order: .reverse) private var screenshots: [ScreenshotItem]
    @State private var selectedScreenshot: ScreenshotItem?
    @State private var showingPermissionAlert = false
    @State private var isScanning = false

    private let photoKitService = PhotoKitService()
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if screenshots.isEmpty {
                    emptyStateView
                } else {
                    screenshotGrid
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        scanForScreenshots()
                    } label: {
                        if isScanning {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .alert("Photo Access Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow photo library access in Settings to detect screenshots.")
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Screenshots Yet",
            systemImage: "photo.on.rectangle.angled",
            description: Text("Tap the scan button to detect and organize your screenshots.")
        )
    }

    private var screenshotGrid: some View {
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
        .sheet(item: $selectedScreenshot) { item in
            ScreenshotDetailView(item: item)
        }
    }

    private func scanForScreenshots() {
        Task {
            if photoKitService.authorizationStatus != .authorized {
                let granted = await photoKitService.requestAuthorization()
                if !granted {
                    showingPermissionAlert = true
                    return
                }
            }

            isScanning = true
            let classifier = ScreenshotClassifier()
            let ocrService = OCRService()
            let monitor = ScreenshotMonitor(
                photoKitService: photoKitService,
                classifier: classifier,
                ocrService: ocrService
            )
            await monitor.processAllScreenshots(modelContext: modelContext)
            isScanning = false
        }
    }
}

struct ScreenshotGridItem: View {
    let item: ScreenshotItem

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .aspectRatio(9/16, contentMode: .fit)
                .overlay {
                    Image(systemName: item.category.icon)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

            if item.isTemporary {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 10, height: 10)
                    .padding(4)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
