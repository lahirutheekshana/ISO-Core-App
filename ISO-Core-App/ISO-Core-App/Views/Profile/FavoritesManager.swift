import SwiftUI
import Combine

@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteRecipes: [MockRecipe] = []
    
    private init() {}
    
    func isFavorite(_ recipe: MockRecipe) -> Bool {
        favoriteRecipes.contains(where: { $0.id == recipe.id })
    }
    
    func toggleFavorite(_ recipe: MockRecipe) {
        if let existingIndex = favoriteRecipes.firstIndex(where: { $0.id == recipe.id }) {
            favoriteRecipes.remove(at: existingIndex)
        } else {
            favoriteRecipes.append(recipe)
        }
    }
}
