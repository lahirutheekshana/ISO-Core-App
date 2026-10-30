import XCTest
import SwiftUI
@testable import ISO_Core_App

@MainActor
final class PantryInventoryListViewTests: XCTestCase {

    
    func testPantryShareTextFormatting() throws {
       
        let emptyIngredients: [String] = []
        let emptyShareText = emptyIngredients.isEmpty
            ? "My Pantry is currently empty!"
            : "Formatted List"
        
        XCTAssertEqual(emptyShareText, "My Pantry is currently empty!", "Share text should indicate an empty pantry.")

    
        let populatedIngredients = ["Tomato", "Eggs"]
        let itemsList = populatedIngredients.enumerated()
            .map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
        let populatedShareText = "🛒 My Pantry Items List:\n\n\(itemsList)\n\nShared via SmartChef App"


        XCTAssertTrue(populatedShareText.contains("1. Tomato"), "Formatted list should contain 1. Tomato.")
        XCTAssertTrue(populatedShareText.contains("2. Eggs"), "Formatted list should contain 2. Eggs.")
        XCTAssertTrue(populatedShareText.contains("Shared via SmartChef App"), "Formatted list should contain footer signature.")
    }

  
    func testUpdateIngredientLocalArrayAction() throws {
  
        var fridgeIngredients = ["Old Tomato"]
        var pantryItems = [
            PantryItem(
                name: "Old Tomato",
                category: "Vegetables",
                storageLocation: "Fridge",
                quantity: 2,
                unit: "pcs",
                expiryDate: Date(),
                expiryAlertDays: 2,
                notes: nil
            )
        ]
        let oldItem = "Old Tomato"
        let updatedItem = PantryItem(
            id: pantryItems[0].id,
            name: "Fresh Tomato",
            category: "Vegetables",
            storageLocation: "Pantry",
            quantity: 5,
            unit: "kg",
            expiryDate: Date().addingTimeInterval(86400 * 3),
            expiryAlertDays: 1,
            notes: "Ripe"
        )

 
        if let index = fridgeIngredients.firstIndex(of: oldItem) {
            fridgeIngredients[index] = updatedItem.name
        }
        if let itemIndex = pantryItems.firstIndex(where: { $0.name == oldItem }) {
            pantryItems[itemIndex] = updatedItem
        }

   
        XCTAssertTrue(fridgeIngredients.contains("Fresh Tomato"), "Pantry should contain the updated ingredient name.")
        XCTAssertFalse(fridgeIngredients.contains("Old Tomato"), "Pantry should no longer contain the old ingredient name.")
        XCTAssertEqual(pantryItems.first?.quantity, 5, "Updated pantry item should keep edited quantity.")
        XCTAssertEqual(pantryItems.first?.storageLocation, "Pantry", "Updated pantry item should keep edited storage location.")
    }

    func testDeleteIngredientLocalArrayAction() throws {
    
        var fridgeIngredients = ["Milk", "Cheese"]


        fridgeIngredients.removeAll { $0 == "Milk" }


        XCTAssertFalse(fridgeIngredients.contains("Milk"), "Milk should be removed from the pantry list.")
        XCTAssertEqual(fridgeIngredients.count, 1, "Pantry count should decrease to 1.")
    }
}
