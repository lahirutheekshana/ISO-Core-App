import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Breakfast", "Pasta", "Vegan", "Desserts", "Meat", "Seafood"]
    
    // Placeholder Mock Data
    let trendingRecipes = [
        MockRecipe(id: "1", title: "Spicy Arrabbiata Pasta", time: "30 min", rating: "4.8", imageURL: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg"),
        MockRecipe(id: "2", title: "Avocado Toast", time: "10 min", rating: "4.9", imageURL: "https://www.themealdb.com/images/media/meals/1529446358.jpg"),
        MockRecipe(id: "3", title: "Vegan Pancakes", time: "20 min", rating: "4.7", imageURL: "https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg"),
        MockRecipe(id: "4", title: "Grilled Salmon", time: "25 min", rating: "4.9", imageURL: "https://www.themealdb.com/images/media/meals/1525876468.jpg")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    searchBar
                    categoryChips
                    heroRecipeCard
                    trendingSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, Chef! 👋")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("What are we cooking today?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                // Profile action
            } label: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .foregroundStyle(.orange, Color(.systemGray5))
            }
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
            
            Button {
                // Filter action
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.orange)
                    .cornerRadius(16)
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
            }
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
            
            HeroCardView()
        }
    }
    
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trending Recipes")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("See All") {
                    // See all action
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(trendingRecipes) { recipe in
                    RecipeCardView(recipe: recipe)
                }
            }
        }
    }
}

// MARK: - Hero Card View
struct HeroCardView: View {
    @State private var isFavorite = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            AsyncImage(url: URL(string: "https://www.themealdb.com/images/media/meals/1529444830.jpg")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Gradient Overlay for Readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.2), .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Favorite Button (Top Right Floating)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            isFavorite.toggle()
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(isFavorite ? .red : .primary)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(16)
                }
                Spacer()
            }
            
            // Hero Content Overlay
            VStack(alignment: .leading, spacing: 10) {
                Text("Beef Wellington")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("⏱️ 45 min")
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame")
                        Text("🔥 650 kcal")
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

// Mock Data Model needed for HomeView and RecipeCardView Preview
struct MockRecipe: Identifiable {
    let id: String
    let title: String
    let time: String
    let rating: String
    let imageURL: String
}

#Preview {
    HomeView()
}
