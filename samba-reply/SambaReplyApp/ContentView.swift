import SwiftUI

struct ContentView: View {
    private let modes = ["chill", "flirt", "funny", "business", "fix"]

    @State private var backendURL = SharedStore.backendURL
    @State private var mode = SharedStore.mode
    @State private var transcript = SharedStore.transcript
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Samba Reply")
                            .font(.largeTitle.bold())
                        Text("Read the conversation on screen, then get replies directly from your keyboard.")
                            .foregroundStyle(.secondary)
                    }

                    GroupBox("1. Enable the keyboard") {
                        Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → Samba Reply. Then turn on Allow Full Access so the keyboard can request AI replies.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("2. Connect the reply backend") {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("https://…/functions/v1/samba-reply", text: $backendURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .textFieldStyle(.roundedBorder)

                            Picker("Default mode", selection: $mode) {
                                ForEach(modes, id: \.self) { Text($0.capitalized).tag($0) }
                            }
                            .pickerStyle(.segmented)

                            Button(saved ? "Saved" : "Save settings") {
                                SharedStore.backendURL = backendURL
                                SharedStore.mode = mode
                                saved = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    GroupBox("3. Start Screen Read") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tap the broadcast button, choose Samba Reply Screen Read, then return to Instagram. iOS always shows when screen capture is active. Stop it when you are finished.")
                            BroadcastPicker()
                                .frame(width: 54, height: 54)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Latest text seen on screen") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(transcript.isEmpty ? "Nothing read yet." : transcript)
                                .font(.footnote.monospaced())
                                .textSelection(.enabled)
                            Button("Refresh") { transcript = SharedStore.transcript }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text("Privacy: the screen reader converts visible text on device and stores only the extracted text in the shared app container. The keyboard sends that text to your configured reply endpoint only when you tap Reply.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
