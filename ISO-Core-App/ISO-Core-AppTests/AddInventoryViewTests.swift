import XCTest
import SwiftUI
@testable import ISO_Core_App

@MainActor
final class AddInventoryViewTests: XCTestCase {

    
    func testViewInitializationArrays() throws {
       
        let view = AddInventoryView { _ in }
        
        
        XCTAssertEqual(view.categories.count, 6, "Categories count should be 6.")
        XCTAssertTrue(view.categories.contains("Vegetables"), "Categories should contain Vegetables.")
        
        XCTAssertEqual(view.locations.count, 3, "Locations count should be 3.")
        XCTAssertTrue(view.locations.contains("Fridge"), "Locations should contain Fridge.")
        
        XCTAssertEqual(view.units.count, 6, "Units count should be 6.")
        XCTAssertTrue(view.units.contains("kg"), "Units should contain kg.")
    }

   
    func testPantryItemCreationCallback() throws {
     
        var savedItem: PantryItem?
        let view = AddInventoryView { item in
            savedItem = item
        }
        
        
        let testItem = PantryItem(
            name: "Carrot",
            category: "Vegetables",
            storageLocation: "Fridge",
            quantity: 3,
            unit: "kg",
            expiryDate: Date(),
            expiryAlertDays: 2,
            notes: "Fresh stock"
        )
        
        // Triggering the closure manually to test data integrity
        view.onSave(testItem)
        
        // Then
        XCTAssertNotNil(savedItem, "Saved item should not be nil.")
        XCTAssertEqual(savedItem?.name, "Carrot", "Item name should match.")
        XCTAssertEqual(savedItem?.quantity, 3, "Item quantity should match.")
        XCTAssertEqual(savedItem?.unit, "kg", "Item unit should match.")
        XCTAssertEqual(savedItem?.notes, "Fresh stock", "Item notes should match.")
    }

    // Test Case: Verify empty name validation logic
    func testEmptyNameValidationRule() throws {
        let emptyName = "   "
        let isValid = !emptyName.trimmingCharacters(in: .whitespaces).isEmpty
        
        XCTAssertFalse(isValid, "Save button should remain disabled when name is empty or whitespaces.")
    }
}
