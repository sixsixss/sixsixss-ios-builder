import UIKit

final class KeyboardViewController: UIInputViewController {
    private let modes: [(id: String, title: String)] = [
        ("auto", "Reply"),
        ("short", "Short"),
        ("direct", "Direct"),
        ("work", "Work"),
        ("fix", "Fix")
    ]

    private let suggestionStack = UIStackView()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
        renderSuggestions(localFallbacks())
    }

    private func buildInterface() {
        view.backgroundColor = .secondarySystemBackground

        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            root.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8)
        ])

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.spacing = 6
        topRow.distribution = .fillProportionally

        let globe = button("🌐") { [weak self] in self?.advanceToNextInputMode() }
        topRow.addArrangedSubview(globe)

        for item in modes {
            let modeButton = button(item.title) { [weak self] in
                SharedStore.mode = item.id
                self?.statusLabel.text = item.id == "auto" ? "Ready" : item.title
                if item.id == "auto" { self?.requestSuggestions() }
            }
            if item.id == "auto" {
                modeButton.configuration = .filled()
            }
            topRow.addArrangedSubview(modeButton)
        }
        root.addArrangedSubview(topRow)

        statusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = .secondaryLabel
        statusLabel.text = "Ready"
        root.addArrangedSubview(statusLabel)

        suggestionStack.axis = .vertical
        suggestionStack.spacing = 6
        root.addArrangedSubview(suggestionStack)
    }

    private func button(_ title: String, action: @escaping () -> Void) -> UIButton {
        var configuration = UIButton.Configuration.gray()
        configuration.title = title
        configuration.cornerStyle = .capsule
        let button = UIButton(configuration: configuration)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func requestSuggestions() {
        guard hasFullAccess else {
            statusLabel.text = "Full Access required"
            return
        }

        let transcript = SharedStore.transcript
        guard !transcript.isEmpty else {
            statusLabel.text = "No conversation detected"
            return
        }

        guard let url = URL(string: SharedStore.backendURL), !SharedStore.backendURL.isEmpty else {
            statusLabel.text = "Open Reply to finish setup"
            return
        }

        let draft = textDocumentProxy.documentContextBeforeInput ?? ""
        let payload: [String: Any] = [
            "conversation": transcript,
            "draft": draft,
            "mode": SharedStore.mode
        ]

        guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return }

        statusLabel.text = "Thinking…"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if error != nil {
                    self.statusLabel.text = "Try again"
                    return
                }
                guard let data,
                      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let suggestions = object["suggestions"] as? [String],
                      !suggestions.isEmpty else {
                    self.statusLabel.text = "No suggestions"
                    return
                }
                self.statusLabel.text = "Tap to insert"
                self.renderSuggestions(Array(suggestions.prefix(3)))
            }
        }.resume()
    }

    private func renderSuggestions(_ suggestions: [String]) {
        suggestionStack.arrangedSubviews.forEach { view in
            suggestionStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for text in suggestions {
            var configuration = UIButton.Configuration.plain()
            configuration.title = text
            configuration.titleAlignment = .leading
            configuration.cornerStyle = .medium
            let choice = UIButton(configuration: configuration)
            choice.backgroundColor = .systemBackground
            choice.layer.cornerRadius = 10
            choice.contentHorizontalAlignment = .leading
            choice.titleLabel?.numberOfLines = 2
            choice.addAction(UIAction { [weak self] _ in self?.insert(text) }, for: .touchUpInside)
            suggestionStack.addArrangedSubview(choice)
        }
    }

    private func insert(_ text: String) {
        if SharedStore.mode == "fix", let draft = textDocumentProxy.documentContextBeforeInput {
            for _ in draft { textDocumentProxy.deleteBackward() }
        }
        textDocumentProxy.insertText(text)
    }

    private func localFallbacks() -> [String] {
        switch SharedStore.mode {
        case "short": return ["Yeah", "Sounds good", "Let me know"]
        case "direct": return ["Yeah that works for me", "Let me know when you know", "Cool, keep me posted"]
        case "work": return ["Sounds good, let me know what works for you.", "Perfect, I’ll keep you posted.", "Yeah that works for me."]
        case "fix": return ["Rewrite what I typed", "Make it clearer", "Keep my tone"]
        default: return ["Yeah that makes sense", "Cool, let me know", "😂 fair enough"]
        }
    }
}
