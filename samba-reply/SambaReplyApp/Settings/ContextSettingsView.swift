import SwiftUI

struct ContextSettingsView: View {
    @State private var enabled = SharedStore.contextEnabled

    var body: some View {
        List {
            Section {
                Toggle("Conversation Context", isOn: $enabled)
                    .tint(Theme.accent)
                    .onChange(of: enabled) { _, newValue in
                        SharedStore.contextEnabled = newValue
                    }
            } footer: {
                Text("Off by default. When on, Reply can read the visible conversation on screen so suggestions answer what was actually said, not just your draft.")
            }

            if enabled {
                Section {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Start Context")
                                .font(.subheadline.weight(.medium))
                            Text("iOS shows its own recording indicator whenever this runs.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        BroadcastPicker()
                            .frame(width: 40, height: 40)
                    }
                } footer: {
                    Text("Text is read on device. Screenshots are never captured or uploaded — only the recognized text is sent to the backend when you tap Reply.")
                }
            }
        }
        .navigationTitle("Context")
        .navigationBarTitleDisplayMode(.inline)
    }
}
