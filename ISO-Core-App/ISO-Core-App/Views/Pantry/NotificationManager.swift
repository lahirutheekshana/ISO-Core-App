import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private let defaultAlertHour = 9
    private let immediateDelaySeconds: TimeInterval = 1

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification Authorization Error: \(error.localizedDescription)")
            }
        }
    }

    func cancelExpiryNotification(for itemID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemID])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [itemID])
    }

    func scheduleExpiryNotification(for item: PantryItem, now: Date = Date()) {
        let alertsEnabled = UserDefaults.standard.object(forKey: "expiryAlertsEnabled") as? Bool ?? true
        guard alertsEnabled else {
            cancelExpiryNotification(for: item.id)
            return
        }

        cancelExpiryNotification(for: item.id)

        let content = UNMutableNotificationContent()
        content.title = "⚠️ Expiry Alert: \(item.name)"
        content.body = "\(item.name) expires in \(item.expiryAlertDays) day(s). Use it soon!"
        content.sound = .default

        guard let trigger = makeTrigger(for: item, now: now) else {
            return
        }

        let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Schedule Error: \(error.localizedDescription)")
            }
        }
    }

    /// Builds the notification trigger for an item.
    /// - Future alert day: fires at 9:00 AM on that day
    /// - Already inside the alert window (including today): fires almost immediately
    /// - Already past expiry: no notification
    func makeTrigger(for item: PantryItem, now: Date = Date()) -> UNNotificationTrigger? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let expiryDay = calendar.startOfDay(for: item.expiryDate)

        guard today <= expiryDay else {
            return nil
        }

        guard let alertDay = calendar.date(byAdding: .day, value: -item.expiryAlertDays, to: expiryDay) else {
            return nil
        }

        var alertComponents = calendar.dateComponents([.year, .month, .day], from: alertDay)
        alertComponents.hour = defaultAlertHour
        alertComponents.minute = 0

        guard let scheduledDate = calendar.date(from: alertComponents) else {
            return nil
        }

        if scheduledDate > now {
            return UNCalendarNotificationTrigger(dateMatching: alertComponents, repeats: false)
        }

        // Alert window has already started (date-picker midnight made the original time "past")
        return UNTimeIntervalNotificationTrigger(timeInterval: immediateDelaySeconds, repeats: false)
    }
}
