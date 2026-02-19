import Foundation

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
        Type 'h' for a hint, 'c' for a cheatsheet, 'l' for a lesson, 't' for AI tutor, or 's' for the solution.
        Viewing the solution is allowed.
        """)
    return filePath
}

func validateProject(
    _ project: Project,
    workspacePath: String = "workspace",
    assistedPass: Bool = false,
    diagnosticOutput: inout String?
) -> Bool {
    let filePath = "\(workspacePath)/\(project.filename)"

    let start = Date()
    let runResult = runSwiftProcess(file: filePath)
    if runResult.exitCode != 0 {
        var fullMsg = ""
        let errorOutput = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        if !errorOutput.isEmpty {
            print(errorOutput)
            print("")
            fullMsg += errorOutput + "\n\n"
        }
        let endMsg = "✗ Compile/runtime error. Check your code."
        print(endMsg)
        fullMsg += endMsg
        diagnosticOutput = fullMsg
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": "compile_fail"],
            intFields: ["seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }
    let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)

    // Parse output lines
    let outputLines = output.components(separatedBy: "\n")
    
    // Check if all test cases pass
    guard outputLines.count == project.testCases.count else {
        let msg = "✗ Expected \(project.testCases.count) outputs, got \(outputLines.count)"
        print(msg)
        diagnosticOutput = msg
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": "line_count_mismatch"],
            intFields: [
                "seconds": Int(Date().timeIntervalSince(start)),
                "expectedLines": project.testCases.count,
                "actualLines": outputLines.count,
            ],
            workspacePath: workspacePath
        )
        return false
    }
    
    var allPassed = true
    var failedCount = 0
    var fullMsg = ""
    for (index, testCase) in project.testCases.enumerated() {
        let expected = testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let actual = outputLines[index].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if actual != expected {
            let msg = "✗ Test \(index + 1) failed\n  expected: \(expected)\n       got: \(actual)"
            print(msg)
            fullMsg += msg + "\n"
            allPassed = false
            failedCount += 1
        }
    }
    
    if allPassed {
        print("Output:\n\(output)\n")
        let completionLabel = assistedPass ? "✓ Project Complete! (assisted)\n" : "✓ Project Complete! Excellent work.\n"
        print(completionLabel)
        let result = assistedPass ? "pass_assisted" : "pass"
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": result],
            intFields: ["seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return true
    } else {
        print("✗ Some tests failed. Keep working!")
        diagnosticOutput = fullMsg
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": "fail"],
            intFields: [
                "seconds": Int(Date().timeIntervalSince(start)),
                "failedTests": failedCount,
            ],
            workspacePath: workspacePath
        )
        return false
    }
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

func runProject(
    _ project: Project,
    workspacePath: String = "workspace",
    confirmCheckEnabled: Bool,
    confirmSolutionEnabled: Bool,
    trackAssisted: Bool = false
) -> Bool {
    _ = loadProject(project, workspacePath: workspacePath)

    var hintIndex = 0
    var solutionViewedBeforePass = false
    var lastDiagnostics: String? = nil
    var tutorSession: TutorSession? = nil

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

        if input == "l" {
            showLesson(for: project)
            continue
        }

        if input == "t" {
            if tutorSession == nil {
                tutorSession = TutorSession(subject: project, workspacePath: workspacePath, lastDiagnostics: lastDiagnostics)
            } else {
                let prevModel = tutorSession?.selectedModel
                tutorSession = TutorSession(subject: project, workspacePath: workspacePath, lastDiagnostics: lastDiagnostics)
                tutorSession?.selectedModel = prevModel
            }
            tutorSession?.start()
            continue
        }

        if input == "s" {
            let solution = project.solution.trimmingCharacters(in: .whitespacesAndNewlines)
            if solution.isEmpty {
                print("Solution not available yet.\n")
            } else {
                if trackAssisted {
                    if !solutionViewedBeforePass {
                        let prompt = "Viewing the solution now will mark this attempt as assisted."
                        if !confirmSolutionEnabled || confirmSolutionAccess(prompt: prompt) {
                            solutionViewedBeforePass = true
                            logSolutionViewed(
                                id: project.id,
                                number: nil,
                                mode: "project",
                                assisted: true,
                                workspacePath: workspacePath
                            )
                            print("Solution:\n\(solution)\n")
                        }
                    } else {
                        print("Solution:\n\(solution)\n")
                    }
                } else {
                    if !confirmSolutionEnabled || confirmSolutionAccess(prompt: "View the solution?") {
                        print("Solution:\n\(solution)\n")
                    }
                }
            }
            continue
        }

        if !input.isEmpty {
            print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 'l' for lesson, 't' for AI tutor, 's' for solution.\n")
            continue
        }

        if !confirmCheckIfNeeded(confirmCheckEnabled) {
            continue
        }

        print("\n--- Testing your project... ---\n")

        if validateProject(project, workspacePath: workspacePath, assistedPass: solutionViewedBeforePass, diagnosticOutput: &lastDiagnostics) {
            sleep(2)
            return true
        }
    }
}
