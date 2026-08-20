import SwiftUI
import FirebaseAuth
import Combine
import FirebaseCore
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
       
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
                self.isAuthenticated = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
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
