import Foundation
import Security

enum KeychainHelper {
    
    private static let serviceName = "com.smartchef.credentials"
    private static let emailAccount = "userEmail"
    private static let passwordAccount = "userPassword"
    
    @discardableResult
    static func saveCredentials(email: String, password: String) -> Bool {
        let didSaveEmail = save(account: emailAccount, value: email)
        let didSavePassword = save(account: passwordAccount, value: password)
        return didSaveEmail && didSavePassword
    }
    
    static func loadCredentials() -> (email: String, password: String)? {
        guard let email = load(account: emailAccount),
              let password = load(account: passwordAccount),
              !email.isEmpty,
              !password.isEmpty else {
            return nil
        }
        return (email, password)
    }
    
    static var hasSavedCredentials: Bool {
        loadCredentials() != nil
    }
    
    static func clearCredentials() {
        delete(account: emailAccount)
        delete(account: passwordAccount)
    }
    
    @discardableResult
    private static func save(account: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        delete(account: account)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess || status == errSecDuplicateItem, "Keychain save failed for \(account): \(status)")
        return status == errSecSuccess || status == errSecDuplicateItem
    }
    
    private static func load(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
    
    private static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
