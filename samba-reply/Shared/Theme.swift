import SwiftUI

/// One restrained accent, used everywhere — the app, Settings and the
/// keyboard all draw from the same small palette so nothing reads as a
/// separate "AI product" bolted onto a keyboard.
enum Theme {
    static var accent: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.46, green: 0.64, blue: 0.80, alpha: 1)
                : UIColor(red: 0.14, green: 0.30, blue: 0.46, alpha: 1)
        })
    }

    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 10
    static let spacing: CGFloat = 16
}
