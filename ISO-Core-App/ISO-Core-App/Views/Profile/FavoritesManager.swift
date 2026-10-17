import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteRecipes: [MockRecipe] = []
    
    private init() {}
    
    func isFavorite(_ recipe: MockRecipe) -> Bool {
        favoriteRecipes.contains(where: { $0.id == recipe.id })
    }
    
    func toggleFavorite(_ recipe: MockRecipe) {
        if isFavorite(recipe) {
            favoriteRecipes.removeAll(where: { $0.id == recipe.id })
        } else {
            favoriteRecipes.append(recipe)
        }
    }
}
