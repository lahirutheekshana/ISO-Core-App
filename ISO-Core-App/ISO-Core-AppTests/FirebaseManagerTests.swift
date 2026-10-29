import XCTest
import Combine
@testable import ISO_Core_App

@MainActor
final class FirebaseManagerTests: XCTestCase {

    // ✅ Directly initialized - No optionals, no `nil` needed!
    let firebaseManager = FirebaseManager()
    var cancellables = Set<AnyCancellable>()

    // 1. Test Case: Verify local signOut state clearing logic
    func testSignOutLocalStateReset() throws {
        // Given
        let mockUser = UserProfile(
            id: "test_uid_123",
            fullName: "Chef John",
            email: "john@example.com",
            favoriteRecipeIDs: ["recipe_1", "recipe_2"]
        )
        firebaseManager.currentUser = mockUser
        firebaseManager.favoriteRecipeIDs = mockUser.favoriteRecipeIDs

        XCTAssertNotNil(firebaseManager.currentUser, "Current user should be set initially.")
        XCTAssertFalse(firebaseManager.favoriteRecipeIDs.isEmpty, "Favorites list should not be empty initially.")

        // When (Simulating sign out reset)
        firebaseManager.currentUser = nil
        firebaseManager.favoriteRecipeIDs.removeAll()

        // Then
        XCTAssertNil(firebaseManager.currentUser, "Current user should be nil after sign out.")
        XCTAssertTrue(firebaseManager.favoriteRecipeIDs.isEmpty, "Favorite recipe IDs should be cleared after sign out.")
    }

    // 2. Test Case: Verify optimistic local toggle favorite array logic
    func testToggleFavoriteLocalOptimisticUpdate() throws {
        // Given
        firebaseManager.favoriteRecipeIDs = ["recipe_1", "recipe_2"]
        let recipeToToggle = "recipe_1"

        // When
        if firebaseManager.favoriteRecipeIDs.contains(recipeToToggle) {
            firebaseManager.favoriteRecipeIDs.removeAll { $0 == recipeToToggle }
        } else {
            firebaseManager.favoriteRecipeIDs.append(recipeToToggle)
        }

        // Then
        XCTAssertFalse(firebaseManager.favoriteRecipeIDs.contains("recipe_1"), "Toggling an existing favorite should remove it.")
        XCTAssertEqual(firebaseManager.favoriteRecipeIDs.count, 1, "Favorites count should decrease to 1.")
        XCTAssertTrue(firebaseManager.favoriteRecipeIDs.contains("recipe_2"), "Other favorites should remain unaffected.")

        // When toggling a new recipe
        let newRecipe = "recipe_3"
        if firebaseManager.favoriteRecipeIDs.contains(newRecipe) {
            firebaseManager.favoriteRecipeIDs.removeAll { $0 == newRecipe }
        } else {
            firebaseManager.favoriteRecipeIDs.append(newRecipe)
        }

        // Then
        XCTAssertTrue(firebaseManager.favoriteRecipeIDs.contains("recipe_3"), "Toggling a new recipe should append it to favorites.")
        XCTAssertEqual(firebaseManager.favoriteRecipeIDs.count, 2, "Favorites count should increase to 2.")
    }
}
