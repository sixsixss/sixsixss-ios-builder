import SwiftUI

/// Wraps a sensitive screen behind Face ID / Touch ID when the user has the
/// setting on and the device supports it. Falls through immediately otherwise.
struct FaceIDGate<Content: View>: View {
    let reason: String
    let content: () -> Content

    @State private var unlocked = false
    @State private var attempted = false

    init(reason: String, @ViewBuilder content: @escaping () -> Content) {
        self.reason = reason
        self.content = content
    }

    private var requiresAuth: Bool {
        SharedStore.faceIDEnabled && BiometricAuth.isAvailable
    }

    var body: some View {
        Group {
            if unlocked || !requiresAuth {
                content()
            } else {
                lockedView
            }
        }
        .task {
            guard requiresAuth, !attempted else { return }
            attempted = true
            unlocked = await BiometricAuth.authenticate(reason: reason)
        }
    }

    private var lockedView: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text("Locked")
                .font(.headline)
            Button("Unlock with \(BiometricAuth.biometryLabel)") {
                Task { unlocked = await BiometricAuth.authenticate(reason: reason) }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
