import XCTest
import UserNotifications
@testable import ISO_Core_App

@MainActor
final class PantryViewModelTests: XCTestCase {

    var viewModel: PantryViewModel!

    override func setUp() async throws {
        try await super.setUp()
        UserDefaults.standard.set(true, forKey: "notificationsEnabled")
        UserDefaults.standard.set(true, forKey: "expiryAlertsEnabled")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        viewModel = PantryViewModel()
    }

    override func tearDown() async throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        viewModel = nil
        try await super.tearDown()
    }

 
    
    func testAddIngredient() throws {
      
        let initialCount = viewModel.fridgeIngredients.count
        let newItem = "Paneer"

       
        viewModel.addIngredient(newItem)

       
        
        XCTAssertTrue(viewModel.fridgeIngredients.contains("Paneer"), "The new item must be added to the array.")
        XCTAssertEqual(viewModel.fridgeIngredients.count, initialCount + 1, "Array count should increase by 1.")
    }

    
    func testRemoveIngredient() throws {
        
        let itemToRemove = "Cheese"
        viewModel.addIngredient(itemToRemove)
        XCTAssertTrue(viewModel.fridgeIngredients.contains(itemToRemove))

    
        viewModel.removeIngredient(itemToRemove)

     
        XCTAssertFalse(viewModel.fridgeIngredients.contains(itemToRemove), "Once the item is deleted, it should not be in the list.")
    }

 
    func testDuplicateIngredientPrevention() throws {

        let duplicateItem = "Butter"
        viewModel.addIngredient(duplicateItem)
        let countAfterFirstAdd = viewModel.fridgeIngredients.count

        
        viewModel.addIngredient("butter")

    
        XCTAssertEqual(viewModel.fridgeIngredients.count, countAfterFirstAdd, "Duplicate items should not be added.")
    }
    
   
    func testAddSearchIngredient() throws {
        
        let searchTag = "Tomato"

       
        viewModel.addSearchIngredient(searchTag)

      
        XCTAssertTrue(viewModel.searchIngredients.contains("Tomato"), "It should be added to the search tag array.")
    }

    func testAddAndUpdatePantryItemKeepsFullDetails() throws {
        let originalItem = PantryItem(
            name: "Yogurt",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 2,
            unit: "pcs",
            expiryDate: Date().addingTimeInterval(86400 * 5),
            expiryAlertDays: 2,
            notes: "Greek"
        )

        viewModel.addPantryItem(originalItem)

        XCTAssertTrue(viewModel.fridgeIngredients.contains("Yogurt"))
        XCTAssertEqual(viewModel.pantryItem(named: "Yogurt")?.quantity, 2)
        XCTAssertEqual(viewModel.pantryItem(named: "Yogurt")?.notes, "Greek")

        let updatedItem = PantryItem(
            id: originalItem.id,
            name: "Greek Yogurt",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 4,
            unit: "pack",
            expiryDate: originalItem.expiryDate,
            expiryAlertDays: 1,
            notes: "Full fat"
        )
        viewModel.updatePantryItem(oldName: "Yogurt", updatedItem: updatedItem)

        XCTAssertFalse(viewModel.fridgeIngredients.contains("Yogurt"))
        XCTAssertTrue(viewModel.fridgeIngredients.contains("Greek Yogurt"))
        XCTAssertEqual(viewModel.pantryItem(named: "Greek Yogurt")?.quantity, 4)
        XCTAssertEqual(viewModel.pantryItem(named: "Greek Yogurt")?.unit, "pack")
        XCTAssertEqual(viewModel.pantryItem(named: "Greek Yogurt")?.notes, "Full fat")
    }

    func testRemoveExpiringIngredientRemovesItFromExpiringList() throws {
        let calendar = Calendar.current
        let expiringItem = PantryItem(
            name: "Milk",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "l",
            expiryDate: calendar.startOfDay(for: Date()),
            expiryAlertDays: 1,
            notes: nil
        )

        viewModel.addPantryItem(expiringItem)

        var expiringItems = viewModel.pantryItems.filter { $0.isExpiringSoon }
        XCTAssertTrue(expiringItems.contains(where: { $0.name == "Milk" }), "Item should appear in the expiring list before delete.")

        viewModel.removeIngredient("Milk")

        expiringItems = viewModel.pantryItems.filter { $0.isExpiringSoon }
        XCTAssertFalse(viewModel.fridgeIngredients.contains("Milk"))
        XCTAssertFalse(viewModel.pantryItems.contains(where: { $0.name == "Milk" }))
        XCTAssertFalse(expiringItems.contains(where: { $0.name == "Milk" }), "Deleted expiring item should leave the expiring list.")
    }

    func testAddPantryItemKeepsReminderEnabledFlag() throws {
        let item = PantryItem(
            id: "vm_schedule_item",
            name: "Tomato",
            category: "Vegetables",
            storageLocation: "Fridge",
            quantity: 2,
            unit: "pcs",
            expiryDate: Date().addingTimeInterval(86400 * 5),
            expiryAlertDays: 2,
            notes: nil,
            expiryReminderEnabled: true
        )

        viewModel.addPantryItem(item)

        XCTAssertTrue(viewModel.fridgeIngredients.contains("Tomato"))
        XCTAssertEqual(viewModel.pantryItem(named: "Tomato")?.expiryReminderEnabled, true)
        XCTAssertEqual(viewModel.pantryItem(named: "Tomato")?.id, item.id)
    }

    func testRemoveIngredientRemovesItemFromPantryState() throws {
        let item = PantryItem(
            id: "vm_cancel_item",
            name: "Spinach",
            category: "Vegetables",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "pack",
            expiryDate: Date().addingTimeInterval(86400 * 4),
            expiryAlertDays: 1,
            notes: nil,
            expiryReminderEnabled: true
        )

        viewModel.addPantryItem(item)
        viewModel.removeIngredient("Spinach")

        XCTAssertFalse(viewModel.fridgeIngredients.contains("Spinach"))
        XCTAssertNil(viewModel.pantryItem(named: "Spinach"))
    }

    func testUpdatePantryItemRespectsReminderDisabled() throws {
        let original = PantryItem(
            id: "vm_update_reminder",
            name: "Yogurt Cup",
            category: "Dairy",
            storageLocation: "Fridge",
            quantity: 1,
            unit: "pcs",
            expiryDate: Date().addingTimeInterval(86400 * 5),
            expiryAlertDays: 2,
            notes: nil,
            expiryReminderEnabled: true
        )
        viewModel.addPantryItem(original)

        var updated = original
        updated.expiryReminderEnabled = false
        viewModel.updatePantryItem(oldName: "Yogurt Cup", updatedItem: updated)

        XCTAssertEqual(viewModel.pantryItem(named: "Yogurt Cup")?.expiryReminderEnabled, false)
    }
}
