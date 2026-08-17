import Foundation

struct UserProfile: Codable, Identifiable {
    var id: String // Firebase Auth UID
    var fullName: String
    var email: String
    var favoriteRecipeIDs: [String] // Saved Recipe IDs array
}
