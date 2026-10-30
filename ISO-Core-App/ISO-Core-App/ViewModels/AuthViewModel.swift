import SwiftUI
import FirebaseAuth
import Combine
import FirebaseCore
import GoogleSignIn
import LocalAuthentication

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var biometricStatusMessage: String?
    @Published var isBiometricLoginAvailable = false
    
    init() {
        refreshBiometricAvailability()
        checkCurrentUser()
    }
    
    private func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            self.isAuthenticated = true
            Task {
                await FirebaseManager.shared.fetchUserProfile(uid: user.uid)
            }
        }
    }
    
    private func refreshBiometricAvailability() {
        isBiometricLoginAvailable = KeychainHelper.hasSavedCredentials
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await FirebaseManager.shared.signIn(email: email, password: password)
                let didSave = KeychainHelper.saveCredentials(email: email, password: password)
                self.isBiometricLoginAvailable = didSave
                self.isAuthenticated = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    // Face ID — uses Keychain credentials, or the email/password currently typed on the login form
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.errorMessage = error?.localizedDescription ?? "Face ID / Biometrics is not supported on this device."
            return
        }
        
        let credentialsFromKeychain = KeychainHelper.loadCredentials()
        let credentialsFromForm: (email: String, password: String)? = {
            guard !email.isEmpty, !password.isEmpty else { return nil }
            return (email, password)
        }()
        
        guard let credentials = credentialsFromKeychain ?? credentialsFromForm else {
            self.errorMessage = "Enter your email and password, then tap Face ID to sign in and enable it for next time."
            self.isBiometricLoginAvailable = false
            return
        }
        
        let reason = "Authenticate to access your saved recipes & pantry in SmartChef."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            Task { @MainActor in
                if success {
                    await self.signInWithCredentials(credentials, saveToKeychain: true)
                } else {
                    self.errorMessage = authenticationError?.localizedDescription ?? "Face ID authentication failed."
                }
            }
        }
    }
    
    /// Profile "Test Face ID" — only verifies biometrics, does not sign in.
    func testBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricStatusMessage = error?.localizedDescription ?? "Face ID / Biometrics is not supported on this device."
            return
        }
        
        let reason = "Confirm Face ID is working for SmartChef."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            Task { @MainActor in
                if success {
                    self.biometricStatusMessage = "Face ID verified successfully."
                } else {
                    self.biometricStatusMessage = authenticationError?.localizedDescription ?? "Face ID authentication failed."
                }
            }
        }
    }
    
    private func signInWithCredentials(_ credentials: (email: String, password: String), saveToKeychain: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirebaseManager.shared.signIn(email: credentials.email, password: credentials.password)
            self.email = credentials.email
            if saveToKeychain {
                self.isBiometricLoginAvailable = KeychainHelper.saveCredentials(
                    email: credentials.email,
                    password: credentials.password
                )
            }
            self.isAuthenticated = true
        } catch {
            if KeychainHelper.hasSavedCredentials {
                KeychainHelper.clearCredentials()
                self.isBiometricLoginAvailable = false
            }
            self.errorMessage = "Could not sign in with Face ID. Check your email and password, then try again."
        }
        
        isLoading = false
    }
    
    func register() {
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await FirebaseManager.shared.signUp(email: email, password: password, fullName: fullName)
                let didSave = KeychainHelper.saveCredentials(email: email, password: password)
                self.isBiometricLoginAvailable = didSave
                self.isAuthenticated = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func logout() {
        do {
            try FirebaseManager.shared.signOut()
            self.isAuthenticated = false
            self.email = ""
            self.password = ""
            refreshBiometricAvailability()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMessage = "Firebase Client ID is missing."
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            self.errorMessage = "Unable to get Root View Controller."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.errorMessage = "Failed to fetch Google ID Token."
                    self.isLoading = false
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                
                do {
                    _ = try await Auth.auth().signIn(with: credential)
                    self.isAuthenticated = true
                } catch {
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
}
