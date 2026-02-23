import Foundation

private final class TutorAttachBox<T>: @unchecked Sendable {
    private var value: T
    private let lock = NSLock()

    init(_ value: T) {
        self.value = value
    }

    func get() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    func set(_ value: T) {
        lock.lock()
        defer { lock.unlock() }
        self.value = value
    }

    func update(_ transform: (inout T) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        transform(&value)
    }
}

func printTutorUsage() {
    print("""
    Usage:
      swift run forge tutor
      swift run forge tutor --help

    Attaches to the active Forge session's tutor bridge from another terminal.
    The tutor context follows the current challenge/project in the running Forge session.
    """)
}

func handleTutorCommand(_ args: [String]) {
    if args.first?.lowercased() == "help" || args.first == "--help" || args.first == "-h" {
        printTutorUsage()
        return
    }
    if !args.isEmpty {
        print("tutor does not accept arguments.")
        printTutorUsage()
        return
    }

    let sessionWorkspacePath = "workspace"
    guard loadTutorBridgeSession(workspacePath: sessionWorkspacePath) != nil else {
        print("No active Forge tutoring session found.")
        print("Start Forge in another terminal with: swift run forge")
        return
    }

    runAttachedTutor(sessionWorkspacePath: sessionWorkspacePath)
}

private func runAttachedTutor(sessionWorkspacePath: String) {
    let client = OllamaClient()
    var selectedModel = loadTutorModelPreference(workspacePath: sessionWorkspacePath)
    var history: [OllamaChatMessage] = []

    func fetchModelsSync() -> Result<[String], Error> {
        let semaphore = DispatchSemaphore(value: 0)
        let modelsBox = TutorAttachBox<[String]>([])
        let errorBox = TutorAttachBox<Error?>(nil)

        client.fetchModels { result in
            switch result {
            case .success(let models):
                modelsBox.set(models)
            case .failure(let error):
                errorBox.set(error)
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        if let error = errorBox.get() {
            return .failure(error)
        }
        return .success(modelsBox.get())
    }

    func subjectKey(for subject: TutorBridgeSubjectSnapshot?) -> String {
        guard let subject else { return "none" }
        return "\(subject.kind.rawValue):\(subject.id):\(subject.workspacePath)"
    }

    func selectModel(from models: [String]) -> String? {
        print("\nAvailable Models:")
        for (index, model) in models.enumerated() {
            print("\(index + 1). \(model)")
        }

        while true {
            print("\nSelect a model (1-\(models.count)) or 'q' to cancel: ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else { continue }
            if input.lowercased() == "q" {
                return nil
            }
            if let number = Int(input), number > 0, number <= models.count {
                return models[number - 1]
            }
            print("Invalid selection.")
        }
    }

    func ensureModelSelected() -> String? {
        if let selectedModel {
            return selectedModel
        }

        let modelResult = fetchModelsSync()
        guard case .success(let models) = modelResult else {
            let error: String
            switch modelResult {
            case .success:
                error = "Unknown error"
            case .failure(let message):
                error = message.localizedDescription
            }
            print("Error connecting to Ollama: \(error)")
            print("Make sure Ollama is running (http://localhost:11434).")
            return nil
        }
        if models.isEmpty {
            print("No Ollama models found.")
            print("Please run 'ollama pull llama3' (or your preferred model) first.")
            return nil
        }

        guard let selected = selectModel(from: models) else {
            return nil
        }
        selectedModel = selected
        saveTutorModelPreference(selected, workspacePath: sessionWorkspacePath)
        return selected
    }

    func printContextHeader(subject: TutorBridgeSubjectSnapshot, diagnostics: String?) {
        clearScreen()
        let kindLabel = subject.kind == .challenge ? "Challenge" : "Project"
        print("\(kindLabel): \(subject.id) - \(subject.title)")
        print(subject.description)
        if let diagnostics, !diagnostics.isEmpty {
            print("\nLast diagnostics:\n\(diagnostics)")
        }
        print("\nTutor commands: [text], model, reset, exit")
    }

    func askTutor(
        question: String,
        model: String,
        subject: TutorBridgeSubjectSnapshot,
        diagnostics: String?
    ) {
        let codePath = "\(subject.workspacePath)/\(subject.filename)"
        let userCode = (try? String(contentsOfFile: codePath, encoding: .utf8)) ?? ""
        let hintsInfo = subject.hints.isEmpty ? "No hints provided yet." : "- " + subject.hints.joined(separator: "\n- ")

        var extraContext = ""
        if let expected = subject.expectedOutput {
            extraContext += "\nExpected Output:\n\(expected)"
        } else if let testCases = subject.testCases {
            extraContext += "\nTest Cases:"
            for (index, testCase) in testCases.enumerated() {
                extraContext += "\n  \(index + 1). Input: \(testCase.input), Expected: \(testCase.expectedOutput)"
            }
        }

        let systemPrompt = """
        You are the Forge AI Tutor, a helpful and Socratic programming instructor.
        Your goal is to guide the student to the answer without ever giving them the code solution directly.

        Current Subject: \(subject.title)
        Description: \(subject.description)\(extraContext)

        Student's Current Code:
        ```swift
        \(userCode)
        ```

        Last Diagnostics/Errors:
        \(diagnostics ?? "No errors yet.")

        Available Lesson Info:
        \(subject.lesson)

        Available Cheatsheet Info:
        \(subject.cheatsheet)

        Hints already available to student:
        \(hintsInfo)

        GUIDELINES:
        1. Be Socratic: Ask questions that lead the student to find the bug or understand the concept.
        2. Never give the full solution or large code blocks that can be copy-pasted.
        3. Keep responses relatively concise and focused on one or two small steps at a time.
        """

        if history.isEmpty {
            history.append(OllamaChatMessage(role: "system", content: systemPrompt))
        } else {
            history[0] = OllamaChatMessage(role: "system", content: systemPrompt)
        }
        history.append(OllamaChatMessage(role: "user", content: question))

        let semaphore = DispatchSemaphore(value: 0)
        let fullResponse = TutorAttachBox("")
        let completionError = TutorAttachBox<String?>(nil)

        print("\nTutor is thinking...\r", terminator: "")
        _ = client.chat(
            model: model,
            messages: history,
            onReceive: { content in
                if fullResponse.get().isEmpty {
                    print("                                \r", terminator: "")
                }
                print(content, terminator: "")
                fflush(stdout)
                fullResponse.set(fullResponse.get() + content)
            },
            onComplete: { result in
                print("")
                switch result {
                case .success:
                    break
                case .failure(let error):
                    completionError.set(error.localizedDescription)
                }
                semaphore.signal()
            }
        )
        semaphore.wait()

        if let error = completionError.get() {
            print("Error from Ollama: \(error)")
            return
        }

        let response = fullResponse.get()
        if response.isEmpty {
            print("Tutor returned an empty response. Try again or switch models.")
            return
        }
        history.append(OllamaChatMessage(role: "assistant", content: response))
    }

    let monitorRunning = TutorAttachBox(true)
    let contextVersion = TutorAttachBox(0)
    let displayVersion = TutorAttachBox(0)
    DispatchQueue.global(qos: .utility).async {
        var lastDisplaySignature = ""
        var lastResetSignature = ""
        if let initialSession = loadTutorBridgeSession(workspacePath: sessionWorkspacePath) {
            let subjectSignature: String
            if let subject = initialSession.subject {
                subjectSignature = "\(subject.kind.rawValue):\(subject.id):\(subject.workspacePath)"
            } else {
                subjectSignature = "none"
            }
            let resetSignature = "\(subjectSignature)|rev:\(initialSession.contextRevision)"
            lastResetSignature = resetSignature
            lastDisplaySignature = "\(resetSignature)|diag:\(initialSession.lastDiagnostics ?? "")"
        }
        while monitorRunning.get() {
            guard let session = loadTutorBridgeSession(workspacePath: sessionWorkspacePath) else {
                if lastDisplaySignature != "__ended__" {
                    lastDisplaySignature = "__ended__"
                    print("\nForge session ended.")
                }
                usleep(300_000)
                continue
            }

            let subjectSignature: String
            if let subject = session.subject {
                subjectSignature = "\(subject.kind.rawValue):\(subject.id):\(subject.workspacePath)"
            } else {
                subjectSignature = "none"
            }
            let resetSignature = "\(subjectSignature)|rev:\(session.contextRevision)"
            let displaySignature = "\(resetSignature)|diag:\(session.lastDiagnostics ?? "")"

            if displaySignature != lastDisplaySignature {
                lastDisplaySignature = displaySignature
                if let subject = session.subject {
                    clearScreen()
                    let kindLabel = subject.kind == .challenge ? "Challenge" : "Project"
                    print("\(kindLabel): \(subject.id) - \(subject.title)")
                    print(subject.description)
                    if let diagnostics = session.lastDiagnostics, !diagnostics.isEmpty {
                        print("\nLast diagnostics:\n\(diagnostics)")
                    }
                    print("\nTutor commands: [text], model, reset, exit")
                } else {
                    clearScreen()
                    print("Waiting for an active challenge or project in Forge...")
                    print("Tutor commands: model, reset, exit")
                }
                displayVersion.update { value in
                    value += 1
                }
            }
            if resetSignature != lastResetSignature {
                lastResetSignature = resetSignature
                contextVersion.update { value in
                    value += 1
                }
            }

            usleep(300_000)
        }
    }
    defer {
        monitorRunning.set(false)
    }

    var seenContextVersion = -1
    var seenDisplayVersion = -1

    if let initialSession = loadTutorBridgeSession(workspacePath: sessionWorkspacePath) {
        if let subject = initialSession.subject {
            clearScreen()
            let kindLabel = subject.kind == .challenge ? "Challenge" : "Project"
            print("\(kindLabel): \(subject.id) - \(subject.title)")
            print(subject.description)
            if let diagnostics = initialSession.lastDiagnostics, !diagnostics.isEmpty {
                print("\nLast diagnostics:\n\(diagnostics)")
            }
            print("\nTutor commands: [text], model, reset, exit")
        } else {
            clearScreen()
            print("Waiting for an active challenge or project in Forge...")
            print("Tutor commands: model, reset, exit")
        }
    }

    while true {
        guard loadTutorBridgeSession(workspacePath: sessionWorkspacePath) != nil else {
            print("\nForge session ended.")
            return
        }

        let currentDisplayVersion = displayVersion.get()
        if currentDisplayVersion != seenDisplayVersion {
            seenDisplayVersion = currentDisplayVersion
        }

        let currentContextVersion = contextVersion.get()
        if currentContextVersion != seenContextVersion {
            seenContextVersion = currentContextVersion
            history = []
        }

        print("\nTutor> ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
        if input.isEmpty {
            print("Enter a question, or use: model, reset, exit")
            continue
        }

        let command = input.lowercased()
        if command == "exit" || command == "q" {
            print("Exiting Tutor.")
            return
        }
        if command == "reset" {
            history = []
            print("Conversation history reset.")
            continue
        }
        if command == "model" {
            let modelResult = fetchModelsSync()
            guard case .success(let models) = modelResult else {
                let error: String
                switch modelResult {
                case .success:
                    error = "Unknown error"
                case .failure(let message):
                    error = message.localizedDescription
                }
                print("Error fetching models: \(error)")
                continue
            }
            if let updated = selectModel(from: models) {
                selectedModel = updated
                saveTutorModelPreference(updated, workspacePath: sessionWorkspacePath)
                print("Switched to \(updated)")
            }
            continue
        }

        guard let currentSession = loadTutorBridgeSession(workspacePath: sessionWorkspacePath),
              let subject = currentSession.subject
        else {
            print("No active challenge/project context yet.")
            continue
        }

        guard let model = ensureModelSelected() else {
            continue
        }

        askTutor(question: input, model: model, subject: subject, diagnostics: currentSession.lastDiagnostics)
    }
}
