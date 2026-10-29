import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PantryViewModel: ObservableObject {
    @Published var fridgeIngredients: [String] = []
    @Published var searchIngredients: [String] = []
    
    @Published var matchedRecipes: [TheMealDBRecipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager.shared
    private let db = Firestore.firestore()
    
    init(){
        fetchPantryItemsFromFirebase()
    }
    
    // MARK: - Search Ingredients Functions
    func addSearchIngredient(_ ingredient: String) {
        let cleanIngredient = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanIngredient.isEmpty else { return }
        
        if !searchIngredients.contains(where: { $0.caseInsensitiveCompare(cleanIngredient) == .orderedSame }) {
            searchIngredients.append(cleanIngredient)
            
            Task {
                await fetchMatchingRecipes()
            }
        }
    }
    
    func removeSearchIngredient(_ ingredient: String) {
        searchIngredients.removeAll { $0 == ingredient }
        
        Task {
            await fetchMatchingRecipes()
        }
    }
    
    // MARK: - Pantry Inventory Functions
    func addIngredient(_ ingredient: String) {
        let cleanIngredient = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanIngredient.isEmpty else { return }
        
        if !fridgeIngredients.contains(where: { $0.caseInsensitiveCompare(cleanIngredient) == .orderedSame }) {
            fridgeIngredients.append(cleanIngredient)
            saveIngredientToFirebase(cleanIngredient)
        }
    }
    
    func removeIngredient(_ ingredient: String) {
        fridgeIngredients.removeAll { $0 == ingredient }
        deleteIngredientFromFirebase(ingredient)
    }
    
    // MARK: - Update / Edit Ingredient Function
    func updateIngredient(oldItem: String, newItem: String) {
        let cleanNewItem = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanNewItem.isEmpty else { return }
        
        if let index = fridgeIngredients.firstIndex(of: oldItem) {
            fridgeIngredients[index] = cleanNewItem
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            db.collection("users").document(userId).collection("pantry")
                .whereField("name", isEqualTo: oldItem)
                .getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents else { return }
                    for doc in documents {
                        doc.reference.updateData(["name": cleanNewItem]) { error in
                            if let error = error {
                                print("Error updating in Firebase: \(error.localizedDescription)")
                            } else {
                                print("✏️ Pantry item updated in Firebase!")
                            }
                        }
                    }
                }
        }
    }
    
    // MARK: - Fetch Recipes using searchIngredients (Fixed!)
    private func fetchMatchingRecipes() async {
       
        guard let rawIngredient = searchIngredients.first else {
            self.matchedRecipes = []
            return
        }
        
    
        let mainIngredient = rawIngredient.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        isLoading = true
        errorMessage = nil
        
        guard let encodedIngredient = mainIngredient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.errorMessage = "Invalid ingredient name"
            self.isLoading = false
            return
        }
        
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(encodedIngredient)"
        print("🔍 API URL: \(urlString)")
        
        do {
            let response: MealDBResponse = try await networkManager.fetch(from: urlString)
            self.matchedRecipes = response.meals ?? []
        } catch {
            self.errorMessage = error.localizedDescription
            self.matchedRecipes = []
        }
        
        isLoading = false
    }
    
    // MARK: - Firebase Functions
    private func saveIngredientToFirebase(_ item: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "name": item,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).collection("pantry").addDocument(data: data) { error in
            if let error = error {
                print("Error saving to Firebase: \(error.localizedDescription)")
            } else {
                print("✅ Pantry item saved to Firebase!")
            }
        }
    }
    
    func fetchPantryItemsFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("pantry")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching from Firebase: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                var loadedItems: [String] = []
                
                for doc in documents {
                    if let name = doc.data()["name"] as? String {
                        loadedItems.append(name)
                    }
                }
                
                self.fridgeIngredients = Array(Set(loadedItems))
            }
    }
    
    private func deleteIngredientFromFirebase(_ item: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("pantry")
            .whereField("name", isEqualTo: item)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                for doc in documents {
                    doc.reference.delete { error in
                        if let error = error {
                            print("Error deleting from Firebase: \(error.localizedDescription)")
                        } else {
                            print("🗑️ Pantry item deleted from Firebase!")
                        }
                    }
                }
            }
    }
}
