import Foundation
import Combine

@MainActor
class PantryViewModel: ObservableObject {
    @Published var fridgeIngredients: [String] = []
    @Published var matchedRecipes: [TheMealDBRecipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    
    func addIngredient(_ ingredient: String) {
        let cleanIngredient = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanIngredient.isEmpty else { return }
        
        if !fridgeIngredients.contains(where: { $0.caseInsensitiveCompare(cleanIngredient) == .orderedSame }) {
            fridgeIngredients.append(cleanIngredient)
            Task {
                await fetchMatchingRecipes()
            }
        }
    }
    
    func removeIngredient(_ ingredient: String) {
        fridgeIngredients.removeAll { $0 == ingredient }
        Task {
            await fetchMatchingRecipes()
        }
    }
    
    private func fetchMatchingRecipes() async {
        guard let mainIngredient = fridgeIngredients.first else {
            self.matchedRecipes = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let encodedIngredient = mainIngredient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.errorMessage = "Invalid ingredient name"
            self.isLoading = false
            return
        }
        
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(encodedIngredient)"
        
        do {
            let response: MealDBResponse = try await networkManager.fetch(from: urlString)
            self.matchedRecipes = response.meals ?? []
        } catch {
            self.errorMessage = error.localizedDescription
            self.matchedRecipes = []
        }
        
        isLoading = false
    }
}