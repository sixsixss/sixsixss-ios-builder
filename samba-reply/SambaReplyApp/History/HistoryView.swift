import SwiftUI

struct HistoryView: View {
    @State private var enabled = SharedStore.historyEnabled
    @State private var expiry = HistoryExpiry(stored: SharedStore.historyExpiryDays)
    @State private var entries = HistoryStore.all()
    @State private var showClearConfirm = false

    var body: some View {
        List {
            Section {
                Toggle("Save Reply History", isOn: $enabled)
                    .tint(Theme.accent)
                    .onChange(of: enabled) { _, newValue in
                        SharedStore.historyEnabled = newValue
                    }

                if enabled {
                    Picker("Automatically Delete", selection: $expiry) {
                        ForEach(HistoryExpiry.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .onChange(of: expiry) { _, newValue in
                        SharedStore.historyExpiryDays = newValue.rawValue
                        HistoryStore.applyExpiry()
                        entries = HistoryStore.all()
                    }
                }
            } footer: {
                Text("Off by default. Only the text you inserted is saved — never the surrounding conversation.")
            }

            if entries.isEmpty {
                Section {
                    Text("No saved replies yet.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.text)
                                .font(.body)
                            Text(entry.date, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                HistoryStore.delete(entry)
                                entries = HistoryStore.all()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Section {
                    Button("Clear All", role: .destructive) {
                        showClearConfirm = true
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Clear all history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                HistoryStore.clearAll()
                entries = []
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
