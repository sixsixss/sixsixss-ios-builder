import SwiftUI

struct StyleSettingsView: View {
    @State private var style = ReplyStyle(stored: SharedStore.style)

    var body: some View {
        List {
            Section {
                ForEach(ReplyStyle.allCases) { option in
                    Button {
                        style = option
                        SharedStore.style = option.rawValue
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .foregroundStyle(.primary)
                                Text(option.subtitle)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if option == style {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                    }
                }
            } footer: {
                Text("Style shades how Reply's automatic suggestions sound. The specific tone is always inferred quietly and never shown.")
            }
        }
        .navigationTitle("Style")
        .navigationBarTitleDisplayMode(.inline)
    }
}
