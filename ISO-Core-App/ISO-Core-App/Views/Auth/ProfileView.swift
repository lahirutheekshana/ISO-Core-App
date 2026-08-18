import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var authVM: AuthViewModel
    
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
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
                .padding(.horizontal, 4)
                
                Spacer()
                
                // Logout Button
                Button {
                    authVM.logout()
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
