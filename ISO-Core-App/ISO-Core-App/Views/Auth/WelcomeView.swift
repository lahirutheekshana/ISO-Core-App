import SwiftUI
import Combine

struct WelcomeView: View {
    @Binding var showLogin: Bool
    
    var body: some View {
        ZStack {
            // Modern Dark Gradient Background (Image එක නැතත් ලස්සනට පෙනේ)
            LinearGradient(
                colors: [Color.black, Color(white: 0.1), Color.orange.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Top Icon / Symbol
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.orange)
                    .padding(.bottom, 10)
                
                // Title (Center Aligned & Safe Fonts)
                Text("Cooking Made\nSimple & Fun")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                // Subtitle
                Text("Discover thousands of recipes, search by ingredients, and save your favorites seamlessly.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineSpacing(4)
                
                Spacer()
                
                // Action Button
                Button {
                    showLogin = true
                } label: {
                    HStack {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.orange)
                    .cornerRadius(16)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
        }
    }
}
