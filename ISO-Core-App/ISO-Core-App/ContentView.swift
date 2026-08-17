import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()
    @State private var showLogin = false
    
    var body: some View {
        Group {
            if authVM.isAuthenticated {
                AppMainTabView(authVM: authVM)
            } else if showLogin {
                LoginView(authVM: authVM)
            } else {
                WelcomeView(showLogin: $showLogin)
            }
        }
    }
}

struct AppMainTabView: View {
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProfileView(authVM: authVM)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.orange)
    }
}
