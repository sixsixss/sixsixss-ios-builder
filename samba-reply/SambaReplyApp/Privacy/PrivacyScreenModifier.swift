import SwiftUI

/// Covers the whole app the instant it stops being active, so a backgrounded
/// snapshot in the iOS app switcher never shows history or draft text.
private struct PrivacyScreenModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .overlay {
                if scenePhase != .active {
                    ZStack {
                        Rectangle().fill(.regularMaterial)
                        VStack(spacing: 8) {
                            Image(systemName: "keyboard.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Theme.accent)
                            Text("Reply")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .ignoresSafeArea()
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: scenePhase)
    }
}

extension View {
    func privacyScreen() -> some View {
        modifier(PrivacyScreenModifier())
    }
}
