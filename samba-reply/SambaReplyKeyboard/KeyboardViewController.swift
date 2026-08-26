import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private let bridge = KeyboardBridge()

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedStore.markKeyboardSeen()

        bridge.hasFullAccess = hasFullAccess
        bridge.insertText = { [weak self] text in self?.textDocumentProxy.insertText(text) }
        bridge.deleteBackward = { [weak self] in self?.textDocumentProxy.deleteBackward() }
        bridge.currentDraft = { [weak self] in self?.textDocumentProxy.documentContextBeforeInput ?? "" }
        bridge.advanceInput = { [weak self] in self?.advanceToNextInputMode() }

        let hosting = UIHostingController(rootView: KeyboardRootView(bridge: bridge))
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bridge.hasFullAccess = hasFullAccess
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        bridge.clearForContextChange()
    }
}
