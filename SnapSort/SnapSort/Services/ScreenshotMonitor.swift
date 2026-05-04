import Photos
import SwiftData
import UIKit
import Combine

final class ScreenshotMonitor: NSObject, PHPhotoLibraryChangeObserver {
    private var fetchResult: PHFetchResult<PHAsset>?
    private var lastScreenshotCount: Int = 0
    private let photoKitService: PhotoKitService
    private let classifier: ScreenshotClassifier
    private let ocrService: OCRService

    var newScreenshots: [ScreenshotItem] = []
    @Published var isProcessing: Bool = false

    init(
        photoKitService: PhotoKitService,
        classifier: ScreenshotClassifier,
        ocrService: OCRService
    ) {
        self.photoKitService = photoKitService
        self.classifier = classifier
        self.ocrService = ocrService
        super.init()
    }

    func startMonitoring() {
        let assets = photoKitService.fetchScreenshots()
        lastScreenshotCount = assets.count

        PHPhotoLibrary.shared().register(self)
    }

    func stopMonitoring() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func processAllScreenshots(modelContext: ModelContext) async {
        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        let assets = photoKitService.fetchScreenshots()

        let existingItems = try? modelContext.fetch(FetchDescriptor<ScreenshotItem>())
        let existingIds = Set((existingItems ?? []).map { $0.assetIdentifier })

        for asset in assets {
            if existingIds.contains(asset.localIdentifier) { continue }

            await processScreenshot(asset, modelContext: modelContext)
        }
    }

    private func processScreenshot(_ asset: PHAsset, modelContext: ModelContext) async {
        guard let image = await photoKitService.loadFullSizeImage(for: asset) else { return }

        let extractedText = await ocrService.recognizeText(in: image)
        let category = await classifier.classify(image: image, extractedText: extractedText)
        let fileSize = photoKitService.getFileSize(for: asset)

        let item = ScreenshotItem(
            assetIdentifier: asset.localIdentifier,
            category: category,
            extractedText: extractedText,
            createdAt: asset.creationDate ?? Date(),
            isTemporary: category.isTemporary,
            fileSize: fileSize
        )

        await MainActor.run {
            modelContext.insert(item)
            try? modelContext.save()
        }
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = fetchResult,
              let details = changeInstance.changeDetails(for: fetchResult) else { return }

        let newCount = details.fetchResultAfterChanges.count
        if newCount > lastScreenshotCount {
            lastScreenshotCount = newCount
        }
    }
}
