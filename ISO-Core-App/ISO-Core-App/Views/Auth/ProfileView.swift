import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
   
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("expiryAlertsEnabled") private var expiryAlertsEnabled: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
               
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 65, height: 65)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(firebaseManager.currentUser?.fullName ?? "Chef User")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(firebaseManager.currentUser?.email ?? "chef@smartchef.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                
                Section(header: Text("Overview")) {
                    HStack {
                        Label("Saved Recipes", systemImage: "heart.fill")
                            .foregroundColor(.red)
                        Spacer()
                        Text("\(firebaseManager.favoriteRecipeIDs.count) items")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                
                
                Section(header: Text("Notifications & Alerts"), footer: Text("Receive timely push notifications before pantry items reach their expiry date.")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Allow Notifications", systemImage: "bell.badge.fill")
                            .foregroundColor(.purple)
                    }
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            NotificationManager.shared.requestAuthorization()
                        }
                    }
                    
                    Toggle(isOn: $expiryAlertsEnabled) {
                        Label("Pantry Expiry Alerts", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                    }
                    .disabled(!notificationsEnabled)
                }
                
                
                Section(header: Text("Security")) {
                    HStack {
                        Label("Face ID / Biometrics", systemImage: "faceid")
                            .foregroundColor(.blue)
                        Spacer()
                        Button {
                            auth.authenticateWithBiometrics()
                        } label: {
                            Text("Test Face ID")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
                
               
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Appearance", systemImage: "moon.fill")
                            .foregroundColor(.indigo)
                    }
                }
                
               
                Section {
                    Button(role: .destructive) {
                        auth.logout()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Log Out", systemImage: "arrow.right.square.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .preferredColorScheme(isDarkMode ? .dark : .light) 
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
