import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.accent)
                    Text("Reply")
                        .font(.headline)
                    Text("Version \(version) (\(build))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            Section {
                Text("A quiet writing assistant for your keyboard.")
                    .foregroundStyle(.secondary)
            }

            Section("If something isn't working") {
                Label("No suggestions? Check Full Access is on in Keyboard settings.", systemImage: "keyboard.badge.ellipsis")
                Label("Suggestions unavailable offline — typing still works normally.", systemImage: "wifi.slash")
                Label("Nothing appears for a secure field like a password box — this is an iOS restriction, not a Reply fault.", systemImage: "lock.fill")
            }
            .font(.footnote)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
