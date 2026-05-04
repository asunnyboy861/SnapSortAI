import Foundation
import SwiftData

@Model
final class ScreenshotItem {
    var assetIdentifier: String
    var categoryRaw: String
    var extractedText: String
    var createdAt: Date
    var isFavorite: Bool
    var isTemporary: Bool
    var fileSize: Int
    var analyzedAt: Date

    var category: ScreenshotCategory {
        get { ScreenshotCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        assetIdentifier: String,
        category: ScreenshotCategory = .other,
        extractedText: String = "",
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        isTemporary: Bool = false,
        fileSize: Int = 0,
        analyzedAt: Date = Date()
    ) {
        self.assetIdentifier = assetIdentifier
        self.categoryRaw = category.rawValue
        self.extractedText = extractedText
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.isTemporary = isTemporary
        self.fileSize = fileSize
        self.analyzedAt = analyzedAt
    }
}
