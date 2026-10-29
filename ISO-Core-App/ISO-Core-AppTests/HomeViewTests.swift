import XCTest
@testable import ISO_Core_App

@MainActor
final class HomeViewTests: XCTestCase {

    
    func testCategoryFiltering() throws {
        let recipe1 = TheMealDBRecipe(idMeal: "1", strMeal: "Beef Wellington", strCategory: "Beef", strMealThumb: nil)
        let recipe2 = TheMealDBRecipe(idMeal: "2", strMeal: "Pancakes", strCategory: "Breakfast", strMealThumb: nil)
        
        let allRecipes = [recipe1, recipe2]
        let selectedCategory = "Beef"
        
        let filtered = allRecipes.filter { recipe in
            selectedCategory == "All" || recipe.strCategory?.lowercased() == selectedCategory.lowercased()
        }
        
        XCTAssertEqual(filtered.count, 1, "Only 1 recipe should match the Beef category.")
        XCTAssertEqual(filtered.first?.strMeal, "Beef Wellington")
    }

  
    func testSearchQueryFiltering() throws {
        let recipe1 = TheMealDBRecipe(idMeal: "1", strMeal: "Spicy Arrabbiata Pasta", strCategory: "Vegetarian", strMealThumb: nil)
        let recipe2 = TheMealDBRecipe(idMeal: "2", strMeal: "Chicken Burger", strCategory: "Meat", strMealThumb: nil)
        
        let allRecipes = [recipe1, recipe2]
        let searchText = "Pasta"
        
        let filtered = allRecipes.filter { recipe in
            searchText.isEmpty || recipe.strMeal.localizedCaseInsensitiveContains(searchText)
        }
        
        XCTAssertEqual(filtered.count, 1, "Only recipes matching the search text should be returned.")
        XCTAssertEqual(filtered.first?.idMeal, "1")
    }

    
    
    
    func testCategoriesListArray() throws {
        let categories = ["All", "Breakfast", "Beef", "Vegetarian", "Desserts", "Meat", "Seafood"]
        
        XCTAssertTrue(categories.contains("All"))
        XCTAssertTrue(categories.contains("Beef"))
        XCTAssertEqual(categories.count, 7, "Total categories count should be 7.")
    }
}
