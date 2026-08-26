import Foundation

/// Visible keyboard actions. Names are intentionally neutral — the AI infers
/// tone internally and nothing here is ever surfaced to the user.
enum ReplyMode: String, CaseIterable, Identifiable {
    case auto
    case short
    case direct
    case work
    case fix

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto: return "Reply"
        case .short: return "Short"
        case .direct: return "Direct"
        case .work: return "Work"
        case .fix: return "Fix"
        }
    }

    var symbol: String {
        switch self {
        case .auto: return "arrowshape.turn.up.left.fill"
        case .short: return "text.alignleft"
        case .direct: return "arrow.right"
        case .work: return "briefcase.fill"
        case .fix: return "wand.and.stars"
        }
    }

    init(stored: String) {
        self = ReplyMode(rawValue: stored) ?? .auto
    }
}

/// Overall tone dial shown in Settings. Kept separate from `ReplyMode` so the
/// keyboard's per-tap actions stay simple while this stays a quiet, coarse
/// preference that only shades how "Reply" behaves.
enum ReplyStyle: String, CaseIterable, Identifiable {
    case automatic
    case natural
    case direct

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: return "Automatic"
        case .natural: return "Natural"
        case .direct: return "Direct"
        }
    }

    var subtitle: String {
        switch self {
        case .automatic: return "Reply quietly matches the conversation."
        case .natural: return "Leans warm and conversational."
        case .direct: return "Leans brief and to the point."
        }
    }

    init(stored: String) {
        self = ReplyStyle(rawValue: stored) ?? .automatic
    }
}

enum HistoryExpiry: Int, CaseIterable, Identifiable {
    case never = 0
    case sevenDays = 7
    case thirtyDays = 30

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .never: return "Never"
        case .sevenDays: return "After 7 Days"
        case .thirtyDays: return "After 30 Days"
        }
    }

    init(stored: Int) {
        self = HistoryExpiry(rawValue: stored) ?? .never
    }
}
