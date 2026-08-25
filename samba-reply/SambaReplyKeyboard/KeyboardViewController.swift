import UIKit

final class KeyboardViewController: UIInputViewController {
    private let modes = ["chill", "flirt", "funny", "business", "fix"]
    private let suggestionStack = UIStackView()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
        renderSuggestions(localFallbacks())
    }

    private func buildInterface() {
        view.backgroundColor = .systemBackground

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

        let modeRow = UIStackView()
        modeRow.axis = .horizontal
        modeRow.spacing = 6
        modeRow.distribution = .fillProportionally

        let globe = button("🌐") { [weak self] in self?.advanceToNextInputMode() }
        modeRow.addArrangedSubview(globe)

        for item in modes {
            let title = item == "business" ? "Biz" : item.capitalized
            modeRow.addArrangedSubview(button(title) { [weak self] in
                SharedStore.mode = item
                self?.statusLabel.text = "Mode: \(title)"
            })
        }
        root.addArrangedSubview(modeRow)

        let reply = button("✨ Reply") { [weak self] in self?.requestSuggestions() }
        reply.configuration = .filled()
        root.addArrangedSubview(reply)

        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabel
        statusLabel.text = "Mode: \(SharedStore.mode.capitalized)"
        root.addArrangedSubview(statusLabel)

        suggestionStack.axis = .vertical
        suggestionStack.spacing = 6
        root.addArrangedSubview(suggestionStack)
    }

    private func button(_ title: String, action: @escaping () -> Void) -> UIButton {
        var configuration = UIButton.Configuration.gray()
        configuration.title = title
        configuration.cornerStyle = .medium
        let button = UIButton(configuration: configuration)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func requestSuggestions() {
        guard hasFullAccess else {
            statusLabel.text = "Turn on Allow Full Access in iPhone Settings."
            return
        }

        let transcript = SharedStore.transcript
        guard !transcript.isEmpty else {
            statusLabel.text = "Start Screen Read first so I can see the chat."
            return
        }

        guard let url = URL(string: SharedStore.backendURL), !SharedStore.backendURL.isEmpty else {
            statusLabel.text = "Open Samba Reply and add the backend URL."
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
                if let error {
                    self.statusLabel.text = "Reply failed: \(error.localizedDescription)"
                    return
                }
                guard let data,
                      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let suggestions = object["suggestions"] as? [String],
                      !suggestions.isEmpty else {
                    self.statusLabel.text = "The reply service returned no suggestions."
                    return
                }
                self.statusLabel.text = "Tap a reply to insert it."
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
            let choice = UIButton(configuration: configuration)
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
        case "flirt": return ["😂 okay I’m holding you to that", "Just let me know when you know", "Cool, I do wanna see you though"]
        case "funny": return ["😂 fair enough", "Very informative thank you", "I hear you 😭"]
        case "business": return ["Sounds good, let me know what works for you.", "Perfect, I’ll keep you posted.", "Yeah that works for me."]
        default: return ["Yeah that makes sense", "Cool, let me know", "😂 fair enough"]
        }
    }
}
