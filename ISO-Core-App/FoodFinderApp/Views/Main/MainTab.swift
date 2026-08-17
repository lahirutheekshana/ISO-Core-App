import SwiftUI

enum MainTab: Int, CaseIterable {
    case home = 0
    case pantry = 1
    case favorites = 2
    case profile = 3
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .pantry: return "Pantry"
        case .favorites: return "Favorites"
        case .profile: return "Profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .pantry: return "basket.fill" // Or refrigerator.fill if using SF Symbols 4+
        case .favorites: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}
