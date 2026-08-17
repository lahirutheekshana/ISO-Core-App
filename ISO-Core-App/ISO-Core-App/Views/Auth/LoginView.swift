import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var showRegister = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("Welcome Back! 👋")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Sign in to access your saved recipes")
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                TextField("Email Address", text: $authVM.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                SecureField("Password", text: $authVM.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.top, 20)
            
            if let error = authVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button {
                authVM.login()
            } label: {
                if authVM.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.orange)
            .cornerRadius(12)
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                Button("Sign Up") {
                    showRegister = true
                }
                .fontWeight(.bold)
                .foregroundColor(.orange)
            }
        }
        .padding(24)
        .sheet(isPresented: $showRegister) {
            RegisterView(authVM: authVM)
        }
    }
}
