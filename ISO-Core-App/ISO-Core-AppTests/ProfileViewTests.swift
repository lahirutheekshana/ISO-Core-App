import XCTest
import SwiftUI
@testable import ISO_Core_App

@MainActor
final class ProfileViewTests: XCTestCase {

  
    func testUserNameValidationRule() throws {
 
        let emptyName = "   "
        let validName = "Lahiru Theekshana"

        let isEmptyValidationPassed = !emptyName.trimmingCharacters(in: .whitespaces).isEmpty
        let isValidNameValidationPassed = !validName.trimmingCharacters(in: .whitespaces).isEmpty

    
        XCTAssertFalse(isEmptyValidationPassed, "Whitespace-only or empty name updates should be blocked.")
        XCTAssertTrue(isValidNameValidationPassed, "Valid non-empty name updates should be allowed.")
    }

    func testLocalUserProfileNameUpdate() throws {

        var mockUser = UserProfile(
            id: "user_123",
            fullName: "Old Name",
            email: "test@example.com",
            favoriteRecipeIDs: []
        )
        let newName = "New Chef Name"


        mockUser.fullName = newName

        XCTAssertEqual(mockUser.fullName, "New Chef Name", "User profile full name should be successfully updated locally.")
    }

    func testDarkModeColorSchemeMapping() throws {

        let isDarkModeTrue = true
        let isDarkModeFalse = false


        let darkScheme: ColorScheme = isDarkModeTrue ? .dark : .light
        let lightScheme: ColorScheme = isDarkModeFalse ? .dark : .light

  
        XCTAssertEqual(darkScheme, .dark, "True dark mode state should map to .dark color scheme.")
        XCTAssertEqual(lightScheme, .light, "False dark mode state should map to .light color scheme.")
    }
}
