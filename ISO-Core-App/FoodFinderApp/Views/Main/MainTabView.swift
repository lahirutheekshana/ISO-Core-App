import SwiftUI

struct MainTabView: View {
    @State private var currentTab: MainTab = .home
    
    init() {
        // Hide the standard system TabBar so our custom one shows perfectly
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Layer
            TabView(selection: $currentTab) {
                HomeView()
                    .tag(MainTab.home)
                
                PantryFinderView()
                    .tag(MainTab.pantry)
                
                FavoritesView()
                    .tag(MainTab.favorites)
                
                ProfileView()
                    .tag(MainTab.profile)
            }
            
            // Floating Custom Tab Bar over the views
            CustomTabBarView(currentTab: $currentTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    MainTabView()
}
