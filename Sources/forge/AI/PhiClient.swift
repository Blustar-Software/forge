import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

typealias AIHTTPTransport = (URLRequest) throws -> (Data, HTTPURLResponse)
typealias PhiHTTPTransport = AIHTTPTransport
typealias OllamaHTTPTransport = AIHTTPTransport

struct PhiClientConfig {
    let endpoint: URL
    let apiKey: String
    let model: String
}

struct OllamaClientConfig {
    let endpoint: URL
    let apiKey: String?
    let model: String
}

enum PhiClientError: LocalizedError {
    case missingEnvironment(String)
    case invalidEndpoint(String)
    case requestEncodingFailed(Error)
    case timedOut
    case requestFailed(Error)
    case nonHTTPResponse
    case badStatus(Int, String)
    case emptyChoices
    case emptyContent
    case invalidDraftPayload(String)

    var errorDescription: String? {
        switch self {
        case .missingEnvironment(let key):
            return "Missing environment variable: \(key)"
        case .invalidEndpoint(let value):
            return "Invalid endpoint URL: \(value)"
        case .requestEncodingFailed(let error):
            return "Failed to encode live request: \(error.localizedDescription)"
        case .timedOut:
            return "Live provider request timed out."
        case .requestFailed(let error):
            return "Live provider request failed: \(error.localizedDescription)"
        case .nonHTTPResponse:
            return "Live provider returned a non-HTTP response."
        case .badStatus(let code, let body):
            if body.isEmpty {
                return "Live provider returned HTTP \(code)."
            }
            return "Live provider returned HTTP \(code): \(body)"
        case .emptyChoices:
            return "Live provider returned no choices."
        case .emptyContent:
            return "Live provider returned empty content."
        case .invalidDraftPayload(let detail):
            return "Live provider payload was not a valid challenge draft: \(detail)"
        }
    }
}

enum OllamaClientError: LocalizedError {
    case invalidEndpoint(String)

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint(let value):
            return "Invalid endpoint URL: \(value)"
        }
    }
}

func loadPhiClientConfig(modelOverride: String?, environment: [String: String]) throws -> PhiClientConfig {
    guard let endpointRaw = environment["FORGE_AI_PHI_ENDPOINT"]?.trimmingCharacters(in: .whitespacesAndNewlines),
          !endpointRaw.isEmpty else {
        throw PhiClientError.missingEnvironment("FORGE_AI_PHI_ENDPOINT")
    }
    guard let apiKey = environment["FORGE_AI_PHI_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
          !apiKey.isEmpty else {
        throw PhiClientError.missingEnvironment("FORGE_AI_PHI_API_KEY")
    }

    let endpointString = normalizedPhiEndpoint(endpointRaw)
    guard let endpoint = URL(string: endpointString) else {
        throw PhiClientError.invalidEndpoint(endpointRaw)
    }

    let model = modelOverride
        ?? environment["FORGE_AI_PHI_MODEL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "Phi-4-mini-instruct"

    return PhiClientConfig(endpoint: endpoint, apiKey: apiKey, model: model)
}

func loadOllamaClientConfig(modelOverride: String?, environment: [String: String]) throws -> OllamaClientConfig {
    let endpointRaw = environment["FORGE_AI_OLLAMA_ENDPOINT"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "http://127.0.0.1:11434/v1"
    let endpointString = normalizedOllamaEndpoint(endpointRaw)
    guard let endpoint = URL(string: endpointString) else {
        throw OllamaClientError.invalidEndpoint(endpointRaw)
    }

    let apiKey: String? = {
        guard let raw = environment["FORGE_AI_OLLAMA_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        return raw
    }()

    let model = modelOverride
        ?? environment["FORGE_AI_OLLAMA_MODEL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "phi4-mini"

    return OllamaClientConfig(endpoint: endpoint, apiKey: apiKey, model: model)
}

func normalizedPhiEndpoint(_ raw: String) -> String {
    var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    while value.hasSuffix("/") {
        value.removeLast()
    }
    if value.hasSuffix("/chat/completions") {
        return value
    }
    return value + "/chat/completions"
}

func normalizedOllamaEndpoint(_ raw: String) -> String {
    var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    while value.hasSuffix("/") {
        value.removeLast()
    }
    if value.hasSuffix("/chat/completions") {
        return value
    }
    return value + "/chat/completions"
}

func fetchPhiLiveDraft(
    modelOverride: String?,
    environment: [String: String],
    transport: PhiHTTPTransport? = nil
) throws -> AIChallengeDraft {
    let config = try loadPhiClientConfig(modelOverride: modelOverride, environment: environment)

    var request = URLRequest(url: config.endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

    let payload = PhiChatRequest(
        model: config.model,
        temperature: 0.2,
        messages: [
            PhiChatMessage(role: "system", content: phiSystemPrompt),
            PhiChatMessage(role: "user", content: phiUserPrompt)
        ]
    )

    do {
        request.httpBody = try JSONEncoder().encode(payload)
    } catch {
        throw PhiClientError.requestEncodingFailed(error)
    }

    let httpTransport = transport ?? defaultPhiHTTPTransport
    let (data, response) = try httpTransport(request)
    guard (200..<300).contains(response.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? ""
        throw PhiClientError.badStatus(response.statusCode, body)
    }

    return try decodeLiveDraft(from: data)
}

func fetchOllamaLiveDraft(
    modelOverride: String?,
    environment: [String: String],
    transport: OllamaHTTPTransport? = nil
) throws -> AIChallengeDraft {
    let config = try loadOllamaClientConfig(modelOverride: modelOverride, environment: environment)

    var request = URLRequest(url: config.endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let apiKey = config.apiKey {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }

    let payload = PhiChatRequest(
        model: config.model,
        temperature: 0.2,
        messages: [
            PhiChatMessage(role: "system", content: phiSystemPrompt),
            PhiChatMessage(role: "user", content: phiUserPrompt)
        ]
    )

    do {
        request.httpBody = try JSONEncoder().encode(payload)
    } catch {
        throw PhiClientError.requestEncodingFailed(error)
    }

    let httpTransport = transport ?? defaultPhiHTTPTransport
    let (data, response) = try httpTransport(request)
    guard (200..<300).contains(response.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? ""
        throw PhiClientError.badStatus(response.statusCode, body)
    }

    return try decodeLiveDraft(from: data)
}

func decodeLiveDraft(from data: Data) throws -> AIChallengeDraft {
    let completion: PhiChatCompletionResponse
    do {
        completion = try JSONDecoder().decode(PhiChatCompletionResponse.self, from: data)
    } catch {
        throw PhiClientError.invalidDraftPayload(error.localizedDescription)
    }

    guard let message = completion.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
          !message.isEmpty else {
        if completion.choices.isEmpty {
            throw PhiClientError.emptyChoices
        }
        throw PhiClientError.emptyContent
    }

    let jsonText = extractJSONObjectText(from: message)
    guard let jsonData = jsonText.data(using: .utf8) else {
        throw PhiClientError.invalidDraftPayload("Response was not UTF-8.")
    }
    do {
        return try JSONDecoder().decode(AIChallengeDraft.self, from: jsonData)
    } catch {
        throw PhiClientError.invalidDraftPayload(error.localizedDescription)
    }
}

func defaultPhiHTTPTransport(_ request: URLRequest) throws -> (Data, HTTPURLResponse) {
    let semaphore = DispatchSemaphore(value: 0)
    let box = PhiTransportResultBox()

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        box.set(data: data, response: response, error: error)
        semaphore.signal()
    }
    task.resume()

    let timeout = DispatchTime.now() + .seconds(30)
    if semaphore.wait(timeout: timeout) == .timedOut {
        task.cancel()
        throw PhiClientError.timedOut
    }

    let snapshot = box.snapshot()
    if let error = snapshot.error {
        throw PhiClientError.requestFailed(error)
    }
    guard let http = snapshot.response as? HTTPURLResponse else {
        throw PhiClientError.nonHTTPResponse
    }
    return (snapshot.data ?? Data(), http)
}

func extractJSONObjectText(from content: String) -> String {
    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
    if let data = trimmed.data(using: .utf8),
       (try? JSONSerialization.jsonObject(with: data)) != nil {
        return trimmed
    }

    let stripped = stripCodeFences(trimmed)
    if let data = stripped.data(using: .utf8),
       (try? JSONSerialization.jsonObject(with: data)) != nil {
        return stripped
    }

    guard let start = stripped.firstIndex(of: "{"), let end = stripped.lastIndex(of: "}") else {
        return stripped
    }
    return String(stripped[start...end])
}

func stripCodeFences(_ text: String) -> String {
    var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if value.hasPrefix("```") {
        if let firstNewline = value.firstIndex(of: "\n") {
            value = String(value[value.index(after: firstNewline)...])
        }
        if value.hasSuffix("```") {
            value = String(value.dropLast(3))
        }
    }
    return value.trimmingCharacters(in: .whitespacesAndNewlines)
}

private struct PhiChatRequest: Encodable {
    let model: String
    let temperature: Double
    let messages: [PhiChatMessage]
}

private struct PhiChatMessage: Encodable {
    let role: String
    let content: String
}

private struct PhiChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
    }
}

private let phiSystemPrompt = """
You generate one Swift challenge draft for Forge.
Return only JSON with keys:
id,title,description,starterCode,solution,expectedOutput,hints,topic,tier,layer
"""

private let phiUserPrompt = """
Generate one beginner-safe Swift challenge in Forge style.
Constraints:
- starterCode must compile once TODOs are implemented.
- Use Swift comments only (`//`), never `#`.
- Do not add markdown fences.
- Do not add "End of solution" markers.
- Use `import Foundation` only when genuinely required.
- topic must be one of Forge topics.
- tier must be mainline or extra.
- layer must be core, mantle, or crust.
- hints must be an array of 2 short hints.
Output only JSON.
"""

private final class PhiTransportResultBox: @unchecked Sendable {
    private let lock = NSLock()
    private var storedData: Data?
    private var storedResponse: URLResponse?
    private var storedError: Error?

    func set(data: Data?, response: URLResponse?, error: Error?) {
        lock.lock()
        storedData = data
        storedResponse = response
        storedError = error
        lock.unlock()
    }

    func snapshot() -> (data: Data?, response: URLResponse?, error: Error?) {
        lock.lock()
        defer { lock.unlock() }
        return (storedData, storedResponse, storedError)
    }
}
