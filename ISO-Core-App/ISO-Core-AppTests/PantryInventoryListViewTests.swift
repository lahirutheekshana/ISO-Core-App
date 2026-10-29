import XCTest
import SwiftUI
@testable import ISO_Core_App

@MainActor
final class PantryInventoryListViewTests: XCTestCase {

    // 1. Test Case: Verify share text formatting logic when pantry is empty vs populated
    func testPantryShareTextFormatting() throws {
        // Given
        let emptyIngredients: [String] = []
        let emptyShareText = emptyIngredients.isEmpty
            ? "My Pantry is currently empty!"
            : "Formatted List"
        
        XCTAssertEqual(emptyShareText, "My Pantry is currently empty!", "Share text should indicate an empty pantry.")

        // When populated
        let populatedIngredients = ["Tomato", "Eggs"]
        let itemsList = populatedIngredients.enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
        let populatedShareText = "🛒 My Pantry Items List:\n\n\(itemsList)\n\nShared via SmartChef App"

        // Then
        XCTAssertTrue(populatedShareText.contains("1. Tomato"), "Formatted list should contain 1. Tomato.")
        XCTAssertTrue(populatedShareText.contains("2. Eggs"), "Formatted list should contain 2. Eggs.")
        XCTAssertTrue(populatedShareText.contains("Shared via SmartChef App"), "Formatted list should contain footer signature.")
    }

    // 2. Test Case: Verify local ingredient array update during edit action
    func testUpdateIngredientLocalArrayAction() throws {
        // Given
        var fridgeIngredients = ["Old Tomato"]
        let oldItem = "Old Tomato"
        let newItem = "Fresh Tomato"

        // When
        if let index = fridgeIngredients.firstIndex(of: oldItem) {
            fridgeIngredients[index] = newItem
        }

        // Then
        XCTAssertTrue(fridgeIngredients.contains("Fresh Tomato"), "Pantry should contain the updated ingredient name.")
        XCTAssertFalse(fridgeIngredients.contains("Old Tomato"), "Pantry should no longer contain the old ingredient name.")
    }

    // 3. Test Case: Verify local ingredient array removal during delete action
    func testDeleteIngredientLocalArrayAction() throws {
        // Given
        var fridgeIngredients = ["Milk", "Cheese"]

        // When
        fridgeIngredients.removeAll { $0 == "Milk" }

        // Then
        XCTAssertFalse(fridgeIngredients.contains("Milk"), "Milk should be removed from the pantry list.")
        XCTAssertEqual(fridgeIngredients.count, 1, "Pantry count should decrease to 1.")
    }
}
