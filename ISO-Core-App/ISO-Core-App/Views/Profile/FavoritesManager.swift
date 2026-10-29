import SwiftUI
import Combine

@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteRecipes: [TheMealDBRecipe] = []
    
    private init() {}
    
    func isFavorite(_ id: String) -> Bool {
        favoriteRecipes.contains(where: { $0.id == id })
    }
    
    func isFavorite(_ recipe: TheMealDBRecipe) -> Bool {
        isFavorite(recipe.id)
    }
    
    func toggleFavorite(_ recipe: TheMealDBRecipe) {
        if let existingIndex = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
            favoriteRecipes.remove(at: existingIndex)
        } else {
            favoriteRecipes.append(recipe)
        }
    }
}

