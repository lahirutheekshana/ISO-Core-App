import XCTest
@testable import ISO_Core_App

final class KeychainHelperTests: XCTestCase {
    
    override func setUpWithError() throws {
        KeychainHelper.clearCredentials()
    }
    
    override func tearDownWithError() throws {
        KeychainHelper.clearCredentials()
    }
    
    func testSaveAndLoadCredentials() throws {
        let email = "faceid@test.com"
        let password = "securePassword123"
        
        let didSave = KeychainHelper.saveCredentials(email: email, password: password)
        
        XCTAssertTrue(didSave, "Credentials should save successfully to the Keychain.")
        XCTAssertTrue(KeychainHelper.hasSavedCredentials)
        
        let loaded = KeychainHelper.loadCredentials()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.email, email)
        XCTAssertEqual(loaded?.password, password)
    }
    
    func testClearCredentials() throws {
        KeychainHelper.saveCredentials(email: "clear@test.com", password: "password123")
        XCTAssertTrue(KeychainHelper.hasSavedCredentials)
        
        KeychainHelper.clearCredentials()
        
        XCTAssertFalse(KeychainHelper.hasSavedCredentials)
        XCTAssertNil(KeychainHelper.loadCredentials())
    }
    
    func testHasSavedCredentialsWhenEmpty() throws {
        XCTAssertFalse(KeychainHelper.hasSavedCredentials)
        XCTAssertNil(KeychainHelper.loadCredentials())
    }
}
