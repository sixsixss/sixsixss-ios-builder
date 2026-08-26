import SwiftUI

struct KeyboardSettingsView: View {
    private var ready: Bool { SharedStore.keyboardSeenAt != nil }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(ready ? "Ready" : "Not set up")
                        .foregroundStyle(ready ? Theme.accent : .secondary)
                }
            }

            Section("Add the keyboard") {
                Label("Settings → General → Keyboard → Keyboards", systemImage: "1.circle")
                Label("Add New Keyboard → Reply", systemImage: "2.circle")
                Label("Turn on Full Access", systemImage: "3.circle")
            }
            .font(.subheadline)

            Section {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }

            Section {
                Text("Full Access lets Reply reach the network when you tap Reply. Nothing is read or sent otherwise.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("Reply is a suggestion keyboard, not a full typing replacement. Tap the globe icon anytime to switch back to your normal keyboard.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Keyboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}
