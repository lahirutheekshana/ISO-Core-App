import SwiftUI
import Combine

struct WelcomeView: View {
    
    @Binding var showLogin: Bool
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors:[
                    Color(red:1.0, green: 0.23, blue: 0.23),
                    Color(red: 0.82, green: 0.12, blue: 0.12),
                    Color(red:0.55, green: 0.05, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                
                Text("Cooking Made\nSimple & Fun")
                    .font(.system(size: 34, weight: .bold, design: .serif)
                    )
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // Subtitle
                
                Text("Discover thousands of recipes, search by ingredients, and save your favorites seamlessly.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
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
                    .background(Color.red)
                    .cornerRadius(16)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 30)
        }
    }
}
