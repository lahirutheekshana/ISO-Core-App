import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case pantry = "basket.fill"
    case favorites = "heart.fill"
    case profile = "person.fill"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .pantry: return "Pantry"
        case .favorites: return "Favorites"
        case .profile: return "Profile"
        }
    }
}

struct MainTabView: View {
    
    @ObservedObject var authVM: AuthViewModel
    
    @State private var currentTab: Tab = .home

    init(authVM: AuthViewModel) {
        self.authVM = authVM
        
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            TabView(selection: $currentTab) {
                HomeView(authVM: authVM)
                    .tag(Tab.home)
                
                PantryFinderView(authVM: authVM)
                    .tag(Tab.pantry)
                
                FavoritesView(authVM: authVM)
                    .tag(Tab.favorites)
                
                Text("Profile View")
                    .tag(Tab.profile)
            }
            
            
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 20, weight: .bold))
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(currentTab == tab ? .orange : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}
