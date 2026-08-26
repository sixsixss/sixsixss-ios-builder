import SwiftUI

struct PrivacySettingsView: View {
    @State private var faceIDEnabled = SharedStore.faceIDEnabled
    private let biometricsAvailable = BiometricAuth.isAvailable

    var body: some View {
        List {
            if biometricsAvailable {
                Section {
                    Toggle("Require \(BiometricAuth.biometryLabel)", isOn: $faceIDEnabled)
                        .tint(Theme.accent)
                        .onChange(of: faceIDEnabled) { _, newValue in
                            SharedStore.faceIDEnabled = newValue
                        }
                } footer: {
                    Text("Protects History and this screen with \(BiometricAuth.biometryLabel).")
                }
            }

            Section {
                Label("Content is hidden when Reply is backgrounded", systemImage: "eye.slash")
                Label("Nothing appears in widgets, Live Activities or notifications", systemImage: "bell.slash")
                Label("You always review a suggestion before it's inserted", systemImage: "checkmark.circle")
                Label("The OpenAI key never lives on this device", systemImage: "key.slash")
            }
            .font(.subheadline)
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
