import Foundation

struct OllamaModel: Codable {
    let name: String
}

struct OllamaTagsResponse: Codable {
    let models: [OllamaModel]
}

struct OllamaChatMessage: Codable {
    let role: String
    let content: String
    let reasoningContent: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case reasoningContent = "reasoning_content"
    }

    init(role: String, content: String, reasoningContent: String? = nil) {
        self.role = role
        self.content = content
        self.reasoningContent = reasoningContent
    }
}

struct OllamaChatRequest: Codable {
    let model: String
    let messages: [OllamaChatMessage]
    let stream: Bool
}

struct OllamaChatResponse: Codable {
    let message: OllamaChatMessage?
    let done: Bool?
    let error: String?
}

class OllamaClient {
    let baseURL: URL

    init(baseURL: URL = URL(string: "http://localhost:11434")!) {
        self.baseURL = baseURL
    }

    func fetchModels(completion: @escaping @Sendable (Result<[String], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("api/tags")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "OllamaClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data from Ollama"])))
                return
            }
            do {
                let tags = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
                completion(.success(tags.models.map { $0.name }))
            } catch {
                if let ollamaError = try? JSONDecoder().decode(OllamaChatResponse.self, from: data), let msg = ollamaError.error {
                    completion(.failure(NSError(domain: "OllamaClient", code: 0, userInfo: [NSLocalizedDescriptionKey: msg])))
                } else {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    @discardableResult
    func chat(
        model: String,
        messages: [OllamaChatMessage],
        onReceive: @escaping @Sendable (String) -> Void,
        onReceiveReasoning: (@Sendable (String) -> Void)? = nil,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    ) -> URLSessionDataTask {
        let url = baseURL.appendingPathComponent("api/chat")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let chatRequest = OllamaChatRequest(model: model, messages: messages, stream: true)
        let body: Data
        do {
            body = try JSONEncoder().encode(chatRequest)
            request.httpBody = body
        } catch {
            onComplete(.failure(error))
            return URLSession().dataTask(with: request)
        }

        let delegate = StreamDelegate(onReceive: onReceive, onReceiveReasoning: onReceiveReasoning, onComplete: onComplete)
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
        return task
    }
}

private class StreamDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    let onReceive: @Sendable (String) -> Void
    let onReceiveReasoning: (@Sendable (String) -> Void)?
    let onComplete: @Sendable (Result<Void, Error>) -> Void
    var buffer = Data()
    private var encounteredError: Error?

    init(
        onReceive: @escaping @Sendable (String) -> Void,
        onReceiveReasoning: (@Sendable (String) -> Void)?,
        onComplete: @escaping @Sendable (Result<Void, Error>) -> Void
    ) {
        self.onReceive = onReceive
        self.onReceiveReasoning = onReceiveReasoning
        self.onComplete = onComplete
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        processBuffer()
    }

    private func processBuffer() {
        while let lineRange = buffer.range(of: Data("\n".utf8)) {
            let lineData = buffer.subdata(in: 0..<lineRange.lowerBound)
            buffer.removeSubrange(0..<lineRange.upperBound)
            decodeAndNotify(lineData)
        }
    }

    private func decodeAndNotify(_ data: Data) {
        guard !data.isEmpty else { return }
        do {
            let response = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
            
            if let errorMsg = response.error {
                var fullError = "[Ollama Error] \(errorMsg)"
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let signinUrl = json["signin_url"] as? String {
                    fullError += "\nPlease sign in at: \(signinUrl)"
                }
                encounteredError = NSError(domain: "OllamaClient", code: 0, userInfo: [NSLocalizedDescriptionKey: fullError])
                return
            }

            let content = response.message?.content ?? ""
            let reasoning = response.message?.reasoningContent ?? ""
            
            if !reasoning.isEmpty {
                if let onReceiveReasoning = onReceiveReasoning {
                    onReceiveReasoning(reasoning)
                } else {
                    onReceive(reasoning)
                }
            }
            if !content.isEmpty {
                onReceive(content)
            }
        } catch {
            if let raw = String(data: data, encoding: .utf8), raw.contains("\"error\":") {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = json["error"] as? String {
                    var fullError = "[Ollama Error] \(errorMsg)"
                    if let signinUrl = json["signin_url"] as? String {
                        fullError += "\nPlease sign in at: \(signinUrl)"
                    }
                    encounteredError = NSError(domain: "OllamaClient", code: 0, userInfo: [NSLocalizedDescriptionKey: fullError])
                    return
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if !buffer.isEmpty {
            decodeAndNotify(buffer)
            buffer = Data()
        }

        if let error = error {
            onComplete(.failure(error))
        } else if let encounteredError = encounteredError {
            onComplete(.failure(encounteredError))
        } else {
            onComplete(.success(()))
        }
    }
}
