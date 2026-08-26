import SwiftUI

struct AdvancedSettingsView: View {
    @State private var backendURL = SharedStore.backendURL
    @State private var saved = false

    var body: some View {
        List {
            Section {
                TextField("Reply service URL", text: $backendURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)

                Button(saved ? "Saved" : "Save") {
                    SharedStore.backendURL = backendURL
                    saved = true
                }
            } header: {
                Text("Backend")
            } footer: {
                Text("Advanced connection settings. Most people never need to change this.")
            }
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}
