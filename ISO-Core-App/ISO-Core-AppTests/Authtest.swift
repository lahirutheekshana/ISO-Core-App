import XCTest
@testable import ISO_Core_App 

final class Authtest: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
       
    }

    func testEmailValidation() throws {
        let validEmail = "lahiru@gmail.com"
        let invalidEmail = "lahiru.com"
        
        XCTAssertTrue(validEmail.contains("@"), "Email should contain @ symbol")
        XCTAssertFalse(invalidEmail.contains("@"), "Invalid email should fail")
    }

    
    func testPasswordLength() throws {
        let password = "securePassword123"
        XCTAssertGreaterThanOrEqual(password.count, 6, "Password must be at least 6 characters long")
    }
}
