import SwiftUI

struct PrivacySettingsView: View {
    @State private var faceIDEnabled = SharedStore.faceIDEnabled
    @State private var showDeleteConfirm = false
    @State private var deleted = false
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

            Section {
                Button(deleted ? "Data Deleted" : "Delete My Data", role: .destructive) {
                    showDeleteConfirm = true
                }
                .disabled(deleted)
            } footer: {
                Text("Erases your saved history and any captured on-screen context stored on this device. This does not remove the Reply keyboard or reset your preferences.")
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete all your Reply data?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete My Data", role: .destructive) {
                SharedStore.deleteAllUserData()
                HistoryStore.clearAll()
                deleted = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }
}
