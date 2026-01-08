// forge.swift

import Foundation

enum Step {
    case challenge(Challenge)
    case project(Project)
}

enum ProgressTarget {
    case challenge(Int)
    case step(Int)
    case project(String)
    case completed
}

func displayWelcome() {
    print(
        """

        ╔═══════════════════════════════════════╗
        ║                                       ║
        ║              F O R G E                ║
        ║                                       ║
        ║         Focus. Build. Master.         ║
        ║                                       ║
        ╚═══════════════════════════════════════╝

        Welcome to Forge - where programmers are made.

        This is your focused programming environment.
        No distractions. No complexity you haven't earned.
        Just you and your code.

        Press Enter to begin your journey...
        """)

    _ = readLine()
}

func clearScreen() {
    print("\u{001B}[2J")
    print("\u{001B}[H")
}

func setupWorkspace() {
    let fileManager = FileManager.default
    let workspacePath = "workspace"

    // Create workspace directory if it doesn't exist
    if !fileManager.fileExists(atPath: workspacePath) {
        try? fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
    }
}

func progressFilePath(workspacePath: String) -> String {
    return "\(workspacePath)/.progress"
}

func getProgressToken(workspacePath: String = "workspace") -> String? {
    let progressFile = progressFilePath(workspacePath: workspacePath)

    if let content = try? String(contentsOfFile: progressFile, encoding: .utf8),
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return nil
}

func saveProgress(_ challengeNumber: Int, workspacePath: String = "workspace") {
    let progressFile = progressFilePath(workspacePath: workspacePath)
    try? String(challengeNumber).write(toFile: progressFile, atomically: true, encoding: .utf8)
}

func resetProgress(workspacePath: String = "workspace") {
    let progressFile = progressFilePath(workspacePath: workspacePath)
    let fileManager = FileManager.default
    
    // Delete progress file
    try? fileManager.removeItem(atPath: progressFile)
    
    // Delete all challenge and project files
    if let files = try? fileManager.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            if (file.hasPrefix("challenge") || file.hasPrefix("project_")) && file.hasSuffix(".swift") {
                try? fileManager.removeItem(atPath: "\(workspacePath)/\(file)")
            }
        }
    }
    
    print("✓ Progress reset! Starting from Challenge 1.\n")
}

func loadChallenge(_ challenge: Challenge) {
    let workspacePath = "workspace/\(challenge.filename)"

    // Write challenge file
    let content = "\(challenge.starterCode)\n"

    try? content.write(toFile: workspacePath, atomically: true, encoding: .utf8)

    print(
        """

        Challenge \(challenge.number): \(challenge.title)
        └─ \(challenge.description)

        Edit: \(workspacePath)

        Watching for changes...
        """)
}

func compileAndRun(file: String) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    process.arguments = [file]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
        return nil
    }
}

func isExpectedOutput(_ output: String, expected: String) -> Bool {
    let normalizedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalizedOutput == normalizedExpected
}

func validateChallenge(_ challenge: Challenge, nextStepIndex: Int) -> Bool {
    let workspacePath = "workspace/\(challenge.filename)"

    guard let output = compileAndRun(file: workspacePath) else {
        print("✗ Compilation failed. Check your code.")
        return false
    }

    // Show what the code printed
    print("Output: \(output)\n")

    if isExpectedOutput(output, expected: challenge.expectedOutput) {
        print("✓ Challenge Complete! Well done.\n")

        // Save progress to next step
        saveProgress(nextStepIndex)

        return true
    } else {
        print("✗ Output doesn't match.")
        print("Expected: \(challenge.expectedOutput)")
        return false
    }
}

func runSteps(_ steps: [Step], startingAt: Int) {
    var currentIndex = startingAt - 1

    while currentIndex < steps.count {
        let step = steps[currentIndex]

        switch step {
        case .challenge(let challenge):
            loadChallenge(challenge)

            let workspacePath = "workspace/\(challenge.filename)"
            let fileManager = FileManager.default
            var lastModified =
                try? fileManager.attributesOfItem(atPath: workspacePath)[.modificationDate] as? Date

            var challengeComplete = false
            while !challengeComplete {
                usleep(500_000)

                guard
                    let currentModified = try? fileManager.attributesOfItem(atPath: workspacePath)[
                        .modificationDate]
                    as? Date
                else {
                    continue
                }

                if currentModified != lastModified {
                    var stableCount = 0
                    var lastSeen = currentModified
                    while stableCount < 2 {
                        usleep(200_000)
                        guard
                            let modified = try? fileManager.attributesOfItem(atPath: workspacePath)[
                                .modificationDate]
                            as? Date
                        else {
                            stableCount = 0
                            continue
                        }

                        if modified == lastSeen {
                            stableCount += 1
                        } else {
                            lastSeen = modified
                            stableCount = 0
                        }
                    }

                    lastModified = currentModified
                    print("\n--- Testing your code... ---\n")

                    let nextStepIndex = currentIndex + 2
                    if validateChallenge(challenge, nextStepIndex: nextStepIndex) {
                        challengeComplete = true
                        currentIndex += 1

                        if currentIndex < steps.count {
                            print(nextStepPrompt(for: steps[currentIndex]))
                            if case .challenge = steps[currentIndex] {
                                sleep(2)
                                clearScreen()
                            }
                        } else {
                            saveProgress(999)
                            print("🎉 You've completed everything!")
                            print("Run 'swift run forge reset' to start over.\n")
                        }
                    }
                }
            }
        case .project(let project):
            if runProject(project) {
                currentIndex += 1
                if currentIndex < steps.count {
                    saveProgress(currentIndex + 1)
                    print(project.completionTitle)
                    print("\(project.completionMessage)\n")
                    print(nextStepPrompt(for: steps[currentIndex]))
                    if case .project = steps[currentIndex] {
                        sleep(2)
                        clearScreen()
                    }
                } else {
                    sleep(2)
                    saveProgress(999)
                    print(project.completionTitle)
                    print("\(project.completionMessage)\n")
                    print("🎉 You've completed everything!")
                    print("Run 'swift run forge reset' to start over.\n")
                }
            }
        }
    }
}

func loadProject(_ project: Project) {
    let workspacePath = "workspace/\(project.filename)"

    try? project.starterCode.write(toFile: workspacePath, atomically: true, encoding: .utf8)

    print(
        """

        🛠️ Project: \(project.title)
        └─ \(project.description)

        Edit: \(workspacePath)

        This project is checked against expected outputs. Build something that works!
        Watching for changes...
        """)
}

func validateProject(_ project: Project) -> Bool {
    let workspacePath = "workspace/\(project.filename)"

    guard let output = compileAndRun(file: workspacePath) else {
        print("✗ Compilation failed. Check your code.")
        return false
    }

    // Show what the code printed
    print("Output: \(output)\n")
    
    // Parse output lines
    let outputLines = output.components(separatedBy: "\n")
    
    // Check if all test cases pass
    guard outputLines.count == project.testCases.count else {
        print("✗ Expected \(project.testCases.count) outputs, got \(outputLines.count)")
        return false
    }
    
    var allPassed = true
    for (index, testCase) in project.testCases.enumerated() {
        let expected = testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let actual = outputLines[index].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if actual != expected {
            print("✗ Test \(index + 1) failed: expected \(expected), got \(actual)")
            allPassed = false
        }
    }
    
    if allPassed {
        print("✓ Project Complete! Excellent work.\n")
        return true
    } else {
        print("✗ Some tests failed. Keep working!")
        return false
    }
}

func firstProject(forPass pass: Int, in projects: [Project]) -> Project? {
    return projects.first { $0.pass == pass }
}

func makeSteps(
    core1Challenges: [Challenge],
    core2Challenges: [Challenge],
    core3Challenges: [Challenge],
    projects: [Project]
) -> [Step] {
    var steps: [Step] = []
    steps.append(contentsOf: core1Challenges.map { Step.challenge($0) })
    if let core1Project = firstProject(forPass: 1, in: projects) {
        steps.append(.project(core1Project))
    }
    steps.append(contentsOf: core2Challenges.map { Step.challenge($0) })
    if let core2Project = firstProject(forPass: 2, in: projects) {
        steps.append(.project(core2Project))
    }
    steps.append(contentsOf: core3Challenges.map { Step.challenge($0) })
    if let core3Project = firstProject(forPass: 3, in: projects) {
        steps.append(.project(core3Project))
    }
    return steps
}

func nextStepPrompt(for step: Step) -> String {
    switch step {
    case .challenge:
        return "→ Moving to next challenge...\n"
    case .project:
        return "→ Time for your project...\n"
    }
}

func runProject(_ project: Project) -> Bool {
    loadProject(project)
    
    let workspacePath = "workspace/\(project.filename)"
    let fileManager = FileManager.default
    var lastModified = try? fileManager.attributesOfItem(atPath: workspacePath)[.modificationDate] as? Date
    
    while true {
        usleep(500_000)
        
        guard
            let currentModified = try? fileManager.attributesOfItem(atPath: workspacePath)[.modificationDate] as? Date
        else {
            continue
        }
        
        if currentModified != lastModified {
            // Debounce
            var stableCount = 0
            var lastSeen = currentModified
            while stableCount < 2 {
                usleep(200_000)
                guard
                    let modified = try? fileManager.attributesOfItem(atPath: workspacePath)[.modificationDate] as? Date
                else {
                    stableCount = 0
                    continue
                }
                
                if modified == lastSeen {
                    stableCount += 1
                } else {
                    lastSeen = modified
                    stableCount = 0
                }
            }
            
            lastModified = currentModified
            print("\n--- Testing your project... ---\n")
            
            if validateProject(project) {
                sleep(2)
                return true
            }
        }
    }
}

func normalizedStepIndex(_ rawProgress: Int, stepsCount: Int) -> Int {
    if rawProgress == 999 {
        return stepsCount + 1
    }
    if rawProgress <= 0 {
        return 1
    }
    if rawProgress > stepsCount {
        return stepsCount + 1
    }
    return rawProgress
}

func parseProgressTarget(_ token: String, projects: [Project]) -> ProgressTarget {
    let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed == "999" {
        return .completed
    }
    let lowered = trimmed.lowercased()
    if lowered.hasPrefix("challenge:") {
        let value = String(trimmed.dropFirst("challenge:".count))
        if let number = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return .challenge(number)
        }
    }
    if lowered.hasPrefix("project:") {
        let projectId = String(trimmed.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        return .project(projectId.lowercased())
    }
    if let number = Int(trimmed) {
        return .step(number)
    }
    let projectIdRaw = trimmed
    let projectId = projectIdRaw.lowercased()
    if projects.contains(where: { $0.id.lowercased() == projectId }) {
        return .project(projectId)
    }
    return .step(1)
}

func challengeStepIndexMap(for steps: [Step]) -> [Int: Int] {
    var map: [Int: Int] = [:]
    for (index, step) in steps.enumerated() {
        if case .challenge(let challenge) = step {
            map[challenge.number] = index + 1
        }
    }
    return map
}

func projectStepIndexMap(for steps: [Step]) -> [String: Int] {
    var map: [String: Int] = [:]
    for (index, step) in steps.enumerated() {
        if case .project(let project) = step {
            map[project.id] = index + 1
        }
    }
    return map
}

func stepIndexForChallenge(
    _ challengeNumber: Int,
    challengeStepIndex: [Int: Int],
    maxChallengeNumber: Int,
    stepsCount: Int
) -> Int {
    if challengeNumber <= 0 {
        return 1
    }
    if challengeNumber > maxChallengeNumber {
        return stepsCount + 1
    }
    return challengeStepIndex[challengeNumber] ?? 1
}

@main
struct Forge {
    static func main() {
        // Check for reset command
        if CommandLine.arguments.count > 1 && CommandLine.arguments[1] == "reset" {
            setupWorkspace()
            resetProgress()
            // Don't return - continue to run challenges
        }
        
        let core1Challenges = makeCore1Challenges()
        let core2Challenges = makeCore2Challenges()
        let core3Challenges = makeCore3Challenges()
        let projects = makeProjects()
        let steps = makeSteps(
            core1Challenges: core1Challenges,
            core2Challenges: core2Challenges,
            core3Challenges: core3Challenges,
            projects: projects
        )
        let challengeIndexMap = challengeStepIndexMap(for: steps)
        let projectIndexMap = projectStepIndexMap(for: steps)
        let maxChallengeNumber = max(core1Challenges.count + core2Challenges.count + core3Challenges.count, 1)

        setupWorkspace()

        let progressToken = getProgressToken() ?? "1"
        let progressTarget = parseProgressTarget(progressToken, projects: projects)
        let startIndex: Int
        switch progressTarget {
        case .completed:
            startIndex = steps.count + 1
        case .project(let projectId):
            startIndex = projectIndexMap[projectId] ?? 1
        case .challenge(let number):
            startIndex = stepIndexForChallenge(
                number,
                challengeStepIndex: challengeIndexMap,
                maxChallengeNumber: maxChallengeNumber,
                stepsCount: steps.count
            )
        case .step(let rawProgress):
            startIndex = normalizedStepIndex(rawProgress, stepsCount: steps.count)
        }

        // Show welcome only on first run
        if startIndex == 1 {
            clearScreen()
            displayWelcome()
        }

        clearScreen()
        print("Let's forge something great.\n")

        if startIndex <= steps.count {
            runSteps(steps, startingAt: startIndex)
        } else {
            print("🎉 You've completed everything!")
            print("Run 'swift run forge reset' to start over.\n")
        }
    }
}
