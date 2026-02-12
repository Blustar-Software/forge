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
    let timeoutSeconds: Int
}

struct AIDraftAuditDecision {
    let model: String
    let approved: Bool
    let risk: String
    let summary: String
    let findings: [String]
    let recommendations: [String]
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
    case invalidAuditPayload(String)

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
        case .invalidAuditPayload(let detail):
            return "Live provider payload was not a valid audit decision: \(detail)"
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
    let timeoutSeconds: Int = {
        let raw = environment["FORGE_AI_OLLAMA_TIMEOUT_SECONDS"]?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let raw, let parsed = Int(raw) else { return 90 }
        return max(10, parsed)
    }()

    return OllamaClientConfig(endpoint: endpoint, apiKey: apiKey, model: model, timeoutSeconds: timeoutSeconds)
}

func resolvedOllamaAuditModel(environment: [String: String]) -> String {
    let raw = environment["FORGE_AI_OLLAMA_AUDIT_MODEL"]?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let raw, !raw.isEmpty {
        return raw
    }
    return "phi4-mini-reasoning:latest"
}

func resolvedOllamaAuditTimeoutSeconds(environment: [String: String], baseTimeout: Int) -> Int {
    let raw = environment["FORGE_AI_OLLAMA_AUDIT_TIMEOUT_SECONDS"]?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let raw, let parsed = Int(raw) {
        return max(20, parsed)
    }
    return max(120, baseTimeout)
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
    retryFeedback: String? = nil,
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
            PhiChatMessage(role: "user", content: buildPhiUserPrompt(retryFeedback: retryFeedback))
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
    retryFeedback: String? = nil,
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
            PhiChatMessage(role: "user", content: buildPhiUserPrompt(retryFeedback: retryFeedback))
        ]
    )

    do {
        request.httpBody = try JSONEncoder().encode(payload)
    } catch {
        throw PhiClientError.requestEncodingFailed(error)
    }

    let httpTransport = transport ?? { request in
        try defaultOllamaHTTPTransport(request, timeoutSeconds: config.timeoutSeconds)
    }
    let (data, response) = try httpTransport(request)
    guard (200..<300).contains(response.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? ""
        throw PhiClientError.badStatus(response.statusCode, body)
    }

    return try decodeLiveDraft(from: data)
}

func fetchOllamaDraftAudit(
    draft: AIChallengeDraft,
    environment: [String: String],
    transport: OllamaHTTPTransport? = nil
) throws -> AIDraftAuditDecision {
    let config = try loadOllamaClientConfig(modelOverride: nil, environment: environment)
    let auditModel = resolvedOllamaAuditModel(environment: environment)
    let timeoutSeconds = resolvedOllamaAuditTimeoutSeconds(environment: environment, baseTimeout: config.timeoutSeconds)

    var request = URLRequest(url: config.endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let apiKey = config.apiKey {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }

    let draftJSON: String = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(draft),
              let text = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return text
    }()

    let payload = PhiChatRequest(
        model: auditModel,
        temperature: 0.1,
        messages: [
            PhiChatMessage(role: "system", content: ollamaAuditSystemPrompt),
            PhiChatMessage(role: "user", content: buildOllamaAuditUserPrompt(draftJSON: draftJSON))
        ]
    )

    do {
        request.httpBody = try JSONEncoder().encode(payload)
    } catch {
        throw PhiClientError.requestEncodingFailed(error)
    }

    let httpTransport = transport ?? { request in
        try defaultOllamaHTTPTransport(request, timeoutSeconds: timeoutSeconds)
    }
    let (data, response) = try httpTransport(request)
    guard (200..<300).contains(response.statusCode) else {
        let body = String(data: data, encoding: .utf8) ?? ""
        throw PhiClientError.badStatus(response.statusCode, body)
    }

    var decision = try decodeLiveAuditDecision(from: data)
    decision = AIDraftAuditDecision(
        model: auditModel,
        approved: decision.approved,
        risk: decision.risk,
        summary: decision.summary,
        findings: decision.findings,
        recommendations: decision.recommendations
    )
    return decision
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
    let candidates = [jsonText, sanitizeLooseJSONText(jsonText)]
    for candidate in candidates {
        guard let jsonData = candidate.data(using: .utf8) else {
            continue
        }
        if let strict = try? JSONDecoder().decode(AIChallengeDraft.self, from: jsonData) {
            return strict
        }
        if let lenient = decodeAIDraftLenient(from: jsonData) {
            return lenient
        }
    }

    if let loose = decodeAIDraftFromLooseText(message) {
        return loose
    }
    let preview = String(message.prefix(300))
    throw PhiClientError.invalidDraftPayload(preview)
}

func decodeLiveAuditDecision(from data: Data) throws -> AIDraftAuditDecision {
    let completion: PhiChatCompletionResponse
    do {
        completion = try JSONDecoder().decode(PhiChatCompletionResponse.self, from: data)
    } catch {
        throw PhiClientError.invalidAuditPayload(error.localizedDescription)
    }

    guard let message = completion.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
          !message.isEmpty else {
        if completion.choices.isEmpty {
            throw PhiClientError.emptyChoices
        }
        throw PhiClientError.emptyContent
    }

    let jsonText = extractJSONObjectText(from: message)
    let candidates = [jsonText, sanitizeLooseJSONText(jsonText)]
    for candidate in candidates {
        guard let jsonData = candidate.data(using: .utf8) else {
            continue
        }
        if let strict = try? JSONDecoder().decode(AIDraftAuditDecisionPayload.self, from: jsonData) {
            return strict.normalized
        }
        if let lenient = decodeAIAuditDecisionLenient(from: jsonData) {
            return lenient
        }
    }

    if let loose = decodeAIAuditDecisionFromLooseText(message) {
        return loose
    }
    let preview = String(message.prefix(300))
    throw PhiClientError.invalidAuditPayload(preview)
}

func decodeAIDraftLenient(from data: Data) -> AIChallengeDraft? {
    guard let object = try? JSONSerialization.jsonObject(with: data),
          var payload = object as? [String: Any] else {
        return nil
    }

    if let wrapped = payload["challenge"] as? [String: Any] {
        payload = wrapped
    } else if let wrapped = payload["draft"] as? [String: Any] {
        payload = wrapped
    } else if let wrapped = payload["candidate"] as? [String: Any] {
        payload = wrapped
    } else if let wrapped = payload["output"] as? [String: Any] {
        payload = wrapped
    }

    let id = draftString(for: ["id", "challengeId", "challenge_id"], in: payload)
        ?? "ai-draft-local-\(UUID().uuidString.lowercased().prefix(8))"
    let title = draftString(for: ["title", "name"], in: payload)
        ?? "AI Generated Challenge"
    let description = draftString(for: ["description", "prompt"], in: payload)
        ?? "Generated challenge draft."
    let starterCode = draftString(for: ["starterCode", "starter_code", "starter", "code"], in: payload)
        ?? "// TODO: Implement the challenge solution."
    let solution = draftString(for: ["solution", "answer", "referenceSolution", "reference_solution"], in: payload)
    let expectedOutput = draftString(for: ["expectedOutput", "expected_output", "expected", "output"], in: payload)
        ?? "TODO"
    let hints = draftHints(from: payload)
    let topic = draftString(for: ["topic", "concept", "category"], in: payload) ?? "general"
    let tier = draftString(for: ["tier", "difficultyTier", "difficulty_tier"], in: payload) ?? "mainline"
    let layer = draftString(for: ["layer", "stage"], in: payload) ?? "core"

    return AIChallengeDraft(
        id: id,
        title: title,
        description: description,
        starterCode: starterCode,
        solution: solution,
        expectedOutput: expectedOutput,
        hints: hints,
        topic: topic,
        tier: tier,
        layer: layer
    )
}

private struct AIDraftAuditDecisionPayload: Decodable {
    let approved: Bool
    let risk: String
    let summary: String
    let findings: [String]?
    let recommendations: [String]?

    var normalized: AIDraftAuditDecision {
        AIDraftAuditDecision(
            model: "",
            approved: approved,
            risk: normalizeAuditRisk(risk),
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            findings: normalizeAuditItems(findings ?? []),
            recommendations: normalizeAuditItems(recommendations ?? [])
        )
    }
}

func decodeAIAuditDecisionLenient(from data: Data) -> AIDraftAuditDecision? {
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let payload = object as? [String: Any] else {
        return nil
    }
    let hasAuditSignal = payload.keys.contains { key in
        let lowered = key.lowercased()
        return [
            "approved",
            "risk",
            "summary",
            "verdict",
            "findings",
            "recommendations",
            "issues",
            "actions",
            "suggestions",
        ].contains(lowered)
    }
    guard hasAuditSignal else {
        return nil
    }

    let approved = parseAuditApproved(payload: payload)
    let risk = parseAuditRisk(payload: payload)
    let summary = draftString(for: ["summary", "notes", "reason", "verdict"], in: payload) ?? "No summary provided."
    let findings = parseAuditItems(keys: ["findings", "issues", "problems"], payload: payload)
    let recommendations = parseAuditItems(keys: ["recommendations", "actions", "suggestions"], payload: payload)

    return AIDraftAuditDecision(
        model: "",
        approved: approved,
        risk: risk,
        summary: summary,
        findings: findings,
        recommendations: recommendations
    )
}

func decodeAIAuditDecisionFromLooseText(_ text: String) -> AIDraftAuditDecision? {
    let hasAuditSignal =
        text.localizedCaseInsensitiveContains("\"approved\"")
        || text.localizedCaseInsensitiveContains("\"risk\"")
        || text.localizedCaseInsensitiveContains("\"summary\"")
        || text.localizedCaseInsensitiveContains("\"verdict\"")
    guard hasAuditSignal else {
        return nil
    }

    let approved: Bool = {
        if let raw = firstRegexCapture(pattern: "\"approved\"\\s*:\\s*(true|false)", in: text, options: [.caseInsensitive]) {
            return raw.lowercased() == "true"
        }
        if let raw = looseStringValue(for: ["approved", "verdict"], in: text) {
            let lowered = raw.lowercased()
            return ["true", "pass", "approved", "yes"].contains(lowered)
        }
        return false
    }()

    let risk = normalizeAuditRisk(looseStringValue(for: ["risk", "severity"], in: text) ?? "medium")
    let summary = looseStringValue(for: ["summary", "notes", "reason", "verdict"], in: text)
        ?? "No summary provided."
    let findings = looseStringArrayValue(for: ["findings", "issues", "problems"], in: text)
    let recommendations = looseStringArrayValue(for: ["recommendations", "actions", "suggestions"], in: text)

    return AIDraftAuditDecision(
        model: "",
        approved: approved,
        risk: risk,
        summary: summary,
        findings: findings,
        recommendations: recommendations
    )
}

func parseAuditApproved(payload: [String: Any]) -> Bool {
    if let value = payload["approved"] as? Bool {
        return value
    }
    if let value = payload["approved"] as? NSNumber {
        return value.intValue != 0
    }
    if let text = draftString(for: ["approved", "verdict", "result"], in: payload)?.lowercased() {
        return ["true", "pass", "approved", "yes"].contains(text)
    }
    return false
}

func parseAuditRisk(payload: [String: Any]) -> String {
    let raw = draftString(for: ["risk", "severity", "confidence"], in: payload) ?? "medium"
    return normalizeAuditRisk(raw)
}

func parseAuditItems(keys: [String], payload: [String: Any]) -> [String] {
    for key in keys {
        guard let raw = payload[key] else { continue }
        if let values = raw as? [String] {
            let normalized = normalizeAuditItems(values)
            if !normalized.isEmpty {
                return normalized
            }
        }
        if let values = raw as? [Any] {
            let normalized = normalizeAuditItems(values.compactMap { draftString(from: $0) })
            if !normalized.isEmpty {
                return normalized
            }
        }
        if let single = draftString(from: raw) {
            let split = single
                .split(whereSeparator: { $0 == "\n" || $0 == ";" })
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !split.isEmpty {
                return split
            }
        }
    }
    return []
}

func normalizeAuditRisk(_ raw: String) -> String {
    let lowered = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if ["low", "medium", "high"].contains(lowered) {
        return lowered
    }
    if ["critical", "severe"].contains(lowered) {
        return "high"
    }
    if ["moderate", "mid"].contains(lowered) {
        return "medium"
    }
    if ["minor", "safe"].contains(lowered) {
        return "low"
    }
    return "medium"
}

func normalizeAuditItems(_ items: [String]) -> [String] {
    items.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

func draftString(for keys: [String], in payload: [String: Any]) -> String? {
    for key in keys {
        guard let raw = payload[key] else { continue }
        if let value = draftString(from: raw), !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return value
        }
    }
    return nil
}

func draftString(from raw: Any) -> String? {
    switch raw {
    case let value as String:
        return value
    case let value as NSNumber:
        return value.stringValue
    case let value as [String: Any]:
        if let text = value["text"] as? String {
            return text
        }
        if let valueField = value["value"] {
            return draftString(from: valueField)
        }
        return nil
    default:
        return nil
    }
}

func draftHints(from payload: [String: Any]) -> [String] {
    let rawHints = payload["hints"]
    if let values = rawHints as? [String] {
        let trimmed = values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if !trimmed.isEmpty {
            return trimmed
        }
    }
    if let values = rawHints as? [Any] {
        let strings = values.compactMap { draftString(from: $0)?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if !strings.isEmpty {
            return strings
        }
    }
    if let single = draftString(for: ["hints", "hint"], in: payload) {
        let split = single
            .split(whereSeparator: { $0 == "\n" || $0 == ";" })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if !split.isEmpty {
            return split
        }
    }
    return [
        "Use print(...) to produce the expected output.",
        "Match expected output exactly, including punctuation."
    ]
}

func sanitizeLooseJSONText(_ text: String) -> String {
    var value = stripCodeFences(text)
    value = replacingRegexMatches(
        pattern: ",\\s*([}\\]])",
        in: value,
        with: "$1",
        options: []
    )
    return value
}

func decodeAIDraftFromLooseText(_ text: String) -> AIChallengeDraft? {
    let id = looseStringValue(for: ["id", "challengeId", "challenge_id"], in: text)
        ?? "ai-draft-local-\(UUID().uuidString.lowercased().prefix(8))"
    let title = looseStringValue(for: ["title", "name"], in: text)
        ?? "AI Generated Challenge"
    let description = looseStringValue(for: ["description", "prompt"], in: text)
        ?? "Generated challenge draft."
    let starterCode = looseStringValue(for: ["starterCode", "starter_code", "starter", "code"], in: text)
        ?? "// TODO: Implement the challenge solution."
    let solution = looseStringValue(for: ["solution", "answer", "referenceSolution", "reference_solution"], in: text)
    let expectedOutput = looseStringValue(for: ["expectedOutput", "expected_output", "expected", "output"], in: text)
        ?? "TODO"
    let hints = looseHints(in: text)
    let topic = looseStringValue(for: ["topic", "concept", "category"], in: text) ?? "general"
    let tier = looseStringValue(for: ["tier", "difficultyTier", "difficulty_tier"], in: text) ?? "mainline"
    let layer = looseStringValue(for: ["layer", "stage"], in: text) ?? "core"

    return AIChallengeDraft(
        id: id,
        title: title,
        description: description,
        starterCode: starterCode,
        solution: solution,
        expectedOutput: expectedOutput,
        hints: hints,
        topic: topic,
        tier: tier,
        layer: layer
    )
}

func looseStringValue(for keys: [String], in text: String) -> String? {
    for key in keys {
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        let quotedPattern = "\"\(escapedKey)\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\""
        if let raw = firstRegexCapture(pattern: quotedPattern, in: text),
           let decoded = decodeJSONStringFragment(raw),
           !decoded.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return decoded
        }

        let barePattern = "\"\(escapedKey)\"\\s*:\\s*([A-Za-z0-9_:\\.-]+)"
        if let raw = firstRegexCapture(pattern: barePattern, in: text),
           !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return raw
        }
    }
    return nil
}

func looseHints(in text: String) -> [String] {
    let arrayPattern = "\"hints\"\\s*:\\s*\\[(.*?)\\]"
    if let body = firstRegexCapture(pattern: arrayPattern, in: text, options: [.dotMatchesLineSeparators]) {
        let stringPattern = "\"((?:\\\\.|[^\"\\\\])*)\""
        let captures = allRegexCaptures(pattern: stringPattern, in: body)
        let decoded = captures.compactMap(decodeJSONStringFragment).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        if !decoded.isEmpty {
            return decoded
        }
    }

    if let hintText = looseStringValue(for: ["hints", "hint"], in: text) {
        let split = hintText
            .split(whereSeparator: { $0 == "\n" || $0 == ";" })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if !split.isEmpty {
            return split
        }
    }

    return [
        "Use print(...) to produce the expected output.",
        "Match expected output exactly, including punctuation."
    ]
}

func looseStringArrayValue(for keys: [String], in text: String) -> [String] {
    for key in keys {
        let escaped = NSRegularExpression.escapedPattern(for: key)
        let arrayPattern = "\"\(escaped)\"\\s*:\\s*\\[(.*?)\\]"
        if let body = firstRegexCapture(pattern: arrayPattern, in: text, options: [.dotMatchesLineSeparators]) {
            let stringPattern = "\"((?:\\\\.|[^\"\\\\])*)\""
            let captures = allRegexCaptures(pattern: stringPattern, in: body)
            let decoded = normalizeAuditItems(captures.compactMap(decodeJSONStringFragment))
            if !decoded.isEmpty {
                return decoded
            }
        }

        if let single = looseStringValue(for: [key], in: text) {
            let split = single
                .split(whereSeparator: { $0 == "\n" || $0 == ";" })
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !split.isEmpty {
                return split
            }
        }
    }
    return []
}

func decodeJSONStringFragment(_ fragment: String) -> String? {
    let wrapped = "\"\(fragment)\""
    guard let data = wrapped.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(String.self, from: data)
}

func firstRegexCapture(
    pattern: String,
    in text: String,
    options: NSRegularExpression.Options = []
) -> String? {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
        return nil
    }
    let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
    guard let match = regex.firstMatch(in: text, range: fullRange), match.numberOfRanges > 1,
          let range = Range(match.range(at: 1), in: text) else {
        return nil
    }
    return String(text[range])
}

func allRegexCaptures(
    pattern: String,
    in text: String,
    options: NSRegularExpression.Options = []
) -> [String] {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
        return []
    }
    let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
    return regex.matches(in: text, range: fullRange).compactMap { match in
        guard match.numberOfRanges > 1, let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[range])
    }
}

func replacingRegexMatches(
    pattern: String,
    in text: String,
    with template: String,
    options: NSRegularExpression.Options = []
) -> String {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
        return text
    }
    let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
    return regex.stringByReplacingMatches(in: text, range: fullRange, withTemplate: template)
}

func defaultPhiHTTPTransport(_ request: URLRequest) throws -> (Data, HTTPURLResponse) {
    return try runHTTPTransport(request, timeoutSeconds: 30)
}

func defaultOllamaHTTPTransport(_ request: URLRequest, timeoutSeconds: Int) throws -> (Data, HTTPURLResponse) {
    return try runHTTPTransport(request, timeoutSeconds: timeoutSeconds)
}

func runHTTPTransport(_ request: URLRequest, timeoutSeconds: Int) throws -> (Data, HTTPURLResponse) {
    let semaphore = DispatchSemaphore(value: 0)
    let box = PhiTransportResultBox()

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        box.set(data: data, response: response, error: error)
        semaphore.signal()
    }
    task.resume()

    let timeout = DispatchTime.now() + .seconds(timeoutSeconds)
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
- Keep the challenge deterministic: use constants, not user/file/network input.
- Do not use `readLine`, `CommandLine.arguments`, file IO, networking, async tasks, or timers.
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

private let ollamaAuditSystemPrompt = """
You audit a Swift learning challenge draft for Forge.
Return only JSON with keys:
approved,risk,summary,findings,recommendations
"""

func buildOllamaAuditUserPrompt(draftJSON: String) -> String {
    return """
    Audit this Swift challenge draft.
    Criteria:
    - Reject if the solution is likely invalid Swift or likely fails to produce expectedOutput.
    - Reject if instructions, starterCode, and solution are inconsistent.
    - Reject if the draft has obvious pedagogy issues for a beginner challenge.
    - Keep findings concrete and short.
    Output rules:
    - JSON only.
    - approved: boolean
    - risk: low|medium|high
    - summary: one short sentence
    - findings: array of short strings
    - recommendations: array of short strings

    Draft:
    \(draftJSON)
    """
}

func buildPhiUserPrompt(retryFeedback: String?) -> String {
    guard let feedback = retryFeedback?.trimmingCharacters(in: .whitespacesAndNewlines),
          !feedback.isEmpty else {
        return phiUserPrompt
    }

    return """
    \(phiUserPrompt)
    Retry instructions:
    - Your previous draft failed validation.
    - Correct the issues and return a fresh full JSON draft.
    - Ensure the provided solution compiles and prints `expectedOutput` exactly.
    Failure summary: \(feedback)
    """
}

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
