import SwiftUI
import Combine

struct LoginView: View {
    
    @ObservedObject var authVM: AuthViewModel
    
    @State private var showRegister = false
    
    @State private var isPasswordVisible: Bool = false
    
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        
        ZStack {
            
           
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
               
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.23))
                    .padding(.bottom, 10)
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
                    Text("Welcome Back!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Sign in to access your saved recipes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)
                
                
                VStack(spacing: 16) {
                    
                    TextField("Email Address", text: $authVM.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .background(Color(white: 0.96))
                        .cornerRadius(14)
                    
                    HStack{
                        if isPasswordVisible{
                            TextField("Password", text: $authVM.password)
                        }else{
                            SecureField("Password", text: $authVM.password)
                        }
                        
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill").foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color(white: 0.96))
                    .cornerRadius(14)
                }
                
               
                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
           
                Button {
                    authVM.login()
                } label: {
                    HStack {
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign In")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(red: 1.0, green: 0.23, blue: 0.23))
                    .cornerRadius(16)
                    .shadow(color: Color(red: 1.0, green: 0.23, blue: 0.23).opacity(0.35), radius: 10, x: 0, y: 6)
                }
                .padding(.top, 4)
                
                HStack(spacing:12){
                    VStack { Divider() }
                    Text("OR")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    VStack { Divider() }
                }
                .padding(.vertical, 4)
                
                
                
                Button {
                    authVM.signInWithGoogle()
                }label: {
                    HStack(spacing: 10){
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text("Continue with Google")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(white: 0.96))
                    .cornerRadius(16)
                    overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Spacer()
                
             
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    Button {
                        showRegister = true
                    } label: {
                        Text("Sign Up")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.23))
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 28)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView(authVM: authVM)
        }
    }
}
