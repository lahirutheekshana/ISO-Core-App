import SwiftUI

struct HomeView: View {
    
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    
    @State private var trendingRecipes: [TheMealDBRecipe] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    let categories = [
        "All",
        "Breakfast",
        "Beef",
        "Vegetarian",
        "Desserts",
        "Meat",
        "Seafood"]

    
    var filteredRecipes: [TheMealDBRecipe] {
        
        trendingRecipes.filter { recipe in
            let matchesSearch = searchText.isEmpty || recipe.title.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = (selectedCategory == "All") ||
            (!searchText.isEmpty) ||
            (recipe.category.lowercased() == selectedCategory.lowercased())
                 return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    searchBar
                    categoryChips
                    
                    if searchText.isEmpty {
                        heroRecipeCard
                    }
                    
                    if isLoading {
                        ProgressView("Loading recipes....")
                            .padding(.vertical, 40)
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.vertical, 40)
                        
                    }else {
                        trendingSection
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 90)
                .iPadReadableWidth()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
            .task{
                await loadApiData()
            }
                
            .onChange(of: searchText) { oldValue, newValue in
                Task {
                    await searchAPIData(query: newValue)
                }
            }
        }
    }
    
    
    
    private func loadApiData() async {
        isLoading = true
        errorMessage = nil
        let urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s="
        do {
            let respone: MealDBResponse = try await NetworkManager.shared.fetch(from:urlString)
            self.trendingRecipes = respone.meals ?? []
        } catch{
            
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func searchAPIData(query: String) async {
        let urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        do {
            let response: MealDBResponse = try await NetworkManager.shared.fetch(from: urlString)
            self.trendingRecipes = response.meals ?? []
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    


    private var headerSection: some View {
        let displayName = FirebaseManager.shared.currentUser?.fullName ?? "Chef User"
        
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(displayName) ")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("What are we cooking today?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.top, 10)
    }

    private var searchBar: some View {
        
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search any recipe or ingredient...", text: $searchText)
                    .submitLabel(.search)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == category
                                ? Color.orange
                                : Color(.systemBackground)
                            )
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                            .shadow(color: selectedCategory == category ? .orange.opacity(0.4) : .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var heroRecipeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipe of the Day")
                .font(.title3)
                .fontWeight(.bold)

            ZStack(alignment: .topTrailing) {
                NavigationLink(destination: RecipeCardView(recipe: HeroCardView.recipeOfTheDay)) {
                    HeroCardView()
                }
                .buttonStyle(PlainButtonStyle())
                
                HeroFavoriteButton(recipe: HeroCardView.recipeOfTheDay)
                    .padding(16)
            }
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(searchText.isEmpty ? "Trending Recipes" : "Search Results")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                
            }

            if filteredRecipes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No recipes found ")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(
                    columns: AdaptiveLayout.recipeGridColumns(for: horizontalSizeClass),
                    spacing: 16
                ) {
                    ForEach(filteredRecipes) { recipe in
                        SimpleRecipeCardView(recipe: recipe)
                    }
                }
            }
        }
    }
}


struct SimpleRecipeCardView: View {
    let recipe: TheMealDBRecipe
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(destination: RecipeCardView(recipe: recipe)) {
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImage(url: URL(string: recipe.imageURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text(recipe.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    HStack {
                        Text(recipe.category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    favoritesManager.toggleFavorite(recipe)
                }
            } label: {
                Image(systemName: favoritesManager.isFavorite(recipe.id) ? "heart.fill" : "heart")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(favoritesManager.isFavorite(recipe.id) ? .red : .white)
                    .padding(8)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
    }
}




struct HeroFavoriteButton: View {
    let recipe: TheMealDBRecipe
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                favoritesManager.toggleFavorite(recipe)
            }
        } label: {
            Image(systemName: favoritesManager.isFavorite(recipe.id) ? "heart.fill" : "heart")
                .font(.system(size: 18))
                .foregroundColor(favoritesManager.isFavorite(recipe.id) ? .red : .primary)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct HeroCardView: View {
    static let recipeOfTheDay = TheMealDBRecipe(
        idMeal: "52803",
        strMeal: "Beef Wellington",
        strCategory: "Beef",
        strMealThumb: "https://www.themealdb.com/images/media/meals/1529444830.jpg"
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: Self.recipeOfTheDay.imageURL)) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.2)).overlay(ProgressView())
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Rectangle().fill(Color.gray.opacity(0.2)).overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            LinearGradient(
                colors: [.clear, .black.opacity(0.2), .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(Self.recipeOfTheDay.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("45 min")
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "flame")
                        Text("650 kcal")
                    }
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.95))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 240)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

typealias MockRecipe = TheMealDBRecipe


#Preview {
    HomeView(authVM: AuthViewModel())
}

