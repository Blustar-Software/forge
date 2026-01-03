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

struct Challenge {
    let number: Int
    let title: String
    let description: String
    let starterCode: String
    let expectedOutput: String

    var filename: String {
        return "challenge\(number).swift"
    }
}

func setupWorkspace() {
    let fileManager = FileManager.default
    let workspacePath = "workspace"

    // Create workspace directory if it doesn't exist
    if !fileManager.fileExists(atPath: workspacePath) {
        try? fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
    }
}

func getCurrentProgress() -> Int {
    let progressFile = "workspace/.progress"

    if let content = try? String(contentsOfFile: progressFile, encoding: .utf8),
        let progress = Int(content.trimmingCharacters(in: .whitespacesAndNewlines))
    {
        return progress
    }

    return 1  // Start at challenge 1
}

func saveProgress(_ challengeNumber: Int) {
    let progressFile = "workspace/.progress"
    try? String(challengeNumber).write(toFile: progressFile, atomically: true, encoding: .utf8)
}

func resetProgress() {
    let progressFile = "workspace/.progress"
    let fileManager = FileManager.default
    
    // Delete progress file
    try? fileManager.removeItem(atPath: progressFile)
    
    // Delete all challenge files
    if let files = try? fileManager.contentsOfDirectory(atPath: "workspace") {
        for file in files {
            if file.hasPrefix("challenge") && file.hasSuffix(".swift") {
                try? fileManager.removeItem(atPath: "workspace/\(file)")
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

func validateChallenge(_ challenge: Challenge, challenges: [Challenge]) -> Bool {
    let workspacePath = "workspace/\(challenge.filename)"

    guard let output = compileAndRun(file: workspacePath) else {
        print("✗ Compilation failed. Check your code.")
        return false
    }

    // Show what the code printed
    print("Output: \(output)\n")

    if output == challenge.expectedOutput {
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
        
        // Define all challenges
        let challenges = [
            Challenge(
                number: 1,
                title: "Hello, Forge",
                description: "Print \"Hello, Forge\" to the console",
                starterCode: """
                    // TODO: Create a function called greet()
                    func greet() {
                        // Your code here
                    }

                    // TODO: Call the function
                    """,
                expectedOutput: "Hello, Forge"
            ),
            Challenge(
                number: 2,
                title: "Variables",
                description: "Create a variable and print it",
                starterCode: """
                    // TODO: Create a variable called 'message' with the text "Learning Swift"

                    // TODO: Print that variable
                    """,
                expectedOutput: "Learning Swift"
            ),
            Challenge(
                number: 3,
                title: "Basic Math",
                description: "Perform arithmetic and print the result",
                starterCode: """
                    // TODO: Create a variable 'result' that holds the sum of 25 and 17

                    // TODO: Print the result
                    """,
                expectedOutput: "42"
            ),
            Challenge(
                number: 4,
                title: "String Interpolation",
                description: "Combine text and variables in a print statement",
                starterCode: """
                    // Create a variable with a number
                    let score = 100

                    // TODO: Print "Your score is 100" using string interpolation
                    // Hint: Use \\(variableName) inside a string
                    """,
                expectedOutput: "Your score is 100"
            ),
            Challenge(
                number: 5,
                title: "Function Parameters",
                description: "Create a function that takes a parameter",
                starterCode: """
                    // TODO: Create a function called 'greet' that takes a 'name' parameter
                    // and prints "Hello, " followed by that name

                    // TODO: Call the function with "Forge"
                    """,
                expectedOutput: "Hello, Forge"
            ),
            Challenge(
                number: 6,
                title: "Return Values",
                description: "Create a function that returns a value",
                starterCode: """
                    // TODO: Create a function called 'double' that takes an Int parameter
                    // and returns that number multiplied by 2

                    // TODO: Call the function with 21 and print the result
                    """,
                expectedOutput: "42"
            ),
        ]

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
