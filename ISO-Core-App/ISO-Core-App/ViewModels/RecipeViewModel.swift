import Foundation
import Combine

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    
    func fetchRecipeDetails(for mealId: String) async {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)"
        
        do {
            let response: MealResponse = try await networkManager.fetch(from: urlString)
            if let fetchedRecipe = response.meals?.first {
                self.recipe = fetchedRecipe
            } else {
                self.errorMessage = "Recipe details not found."
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
