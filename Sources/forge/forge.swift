// forge.swift

import Foundation

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

func getCurrentProgress(workspacePath: String = "workspace") -> Int {
    let progressFile = progressFilePath(workspacePath: workspacePath)

    if let content = try? String(contentsOfFile: progressFile, encoding: .utf8),
        let progress = Int(content.trimmingCharacters(in: .whitespacesAndNewlines))
    {
        return progress
    }

    return 1  // Start at challenge 1
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
    
    // Delete all challenge files
    if let files = try? fileManager.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            if file.hasPrefix("challenge") && file.hasSuffix(".swift") {
                try? fileManager.removeItem(atPath: "\(workspacePath)/\(file)")
            }
        }
    }
    
    print("✓ Progress reset! Starting from Challenge 1.\n")
}

func loadChallenge(_ challenge: Challenge) {
    let workspacePath = "workspace/\(challenge.filename)"

    // Write challenge file
    let content = """
        // Challenge \(challenge.number): \(challenge.title)
        // \(challenge.description)

        \(challenge.starterCode)
        """

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

func validateChallenge(_ challenge: Challenge, challenges: [Challenge]) -> Bool {
    let workspacePath = "workspace/\(challenge.filename)"

    guard let output = compileAndRun(file: workspacePath) else {
        print("✗ Compilation failed. Check your code.")
        return false
    }

    // Show what the code printed
    print("Output: \(output)\n")

    if isExpectedOutput(output, expected: challenge.expectedOutput) {
        print("✓ Challenge Complete! Well done.\n")

        // Save progress to next challenge
        let nextChallengeNum = challenge.number + 1
        saveProgress(nextChallengeNum)

        return true
    } else {
        print("✗ Output doesn't match.")
        print("Expected: \(challenge.expectedOutput)")
        return false
    }
}

func runChallenges(_ challenges: [Challenge], startingAt: Int) {
    var currentIndex = startingAt - 1

    while currentIndex < challenges.count {
        let challenge = challenges[currentIndex]
        loadChallenge(challenge)

        let workspacePath = "workspace/\(challenge.filename)"
        let fileManager = FileManager.default
        var lastModified =
            try? fileManager.attributesOfItem(atPath: workspacePath)[.modificationDate] as? Date

        // Watch for changes
        var challengeComplete = false
        while !challengeComplete {
            usleep(500_000)  // Check every 0.5 seconds

            guard
                let currentModified = try? fileManager.attributesOfItem(atPath: workspacePath)[
                    .modificationDate]
                as? Date
            else {
                continue
            }

            if currentModified != lastModified {
                // Debounce to avoid validating mid-write (common with editors that save via temp files).
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

                if validateChallenge(challenge, challenges: challenges) {
                    challengeComplete = true
                    currentIndex += 1

                    if currentIndex < challenges.count {
                        sleep(2)  // Brief pause before next challenge
                        print("→ Moving to next challenge...\n")
                    }
                }
            }
        }
    }

    print("🎉 You've completed all challenges! You're a Swift master.\n")
    print("Run 'swift run forge reset' to start over.\n")
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
        
        let challenges = makeChallenges()

        setupWorkspace()

        let currentProgress = getCurrentProgress()

        // Show welcome only on first run
        if currentProgress == 1 {
            clearScreen()
            displayWelcome()
        }

        clearScreen()
        print("Let's forge something great.\n")

        guard currentProgress <= challenges.count else {
            print("🎉 You've completed all challenges!")
            print("Run 'swift run forge reset' to start over.\n")
            return
        }

        runChallenges(challenges, startingAt: currentProgress)
    }
}
