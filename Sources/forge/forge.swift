// forge.swift

import Foundation

enum Step {
    case challenge(Challenge)
    case project(Project)
}

enum ProgressTarget {
    case challenge(Int)
    case challengeId(String)
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

func setupWorkspace(at workspacePath: String = "workspace") {
    let fileManager = FileManager.default

    // Create workspace directory if it doesn't exist
    if !fileManager.fileExists(atPath: workspacePath) {
        try? fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
    }
}

func clearWorkspaceContents(at workspacePath: String) {
    if let files = try? FileManager.default.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            try? FileManager.default.removeItem(atPath: "\(workspacePath)/\(file)")
        }
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

func getCurrentProgress(workspacePath: String = "workspace") -> Int {
    guard let token = getProgressToken(workspacePath: workspacePath),
        let value = Int(token.trimmingCharacters(in: .whitespacesAndNewlines))
    else {
        return 1
    }

    return value
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
    
    // Delete all generated Swift files in workspace
    if let files = try? fileManager.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            if file.hasSuffix(".swift") {
                try? fileManager.removeItem(atPath: "\(workspacePath)/\(file)")
            }
        }
    }
    
    print("✓ Progress reset! Starting from Challenge 1.\n")
}

func loadChallenge(_ challenge: Challenge, workspacePath: String = "workspace") {
    let filePath = "\(workspacePath)/\(challenge.filename)"

    // Write challenge file
    let content = "\(challenge.starterCode)\n"

    try? content.write(toFile: filePath, atomically: true, encoding: .utf8)

    let checkMessage = challenge.manualCheck
        ? "Manual check: run 'swift \(filePath)' yourself, then press Enter to mark complete."
        : "Press Enter to check your work."

    print(
        """

        Challenge \(challenge.displayId): \(challenge.title)
        └─ \(challenge.description)

        Edit: \(filePath)

        \(checkMessage)
        Type 'h' for a hint, 'c' for a cheatsheet, or 's' for the solution.
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

func compileAndRunWithTimeout(file: String, timeoutSeconds: TimeInterval) -> (output: String?, timedOut: Bool, exitCode: Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    process.arguments = [file]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        let start = Date()
        while process.isRunning {
            if Date().timeIntervalSince(start) > timeoutSeconds {
                process.terminate()
                return (nil, true, -1)
            }
            usleep(50_000)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (output, false, process.terminationStatus)
    } catch {
        return (nil, false, -1)
    }
}

func applySolutionToStarter(starterCode: String, solution: String) -> String {
    var lines = starterCode.components(separatedBy: "\n")
    if let index = lines.firstIndex(where: { $0.contains("// TODO:") }) {
        let indent = lines[index].prefix { $0 == " " || $0 == "\t" }
        let solutionLines = solution.components(separatedBy: "\n").map { line in
            line.isEmpty ? "" : "\(indent)\(line)"
        }
        lines.replaceSubrange(index...index, with: solutionLines)
        return lines.joined(separator: "\n")
    }
    return starterCode + "\n" + solution + "\n"
}

func skipReasonForVerification(starterCode: String, solution: String) -> String? {
    let combined = starterCode + "\n" + solution
    if combined.contains("readLine(") {
        return "requires stdin"
    }
    if combined.contains("CommandLine.arguments") {
        return "requires arguments"
    }
    if combined.contains("contentsOfFile") || combined.contains("FileHandle") || combined.contains("FileManager") {
        return "requires file IO"
    }
    return nil
}

func verifyChallengeSolutions(_ challenges: [Challenge]) -> Bool {
    let workspacePath = "workspace_verify"
    setupWorkspace(at: workspacePath)
    clearWorkspaceContents(at: workspacePath)

    var failures: [(id: String, reason: String)] = []
    var skipped = 0
    var skippedReasons: [String: Int] = [:]
    var checked = 0

    print("Verifying \(challenges.count) challenge solution(s)...")

    for (index, challenge) in challenges.enumerated() {
        if challenge.manualCheck {
            skipped += 1
            skippedReasons["manual check", default: 0] += 1
            continue
        }
        let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
        if solution.isEmpty {
            skipped += 1
            skippedReasons["missing solution", default: 0] += 1
            continue
        }
        if let reason = skipReasonForVerification(starterCode: challenge.starterCode, solution: solution) {
            skipped += 1
            skippedReasons[reason, default: 0] += 1
            continue
        }

        let filePath = "\(workspacePath)/\(challenge.filename)"
        let expected = challenge.expectedOutput

        var passed = false
        var lastExitCode: Int32 = 0
        try? solution.write(toFile: filePath, atomically: true, encoding: .utf8)
        let firstRun = compileAndRunWithTimeout(file: filePath, timeoutSeconds: 2.0)
        if firstRun.timedOut {
            failures.append((challenge.displayId, "timeout"))
            continue
        }
        lastExitCode = firstRun.exitCode
        if let output = firstRun.output, isExpectedOutput(output, expected: expected) {
            passed = true
        }

        if !passed {
            let combined = applySolutionToStarter(starterCode: challenge.starterCode, solution: solution)
            try? combined.write(toFile: filePath, atomically: true, encoding: .utf8)
            let secondRun = compileAndRunWithTimeout(file: filePath, timeoutSeconds: 2.0)
            if secondRun.timedOut {
                failures.append((challenge.displayId, "timeout"))
                continue
            }
            lastExitCode = secondRun.exitCode
            if let output = secondRun.output, isExpectedOutput(output, expected: expected) {
                passed = true
            }
        }

        if !passed {
            let exitCode = max(lastExitCode, 0)
            let reason = exitCode == 0 ? "output mismatch" : "compile/runtime error"
            failures.append((challenge.displayId, reason))
        } else {
            checked += 1
        }

        if (index + 1) % 10 == 0 {
            print("Checked \(index + 1)/\(challenges.count)...")
        }
    }

    if failures.isEmpty {
        print("✓ Verified solutions: \(challenges.count - skipped)")
        if skipped > 0 {
            let reasons = skippedReasons.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", ")
            print("Skipped: \(skipped) (\(reasons))")
        }
        return true
    }

    print("✗ Solution verification failed for \(failures.count) challenge(s).")
    for failure in failures {
        print("- \(failure.id): \(failure.reason)")
    }
    if skipped > 0 {
        let reasons = skippedReasons.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", ")
        print("Skipped: \(skipped) (\(reasons))")
    }
    return false
}

func isExpectedOutput(_ output: String, expected: String) -> Bool {
    let normalizedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalizedOutput == normalizedExpected
}

func validateChallenge(_ challenge: Challenge, nextStepIndex: Int, workspacePath: String = "workspace") -> Bool {
    let filePath = "\(workspacePath)/\(challenge.filename)"

    if challenge.manualCheck {
        print("Manual check: forge does not auto-validate this challenge.")
        saveProgress(nextStepIndex)
        print("✓ Challenge marked complete.\n")
        return true
    }

    guard let output = compileAndRun(file: filePath) else {
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
            var hintIndex = 0
            var challengeComplete = false
            while !challengeComplete {
                print("> ", terminator: "")
                let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

                if input == "h" {
                    if challenge.hints.isEmpty {
                        print("No hints available yet.\n")
                    } else if hintIndex < challenge.hints.count {
                        print("Hint \(hintIndex + 1)/\(challenge.hints.count):")
                        print("\(challenge.hints[hintIndex])\n")
                        hintIndex += 1
                    } else {
                        print("No more hints.\n")
                    }
                    continue
                }

                if input == "c" {
                    let cheatsheet = challenge.cheatsheet.trimmingCharacters(in: .whitespacesAndNewlines)
                    if cheatsheet.isEmpty {
                        print("Cheatsheet not available yet.\n")
                    } else {
                        print("Cheatsheet:\n\(cheatsheet)\n")
                    }
                    continue
                }

                if input == "s" {
                    let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
                    if solution.isEmpty {
                        print("Solution not available yet.\n")
                    } else {
                        print("Solution:\n\(solution)\n")
                    }
                    continue
                }

                if !input.isEmpty {
                    print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 's' for solution.\n")
                    continue
                }

                if challenge.manualCheck {
                    print("\n--- Manual check ---\n")
                } else {
                    print("\n--- Testing your code... ---\n")
                }

                let nextStepIndex = currentIndex + 2
                if validateChallenge(challenge, nextStepIndex: nextStepIndex) {
                    challengeComplete = true
                    currentIndex += 1

                    if currentIndex < steps.count {
                        let prompt = nextStepPrompt(for: steps[currentIndex])
                        if !prompt.isEmpty {
                            print(prompt)
                        }
                        if case .challenge = steps[currentIndex] {
                            waitForEnterToContinue()
                            clearScreen()
                        }
                    } else {
                        saveProgress(999)
                        print("🎉 You've completed everything!")
                        print("Run 'swift run forge reset' to start over.\n")
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
                    let prompt = nextStepPrompt(for: steps[currentIndex])
                    if !prompt.isEmpty {
                        print(prompt)
                    }
                    if case .project = steps[currentIndex] {
                        sleep(2)
                        clearScreen()
                    }
                    if case .challenge = steps[currentIndex] {
                        waitForEnterToContinue()
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

func loadProject(_ project: Project, workspacePath: String = "workspace") -> String {
    let filePath = "\(workspacePath)/\(project.filename)"

    try? project.starterCode.write(toFile: filePath, atomically: true, encoding: .utf8)

    print(
        """

        🛠️ Project: \(project.title)
        └─ \(project.description)

        Edit: \(filePath)

        This project is checked against expected outputs. Build something that works!
        Press Enter to check your work.
        Type 'h' for a hint, 'c' for a cheatsheet, or 's' for the solution.
        """)
    return filePath
}

func validateProject(_ project: Project, workspacePath: String = "workspace") -> Bool {
    let filePath = "\(workspacePath)/\(project.filename)"

    guard let output = compileAndRun(file: filePath) else {
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
    return projects.first { $0.pass == pass && $0.tier == .mainline }
}

func makeSteps(
    core1Challenges: [Challenge],
    core2Challenges: [Challenge],
    core3Challenges: [Challenge],
    mantleChallenges: [Challenge],
    crustChallenges: [Challenge],
    projects: [Project]
) -> [Step] {
    let core1Only = core1Challenges.filter { $0.tier == .mainline }
    let core2Only = core2Challenges.filter { $0.tier == .mainline }
    let core3Only = core3Challenges.filter { $0.tier == .mainline }
    let mantleOnly = mantleChallenges.filter { $0.tier == .mainline }
    let crustOnly = crustChallenges.filter { $0.tier == .mainline }
    let mantle1Only = mantleOnly.filter { $0.number >= 121 && $0.number <= 134 }
    let mantle2Only = mantleOnly.filter { $0.number >= 135 && $0.number <= 144 }
    let mantle3Only = mantleOnly.filter { $0.number >= 145 && $0.number <= 153 }
    let crust1Only = crustOnly.filter { $0.number >= 172 && $0.number <= 189 }
    let crust2Only = crustOnly.filter { $0.number >= 190 && $0.number <= 207 }
    let crust3Only = crustOnly.filter { $0.number >= 208 && $0.number <= 225 }

    var steps: [Step] = []
    steps.append(contentsOf: core1Only.map { Step.challenge($0) })
    if let core1Project = firstProject(forPass: 1, in: projects) {
        steps.append(.project(core1Project))
    }
    steps.append(contentsOf: core2Only.map { Step.challenge($0) })
    if let core2Project = firstProject(forPass: 2, in: projects) {
        steps.append(.project(core2Project))
    }
    steps.append(contentsOf: core3Only.map { Step.challenge($0) })
    if let core3Project = firstProject(forPass: 3, in: projects) {
        steps.append(.project(core3Project))
    }
    steps.append(contentsOf: mantle1Only.map { Step.challenge($0) })
    if let mantle1Project = firstProject(forPass: 4, in: projects) {
        steps.append(.project(mantle1Project))
    }
    steps.append(contentsOf: mantle2Only.map { Step.challenge($0) })
    if let mantle2Project = firstProject(forPass: 5, in: projects) {
        steps.append(.project(mantle2Project))
    }
    steps.append(contentsOf: mantle3Only.map { Step.challenge($0) })
    if let mantle3Project = firstProject(forPass: 6, in: projects) {
        steps.append(.project(mantle3Project))
    }
    steps.append(contentsOf: crust1Only.map { Step.challenge($0) })
    if let crust1Project = firstProject(forPass: 7, in: projects) {
        steps.append(.project(crust1Project))
    }
    steps.append(contentsOf: crust2Only.map { Step.challenge($0) })
    if let crust2Project = firstProject(forPass: 8, in: projects) {
        steps.append(.project(crust2Project))
    }
    steps.append(contentsOf: crust3Only.map { Step.challenge($0) })
    if let crust3Project = firstProject(forPass: 9, in: projects) {
        steps.append(.project(crust3Project))
    }
    return steps
}

func nextStepPrompt(for step: Step) -> String {
    switch step {
    case .challenge:
        return ""
    case .project:
        return "→ Time for your project...\n"
    }
}

func waitForEnterToContinue() {
    print("Press Enter to continue.")
    _ = readLine()
}

func printMainUsage() {
    print("""
    Usage:
      swift run forge
      swift run forge reset
      swift run forge random [count] [topic] [tier] [layer]
      swift run forge project <id>
      swift run forge verify-solutions
      swift run forge --help

    Try:
      swift run forge random --help
      swift run forge project --help
      swift run forge verify-solutions crust
      swift run forge verify-solutions 190-237
    """)
}

func printRandomUsage() {
    print("""
    Usage: swift run forge random [count] [topic] [tier] [layer]

    Topics: conditionals, loops, optionals, collections, functions, strings, structs, general
    Tiers: mainline, extra
    Layers: core, mantle, crust

    Examples:
      swift run forge random 8
      swift run forge random conditionals
      swift run forge random 6 loops extra
      swift run forge random 10 mantle
      swift run forge random 12 mainline
    """)
}

func printProjectUsage() {
    print("""
    Usage:
      swift run forge project <id>
      swift run forge project --list [tier] [layer]
      swift run forge project --random [tier] [layer]

    Tiers: mainline, extra
    Layers: core, mantle, crust

    Examples:
      swift run forge project core2b
      swift run forge project --list
      swift run forge project --list extra
      swift run forge project --list mantle
      swift run forge project --random
      swift run forge project --random extra mantle
    """)
}

func parseRandomArguments(
    _ args: [String]
) -> (count: Int, topic: ChallengeTopic?, tier: ChallengeTier?, layer: ChallengeLayer?) {
    var count = 5
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?

    for value in args {
        if let number = Int(value) {
            count = max(number, 1)
            continue
        }
        let lowered = value.lowercased()
        if lowered == "help" || lowered == "-h" || lowered == "--help" {
            continue
        }
        if let parsedTopic = ChallengeTopic(rawValue: lowered) {
            topic = parsedTopic
            continue
        }
        if let parsedTier = ChallengeTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ChallengeLayer(rawValue: lowered) {
            layer = parsedLayer
        }
    }

    return (count, topic, tier, layer)
}

func parseVerifyArguments(
    _ args: [String]
) -> (range: ClosedRange<Int>?, topic: ChallengeTopic?, tier: ChallengeTier?, layer: ChallengeLayer?) {
    var range: ClosedRange<Int>?
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?

    for value in args {
        let lowered = value.lowercased()
        if ["help", "-h", "--help"].contains(lowered) {
            continue
        }
        if let parsedTopic = ChallengeTopic(rawValue: lowered) {
            topic = parsedTopic
            continue
        }
        if let parsedTier = ChallengeTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ChallengeLayer(rawValue: lowered) {
            layer = parsedLayer
            continue
        }
        if let number = Int(lowered) {
            range = number...number
            continue
        }
        if let dashIndex = lowered.firstIndex(of: "-") {
            let startPart = String(lowered[..<dashIndex])
            let endPart = String(lowered[lowered.index(after: dashIndex)...])
            if let start = Int(startPart), let end = Int(endPart), start <= end {
                range = start...end
            }
        }
    }

    return (range, topic, tier, layer)
}

func parseProjectListArguments(_ args: [String]) -> (tier: ProjectTier?, layer: ProjectLayer?) {
    var tier: ProjectTier?
    var layer: ProjectLayer?

    for value in args {
        let lowered = value.lowercased()
        if let parsedTier = ProjectTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ProjectLayer(rawValue: lowered) {
            layer = parsedLayer
        }
    }

    return (tier, layer)
}

func parseProjectRandomArguments(_ args: [String]) -> (tier: ProjectTier?, layer: ProjectLayer?) {
    return parseProjectListArguments(args)
}

func printProjectList(_ projects: [Project], tier: ProjectTier?, layer: ProjectLayer?) {
    var pool = projects
    if let tier = tier {
        pool = pool.filter { $0.tier == tier }
    }
    if let layer = layer {
        pool = pool.filter { $0.layer == layer }
    }

    if pool.isEmpty {
        print("No projects match those filters.")
        return
    }

    print("Projects:")
    for project in pool {
        print("- \(project.id): \(project.title) (\(project.tier.rawValue), \(project.layer.rawValue))")
    }
}

func pickRandomProject(
    _ projects: [Project],
    tier: ProjectTier?,
    layer: ProjectLayer?
) -> Project? {
    var pool = projects
    if let tier = tier {
        pool = pool.filter { $0.tier == tier }
    }
    if let layer = layer {
        pool = pool.filter { $0.layer == layer }
    }
    return pool.randomElement()
}

func runPracticeChallenges(_ challenges: [Challenge], workspacePath: String) {
    var completedFiles: [String] = []

    for (index, challenge) in challenges.enumerated() {
        loadChallenge(challenge, workspacePath: workspacePath)
        var hintIndex = 0
        var challengeComplete = false

        while !challengeComplete {
            print("> ", terminator: "")
            let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

            if input == "h" {
                if challenge.hints.isEmpty {
                    print("No hints available yet.\n")
                } else if hintIndex < challenge.hints.count {
                    print("Hint \(hintIndex + 1)/\(challenge.hints.count):")
                    print("\(challenge.hints[hintIndex])\n")
                    hintIndex += 1
                } else {
                    print("No more hints.\n")
                }
                continue
            }

            if input == "c" {
                let cheatsheet = challenge.cheatsheet.trimmingCharacters(in: .whitespacesAndNewlines)
                if cheatsheet.isEmpty {
                    print("Cheatsheet not available yet.\n")
                } else {
                    print("Cheatsheet:\n\(cheatsheet)\n")
                }
                continue
            }

            if input == "s" {
                let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
                if solution.isEmpty {
                    print("Solution not available yet.\n")
                } else {
                    print("Solution:\n\(solution)\n")
                }
                continue
            }

            if !input.isEmpty {
                print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 's' for solution.\n")
                continue
            }

            if challenge.manualCheck {
                print("\n--- Manual check ---\n")
                print("Manual check: forge does not auto-validate this challenge.")
                print("✓ Challenge marked complete.\n")
                completedFiles.append("\(workspacePath)/\(challenge.filename)")
                challengeComplete = true
            } else {
                print("\n--- Testing your code... ---\n")
                guard let output = compileAndRun(file: "\(workspacePath)/\(challenge.filename)") else {
                    print("✗ Compilation failed. Check your code.")
                    continue
                }

                print("Output: \(output)\n")

                if isExpectedOutput(output, expected: challenge.expectedOutput) {
                    print("✓ Challenge Complete! Well done.\n")
                    completedFiles.append("\(workspacePath)/\(challenge.filename)")
                    challengeComplete = true
                } else {
                    print("✗ Output doesn't match.")
                    print("Expected: \(challenge.expectedOutput)")
                }
            }
        }

        if index < challenges.count - 1 {
            print("Press Enter for the next random challenge.")
            _ = readLine()
            clearScreen()
        }
    }

    print("✅ Random set complete!")
    print("Press Enter to finish.\n")
    _ = readLine()
    for filePath in completedFiles {
        try? FileManager.default.removeItem(atPath: filePath)
    }
    if let files = try? FileManager.default.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            try? FileManager.default.removeItem(atPath: "\(workspacePath)/\(file)")
        }
    }
}

func runProject(_ project: Project, workspacePath: String = "workspace") -> Bool {
    _ = loadProject(project, workspacePath: workspacePath)

    var hintIndex = 0
    while true {
        print("> ", terminator: "")
        let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

        if input == "h" {
            if project.hints.isEmpty {
                print("No hints available yet.\n")
            } else if hintIndex < project.hints.count {
                print("Hint \(hintIndex + 1)/\(project.hints.count):")
                print("\(project.hints[hintIndex])\n")
                hintIndex += 1
            } else {
                print("No more hints.\n")
            }
            continue
        }

        if input == "c" {
            let cheatsheet = project.cheatsheet.trimmingCharacters(in: .whitespacesAndNewlines)
            if cheatsheet.isEmpty {
                print("Cheatsheet not available yet.\n")
            } else {
                print("Cheatsheet:\n\(cheatsheet)\n")
            }
            continue
        }

        if input == "s" {
            let solution = project.solution.trimmingCharacters(in: .whitespacesAndNewlines)
            if solution.isEmpty {
                print("Solution not available yet.\n")
            } else {
                print("Solution:\n\(solution)\n")
            }
            continue
        }

        if !input.isEmpty {
            print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 's' for solution.\n")
            continue
        }

        print("\n--- Testing your project... ---\n")

        if validateProject(project, workspacePath: workspacePath) {
            sleep(2)
            return true
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
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(trimmedValue) {
            return .challenge(number)
        }
        return .challengeId(trimmedValue.lowercased())
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

func challengeIdStepIndexMap(for steps: [Step]) -> [String: Int] {
    var map: [String: Int] = [:]
    for (index, step) in steps.enumerated() {
        if case .challenge(let challenge) = step {
            map[challenge.progressId.lowercased()] = index + 1
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
        let practiceWorkspace = "workspace_random"
        let projectWorkspace = "workspace_projects"

        if CommandLine.arguments.count > 1 {
            let firstArg = CommandLine.arguments[1].lowercased()
            if ["help", "-h", "--help"].contains(firstArg) {
                printMainUsage()
                return
            }
        }

        let overrideToken: String? = {
            guard CommandLine.arguments.count > 1 else { return nil }
            let arg = CommandLine.arguments[1]
            let lowered = arg.lowercased()
            if ["reset", "random", "project", "verify-solutions", "verify"].contains(lowered) {
                return nil
            }
            if ["help", "-h", "--help"].contains(lowered) {
                return nil
            }
            return arg
        }()

        // Check for reset command
        if CommandLine.arguments.count > 1 && CommandLine.arguments[1] == "reset" {
            setupWorkspace()
            resetProgress()
            // Don't return - continue to run challenges
        }

        let core1Challenges = makeCore1Challenges()
        let core2Challenges = makeCore2Challenges()
        let core3Challenges = makeCore3Challenges()
        let mantleChallenges = makeMantleChallenges()
        let crustChallenges = makeCrustChallenges()
        let projects = makeProjects()

        if CommandLine.arguments.count > 1 {
            let firstArg = CommandLine.arguments[1].lowercased()
            if ["verify-solutions", "verify"].contains(firstArg) {
                let args = Array(CommandLine.arguments.dropFirst(2))
                let (range, topic, tier, layer) = parseVerifyArguments(args)
                var pool = core1Challenges + core2Challenges + core3Challenges + mantleChallenges + crustChallenges
                if let range = range {
                    pool = pool.filter { range.contains($0.number) }
                }
                if let topic = topic {
                    pool = pool.filter { $0.topic == topic }
                }
                if let tier = tier {
                    pool = pool.filter { $0.tier == tier }
                }
                if let layer = layer {
                    pool = pool.filter { $0.layer == layer }
                }
                if pool.isEmpty {
                    print("No challenges match those filters.")
                    return
                }
                _ = verifyChallengeSolutions(pool)
                return
            }
        }

        if CommandLine.arguments.count > 1 && CommandLine.arguments[1] == "random" {
            setupWorkspace(at: practiceWorkspace)
            setupWorkspace(at: projectWorkspace)
            clearWorkspaceContents(at: practiceWorkspace)
            clearWorkspaceContents(at: projectWorkspace)
            let args = Array(CommandLine.arguments.dropFirst(2))
            if args.contains(where: { ["help", "-h", "--help"].contains($0.lowercased()) }) {
                printRandomUsage()
                return
            }
            let (count, topic, tier, layer) = parseRandomArguments(args)
            var pool = core1Challenges + core2Challenges + core3Challenges + mantleChallenges + crustChallenges

            if let topic = topic {
                pool = pool.filter { $0.topic == topic }
            }
            if let tier = tier {
                pool = pool.filter { $0.tier == tier }
            }
            if let layer = layer {
                pool = pool.filter { $0.layer == layer }
            }

            if pool.isEmpty {
                print("No challenges match those filters.")
                return
            }

            let selectionCount = min(count, pool.count)
            let selection = Array(pool.shuffled().prefix(selectionCount))
            clearScreen()
            print("Random mode: \(selectionCount) challenge(s).")
            print("Workspace: \(practiceWorkspace)\n")
            runPracticeChallenges(selection, workspacePath: practiceWorkspace)
            return
        }

        if CommandLine.arguments.count > 1 && CommandLine.arguments[1] == "project" {
            setupWorkspace(at: projectWorkspace)
            setupWorkspace(at: practiceWorkspace)
            clearWorkspaceContents(at: projectWorkspace)
            clearWorkspaceContents(at: practiceWorkspace)
            guard CommandLine.arguments.count > 2 else {
                printProjectUsage()
                return
            }
            let projectCommand = CommandLine.arguments[2].lowercased()
            if ["--help", "-h", "help"].contains(projectCommand) {
                printProjectUsage()
                return
            }
            if ["--list", "-l", "list"].contains(projectCommand) {
                let args = Array(CommandLine.arguments.dropFirst(3))
                let (tier, layer) = parseProjectListArguments(args)
                printProjectList(projects, tier: tier, layer: layer)
                return
            }
            if ["--random", "-r", "random"].contains(projectCommand) {
                let args = Array(CommandLine.arguments.dropFirst(3))
                let (tier, layer) = parseProjectRandomArguments(args)
                guard let project = pickRandomProject(projects, tier: tier, layer: layer) else {
                    print("No projects match those filters.")
                    return
                }
                clearScreen()
                print("Project mode: \(project.title)")
                print("Workspace: \(projectWorkspace)\n")
                let completed = runProject(project, workspacePath: projectWorkspace)
                print("Press Enter to finish.\n")
                _ = readLine()
                if completed {
                    try? FileManager.default.removeItem(atPath: "\(projectWorkspace)/\(project.filename)")
                }
                return
            }
            let projectId = projectCommand
            guard let project = projects.first(where: { $0.id.lowercased() == projectId }) else {
                print("Unknown project id: \(projectId)")
                print("Try: swift run forge project --help")
                return
            }
            clearScreen()
            print("Project mode: \(project.title)")
            print("Workspace: \(projectWorkspace)\n")
            let completed = runProject(project, workspacePath: projectWorkspace)
            print("Press Enter to finish.\n")
            _ = readLine()
            if completed {
                try? FileManager.default.removeItem(atPath: "\(projectWorkspace)/\(project.filename)")
            }
            return
        }

        let steps = makeSteps(
            core1Challenges: core1Challenges,
            core2Challenges: core2Challenges,
            core3Challenges: core3Challenges,
            mantleChallenges: mantleChallenges,
            crustChallenges: crustChallenges,
            projects: projects
        )
        let challengeIndexMap = challengeStepIndexMap(for: steps)
        let challengeIdIndexMap = challengeIdStepIndexMap(for: steps)
        let allChallenges = core1Challenges + core2Challenges + core3Challenges + mantleChallenges + crustChallenges
        let allChallengeIdMap = Dictionary(uniqueKeysWithValues: allChallenges.map { ($0.progressId.lowercased(), $0) })
        let allChallengeNumberMap = Dictionary(uniqueKeysWithValues: allChallenges.map { ($0.number, $0) })
        let projectIndexMap = projectStepIndexMap(for: steps)
        let maxChallengeNumber = max(
            steps.compactMap { step in
                if case .challenge(let challenge) = step { return challenge.number }
                return nil
            }.max() ?? 1,
            1
        )

        setupWorkspace()
        setupWorkspace(at: practiceWorkspace)
        setupWorkspace(at: projectWorkspace)
        clearWorkspaceContents(at: practiceWorkspace)
        clearWorkspaceContents(at: projectWorkspace)

        let progressToken = overrideToken ?? getProgressToken() ?? "1"
        let progressTarget = parseProgressTarget(progressToken, projects: projects)
        let startIndex: Int
        var extraNotice: String? = nil
        switch progressTarget {
        case .completed:
            startIndex = steps.count + 1
        case .project(let projectId):
            startIndex = projectIndexMap[projectId] ?? 1
        case .challenge(let number):
            if let index = challengeIndexMap[number] {
                startIndex = index
            } else if let extraChallenge = allChallengeNumberMap[number], extraChallenge.tier == .extra {
                extraNotice = "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras."
                startIndex = steps.count + 1
            } else {
                startIndex = stepIndexForChallenge(
                    number,
                    challengeStepIndex: challengeIndexMap,
                    maxChallengeNumber: maxChallengeNumber,
                    stepsCount: steps.count
                )
            }
        case .challengeId(let id):
            if let index = challengeIdIndexMap[id.lowercased()] {
                startIndex = index
            } else if let extraChallenge = allChallengeIdMap[id.lowercased()], extraChallenge.tier == .extra {
                extraNotice = "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras."
                startIndex = steps.count + 1
            } else {
                startIndex = 1
            }
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
            if let extraNotice = extraNotice {
                print(extraNotice)
            }
            print("🎉 You've completed everything!")
            print("Run 'swift run forge reset' to start over.\n")
        }
    }
}
