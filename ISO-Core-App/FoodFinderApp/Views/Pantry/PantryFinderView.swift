import SwiftUI

struct PantryFinderView: View {
    var body: some View {
        VStack {
            Image(systemName: "basket.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
                .padding()
            Text("Pantry Finder")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    PantryFinderView()
}
