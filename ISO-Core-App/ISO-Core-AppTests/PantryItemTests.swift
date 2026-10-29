import XCTest
@testable import ISO_Core_App

final class PantryItemTests: XCTestCase {

    func testIsExpiringSoonTrue() throws {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let item = PantryItem(
            name: "Fresh Milk",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "l",
            expiryDate: tomorrow,
            expiryAlertDays: 2,
            notes: "Keep refrigerated"
        )

        XCTAssertTrue(item.isExpiringSoon, "Item should be marked as expiring soon since today falls within the alert window.")
    }

    func testIsExpiringSoonFalseForFreshItem() throws {
        let calendar = Calendar.current
        let today = Date()
        let futureDate = calendar.date(byAdding: .day, value: 10, to: today)!

        let item = PantryItem(
            name: "Rice Pack",
            category: "Grains",
            storageLocation: "Pantry",
            quantity: 2,
            unit: "kg",
            expiryDate: futureDate,
            expiryAlertDays: 2,
            notes: nil
        )

        XCTAssertFalse(item.isExpiringSoon, "Item should not be marked as expiring soon if expiry date is far away.")
    }

    func testPantryItemInitialization() throws {
        let item1 = PantryItem(
            name: "Apple",
            category: "Fruits",
            storageLocation: "Fridge",
            quantity: 4,
            unit: "pcs",
            expiryDate: Date(),
            expiryAlertDays: 1,
            notes: nil
        )

        let item2 = PantryItem(
            name: "Apple",
            category: "Fruits",
            storageLocation: "Fridge",
            quantity: 4,
            unit: "pcs",
            expiryDate: Date(),
            expiryAlertDays: 1,
            notes: nil
        )

        XCTAssertFalse(item1.id.isEmpty, "Item ID should be generated automatically.")
        XCTAssertNotEqual(item1.id, item2.id, "Each PantryItem instance should have a unique ID.")
        XCTAssertEqual(item1.name, "Apple", "Item name should match.")
        XCTAssertNil(item1.notes, "Notes should be nil if not provided.")
    }
}
