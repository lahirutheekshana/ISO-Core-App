import SwiftUI

struct FavoritesView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Favorites View")
                .font(.title2)
                .bold()
                .padding(.top, 10)
        }
    }
}

#Preview {
    FavoritesView()
}
