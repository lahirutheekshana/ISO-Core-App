import SwiftUI

struct RecipeDetailView: View {
    let mealId: String
    
    var body: some View {
        RecipeCardView(recipeId: mealId)
    }
}

