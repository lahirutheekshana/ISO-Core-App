import SwiftUI

struct CustomTabBarView: View {
    @Binding var currentTab: MainTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22))
                            .frame(height: 24)
                        
                        if currentTab == tab {
                            Text(tab.title)
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(currentTab == tab ? .orange : .secondary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()
        VStack {
            Spacer()
            CustomTabBarView(currentTab: .constant(.home))
        }
    }
}
