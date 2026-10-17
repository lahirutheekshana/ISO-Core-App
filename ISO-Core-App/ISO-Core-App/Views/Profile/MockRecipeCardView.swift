import SwiftUI

struct MockRecipeCardView: View {
    let recipe: MockRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(recipe.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            HStack {
                Label(recipe.time, systemImage: "clock")
                Spacer()
                Label("\(recipe.calories) kcal", systemImage: "flame")
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

