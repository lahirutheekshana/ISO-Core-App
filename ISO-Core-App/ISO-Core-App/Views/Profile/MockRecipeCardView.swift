import SwiftUI

struct MockRecipeCardView: View {
    let recipe: TheMealDBRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RecipeRemoteImage(urlString: recipe.imageURL)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(recipe.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            HStack {
                Label(recipe.category, systemImage: "tag.fill")
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

