import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    nonisolated init() {
            Task { @MainActor in
                if let user = Auth.auth().currentUser {
                    self.isAuthenticated = true
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
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
