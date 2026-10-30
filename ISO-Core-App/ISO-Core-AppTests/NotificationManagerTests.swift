import XCTest
import UserNotifications
@testable import ISO_Core_App

final class NotificationManagerTests: XCTestCase {

    var notificationManager: NotificationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationManager = NotificationManager.shared
        UserDefaults.standard.set(true, forKey: "expiryAlertsEnabled")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    override func tearDownWithError() throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationManager = nil
        try super.tearDownWithError()
    }

    func testScheduleExpiryNotification() async throws {
        let futureExpiryDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let mockItem = PantryItem(
            id: "test_item_123",
            name: "Fresh Milk",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "pcs",
            expiryDate: futureExpiryDate,
            expiryAlertDays: 2,
            notes: "Keep chilled"
        )

        notificationManager.scheduleExpiryNotification(for: mockItem)

        try await Task.sleep(nanoseconds: 500_000_000)

        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        XCTAssertFalse(pendingRequests.isEmpty, "Scheduled notification should be present in pending requests.")

        let scheduledNotification = pendingRequests.first { $0.identifier == mockItem.id }
        XCTAssertNotNil(scheduledNotification, "Notification matching item ID should be scheduled.")
        XCTAssertEqual(scheduledNotification?.content.title, "⚠️ Expiry Alert: Fresh Milk")
        XCTAssertEqual(
            scheduledNotification?.content.body,
            "Fresh Milk expires in 2 day(s). Use it soon!"
        )
    }

    func testExpiryNotificationDateCalculation() throws {
        let calendar = Calendar.current
        let expiryDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 10, minute: 0))!
        let alertDays = 2

        let calculatedNotifyDate = calendar.date(byAdding: .day, value: -alertDays, to: expiryDate)
        let expectedNotifyDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 8, hour: 10, minute: 0))!

        XCTAssertEqual(calculatedNotifyDate, expectedNotifyDate, "Expiry alert date should be calculated correctly 2 days prior.")
    }

    func testImmediateTriggerWhenExpiryIsToday() throws {
        let calendar = Calendar.current
        let todayMidnight = calendar.startOfDay(for: Date())
        let item = PantryItem(
            id: "expire_today",
            name: "Yogurt",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "pcs",
            expiryDate: todayMidnight,
            expiryAlertDays: 1,
            notes: nil
        )

        let trigger = notificationManager.makeTrigger(for: item)
        XCTAssertTrue(
            trigger is UNTimeIntervalNotificationTrigger,
            "When today is inside the alert window, notification should fire immediately instead of a past midnight date."
        )
    }

    func testCalendarTriggerWhenAlertDayIsInTheFuture() throws {
        let calendar = Calendar.current
        let futureExpiry = calendar.date(byAdding: .day, value: 10, to: calendar.startOfDay(for: Date()))!
        let item = PantryItem(
            id: "expire_future",
            name: "Rice",
            category: "Grains",
            storageLocation: "Pantry",
            quantity: 1,
            unit: "kg",
            expiryDate: futureExpiry,
            expiryAlertDays: 2,
            notes: nil
        )

        let trigger = notificationManager.makeTrigger(for: item)
        XCTAssertTrue(
            trigger is UNCalendarNotificationTrigger,
            "Future alert days should use a calendar trigger at 9:00 AM."
        )
    }

    func testNoTriggerWhenItemAlreadyExpired() throws {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        let item = PantryItem(
            id: "already_expired",
            name: "Old Bread",
            category: "Grains",
            storageLocation: "Pantry",
            quantity: 1,
            unit: "pcs",
            expiryDate: yesterday,
            expiryAlertDays: 2,
            notes: nil
        )

        let trigger = notificationManager.makeTrigger(for: item)
        XCTAssertNil(trigger, "Already expired items should not schedule a notification.")
    }

    func testRescheduleReplacesExistingNotification() async throws {
        let calendar = Calendar.current
        let itemID = "reschedule_item"
        let originalExpiry = calendar.date(byAdding: .day, value: 7, to: Date())!
        let updatedExpiry = calendar.startOfDay(for: Date())

        let originalItem = PantryItem(
            id: itemID,
            name: "Milk",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "l",
            expiryDate: originalExpiry,
            expiryAlertDays: 3,
            notes: nil
        )
        notificationManager.scheduleExpiryNotification(for: originalItem)

        let updatedItem = PantryItem(
            id: itemID,
            name: "Milk",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "l",
            expiryDate: updatedExpiry,
            expiryAlertDays: 1,
            notes: nil
        )
        notificationManager.scheduleExpiryNotification(for: updatedItem)

        try await Task.sleep(nanoseconds: 500_000_000)

        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let matching = pendingRequests.filter { $0.identifier == itemID }
        XCTAssertEqual(matching.count, 1, "Editing expiry should replace the previous pending notification, not stack duplicates.")
        XCTAssertTrue(
            matching.first?.trigger is UNTimeIntervalNotificationTrigger,
            "Edited item already in alert window should use an immediate trigger."
        )
    }
}
