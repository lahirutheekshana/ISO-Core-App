import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PantryViewModel: ObservableObject {
    @Published var fridgeIngredients: [String] = []
    @Published var pantryItems: [PantryItem] = []
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
            let newItem = PantryItem(
                name: cleanIngredient,
                category: "Vegetables",
                storageLocation: "Fridge",
                quantity: 1,
                unit: "pcs",
                expiryDate: Date().addingTimeInterval(86400 * 7),
                expiryAlertDays: 1,
                notes: nil,
                expiryReminderEnabled: true
            )
            pantryItems.append(newItem)
            fridgeIngredients.append(cleanIngredient)
            NotificationManager.shared.applyExpiryReminder(for: newItem)
            savePantryItemToFirebase(newItem)
        }
    }
    
    func addPantryItem(_ item: PantryItem) {
        let cleanName = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        if !fridgeIngredients.contains(where: { $0.caseInsensitiveCompare(cleanName) == .orderedSame }) {
            var itemToSave = item
            itemToSave.name = cleanName
            pantryItems.append(itemToSave)
            fridgeIngredients.append(cleanName)
            NotificationManager.shared.applyExpiryReminder(for: itemToSave)
            savePantryItemToFirebase(itemToSave)
        }
    }
    
    func removeIngredient(_ ingredient: String) {
        if let item = pantryItems.first(where: { $0.name == ingredient }) {
            NotificationManager.shared.cancelExpiryNotification(for: item.id)
        }

        fridgeIngredients.removeAll { $0 == ingredient }
        pantryItems.removeAll { $0.name == ingredient }
        deleteIngredientFromFirebase(ingredient)
    }
    
    // MARK: - Update / Edit Ingredient Function
    func updateIngredient(oldItem: String, newItem: String) {
        let cleanNewItem = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanNewItem.isEmpty else { return }
        
        if let index = fridgeIngredients.firstIndex(of: oldItem) {
            fridgeIngredients[index] = cleanNewItem
        }
        
        if let itemIndex = pantryItems.firstIndex(where: { $0.name == oldItem }) {
            pantryItems[itemIndex].name = cleanNewItem
            NotificationManager.shared.applyExpiryReminder(for: pantryItems[itemIndex])
        }
        
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
    
    func updatePantryItem(oldName: String, updatedItem: PantryItem) {
        let cleanName = updatedItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        var itemToSave = updatedItem
        itemToSave.name = cleanName
        
        if let nameIndex = fridgeIngredients.firstIndex(of: oldName) {
            fridgeIngredients[nameIndex] = cleanName
        }
        
        if let itemIndex = pantryItems.firstIndex(where: { $0.name == oldName || $0.id == updatedItem.id }) {
            pantryItems[itemIndex] = itemToSave
        }
        
        NotificationManager.shared.applyExpiryReminder(for: itemToSave)
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "id": itemToSave.id,
            "name": itemToSave.name,
            "category": itemToSave.category,
            "storageLocation": itemToSave.storageLocation,
            "quantity": itemToSave.quantity,
            "unit": itemToSave.unit,
            "expiryDate": Timestamp(date: itemToSave.expiryDate),
            "expiryAlertDays": itemToSave.expiryAlertDays,
            "notes": itemToSave.notes ?? "",
            "expiryReminderEnabled": itemToSave.expiryReminderEnabled
        ]
        
        db.collection("users").document(userId).collection("pantry")
            .whereField("name", isEqualTo: oldName)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                for doc in documents {
                    doc.reference.updateData(data) { error in
                        if let error = error {
                            print("Error updating pantry item in Firebase: \(error.localizedDescription)")
                        } else {
                            print("✏️ Full pantry item updated in Firebase!")
                        }
                    }
                }
            }
    }
    
    func pantryItem(named name: String) -> PantryItem? {
        pantryItems.first { $0.name == name }
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
    private func savePantryItemToFirebase(_ item: PantryItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let data: [String: Any] = [
            "id": item.id,
            "name": item.name,
            "category": item.category,
            "storageLocation": item.storageLocation,
            "quantity": item.quantity,
            "unit": item.unit,
            "expiryDate": Timestamp(date: item.expiryDate),
            "expiryAlertDays": item.expiryAlertDays,
            "notes": item.notes ?? "",
            "expiryReminderEnabled": item.expiryReminderEnabled,
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
                var loadedItems: [PantryItem] = []
                var loadedNames: [String] = []
                
                for doc in documents {
                    let data = doc.data()
                    guard let name = data["name"] as? String else { continue }
                    
                    if loadedNames.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
                        continue
                    }
                    
                    let expiryDate: Date
                    if let timestamp = data["expiryDate"] as? Timestamp {
                        expiryDate = timestamp.dateValue()
                    } else {
                        expiryDate = Date().addingTimeInterval(86400 * 7)
                    }
                    
                    let notesValue = data["notes"] as? String
                    let item = PantryItem(
                        id: data["id"] as? String ?? doc.documentID,
                        name: name,
                        category: data["category"] as? String ?? "Vegetables",
                        storageLocation: data["storageLocation"] as? String ?? "Fridge",
                        quantity: data["quantity"] as? Int ?? 1,
                        unit: data["unit"] as? String ?? "pcs",
                        expiryDate: expiryDate,
                        expiryAlertDays: data["expiryAlertDays"] as? Int ?? 1,
                        notes: (notesValue?.isEmpty == false) ? notesValue : nil,
                        expiryReminderEnabled: data["expiryReminderEnabled"] as? Bool ?? true
                    )
                    
                    loadedItems.append(item)
                    loadedNames.append(name)
                }
                
                self.pantryItems = loadedItems
                self.fridgeIngredients = loadedNames
                NotificationManager.shared.syncExpiryNotifications(for: loadedItems)
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
