import Foundation
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    
    func fetchRecipes(searchQuery: String = "") async {
        isLoading = true
        errorMessage = nil
        
        // URL encode the query
        guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.errorMessage = "Invalid search query"
            self.isLoading = false
            return
        }
        
        // If empty, perhaps fetch some default or leave empty. 
        // Here we default to searching by letter 'a' or just pass empty for search.php?s=
        let urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encodedQuery)"
        
        do {
            let response: MealResponse = try await networkManager.fetch(from: urlString)
            self.recipes = response.meals ?? []
        } catch {
            self.errorMessage = error.localizedDescription
            self.recipes = []
        }
        
        isLoading = false
    }
}
