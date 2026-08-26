import SwiftUI

struct KeyboardRootView: View {
    @ObservedObject var bridge: KeyboardBridge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Button(action: bridge.advanceInput) {
                    Image(systemName: "globe")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .background(Color(.tertiarySystemFill), in: Circle())

                Button(action: bridge.backspace) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .background(Color(.tertiarySystemFill), in: Circle())

                ForEach(ReplyMode.allCases) { mode in
                    modeChip(mode)
                }
            }

            HStack(spacing: 6) {
                if bridge.isLoading {
                    ProgressView().controlSize(.mini)
                }
                Text(bridge.statusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(height: 14)

            if !bridge.suggestions.isEmpty {
                VStack(spacing: 6) {
                    ForEach(bridge.suggestions, id: \.self) { suggestion in
                        Button {
                            bridge.choose(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: Theme.controlRadius))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
    }

    private func modeChip(_ mode: ReplyMode) -> some View {
        let selected = bridge.mode == mode
        return Button {
            bridge.activate(mode)
        } label: {
            Text(mode.title)
                .font(.system(size: 13, weight: selected ? .semibold : .regular))
                .foregroundStyle(selected ? Color.white : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(selected ? Theme.accent : Color(.tertiarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
