import SwiftUI

struct PantryFinderView: View {
    
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var pantryVM = PantryViewModel()
    @State private var newIngredient: String = ""
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    fridgeInputSection
                    ingredientsList
                    resultsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 90)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showingImagePicker, onDismiss: processScannedImage) {
                            ImagePicker(image: $inputImage, sourceType: sourceType)
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
        HStack(spacing:12){
            Image(systemName: "plus.circle")
                .foregroundColor(.secondary)
            
            TextField("e.g. Eggs, Tomato, Cheese...", text: $newIngredient)
                .onSubmit {
                    pantryVM.addIngredient(newIngredient)
                    newIngredient = ""
                }
                .submitLabel(.done)
            
            Button{
                #if targetEnvironment(simulator)
                self.sourceType = .photoLibrary
                #else
                self.sourceType = .camera
                #endif
                self.showingImagePicker = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size:18,weight: .medium))
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Circle())
            }
            
            if !newIngredient.isEmpty {
                Button {
                    pantryVM.addIngredient(newIngredient)
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
            if !pantryVM.fridgeIngredients.isEmpty {
                Text("Your Fridge:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(pantryVM.fridgeIngredients, id: \.self) { ingredient in
                            HStack(spacing: 6) {
                                Text(ingredient)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Button {
                                    withAnimation {
                                        pantryVM.removeIngredient(ingredient)
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
            } else if pantryVM.fridgeIngredients.isEmpty {
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
        guard let image = inputImage else { return }
        
        let detectedIngredients = ["Tomato", "Eggs", "Cheese"]
                
        for item in detectedIngredients {
            pantryVM.addIngredient(item)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    PantryFinderView(authVM: AuthViewModel())
}
