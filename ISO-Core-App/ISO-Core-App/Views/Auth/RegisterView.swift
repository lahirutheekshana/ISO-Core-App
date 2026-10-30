import SwiftUI
import Combine

struct RegisterView: View {
    
    @ObservedObject var authVM: AuthViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var iconScale: CGFloat = 1.0
    
    @State private var isPasswordVisible: Bool = false
    
    private let brandRed = Color(red: 1.0, green: 0.23, blue: 0.23)
    
    private var fieldBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    
    private var screenBackground: Color {
        Color(uiColor: .systemBackground)
    }
    
    var body: some View {
        
        ZStack {

            screenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(brandRed)
                    .padding(.bottom, 10)
                    .scaleEffect(iconScale)
                    .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                                iconScale = 1.2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    iconScale = 1.0
                                }
                            }
                        }
                

                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    Text("Sign up to start cooking today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                

                VStack(spacing: 16) {
                    TextField("Full Name", text: $authVM.fullName)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(fieldBackground)
                        .cornerRadius(14)
                    
                    TextField("Email Address", text: $authVM.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(fieldBackground)
                        .cornerRadius(14)
                    
                    HStack {
                        
                        if isPasswordVisible {
                            TextField("Password", text: $authVM.password)
                                .foregroundColor(.primary)
                        } else {
                            SecureField("Password", text: $authVM.password)
                                .foregroundColor(.primary)
                        }
                                            
                        Button {
                            isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(fieldBackground)
                        .cornerRadius(14)
                    
                }
                
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
            
                Button {
                    authVM.register()
                    if authVM.errorMessage == nil { dismiss() }
                } label: {
                    HStack {
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(brandRed)
                    .cornerRadius(16)
                    .shadow(color: brandRed.opacity(0.35), radius: 10, x: 0, y: 6)
                }
                .padding(.top, 8)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Sign In")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(brandRed)
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 28)
        }
    }
}
