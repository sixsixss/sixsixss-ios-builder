import SwiftUI

struct RootView: View {
    @State private var onboardingCompleted = SharedStore.onboardingCompleted

    var body: some View {
        Group {
            if onboardingCompleted {
                HomeView()
                    .tint(Theme.accent)
            } else {
                OnboardingView { onboardingCompleted = true }
                    .tint(Theme.accent)
            }
        }
        .privacyScreen()
    }
}
