import SwiftUI

struct OnboardingView: View {
    var onFinished: () -> Void

    @State private var page = 0
    @State private var contextOptIn = false

    private let lastPage = 3

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(page == lastPage ? 0 : 1)
                    .disabled(page == lastPage)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            TabView(selection: $page) {
                introPage.tag(0)
                enableKeyboardPage.tag(1)
                fullAccessPage.tag(2)
                contextPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(page == lastPage ? "Get Started" : "Continue") {
                if page == lastPage {
                    finish()
                } else {
                    withAnimation { page += 1 }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
    }

    private func finish() {
        SharedStore.contextEnabled = contextOptIn
        SharedStore.onboardingCompleted = true
        onFinished()
    }

    private var introPage: some View {
        OnboardingPage(
            symbol: "keyboard.fill",
            title: "Reply",
            message: "Type anywhere. When you want a hand, tap Reply on your keyboard for suggestions that sound like you."
        )
    }

    private var enableKeyboardPage: some View {
        OnboardingPage(
            symbol: "switch.2",
            title: "Turn on the keyboard",
            message: "Settings → General → Keyboard → Keyboards → Add New Keyboard → Reply."
        ) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var fullAccessPage: some View {
        OnboardingPage(
            symbol: "lock.open",
            title: "Full Access",
            message: "iOS requires Full Access before a keyboard can reach the network. Reply only uses it to fetch suggestions when you tap Reply — nothing is read or sent otherwise."
        )
    }

    private var contextPage: some View {
        OnboardingPage(
            symbol: "text.viewfinder",
            title: "Conversation Context",
            message: "Reply can optionally read the visible conversation on screen to give more relevant suggestions. It's off by default, shows Apple's own recording indicator whenever it runs, and you can turn it on later from Settings."
        ) {
            Toggle("Enable Conversation Context", isOn: $contextOptIn)
                .toggleStyle(.switch)
                .tint(Theme.accent)
                .padding(.horizontal, 32)
        }
    }
}

private struct OnboardingPage<Extra: View>: View {
    let symbol: String
    let title: String
    let message: String
    let extra: () -> Extra

    init(symbol: String, title: String, message: String, @ViewBuilder extra: @escaping () -> Extra = { EmptyView() }) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.extra = extra
    }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.accent)

            Text(title)
                .font(.title2.weight(.semibold))

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            extra()
                .padding(.top, 4)

            Spacer()
            Spacer()
        }
    }
}
