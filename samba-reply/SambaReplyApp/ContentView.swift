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

                    readyCard

                    GroupBox("Reply style") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Reply style", selection: $mode) {
                                ForEach(modes, id: \.id) { item in
                                    Text(item.title).tag(item.id)
                                }
                            }
                            .pickerStyle(.menu)

                            Text("Auto quietly chooses the right tone from context. Personal labels are never shown on the keyboard.")
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

                    GroupBox("Keyboard") {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Add Reply in iPhone Keyboard settings", systemImage: "keyboard")
                            Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → Reply. Turn on Full Access so it can request suggestions when you tap Reply.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GroupBox("Assist") {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.secondary.opacity(0.10))
                                    .frame(width: 46, height: 46)
                                Image(systemName: "circle.grid.2x2.fill")
                                    .foregroundStyle(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Optional")
                                    .font(.subheadline.weight(.semibold))
                                Text("Use only when you want extra context")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            BroadcastPicker()
                                .frame(width: 44, height: 44)
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
                            Label("Nothing runs unless you choose it", systemImage: "lock.fill")
                            Label("You always review text before sending", systemImage: "checkmark.circle")
                            Label("No personal mode names appear on screen", systemImage: "eye.slash")
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

    private var readyCard: some View {
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
                Text("Open your keyboard whenever you need it")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
