import SwiftUI
import Combine
import AVFoundation

struct RecipeCardView: View {
    let recipeId: String
    let initialRecipe: TheMealDBRecipe?
    
    @StateObject private var viewModel = RecipeDetailViewModel()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var checkedIngredients: Set<String> = []
    
    @Environment(\.dismiss) private var dismiss
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var currentlyReadingStep: Int? = nil
    
    init(recipeId: String, initialRecipe: TheMealDBRecipe? = nil) {
        self.recipeId = recipeId
        self.initialRecipe = initialRecipe
    }
    
    init(recipe: TheMealDBRecipe) {
        self.recipeId = recipe.id
        self.initialRecipe = recipe
    }
    
    private var currentTitle: String {
        viewModel.recipe?.strMeal ?? initialRecipe?.title ?? "Recipe Details"
    }
    
    private var currentImageURL: String {
        viewModel.recipe?.strMealThumb ?? initialRecipe?.imageURL ?? ""
    }
    
    private var currentCategory: String {
        viewModel.recipe?.strCategory ?? initialRecipe?.category ?? "General"
    }
    
    private var currentArea: String {
        viewModel.recipe?.strArea ?? ""
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    nutritionalTagsSection
                    Divider()
                    ingredientsSection
                    Divider()
                    instructionsSection
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchRecipeDetails(for: recipeId)
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                AsyncImage(url: URL(string: currentImageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Rectangle().fill(Color.gray.opacity(0.3)).overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 350)
                .clipped()
                
                LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .center, endPoint: .bottom)
                    .frame(height: 350)
            }
            
            // Floating back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.leading, 20)
            .padding(.top, 56)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Text(currentTitle)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        let favRecipe = initialRecipe ?? TheMealDBRecipe(
                            idMeal: recipeId,
                            strMeal: currentTitle,
                            strCategory: currentCategory,
                            strMealThumb: currentImageURL,
                            strInstructions: viewModel.recipe?.strInstructions
                        )
                        favoritesManager.toggleFavorite(favRecipe)
                    }
                } label: {
                    Image(systemName: favoritesManager.isFavorite(recipeId) ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(favoritesManager.isFavorite(recipeId) ? .red : .secondary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text("4.8 Reviews").font(.subheadline).foregroundColor(.secondary)
                }
                
                if !currentArea.isEmpty {
                    Text("•").foregroundColor(.secondary)
                    Text(currentArea).font(.subheadline).foregroundColor(.secondary)
                }
                
                if !currentCategory.isEmpty && currentCategory != "All" {
                    Text("•").foregroundColor(.secondary)
                    Text(currentCategory).font(.subheadline).foregroundColor(.orange)
                }
            }
        }
    }
    
    private var nutritionalTagsSection: some View {
        HStack(spacing: 16) {
            NutritionalTag(icon: "flame.fill", label: "Calories", value: "450 kcal")
            NutritionalTag(icon: "clock.fill", label: "Prep", value: "30 min")
            NutritionalTag(icon: "person.2.fill", label: "Servings", value: "2")
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingredients Checklist")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Select the ingredients you already have:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if viewModel.isLoading && viewModel.recipe == nil {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Fetching ingredients...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else if let error = viewModel.errorMessage, viewModel.recipe == nil {
                VStack(spacing: 8) {
                    Text("Failed to load recipe: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await viewModel.fetchRecipeDetails(for: recipeId) }
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
            } else if let recipe = viewModel.recipe {
                if recipe.ingredients.isEmpty {
                    Text("No ingredient measurements listed for this recipe.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(recipe.ingredients, id: \.ingredient) { item in
                            let ingredientText = item.measure.isEmpty ? item.ingredient : "\(item.measure) \(item.ingredient)"
                            let isChecked = checkedIngredients.contains(ingredientText)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if isChecked {
                                        checkedIngredients.remove(ingredientText)
                                    } else {
                                        checkedIngredients.insert(ingredientText)
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isChecked ? .green : .gray.opacity(0.5))
                                        .font(.system(size: 24))
                                    
                                    Text(ingredientText)
                                        .font(.body)
                                        .foregroundColor(isChecked ? .secondary : .primary)
                                        .strikethrough(isChecked, color: .secondary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(isChecked ? Color.green.opacity(0.05) : Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step-by-Step Instructions")
                .font(.title3)
                .fontWeight(.bold)
            
            if viewModel.isLoading && viewModel.recipe == nil {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Fetching instructions...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else if let recipe = viewModel.recipe {
                let steps = recipe.instructionSteps
                
                if steps.isEmpty {
                    Text(recipe.strInstructions ?? "No instructions available.")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 16) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.orange)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(step)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineSpacing(4)
                                
                                HStack(spacing: 16) {
                                    Button {
                                        readAloud(text: step, index: index)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: currentlyReadingStep == index ? "speaker.wave.3.fill" : "play.circle.fill")
                                            Text(currentlyReadingStep == index ? "Reading..." : "Read Aloud")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        if index < steps.count - 1 {
                            Divider().padding(.leading, 48)
                        }
                    }
                }
            }
        }
    }
    
    private func readAloud(text: String, index: Int) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        currentlyReadingStep = index
        speechSynthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.1) {
            if currentlyReadingStep == index {
                currentlyReadingStep = nil
            }
        }
    }
}

struct NutritionalTag: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// Helper to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

