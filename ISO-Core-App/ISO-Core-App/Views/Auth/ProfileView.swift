import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // User Info Card
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.orange)
                    
                    Text(firebaseManager.currentUser?.fullName ?? "Chef User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(firebaseManager.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                // Saved Recipes Count
                HStack {
                    Text("Saved Recipes")
                        .font(.headline)
                    Spacer()
                    Text("\(firebaseManager.favoriteRecipeIDs.count) items")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 8)
                
                // App Settings & Security Section
                VStack(spacing: 12) {
                    HStack {
                        Text("App Security")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundColor(Color(red: 1.0, green: 0.23, blue: 0.23))
                            .font(.title3)
                        
                        Text("Face ID Unlock")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button {
                            auth.authenticateWithBiometrics()
                        } label: {
                            Text("Test Face ID")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                }
                
                Spacer()
                
                // Logout Button
                Button {
                    auth.logout()
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Log Out")
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .navigationTitle("Profile")
            .background(Color(.systemGroupedBackground))
        }
    }
}
