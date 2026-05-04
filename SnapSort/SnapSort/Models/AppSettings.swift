import Foundation
import SwiftData

@Model
final class AppSettings {
    var hasCompletedOnboarding: Bool
    var photoLibraryAuthorized: Bool
    var notificationsEnabled: Bool
    var faceIDEnabled: Bool
    var cleanupReminderDays: Int
    var ocrSearchCount: Int
    var ocrSearchResetDate: Date
    var isPremium: Bool

    var dailyOCRRemaining: Int {
        let calendar = Calendar.current
        if !calendar.isDate(ocrSearchResetDate, inSameDayAs: Date()) {
            return 5
        }
        return max(0, 5 - ocrSearchCount)
    }

    init(
        hasCompletedOnboarding: Bool = false,
        photoLibraryAuthorized: Bool = false,
        notificationsEnabled: Bool = true,
        faceIDEnabled: Bool = false,
        cleanupReminderDays: Int = 3,
        ocrSearchCount: Int = 0,
        ocrSearchResetDate: Date = Date(),
        isPremium: Bool = false
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.photoLibraryAuthorized = photoLibraryAuthorized
        self.notificationsEnabled = notificationsEnabled
        self.faceIDEnabled = faceIDEnabled
        self.cleanupReminderDays = cleanupReminderDays
        self.ocrSearchCount = ocrSearchCount
        self.ocrSearchResetDate = ocrSearchResetDate
        self.isPremium = isPremium
    }
}
