import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    @Published var currentUser: UserProfile?
    @Published var favoriteRecipeIDs: [String] = []
    
    
    func signUp(email: String, password: String, fullName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        
        let newUser = UserProfile(id: uid, fullName: fullName, email: email, favoriteRecipeIDs: [])
        try db.collection("users").document(uid).setData(from: newUser)
        
        DispatchQueue.main.async {
            self.currentUser = newUser
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid
        await fetchUserProfile(uid: uid)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.favoriteRecipeIDs = []
        }
    }
    
    func fetchUserProfile(uid: String) async {
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            if let user = try? snapshot.data(as: UserProfile.self) {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.favoriteRecipeIDs = user.favoriteRecipeIDs
                }
            }
        } catch {
            print("Error fetching profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Firestore Favorites / Bookmarks Logic
    
    func toggleFavorite(recipeID: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if favoriteRecipeIDs.contains(recipeID) {
            favoriteRecipeIDs.removeAll { $0 == recipeID }
        } else {
            favoriteRecipeIDs.append(recipeID)
        }
        
        db.collection("users").document(uid).updateData([
            "favoriteRecipeIDs": favoriteRecipeIDs
        ])
    }
}

