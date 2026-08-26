import SwiftUI

struct HomeView: View {
    private var style: ReplyStyle { ReplyStyle(stored: SharedStore.style) }
    private var keyboardReady: Bool { SharedStore.keyboardSeenAt != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reply")
                            .font(.system(size: 32, weight: .semibold))
                        Text("Write better. Faster.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    card {
                        NavigationLink {
                            KeyboardSettingsView()
                        } label: {
                            row(icon: "keyboard.fill", title: "Keyboard", value: keyboardReady ? "Ready" : "Set Up")
                        }
                        .buttonStyle(.plain)

                        rowDivider

                        NavigationLink {
                            StyleSettingsView()
                        } label: {
                            row(icon: "slider.horizontal.3", title: "Style", value: style.title)
                        }
                        .buttonStyle(.plain)
                    }

                    card {
                        NavigationLink {
                            FaceIDGate(reason: "Unlock History") { HistoryView() }
                        } label: {
                            row(icon: "clock", title: "History", value: "")
                        }
                        .buttonStyle(.plain)

                        rowDivider

                        NavigationLink {
                            SettingsView()
                        } label: {
                            row(icon: "gearshape", title: "Settings", value: "")
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var rowDivider: some View {
        Divider().padding(.leading, 50)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0, content: content)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private func row(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.accent)
                .frame(width: 22)

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            if !value.isEmpty {
                Text(value)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
