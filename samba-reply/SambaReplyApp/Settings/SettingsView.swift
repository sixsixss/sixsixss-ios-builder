import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Keyboard") { KeyboardSettingsView() }
                NavigationLink("Style") { StyleSettingsView() }
            }

            Section {
                NavigationLink("Privacy") { PrivacySettingsView() }
                NavigationLink("Context") { ContextSettingsView() }
                NavigationLink("History") { FaceIDGate(reason: "Unlock History") { HistoryView() } }
            }

            Section {
                NavigationLink("Advanced") { AdvancedSettingsView() }
                NavigationLink("About") { AboutView() }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
