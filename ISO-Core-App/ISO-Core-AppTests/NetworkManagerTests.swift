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
            
           
            XCTAssertNil(response.meals, "නැති ingredient එකක් දුන් විට meals array එක nil විය යුතුය.")
        } catch {
            
            XCTAssertNotNil(error, "Invalid URL/Request එකකදී error එකක් throw වීම නිවැරදිය.")
        }
    }
}
