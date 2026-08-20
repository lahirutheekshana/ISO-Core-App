import SwiftUI

struct PantryFinderView: View {
    
    @ObservedObject var authVM: AuthViewModel
    
    
    var body: some View {
        VStack {
            Image(systemName: "basket.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Pantry Finder View")
                .font(.title2)
                .bold()
                .padding(.top, 10)
        }
    }
}

#Preview {
    PantryFinderView(authVM: AuthViewModel())
}
