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
        static let clientKey = "clientKey"
        static let mode = "replyMode"
        static let style = "replyStyle"
        static let onboardingCompleted = "onboardingCompleted"
        static let contextEnabled = "contextEnabled"
        static let historyEnabled = "historyEnabled"
        static let historyExpiryDays = "historyExpiryDays"
        static let faceIDEnabled = "faceIDEnabled"
        static let keyboardSeenAt = "keyboardSeenAt"
        static let historyEntries = "historyEntries"
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

    /// How long a captured on-screen transcript stays usable before it is
    /// treated as stale. Context should be cleared quickly, not held
    /// indefinitely in case a broadcast is never explicitly stopped.
    private static let transcriptFreshWindow: TimeInterval = 10 * 60

    /// The captured transcript, or empty if it is older than the fresh
    /// window. Callers should read this instead of `transcript` directly
    /// when deciding what context to send.
    static var freshTranscript: String {
        guard let updatedAt = transcriptUpdatedAt,
              Date().timeIntervalSince(updatedAt) <= transcriptFreshWindow else {
            return ""
        }
        return transcript
    }

    static var backendURL: String {
        get { defaults.string(forKey: Key.backendURL) ?? "" }
        set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Key.backendURL) }
    }

    /// A shared secret sent with every backend request so the function is not
    /// fully open on the public internet. Configured post-install, never
    /// hard-coded in source, matching how `backendURL` is handled.
    static var clientKey: String {
        get { defaults.string(forKey: Key.clientKey) ?? "" }
        set { defaults.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Key.clientKey) }
    }

    static var mode: String {
        get {
            let stored = defaults.string(forKey: Key.mode) ?? "auto"
            if ReplyMode(rawValue: stored) == nil { return "auto" }
            return stored
        }
        set { defaults.set(newValue, forKey: Key.mode) }
    }

    /// Overall tone dial from Settings. Independent of the per-tap keyboard mode.
    static var style: String {
        get { defaults.string(forKey: Key.style) ?? ReplyStyle.automatic.rawValue }
        set { defaults.set(newValue, forKey: Key.style) }
    }

    static var onboardingCompleted: Bool {
        get { defaults.bool(forKey: Key.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Key.onboardingCompleted) }
    }

    /// Off by default. Gates whether the keyboard is allowed to use any
    /// captured on-screen transcript when building a request.
    static var contextEnabled: Bool {
        get { defaults.bool(forKey: Key.contextEnabled) }
        set {
            defaults.set(newValue, forKey: Key.contextEnabled)
            if !newValue { transcript = "" }
        }
    }

    /// Off by default.
    static var historyEnabled: Bool {
        get { defaults.bool(forKey: Key.historyEnabled) }
        set { defaults.set(newValue, forKey: Key.historyEnabled) }
    }

    static var historyExpiryDays: Int {
        get { defaults.integer(forKey: Key.historyExpiryDays) }
        set { defaults.set(newValue, forKey: Key.historyExpiryDays) }
    }

    static var faceIDEnabled: Bool {
        get { defaults.bool(forKey: Key.faceIDEnabled) }
        set { defaults.set(newValue, forKey: Key.faceIDEnabled) }
    }

    /// Set once by the keyboard extension the first time it actually runs,
    /// so the host app can show a real "Ready" state instead of guessing.
    static var keyboardSeenAt: Date? {
        get {
            let timestamp = defaults.double(forKey: Key.keyboardSeenAt)
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set { defaults.set(newValue?.timeIntervalSince1970 ?? 0, forKey: Key.keyboardSeenAt) }
    }

    static func markKeyboardSeen() {
        defaults.set(Date().timeIntervalSince1970, forKey: Key.keyboardSeenAt)
    }

    // MARK: History

    static var rawHistoryEntries: Data? {
        get { defaults.data(forKey: Key.historyEntries) }
        set { defaults.set(newValue, forKey: Key.historyEntries) }
    }

    /// Erases everything Reply has captured or saved: the current on-screen
    /// transcript and all saved history. Turns Context and History back off
    /// since there is nothing left for them to use. Leaves app configuration
    /// (backend URL, style preference, onboarding state) untouched — this
    /// deletes data, not settings.
    static func deleteAllUserData() {
        transcript = ""
        rawHistoryEntries = nil
        historyEnabled = false
        contextEnabled = false
    }
}
