import SwiftUI

struct FavoritesView: View {
    
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Favorites View org")
                .font(.title2)
                .bold()
                .padding(.top, 10)
        }
    }
}

#Preview {
    FavoritesView(authVM: AuthViewModel())
}
