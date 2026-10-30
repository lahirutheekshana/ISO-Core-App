import SwiftUI

/// Shared layout metrics so phone-first screens stay readable and aligned on iPad.
enum AdaptiveLayout {
    /// Max width for auth / form-style screens (Login, Register, Welcome).
    static let formMaxWidth: CGFloat = 480
    /// Max width for browsing content (Home, Pantry, Favorites).
    static let contentMaxWidth: CGFloat = 820
    /// Max width for long-form detail text (Recipe detail).
    static let detailMaxWidth: CGFloat = 700
    /// Max width for the custom floating tab bar capsule.
    static let tabBarMaxWidth: CGFloat = 560
    
    static func recipeGridColumns(
        for horizontalSizeClass: UserInterfaceSizeClass?,
        spacing: CGFloat = 16
    ) -> [GridItem] {
        let columnCount = horizontalSizeClass == .regular ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
}

extension View {
    /// Centers content and caps width on regular-width (iPad) layouts.
    func iPadReadableWidth(_ maxWidth: CGFloat = AdaptiveLayout.contentMaxWidth) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}
