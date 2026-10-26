import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("expiryAlertsEnabled") private var expiryAlertsEnabled: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isUploading: Bool = false
    
    @State private var isEditingName: Bool = false
    @State private var newName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 65, height: 65)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 65, height: 65)
                                        .foregroundColor(.primary)
                                }
                                
                                if isUploading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                        .frame(width: 65, height: 65)
                                        .background(Color.black.opacity(0.4))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    uploadProfileImageToFirebase(data: data)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(firebaseManager.currentUser?.fullName ?? "lahiru teek")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Button {
                                    newName = firebaseManager.currentUser?.fullName ?? ""
                                    isEditingName = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                }
                            }
                            
                            Text(firebaseManager.currentUser?.email ?? "lahiruteek@gmail.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Overview")) {
                    HStack {
                        Label("Saved Recipes", systemImage: "heart.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(firebaseManager.favoriteRecipeIDs.count) items")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notifications & Alerts"),
                        footer: Text("Receive timely push notifications before pantry items reach their expiry date.")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Allow Notifications", systemImage: "bell.badge.fill")
                            .foregroundColor(.primary)
                    }
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            NotificationManager.shared.requestAuthorization()
                        }
                    }
                    
                    Toggle(isOn: $expiryAlertsEnabled) {
                        Label("Pantry Expiry Alerts", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.primary)
                    }
                    .disabled(!notificationsEnabled)
                }
                
                Section(header: Text("Security")) {
                    HStack {
                        Label("Face ID / Biometrics", systemImage: "faceid")
                            .foregroundColor(.primary)
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
                            .foregroundColor(.primary)
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
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .alert("Edit Name", isPresented: $isEditingName) {
                TextField("Enter new name", text: $newName)
                Button("Save", action: updateUserNameInFirebase)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your updated display name below.")
            }
        }
    }
    
    // MARK: - Firebase Functions (FirebaseManager එකට හරියටම Connect කර ඇත)
    
    func uploadProfileImageToFirebase(data: Data) {
        // Firebase Auth එකෙන් හෝ CurrentUser එකෙන් direct UID එක ලබා ගැනීම
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isUploading = true
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: metadata) { metadata, error in
            isUploading = false
            if let error = error {
                print("Image Upload Error: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let downloadURL = url {
                    Firestore.firestore().collection("users").document(userId).updateData([
                        "profileImageURL": downloadURL.absoluteString
                    ]) { error in
                        if error == nil {
                            print("Profile image URL updated successfully in Firestore!")
                        }
                    }
                }
            }
        }
    }
    
    func updateUserNameInFirebase() {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).updateData([
            "fullName": newName
        ]) { error in
            if let error = error {
                print("Error updating name: \(error.localizedDescription)")
            } else {
                print("Name updated successfully in Firestore!")
                // Local UI එකත් එකවරම Update වීමට
                DispatchQueue.main.async {
                    if var currentUser = firebaseManager.currentUser {
                        currentUser.fullName = newName
                        firebaseManager.currentUser = currentUser
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
