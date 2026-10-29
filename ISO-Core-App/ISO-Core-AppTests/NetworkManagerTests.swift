import XCTest
@testable import ISO_Core_App

final class NetworkManagerTests: XCTestCase {

    var networkManager: NetworkManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkManager = NetworkManager.shared
    }

    override func tearDownWithError() throws {
        networkManager = nil
        try super.tearDownWithError()
    }

    
    func testFetchRecipesSuccess() async throws {
        let ingredient = "chicken"
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(ingredient)"

        do {
            let response: MealDBResponse = try await networkManager.fetch(from: urlString)
            
    
            XCTAssertNotNil(response.meals, "The 'Response meals' must not be null.")
            XCTAssertFalse(response.meals?.isEmpty ?? true, "I need a list of recipes for chicken.")
        } catch {
            XCTFail("Network fetch failed: \(error.localizedDescription)")
        }
    }

    func testFetchRecipesEmpty() async throws {
        let invalidIngredient = "xyzabcdef12345"
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(invalidIngredient)"

  
        do {
            let response: MealDBResponse = try await networkManager.fetch(from: urlString)
            
           
            XCTAssertNil(response.meals, "When an ingredient that does not exist is provided, the `meals` array should be `nil`.")
        } catch {
            XCTAssertNotNil(error, "It is correct for an error to be thrown in the case of an invalid URL or request.")
        }
    }
    
    func testFetchRecipeLookupSuccess() async throws {
        let mealId = "52803" // Beef Wellington
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)"
        
        do {
            let response: MealResponse = try await networkManager.fetch(from: urlString)
            let recipe = response.meals?.first
            
            XCTAssertNotNil(recipe, "Beef Wellington recipe should be found.")
            XCTAssertEqual(recipe?.idMeal, "52803")
            XCTAssertEqual(recipe?.strMeal, "Beef Wellington")
            XCTAssertFalse(recipe?.ingredients.isEmpty ?? true, "Recipe should contain parsed ingredients.")
            XCTAssertFalse(recipe?.instructionSteps.isEmpty ?? true, "Recipe should contain parsed instruction steps.")
        } catch {
            XCTFail("Network fetch failed: \(error.localizedDescription)")
        }
    }
}

