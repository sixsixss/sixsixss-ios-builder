import Foundation

/// Everything the keyboard's SwiftUI surface needs, decoupled from
/// `UIInputViewController` so the view stays a plain, testable SwiftUI tree.
@MainActor
final class KeyboardBridge: ObservableObject {
    @Published var mode: ReplyMode = ReplyMode(stored: SharedStore.mode)
    @Published var suggestions: [String] = []
    @Published var statusText: String = "Ready"
    @Published var isLoading = false
    var hasFullAccess = false

    var insertText: (String) -> Void = { _ in }
    var deleteBackward: () -> Void = {}
    var currentDraft: () -> String = { "" }
    var advanceInput: () -> Void = {}

    private var activeTask: Task<Void, Never>?

    /// Selecting a mode and generating are the same tap — each chip in the
    /// top row is itself the action, with Reply/Auto as the emphasized default.
    func activate(_ newMode: ReplyMode) {
        activeTask?.cancel()
        mode = newMode
        SharedStore.mode = newMode.rawValue
        suggestions = []
        generate()
    }

    private func generate() {
        guard hasFullAccess else {
            statusText = "Open Reply to finish setup"
            return
        }

        let draft = currentDraft()
        if mode == .fix, draft.isEmpty {
            statusText = "Nothing to fix"
            return
        }

        isLoading = true
        statusText = "Thinking…"

        let conversation = SharedStore.contextEnabled ? SharedStore.freshTranscript : ""
        let requestMode = mode.rawValue
        let style = SharedStore.style

        activeTask = Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await ReplyAPIClient.requestReplies(
                    conversation: conversation,
                    draft: draft,
                    mode: requestMode,
                    style: style
                )
                if Task.isCancelled { return }
                self.isLoading = false
                self.suggestions = results
                self.statusText = "Tap to insert"
            } catch {
                if Task.isCancelled { return }
                self.isLoading = false
                self.statusText = (error as? ReplyRequestError)?.statusText ?? "Try again"
            }
        }
    }

    /// A minimal edit affordance so a stray character can be corrected without
    /// leaving Reply to switch back to the system keyboard.
    func backspace() {
        deleteBackward()
    }

    func choose(_ suggestion: String) {
        if mode == .fix {
            let draft = currentDraft()
            for _ in draft { deleteBackward() }
        }
        insertText(suggestion)
        HistoryStore.record(mode: mode.rawValue, text: suggestion)
        suggestions = []
        statusText = "Ready"
        // The reply is in — the captured context that produced it has served
        // its purpose and should not linger for reuse.
        if SharedStore.contextEnabled { SharedStore.transcript = "" }
    }

    /// Called when the user moves to a different field or app, or keeps
    /// typing past a suggestion — the old suggestions no longer apply.
    func clearForContextChange() {
        guard !suggestions.isEmpty || isLoading else { return }
        activeTask?.cancel()
        isLoading = false
        suggestions = []
        statusText = mode == .auto ? "Ready" : mode.title
    }
}
