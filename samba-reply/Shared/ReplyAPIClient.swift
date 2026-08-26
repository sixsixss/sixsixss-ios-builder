import Foundation

enum ReplyRequestError: Error, Equatable {
    case notConfigured
    case offline
    case timedOut
    case server(String)
    case invalidResponse

    var statusText: String {
        switch self {
        case .notConfigured: return "Open Reply to finish setup"
        case .offline: return "You're offline"
        case .timedOut: return "Try again"
        case .server: return "Try again"
        case .invalidResponse: return "Try again"
        }
    }
}

/// Talks to the configured backend only. The OpenAI key never lives on
/// device — every request goes through the Supabase edge function.
enum ReplyAPIClient {
    static func requestReplies(conversation: String, draft: String, mode: String, style: String) async throws -> [String] {
        guard let url = URL(string: SharedStore.backendURL), !SharedStore.backendURL.isEmpty else {
            throw ReplyRequestError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let payload: [String: Any] = [
            "conversation": conversation,
            "draft": draft,
            "mode": mode,
            "style": style
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                throw ReplyRequestError.offline
            case .timedOut:
                throw ReplyRequestError.timedOut
            default:
                throw ReplyRequestError.invalidResponse
            }
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ReplyRequestError.server("Backend returned an error")
        }

        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let suggestions = object["suggestions"] as? [String],
              !suggestions.isEmpty else {
            throw ReplyRequestError.invalidResponse
        }

        return Array(suggestions.prefix(3))
    }
}
