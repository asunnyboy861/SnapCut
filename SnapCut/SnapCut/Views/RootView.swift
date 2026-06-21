import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState.shared

    var body: some View {
        Group {
            if appState.isFirstLaunch {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isFirstLaunch)
    }
}

#Preview {
    RootView()
}
