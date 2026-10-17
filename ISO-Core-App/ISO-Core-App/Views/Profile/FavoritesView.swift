import SwiftUI
import Combine

struct FavoritesView: View {
    
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var favoritesManager = FavoritesManager.shared
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if favoritesManager.favoriteRecipes.isEmpty {
                        emptyStateView
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(favoritesManager.favoriteRecipes) { recipe in
                                NavigationLink(destination: RecipeCardView(recipe: recipe)) {
                                    MockRecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }
            .navigationTitle("Favorites")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 100)
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Save your favorite recipes here to quickly access them anytime!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FavoritesView(authVM: AuthViewModel())
}
