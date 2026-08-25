import Foundation

enum SharedStore {
    static let appGroup = "group.com.sixsixss.sambareply"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    private enum Key {
        static let transcript = "latestTranscript"
        static let transcriptUpdatedAt = "transcriptUpdatedAt"
        static let backendURL = "backendURL"
        static let mode = "replyMode"
    }

    static var transcript: String {
        get { defaults.string(forKey: Key.transcript) ?? "" }
        set {
            defaults.set(newValue, forKey: Key.transcript)
            defaults.set(Date().timeIntervalSince1970, forKey: Key.transcriptUpdatedAt)
        }
    }

    static var transcriptUpdatedAt: Date? {
        let timestamp = defaults.double(forKey: Key.transcriptUpdatedAt)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }

    static var backendURL: String {
        get { defaults.string(forKey: Key.backendURL) ?? "" }
        set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Key.backendURL) }
    }

    static var mode: String {
        get {
            let stored = defaults.string(forKey: Key.mode) ?? "auto"
            if ["chill", "flirt", "funny", "business"].contains(stored) { return "auto" }
            return stored
        }
        set { defaults.set(newValue, forKey: Key.mode) }
    }
}
