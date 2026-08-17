import SwiftUI
import Combine

struct RegisterView: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("Create Account ✨")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Sign up to start cooking today")
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                TextField("Full Name", text: $authVM.fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
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
            
            if let error = authVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button {
                authVM.register()
                if authVM.errorMessage == nil { dismiss() }
            } label: {
                if authVM.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.orange)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding(24)
    }
}
