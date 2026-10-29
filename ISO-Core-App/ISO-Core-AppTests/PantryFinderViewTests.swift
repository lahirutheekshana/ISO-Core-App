import XCTest
import SwiftUI
@testable import ISO_Core_App

@MainActor
final class PantryFinderViewTests: XCTestCase {

    func testExpiringSoonItemsCount() throws {
        let today = Date()
        let expiringSoonDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let freshDate = Calendar.current.date(byAdding: .day, value: 10, to: today)!

        let item1 = PantryItem(
            id: "1",
            name: "Milk",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "l",
            expiryDate: expiringSoonDate,
            expiryAlertDays: 2,
            notes: nil
        )

        let item2 = PantryItem(
            id: "2",
            name: "Rice",
            category: "Grains",
            storageLocation: "Pantry",
            quantity: 1,
            unit: "kg",
            expiryDate: freshDate,
            expiryAlertDays: 2,
            notes: nil
        )

        let pantryInventory = [item1, item2]

        let expiringCount = pantryInventory.filter { $0.isExpiringSoon }.count

        XCTAssertEqual(expiringCount, 1, "Only 1 item should be marked as expiring soon.")
    }

    func testScannedTextIngredientMatching() throws {
        let recognizedStrings = ["found some organic tomato", "fresh eggs in basket", "random text"]
        
        
        
        let commonIngredients = ["tomato", "eggs", "cheese", "milk", "bread", "butter", "chicken", "onion", "garlic"]

        var foundIngredientsSet: Set<String> = []

        for text in recognizedStrings {
            for ingredient in commonIngredients {
                if text.contains(ingredient) {
                    foundIngredientsSet.insert(ingredient.capitalized)
                }
            }
        }

        XCTAssertTrue(foundIngredientsSet.contains("Tomato"), "Scanned text matching should identify Tomato.")
        XCTAssertTrue(foundIngredientsSet.contains("Eggs"), "Scanned text matching should identify Eggs.")
        XCTAssertEqual(foundIngredientsSet.count, 2, "Exactly 2 unique matching ingredients should be recognized.")
    }

    func testOCRFallbackIngredientsWhenNoMatchFound() throws {
        let recognizedStrings = ["newspaper headline", "receipt total $15"]
        let commonIngredients = ["tomato", "eggs", "cheese", "milk"]

        var foundAny = false
        var searchIngredients: [String] = []

        for text in recognizedStrings {
            for ingredient in commonIngredients {
                if text.contains(ingredient) {
                    foundAny = true
                    searchIngredients.append(ingredient.capitalized)
                }
            }
        }

        if !foundAny {
            let fallback = ["Tomato", "Eggs", "Cheese"]
            searchIngredients.append(contentsOf: fallback)
        }

        XCTAssertFalse(foundAny, "No matching ingredient should be found in un-related text.")
        XCTAssertEqual(searchIngredients.count, 3, "Fallback list of 3 ingredients should be applied.")
        XCTAssertEqual(searchIngredients, ["Tomato", "Eggs", "Cheese"], "Fallback list should match default values.")
    }
}
