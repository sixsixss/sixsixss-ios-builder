import SwiftUI

struct AdvancedSettingsView: View {
    @State private var backendURL = SharedStore.backendURL
    @State private var clientKey = SharedStore.clientKey
    @State private var saved = false

    var body: some View {
        List {
            Section {
                TextField("Reply service URL", text: $backendURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)

                SecureField("Client key", text: $clientKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button(saved ? "Saved" : "Save") {
                    SharedStore.backendURL = backendURL
                    SharedStore.clientKey = clientKey
                    saved = true
                }
            } header: {
                Text("Backend")
            } footer: {
                Text("Advanced connection settings. Must be an https address. Most people never need to change this.")
            }
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}
