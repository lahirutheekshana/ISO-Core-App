import SwiftUI
import PhotosUI
import Vision

struct PantryFinderView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var pantryVM = PantryViewModel()
    @State private var newIngredient: String = ""
    
    @State private var pantryInventory: [PantryItem] = []
    @State private var showingAddInventorySheet: Bool = false
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var inputImage: UIImage?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    
                    NavigationLink(destination: PantryInventoryListView(pantryVM: pantryVM)) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait.fill")
                                .font(.title3)
                            Text("View Stored Pantry Items")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(14)
                    }
                    
                    let expiringCount = pantryInventory.filter { $0.isExpiringSoon }.count
                    if expiringCount > 0 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("\(expiringCount) ingredients expiring soon!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.15))
                        .cornerRadius(12)
                    }
                    
                    fridgeInputSection
                    ingredientsList
                    resultsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 90)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddInventorySheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(10)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddInventorySheet) {
                AddInventoryView { newItem in
                    pantryInventory.append(newItem)
                    pantryVM.addIngredient(newItem.name)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.inputImage = uiImage
                        processScannedImage()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "refrigerator.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .padding(.top, 20)
            
            Text("Pantry Match")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add what you have, we'll tell you what to make.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var fridgeInputSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .foregroundColor(.secondary)
            
            TextField("e.g. Eggs, Tomato, Cheese...", text: $newIngredient)
                .onSubmit {
                    pantryVM.addSearchIngredient(newIngredient)
                    newIngredient = ""
                }
                .submitLabel(.done)
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Circle())
            }
            
            if !newIngredient.isEmpty {
                Button {
                    pantryVM.addSearchIngredient(newIngredient)
                    newIngredient = ""
                } label: {
                    Text("Add")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    private var ingredientsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !pantryVM.searchIngredients.isEmpty {
                Text("Your Search Ingredients:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(pantryVM.searchIngredients, id: \.self) { ingredient in
                            HStack(spacing: 6) {
                                Text(ingredient)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Button {
                                    withAnimation {
                                        pantryVM.removeSearchIngredient(ingredient)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if pantryVM.isLoading {
                ProgressView("Finding recipes...")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if let error = pantryVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if pantryVM.searchIngredients.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Add ingredients to see recipes")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else if pantryVM.matchedRecipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No matching recipes found")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                Text("You can make:")
                    .font(.title3)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(pantryVM.matchedRecipes) { recipe in
                        SimpleRecipeCardView(recipe: recipe)
                    }
                }
            }
        }
    }
    
    private func processScannedImage() {
        guard let image = inputImage, let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string.lowercased() }
            
            DispatchQueue.main.async {
                let commonIngredients = ["tomato", "eggs", "egg", "cheese", "milk", "bread", "butter", "chicken", "onion", "garlic"]
                
                var foundAny = false
                for text in recognizedStrings {
                    for ingredient in commonIngredients {
                        if text.contains(ingredient) {
                            pantryVM.addSearchIngredient(ingredient.capitalized)
                            foundAny = true
                        }
                    }
                }
                if !foundAny {
                    let fallback = ["Tomato", "Eggs", "Cheese"]
                    for item in fallback {
                        pantryVM.addSearchIngredient(item)
                    }
                }
            }
        }
        
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

#Preview {
    PantryFinderView(authVM: AuthViewModel())
}
