import SwiftUI
import AVFoundation

struct RecipeCardView: View {
    let recipe: MockRecipe
    @State private var isFavorite = false
    @State private var checkedIngredients: Set<String> = []
    
    // Voice Reader property
    private let speechSynthesizer = AVSpeechSynthesizer()
    @State private var currentlyReadingStep: Int? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // 1. Large Cover Photo with Floating Button
                headerSection
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title and Ratings
                    titleSection
                    
                    // 2. Nutritional Breakdown Tags
                    nutritionalTagsSection
                    
                    Divider()
                    
                    // 3. Interactive Ingredients Checklist
                    ingredientsSection
                    
                    Divider()
                    
                    // 4. Step-by-Step Instructions with Voice/Timer
                    instructionsSection
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .offset(y: -30) // Overlap the header image
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: recipe.imageURL)) { phase in
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
            
            // Gradient Overlay for readability at bottom of image
            LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .center, endPoint: .bottom)
                .frame(height: 350)
            
            // Floating Bookmark/Favorite Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isFavorite.toggle()
                }
            } label: {
                Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(isFavorite ? .orange : .white)
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(recipe.rating) Reviews").font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
    
    private var nutritionalTagsSection: some View {
        HStack(spacing: 16) {
            NutritionalTag(icon: "flame.fill", label: "Calories", value: "\(recipe.calories) kcal")
            NutritionalTag(icon: "clock.fill", label: "Prep", value: recipe.time)
            NutritionalTag(icon: "person.2.fill", label: "Servings", value: "\(recipe.servings)")
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
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    let isChecked = checkedIngredients.contains(ingredient)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isChecked {
                                checkedIngredients.remove(ingredient)
                            } else {
                                checkedIngredients.insert(ingredient)
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isChecked ? .green : .gray.opacity(0.5))
                                .font(.system(size: 24))
                            
                            Text(ingredient)
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
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step-by-Step Instructions")
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 16) {
                    // Step Number Bubble
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
                        
                        // Voice Reader & Timer Actions
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
                            
                            // Mock Timer Button (conditional based on text)
                            if step.lowercased().contains("min") || step.lowercased().contains("hour") {
                                Button {
                                    // Mock start timer
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "timer")
                                        Text("Start Timer")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                if index < recipe.instructions.count - 1 {
                    Divider().padding(.leading, 48)
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
        
        // Very basic mock reset (In a real app, use AVSpeechSynthesizerDelegate)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.1) {
            if currentlyReadingStep == index {
                currentlyReadingStep = nil
            }
        }
    }
}

// MARK: - Subcomponents

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
        clipShape( RoundedCorner(radius: radius, corners: corners) )
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

#Preview {
    RecipeCardView(recipe: MockRecipe(
        id: "1",
        title: "Spicy Arrabbiata Pasta",
        time: "30 min",
        rating: "4.8",
        imageURL: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
        calories: 650,
        servings: 2,
        ingredients: [
            "200g Penne Pasta",
            "2 tbsp Olive Oil",
            "3 Cloves Garlic, minced",
            "1 tsp Red Chili Flakes",
            "400g Crushed Tomatoes",
            "Fresh Basil",
            "Parmesan Cheese"
        ],
        instructions: [
            "Boil water in a large pot. Add salt and the penne pasta. Cook until al dente.",
            "In a large pan, heat olive oil over medium heat. Add minced garlic and sauté for 1 minute until fragrant.",
            "Add red chili flakes and crushed tomatoes to the pan. Simmer for 15 minutes.",
            "Drain the pasta and add it directly to the sauce. Toss well to combine.",
            "Garnish with fresh basil and grated Parmesan cheese before serving."
        ]
    ))
}
