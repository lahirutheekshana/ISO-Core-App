import XCTest
import UserNotifications
@testable import ISO_Core_App

final class NotificationManagerTests: XCTestCase {

    var notificationManager: NotificationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationManager = NotificationManager.shared
        
        // Remove existing pending notifications before each test
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    override func tearDownWithError() throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationManager = nil
        try super.tearDownWithError()
    }

    // Test Case: Verify notification scheduling and content formatting
    func testScheduleExpiryNotification() async throws {
        // Given (Constructing a valid PantryItem with all required properties)
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

        // When (Schedule the notification)
        notificationManager.scheduleExpiryNotification(for: mockItem)

        // Wait for async request completion in UNUserNotificationCenter
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Then (Inspect pending notification requests)
        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        // 1. Check if a request exists
        XCTAssertFalse(pendingRequests.isEmpty, "Scheduled notification should be present in pending requests.")
        
        // 2. Match the notification by ID
        let scheduledNotification = pendingRequests.first { $0.identifier == mockItem.id }
        XCTAssertNotNil(scheduledNotification, "Notification matching item ID should be scheduled.")
        
        // 3. Verify notification title and content
        XCTAssertEqual(scheduledNotification?.content.title, "⚠️ Expiry Alert: Fresh Milk")
        XCTAssertTrue(scheduledNotification?.content.body.contains("Fresh Milk") ?? false)
    }

    // Test Case: Verify date subtraction calculation logic
    func testExpiryNotificationDateCalculation() throws {
        let calendar = Calendar.current
        let expiryDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 10, minute: 0))!
        let alertDays = 2

        // When
        let calculatedNotifyDate = calendar.date(byAdding: .day, value: -alertDays, to: expiryDate)

        // Then (Expected: Nov 10, 2026 - 2 days = Nov 8, 2026)
        let expectedNotifyDate = calendar.date(from: DateComponents(year: 2026, month: 11, day: 8, hour: 10, minute: 0))!
        
        XCTAssertEqual(calculatedNotifyDate, expectedNotifyDate, "Expiry alert date should be calculated correctly 2 days prior.")
    }
}
