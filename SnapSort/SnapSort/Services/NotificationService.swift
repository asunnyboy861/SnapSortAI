import UserNotifications

@Observable
final class NotificationService {
    var isAuthorized: Bool = false

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func scheduleCleanupReminder(for category: ScreenshotCategory, itemCount: Int, days: Int) {
        guard category.isTemporary else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cleanup Reminder"
        content.body = "You have \(itemCount) \(category.rawValue.lowercased()) screenshots that may be expired. Tap to review and clean up."
        content.sound = .default
        content.categoryIdentifier = "CLEANUP_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(days * 86400),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "cleanup_\(category.rawValue)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleTemporaryScreenshotReminders(items: [ScreenshotItem], days: Int) {
        cancelAllReminders()

        let temporaryItems = items.filter { $0.isTemporary }
        let grouped = Dictionary(grouping: temporaryItems) { $0.category }

        for (category, items) in grouped {
            scheduleCleanupReminder(for: category, itemCount: items.count, days: days)
        }
    }
}
