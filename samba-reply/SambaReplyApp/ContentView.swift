import SwiftUI

struct ContentView: View {
    private let modes: [(id: String, title: String)] = [
        ("auto", "Auto"),
        ("short", "Short"),
        ("direct", "Direct"),
        ("work", "Work"),
        ("fix", "Fix")
    ]

    @State private var backendURL = SharedStore.backendURL
    @State private var mode = SharedStore.mode
    @State private var transcript = SharedStore.transcript
    @State private var saved = false
    @State private var showAdvanced = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Reply")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("A private writing assistant for your keyboard.")
                            .foregroundStyle(.secondary)
                    }

                    statusCard

                    GroupBox("Keyboard") {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Add Reply in iPhone Keyboard settings", systemImage: "keyboard")
                            Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → Reply. Turn on Full Access so it can request replies when you tap Reply.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Screen Read") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Start only when you want the current conversation read. iPhone will always show when screen capture is active.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            BroadcastPicker()
                                .frame(width: 54, height: 54)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Reply style") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Reply style", selection: $mode) {
                                ForEach(modes, id: \.id) { item in
                                    Text(item.title).tag(item.id)
                                }
                            }
                            .pickerStyle(.menu)

                            Text("Auto quietly works out the right tone from the conversation. Personal context is never shown as a label on the keyboard.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Button(saved ? "Saved" : "Save") {
                                SharedStore.mode = mode
                                saved = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DisclosureGroup("Advanced", isExpanded: $showAdvanced) {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Reply service", text: $backendURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .textFieldStyle(.roundedBorder)

                            Button("Save connection") {
                                SharedStore.backendURL = backendURL
                                saved = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 10)
                    }

                    GroupBox("Privacy") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Nothing is sent until you tap Reply", systemImage: "lock.fill")
                            Label("Visible chat text is extracted on your phone", systemImage: "iphone")
                            Label("You always review the reply before sending", systemImage: "checkmark.circle")
                        }
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.blue.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Ready")
                    .font(.headline)
                Text(transcript.isEmpty ? "Start Screen Read when you need it" : "Conversation detected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Refresh") {
                transcript = SharedStore.transcript
            }
            .font(.footnote.weight(.semibold))
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
