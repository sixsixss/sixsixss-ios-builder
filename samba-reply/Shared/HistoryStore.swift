import Foundation

/// A single past reply. Deliberately minimal: we keep the text that was
/// actually inserted plus its mode and timestamp, never the surrounding
/// conversation — history should be useful without becoming a message log.
struct HistoryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let mode: String
    let text: String

    init(id: UUID = UUID(), date: Date = Date(), mode: String, text: String) {
        self.id = id
        self.date = date
        self.mode = mode
        self.text = text
    }
}

enum HistoryStore {
    private static let limit = 200

    static func all() -> [HistoryEntry] {
        guard let data = SharedStore.rawHistoryEntries,
              let entries = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return []
        }
        return entries.sorted { $0.date > $1.date }
    }

    /// Appends an entry if history is enabled, then applies the configured
    /// expiry window. Safe to call unconditionally after every insert.
    static func record(mode: String, text: String) {
        guard SharedStore.historyEnabled else { return }
        var entries = all()
        entries.insert(HistoryEntry(mode: mode, text: text), at: 0)
        if entries.count > limit { entries.removeLast(entries.count - limit) }
        save(entries)
        applyExpiry()
    }

    static func delete(_ entry: HistoryEntry) {
        var entries = all()
        entries.removeAll { $0.id == entry.id }
        save(entries)
    }

    static func clearAll() {
        save([])
    }

    static func applyExpiry() {
        let days = SharedStore.historyExpiryDays
        guard days > 0 else { return }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? .distantPast
        let entries = all().filter { $0.date >= cutoff }
        save(entries)
    }

    private static func save(_ entries: [HistoryEntry]) {
        SharedStore.rawHistoryEntries = try? JSONEncoder().encode(entries)
    }
}
