import XCTest


@testable import ISO_Core_App

@MainActor
final class PantryViewModelTests: XCTestCase {

    var viewModel: PantryViewModel!

    override func setUp() async throws {
        try await super.setUp()
        
        viewModel = PantryViewModel()
    }

    override func tearDown() async throws {
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
}
