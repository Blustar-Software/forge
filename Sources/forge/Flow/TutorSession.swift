import Foundation

private class ThreadSafeBox<T>: @unchecked Sendable {
    private var _value: T
    private let lock = NSLock()
    init(_ value: T) { self._value = value }
    var value: T {
        get { lock.lock(); defer { lock.unlock() }; return _value }
        set { lock.lock(); defer { lock.unlock() }; _value = newValue }
    }
}

class TutorSession: @unchecked Sendable {
    let client = OllamaClient()
    private let lock = NSLock()
    
    private var _selectedModel: String?
    var selectedModel: String? {
        get { lock.lock(); defer { lock.unlock() }; return _selectedModel }
        set { lock.lock(); defer { lock.unlock() }; _selectedModel = newValue }
    }
    
    private var _history: [OllamaChatMessage] = []
    var history: [OllamaChatMessage] {
        get { lock.lock(); defer { lock.unlock() }; return _history }
        set { lock.lock(); defer { lock.unlock() }; _history = newValue }
    }
    
    let subject: Tutorable
    let workspacePath: String
    let preferenceWorkspacePath: String
    
    private var _lastDiagnostics: String?
    var lastDiagnostics: String? {
        get { lock.lock(); defer { lock.unlock() }; return _lastDiagnostics }
        set { lock.lock(); defer { lock.unlock() }; _lastDiagnostics = newValue }
    }

    private var _activeTask = ThreadSafeBox<URLSessionDataTask?>(nil)

    init(
        subject: Tutorable,
        workspacePath: String,
        preferenceWorkspacePath: String = "workspace",
        lastDiagnostics: String?
    ) {
        self.subject = subject
        self.workspacePath = workspacePath
        self.preferenceWorkspacePath = preferenceWorkspacePath
        self._selectedModel = loadTutorModelPreference(workspacePath: preferenceWorkspacePath)
        self._lastDiagnostics = lastDiagnostics
    }

    func start() {
        print("\n--- AI Tutor Mode ---")
        print("(Press Ctrl+C to interrupt a response)")
        
        if selectedModel == nil {
            let semaphore = DispatchSemaphore(value: 0)
            
            let modelsBox = ThreadSafeBox<[String]>([])
            let errorBox = ThreadSafeBox<String?>(nil)

            client.fetchModels { result in
                switch result {
                case .success(let models):
                    modelsBox.value = models
                case .failure(let error):
                    errorBox.value = error.localizedDescription
                }
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .now() + 5)
            
            if let errorDesc = errorBox.value {
                print("Error connecting to Ollama: \(errorDesc)")
                print("Make sure Ollama is running (http://localhost:11434).")
                return
            }
            
            let models = modelsBox.value
            if models.isEmpty {
                print("No Ollama models found.")
                print("Please run 'ollama pull llama3' (or your preferred model) in another terminal first.")
                return
            }
            
            selectedModel = selectModel(from: models)
            if let selectedModel {
                saveTutorModelPreference(selectedModel, workspacePath: preferenceWorkspacePath)
            }
            if selectedModel == nil {
                return
            }
        }

        print("Tutor active (\(selectedModel!)). Type your question, 'model' to switch, or 'exit' to quit.")
        
        runChatLoop()
    }

    private func selectModel(from models: [String]) -> String? {
        print("\nAvailable Models:")
        for (index, model) in models.enumerated() {
            print("\(index + 1). \(model)")
        }
        
        while true {
            print("\nSelect a model (1-\(models.count)) or 'q' to cancel: ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else { continue }
            
            if input.lowercased() == "q" { return nil }
            
            if let choice = Int(input), choice > 0 && choice <= models.count {
                return models[choice - 1]
            }
            print("Invalid selection.")
        }
    }

    private func runChatLoop() {
        while true {
            print("\nTutor> ", terminator: "")
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            
            if input.isEmpty {
                print("\nAI Tutor Commands:")
                print("  [text]  Ask a question about the current challenge")
                print("  model   Switch to a different AI model")
                print("  reset   Reset the conversation history")
                print("  exit    Exit Tutor Mode (or 'q')")
                continue
            }
            
            let cmd = input.lowercased()
            if cmd == "exit" || cmd == "q" {
                print("Exiting Tutor Mode.\n")
                break
            }
            
            if cmd == "model" {
                let semaphore = DispatchSemaphore(value: 0)
                client.fetchModels { [weak self] result in
                    guard let self = self else {
                        semaphore.signal()
                        return
                    }
                    if case .success(let models) = result {
                        if let newModel = self.selectModel(from: models) {
                            self.selectedModel = newModel
                            saveTutorModelPreference(newModel, workspacePath: self.preferenceWorkspacePath)
                            print("Switched to \(newModel)")
                        }
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                continue
            }

            if cmd == "reset" {
                history = []
                print("Conversation history reset.")
                continue
            }

            askTutor(question: input)
        }
    }

    private func askTutor(question: String) {
        guard let model = selectedModel else { return }
        
        let userCode = (try? String(contentsOfFile: "\(workspacePath)/\(subject.filename)", encoding: .utf8)) ?? ""
        
        var extraContext = ""
        if let challenge = subject as? Challenge {
            extraContext += "\nExpected Output:\n\(challenge.expectedOutput)"
        } else if let project = subject as? Project {
            extraContext += "\nTest Cases:"
            for (index, tc) in project.testCases.enumerated() {
                extraContext += "\n  \(index + 1). Input: \(tc.input), Expected: \(tc.expectedOutput)"
            }
        }
        
        let hintsInfo = subject.hints.isEmpty ? "No hints provided yet." : "- " + subject.hints.joined(separator: "\n- ")
        
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
        \(lastDiagnostics ?? "No errors yet.")
        
        Available Lesson Info:
        \(subject.lesson)
        
        Available Cheatsheet Info:
        \(subject.cheatsheet)
        
        Hints already available to student:
        \(hintsInfo)
        
        GUIDELINES:
        1. Be Socratic: Ask questions that lead the student to find the bug or understand the concept.
        2. Never give the full solution or large code blocks that can be copy-pasted.
        3. Use Forge's philosophy: focus on the concepts introduced so far.
        4. If they are completely stuck, give a tiny hint or a pseudo-code example of a similar (but different) problem.
        5. Acknowledge their specific code and point out where it might be deviating from the requirements.
        6. Keep responses relatively concise and focused on one or two small steps at a time.
        """

        var currentHistory = history
        if currentHistory.isEmpty {
            currentHistory.append(OllamaChatMessage(role: "system", content: systemPrompt))
        } else {
            currentHistory[0] = OllamaChatMessage(role: "system", content: systemPrompt)
        }
        
        currentHistory.append(OllamaChatMessage(role: "user", content: question))
        
        let semaphore = DispatchSemaphore(value: 0)
        let fullResponseBox = ThreadSafeBox<String>("")
        let historyBox = ThreadSafeBox<[OllamaChatMessage]>(currentHistory)
        let wasInterrupted = ThreadSafeBox<Bool>(false)

        // Setup SIGINT interception
        let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        signalSource.setEventHandler { [weak self] in
            wasInterrupted.value = true
            self?._activeTask.value?.cancel()
            semaphore.signal()
        }
        signal(SIGINT, SIG_IGN) // Ignore default process-kill behavior
        signalSource.resume()

        print("\nTutor is thinking...\r", terminator: "")
        
        let task = client.chat(model: model, messages: currentHistory, onReceive: { content in
            if fullResponseBox.value.isEmpty {
                print("                                \r", terminator: "") // Clear "thinking" line
            }
            print(content, terminator: "")
            fflush(stdout)
            fullResponseBox.value += content
        }, onComplete: { [weak self] result in
            if !wasInterrupted.value {
                print("") // New line after stream
                switch result {
                case .success:
                    let response = fullResponseBox.value
                    if response.isEmpty {
                        print("Tutor returned an empty response. You might want to try again or switch models.")
                    } else {
                        var h = historyBox.value
                        h.append(OllamaChatMessage(role: "assistant", content: response))
                        self?.history = h
                    }
                case .failure(let error):
                    if (error as NSError).code != NSURLErrorCancelled {
                        print("\nError from Ollama: \(error.localizedDescription)")
                    }
                }
                semaphore.signal()
            }
        })
        
        self._activeTask.value = task
        semaphore.wait()
        
        // Cleanup SIGINT interception
        signalSource.cancel()
        signal(SIGINT, SIG_DFL) // Restore default behavior
        
        if wasInterrupted.value {
            print("\n[Interrupted]")
        }
        self._activeTask.value = nil
    }
}
