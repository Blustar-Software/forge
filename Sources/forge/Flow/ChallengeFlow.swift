import Foundation

func challengePromptText(for challenge: Challenge, filePath: String) -> String {
    let checkMessage = challenge.manualCheck
        ? "Manual check: run 'swift \(filePath)' yourself, then press Enter to mark complete."
        : "Press Enter to check your work."
    let prereqLine = prerequisiteLine(for: challenge) ?? ""
    let prereqBlock = prereqLine.isEmpty ? "" : "\n\(prereqLine)\n"

    let idLabel = challenge.id.isEmpty || challenge.id == challenge.displayId ? "" : " (\(challenge.id))"
    return """

        Challenge \(challenge.displayId)\(idLabel): \(challenge.title)
        └─ \(challenge.description)

        Edit: \(filePath)

        \(prereqBlock)
        \(checkMessage)
        Type 'h' for a hint, 'c' for a cheatsheet, 'l' for a lesson, or 's' for the solution.
        Viewing the solution may queue practice when adaptive is enabled.
        """
}

func loadChallenge(_ challenge: Challenge, workspacePath: String = "workspace") {
    let filePath = "\(workspacePath)/\(challenge.filename)"

    // Write challenge file
    let content = "\(normalizedStarterCode(for: challenge))\n"

    try? content.write(toFile: filePath, atomically: true, encoding: .utf8)

    print(challengePromptText(for: challenge, filePath: filePath))
}

func normalizedStarterCode(for challenge: Challenge) -> String {
    let displayId = starterDisplayId(for: challenge)
    let lines = challenge.starterCode.split(separator: "\n", omittingEmptySubsequences: false)
    var updated: [String] = []
    var replaced = false

    for lineSub in lines {
        let line = String(lineSub)
        if !replaced {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("// Challenge "), let colonIndex = line.firstIndex(of: ":"),
               let prefixRange = line.range(of: "// Challenge ") {
                let numberStart = prefixRange.upperBound
                let newLine = String(line[..<numberStart]) + displayId + String(line[colonIndex...])
                updated.append(newLine)
                replaced = true
                continue
            }
        }
        updated.append(line)
    }

    return updated.joined(separator: "\n")
}

func starterDisplayId(for challenge: Challenge) -> String {
    let id = challenge.displayId
    if id.hasPrefix("bridge:") {
        return id
    }
    if let colonIndex = id.firstIndex(of: ":") {
        let prefix = id[..<colonIndex]
        if ["core", "mantle", "crust"].contains(String(prefix)) {
            let start = id.index(after: colonIndex)
            return String(id[start...])
        }
    }
    return id
}

func diagnosticsForMismatch(_ context: DiagnosticContext) -> [String] {
    let expectedTrimmed = context.expected.trimmingCharacters(in: .whitespacesAndNewlines)
    let outputTrimmed = context.output.trimmingCharacters(in: .whitespacesAndNewlines)
    let expectedLines = context.expected.components(separatedBy: "\n")
    let outputLines = context.output.components(separatedBy: "\n")

    var diagnostics: [String] = []

    if !expectedTrimmed.isEmpty, outputTrimmed.isEmpty {
        diagnostics.append("No output detected. Make sure your code prints a result.")
    }

    if outputLines.count != expectedLines.count {
        diagnostics.append("Line count differs. Check how many times you print.")
    }

    if outputTrimmed.contains("Optional(") {
        diagnostics.append("You're printing an optional. Unwrap it or use ?? before printing.")
    }

    if let source = context.source {
        let cleanedSource = stripCommentsAndStrings(from: source)
        let tokens = tokenizeSource(cleanedSource)

        if !expectedTrimmed.isEmpty, !hasToken(tokens, "print") {
            diagnostics.append("No print(...) calls detected. Add output to match the expected result.")
        }

        let hintText = "\(context.challenge.description) \(context.challenge.starterCode)"
        let hintTokens = hintText
            .lowercased()
            .split { !$0.isLetter }
            .map(String.init)
        let loopConcepts: [ConstraintConcept] = [.forInLoop, .whileLoop, .repeatWhileLoop]
        let requiresLoop = !context.challenge.introduces
            .filter { loopConcepts.contains($0) }
            .isEmpty
            || !context.challenge.requires
                .filter { loopConcepts.contains($0) }
                .isEmpty
        let wantsLoop = hintTokens.contains("loop")
            || hintTokens.contains("loops")
            || hintTokens.contains("repeat")
            || hintTokens.contains("iterate")
            || hintTokens.contains("times")
            || hintTokens.contains("while")
            || hintTokens.contains("for")

        if context.challenge.topic == .loops,
           (requiresLoop || wantsLoop),
           !hasToken(tokens, "for"),
           !hasToken(tokens, "while"),
           !hasToken(tokens, "repeat") {
            diagnostics.append("This task likely needs a loop to produce repeated output.")
        }

        let branchingConcepts: [ConstraintConcept] = [.ifElse, .switchStatement]
        let requiresBranching = !context.challenge.introduces
            .filter { branchingConcepts.contains($0) }
            .isEmpty
            || !context.challenge.requires
                .filter { branchingConcepts.contains($0) }
                .isEmpty
        let wantsBranching = hintTokens.contains("if")
            || hintTokens.contains("else")
            || hintTokens.contains("switch")
            || hintTokens.contains("ternary")
            || hintTokens.contains("conditional")
            || hintTokens.contains("branch")
            || hintTokens.contains("branching")

        if context.challenge.topic == .conditionals,
           (requiresBranching || wantsBranching),
           !hasToken(tokens, "if"),
           !hasToken(tokens, "switch"),
           !hasToken(tokens, "?") {
            diagnostics.append("This task expects branching logic. Use a conditional to select output.")
        }

        if context.challenge.topic == .functions, hasToken(tokens, "func") {
            let names = definedFunctionNames(tokens: tokens)
            let hasCall = names.contains(where: { hasFunctionCall(named: $0, tokens: tokens) })
            if !names.isEmpty, !hasCall {
                diagnostics.append("Your function is defined, but it may not be called.")
            }
        }
    }

    return diagnostics
}

func printDiagnostics(_ diagnostics: [String]) {
    guard !diagnostics.isEmpty else { return }
    print("Possible fix:")
    for item in diagnostics {
        print("- \(item)")
    }
    print("")
}

func validateChallenge(
    _ challenge: Challenge,
    nextStepIndex: Int,
    workspacePath: String = "workspace",
    constraintIndex: ConstraintIndex,
    enableConstraintProfiles: Bool,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true,
    assistedPass: Bool = false,
    saveProgressOnPass: Bool = true
) -> Bool {
    let filePath = "\(workspacePath)/\(challenge.filename)"
    var sourceForDiagnostics: String? = nil
    let missingPrereqs = missingPrerequisites(for: challenge, index: constraintIndex)
    if !missingPrereqs.isEmpty {
        let names = missingPrereqs.map(constraintConceptName).joined(separator: ", ")
        print("✗ Prerequisites not introduced yet: \(names).")
        return false
    }

    if challenge.manualCheck {
        print("Manual check: forge does not auto-validate this challenge.")
        let result = assistedPass ? "pass_assisted" : "manual_pass"
        recordAdaptiveStat(topic: challenge.topic, result: result, workspacePath: workspacePath)
        recordAdaptiveChallengeStat(challenge: challenge, result: result, workspacePath: workspacePath)
        logEvent(
            "challenge_manual_complete",
            fields: ["id": challenge.displayId, "result": result],
            intFields: ["number": layerIndex(for: challenge)],
            workspacePath: workspacePath
        )
        if saveProgressOnPass {
            saveProgress(nextStepIndex)
        }
        print("✓ Challenge marked complete.\n")
        return true
    }

    var hadWarnings = false
    if let source = try? String(contentsOfFile: filePath, encoding: .utf8) {
        sourceForDiagnostics = source
        let violations = constraintViolations(
            for: source,
            challenge: challenge,
            enabled: enableConstraintProfiles,
            index: constraintIndex
        )
        if !violations.isEmpty {
            for violation in violations {
                print(violation)
            }
            print("\n✗ Constraint violation. Fix and retry.")
            logConstraintViolation(challenge, mode: "main", workspacePath: workspacePath)
            return false
        }
        let warnings = constraintWarnings(
            for: source,
            challenge: challenge,
            index: constraintIndex,
            enableDiMockHeuristics: enableDiMockHeuristics
        )
        if !warnings.isEmpty {
            hadWarnings = true
            for warning in warnings {
                print(warning)
            }
            print("")
            if effectiveConstraintEnforcement(for: challenge.topic, enforceConstraints: enforceConstraints, workspacePath: workspacePath) {
                print("✗ Constraint violation. Remove early concepts and retry.")
                return false
            }
        }
    }

    let start = Date()
    let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
    let runResult = runSwiftProcess(file: filePath, arguments: args, stdin: stdin)
    if runResult.exitCode != 0 {
        let errorOutput = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        if !errorOutput.isEmpty {
            print(errorOutput)
            print("")
        }
        print("✗ Compile/runtime error. Check your code.")
        recordAdaptiveStat(topic: challenge.topic, result: "compile_fail", workspacePath: workspacePath)
        recordAdaptiveChallengeStat(challenge: challenge, result: "compile_fail", workspacePath: workspacePath)
        logEvent(
            "challenge_attempt",
            fields: ["id": challenge.displayId, "result": "compile_fail"],
            intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }
    let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)

    if validateOutputLines(output: output, expected: challenge.expectedOutput) {
        print("Output:\n\(output)\n")
        let completionLabel = assistedPass ? "✓ Challenge Complete! (assisted)\n" : "✓ Challenge Complete! Well done.\n"
        print(completionLabel)
        recordConstraintMastery(topic: challenge.topic, hadWarnings: hadWarnings, passed: true, workspacePath: workspacePath)
        let result = assistedPass ? "pass_assisted" : "pass"
        recordAdaptiveStat(topic: challenge.topic, result: result, workspacePath: workspacePath)
        recordAdaptiveChallengeStat(challenge: challenge, result: result, workspacePath: workspacePath)
        logEvent(
            "challenge_attempt",
            fields: ["id": challenge.displayId, "result": result],
            intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )

        if saveProgressOnPass {
            saveProgress(nextStepIndex)
        }

        return true
    } else {
        print("✗ Output doesn't match.")
        let diagnostics = diagnosticsForMismatch(
            DiagnosticContext(
                challenge: challenge,
                output: output,
                expected: challenge.expectedOutput,
                source: sourceForDiagnostics
            )
        )
        printDiagnostics(diagnostics)
        recordConstraintMastery(topic: challenge.topic, hadWarnings: hadWarnings, passed: false, workspacePath: workspacePath)
        recordAdaptiveStat(topic: challenge.topic, result: "fail", workspacePath: workspacePath)
        recordAdaptiveChallengeStat(challenge: challenge, result: "fail", workspacePath: workspacePath)
        logEvent(
            "challenge_attempt",
            fields: ["id": challenge.displayId, "result": "fail"],
            intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }
}

func runGateChallenges(
    _ challenges: [Challenge],
    challengeWorkspacePath: String,
    statsWorkspacePath: String,
    constraintIndex: ConstraintIndex,
    confirmCheckEnabled: Bool,
    confirmSolutionEnabled: Bool,
    enableConstraintProfiles: Bool,
    trackAssisted: Bool,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true
) -> Bool {
    for (index, challenge) in challenges.enumerated() {
        loadChallenge(challenge, workspacePath: challengeWorkspacePath)
        var hintIndex = 0
        var challengeComplete = false
        var solutionViewedBeforePass = false
        var sourceForDiagnostics: String? = nil
        let missingPrereqs = missingPrerequisites(for: challenge, index: constraintIndex)
        let missingPrereqNames = missingPrereqs.map(constraintConceptName).joined(separator: ", ")

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

                if input == "l" {
                    showLesson(for: challenge)
                    continue
                }

                if input == "s" {
                    let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
                    if solution.isEmpty {
                        print("Solution not available yet.\n")
                    } else {
                        if trackAssisted {
                            if !solutionViewedBeforePass {
                                let prompt = "Viewing the solution now will mark this attempt as assisted."
                                if !confirmSolutionEnabled || confirmSolutionAccess(prompt: prompt) {
                                    solutionViewedBeforePass = true
                                    logSolutionViewed(
                                        id: challenge.displayId,
                                        number: layerIndex(for: challenge),
                                        mode: "stage_review",
                                        assisted: true,
                                        workspacePath: statsWorkspacePath
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
                print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 'l' for lesson, 's' for solution.\n")
                continue
            }

            if !confirmCheckIfNeeded(confirmCheckEnabled) {
                continue
            }

            if !missingPrereqs.isEmpty {
                print("✗ Prerequisites not introduced yet: \(missingPrereqNames).")
                continue
            }

            if challenge.manualCheck {
                print("\n--- Manual check ---\n")
                print("Manual check: forge does not auto-validate this challenge.")
                print("✓ Challenge marked complete.\n")
                recordConstraintMastery(topic: challenge.topic, hadWarnings: false, passed: true, workspacePath: statsWorkspacePath)
                let result = solutionViewedBeforePass ? "pass_assisted" : "manual_pass"
                recordAdaptiveStat(topic: challenge.topic, result: result, workspacePath: statsWorkspacePath)
                logEvent(
                    "challenge_manual_complete",
                    fields: ["id": challenge.displayId, "mode": "stage_review", "result": result],
                    intFields: ["number": layerIndex(for: challenge)],
                    workspacePath: statsWorkspacePath
                )
                challengeComplete = true
            } else {
                print("\n--- Testing your code... ---\n")
                let filePath = "\(challengeWorkspacePath)/\(challenge.filename)"
                var hadWarnings = false
                if let source = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    sourceForDiagnostics = source
                    let violations = constraintViolations(
                        for: source,
                        challenge: challenge,
                        enabled: enableConstraintProfiles,
                        index: constraintIndex
                    )
                    if !violations.isEmpty {
                        for violation in violations {
                            print(violation)
                        }
                        print("\n✗ Constraint violation. Fix and retry.")
                        logConstraintViolation(challenge, mode: "stage_review", workspacePath: statsWorkspacePath)
                        continue
                    }
                    let warnings = constraintWarnings(
                        for: source,
                        challenge: challenge,
                        index: constraintIndex,
                enableDiMockHeuristics: enableDiMockHeuristics
            )
                    if !warnings.isEmpty {
                        hadWarnings = true
                        for warning in warnings {
                            print(warning)
                        }
                        print("")
                        if effectiveConstraintEnforcement(for: challenge.topic, enforceConstraints: enforceConstraints, workspacePath: statsWorkspacePath) {
                            print("✗ Constraint violation. Remove early concepts and retry.")
                            continue
                        }
                    }
                }
                let start = Date()
                let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: challengeWorkspacePath)
                let runResult = runSwiftProcess(file: filePath, arguments: args, stdin: stdin)
                if runResult.exitCode != 0 {
                    let errorOutput = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !errorOutput.isEmpty {
                        print(errorOutput)
                        print("")
                    }
                    print("✗ Compile/runtime error. Check your code.")
                    recordAdaptiveStat(topic: challenge.topic, result: "compile_fail", workspacePath: statsWorkspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "compile_fail", "mode": "stage_review"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: statsWorkspacePath
                    )
                    continue
                }
                let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)

                if validateOutputLines(output: output, expected: challenge.expectedOutput) {
                    print("Output:\n\(output)\n")
                    let completionLabel = solutionViewedBeforePass
                        ? "✓ Challenge Complete! (assisted)\n"
                        : "✓ Challenge Complete! Well done.\n"
                    print(completionLabel)
                    recordConstraintMastery(topic: challenge.topic, hadWarnings: hadWarnings, passed: true, workspacePath: statsWorkspacePath)
                    let result = solutionViewedBeforePass ? "pass_assisted" : "pass"
                    recordAdaptiveStat(topic: challenge.topic, result: result, workspacePath: statsWorkspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": result, "mode": "stage_review"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: statsWorkspacePath
                    )
                    challengeComplete = true
                } else {
                    print("✗ Output doesn't match.")
                    let diagnostics = diagnosticsForMismatch(
                        DiagnosticContext(
                            challenge: challenge,
                            output: output,
                            expected: challenge.expectedOutput,
                            source: sourceForDiagnostics
                        )
                    )
                    printDiagnostics(diagnostics)
                    recordConstraintMastery(topic: challenge.topic, hadWarnings: hadWarnings, passed: false, workspacePath: statsWorkspacePath)
                    recordAdaptiveStat(topic: challenge.topic, result: "fail", workspacePath: statsWorkspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "fail", "mode": "stage_review"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: statsWorkspacePath
                    )
                }
            }
        }

        if index < challenges.count - 1 {
            print("Press Enter for the next stage review challenge.")
            _ = readLine()
            clearScreen()
        }
    }

    return true
}

func runStageGate(
    _ gate: StageGate,
    progressWorkspacePath: String = "workspace",
    reviewWorkspacePath: String = "workspace_review",
    constraintIndex: ConstraintIndex,
    adaptiveEnabled: Bool,
    confirmCheckEnabled: Bool,
    confirmSolutionEnabled: Bool,
    enableConstraintProfiles: Bool,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true
) {
    let current = loadStageGateProgress(workspacePath: progressWorkspacePath)
    var passes = current?.id == gate.id ? current?.passes ?? 0 : 0
    let startedAt = Date()
    setupWorkspace(at: reviewWorkspacePath)
    clearWorkspaceContents(at: reviewWorkspacePath)
    let review: [Challenge]
    if adaptiveEnabled {
        let stats = loadAdaptiveStats(workspacePath: progressWorkspacePath)
        let challengeStats = loadAdaptiveChallengeStats(workspacePath: progressWorkspacePath)
        review = pickStageReviewChallengesAdaptive(
            from: gate.pool,
            count: gate.count,
            stats: stats,
            challengeStats: challengeStats
        )
    } else {
        review = pickStageReviewChallenges(from: gate.pool, count: gate.count)
    }

    while passes < gate.requiredPasses {
        print("Stage review: \(gate.title)")
        print("Pass \(passes + 1)/\(gate.requiredPasses)")
        print("Complete each review challenge without errors.\n")

        _ = runGateChallenges(
            review,
            challengeWorkspacePath: reviewWorkspacePath,
            statsWorkspacePath: progressWorkspacePath,
            constraintIndex: constraintIndex,
            confirmCheckEnabled: confirmCheckEnabled,
            confirmSolutionEnabled: confirmSolutionEnabled,
            enableConstraintProfiles: enableConstraintProfiles,
            trackAssisted: adaptiveEnabled,
            enforceConstraints: enforceConstraints,
            enableDiMockHeuristics: enableDiMockHeuristics
        )
        passes += 1
        saveStageGateProgress(id: gate.id, passes: passes, workspacePath: progressWorkspacePath)
        if passes < gate.requiredPasses {
            print("Stage review pass complete. Press Enter to repeat.\n")
            _ = readLine()
            clearScreen()
        }
    }

    let elapsed = Date().timeIntervalSince(startedAt)
    var summary = loadStageGateSummary(workspacePath: progressWorkspacePath)
    summary[gate.id] = "passes=\(gate.requiredPasses), seconds=\(Int(elapsed))"
    saveStageGateSummary(summary, workspacePath: progressWorkspacePath)
    print("Stage review complete: \(gate.title)")
    print("Total passes: \(gate.requiredPasses)")
    print("Time: \(Int(elapsed))s\n")
    printStageReviewDebrief(startedAt: startedAt, workspacePath: progressWorkspacePath)

    logEvent(
        "stage_review",
        fields: ["stage": gate.id],
        intFields: ["passes": gate.requiredPasses, "seconds": Int(elapsed)],
        workspacePath: progressWorkspacePath
    )

    clearStageGateProgress(workspacePath: progressWorkspacePath)
    resetWorkspaceContents(at: reviewWorkspacePath, removeAll: true)
}

func runSteps(
    _ steps: [Step],
    startingAt: Int,
    constraintIndex: ConstraintIndex,
    practicePool: [Challenge],
    practiceWorkspace: String,
    adaptiveThreshold: Int,
    adaptiveCount: Int,
    adaptiveMinTopicFailures: Int,
    adaptiveMinChallengeFailures: Int,
    adaptiveCooldownSteps: Int,
    adaptiveEnabled: Bool,
    enableConstraintProfiles: Bool,
    confirmCheckEnabled: Bool,
    confirmSolutionEnabled: Bool,
    enforceConstraints: Bool,
    enableDiMockHeuristics: Bool
) {
    let practicePoolFiltered = filteredPracticePool(
        from: practicePool,
        steps: [],
        progressStep: 0,
        topic: nil,
        tier: nil,
        layer: nil,
        range: nil,
        includeAll: true,
        bridgeOnly: false
    )
    var adaptiveGateScores: [ChallengeTopic: Int] = [:]
    var pendingAdaptiveTopic: ChallengeTopic? = nil
    var pendingAdaptivePool: [Challenge] = []
    var justRanAdaptivePractice = false
    var lastFailedTopic: ChallengeTopic? = nil
    var topicFailureStreak = 0
    var challengeFailureCounts: [String: Int] = [:]
    var adaptiveCooldownRemaining = 0
    var currentIndex = startingAt - 1

    if adaptiveEnabled, let pending = loadPendingPractice(workspacePath: "workspace") {
        let allChallenges = steps.compactMap { step -> Challenge? in
            if case .challenge(let stepChallenge) = step {
                return stepChallenge
            }
            return nil
        }
        let pendingChallenge = allChallenges.first { $0.displayId == pending.challengeId }
        let pendingIndex = pendingChallenge.map { layerIndex(for: $0) } ?? pending.challengeNumber
        let fallbackPool = practicePoolFiltered.filter { candidate in
            guard candidate.topic == pending.topic else { return false }
            guard candidate.layer == pending.layer else { return false }
            guard layerIndex(for: candidate) <= pendingIndex else { return false }
            return candidate.progressId != pending.challengeId
        }
        let scopedPool: [Challenge]
        if let pendingChallenge = pendingChallenge {
            let scoped = adaptivePracticePool(for: pendingChallenge, from: practicePoolFiltered)
            scopedPool = scoped.isEmpty ? fallbackPool : scoped
        } else {
            scopedPool = fallbackPool
        }

        if !scopedPool.isEmpty {
            let stats = loadAdaptiveStats(workspacePath: "workspace")
            let challengeStats = loadAdaptiveChallengeStats(workspacePath: "workspace")
            print("Resuming assisted practice for \(pending.topic.rawValue). Press Enter to start.")
            _ = readLine()
            clearScreen()
            runAdaptiveGate(
                topic: pending.topic,
                pool: scopedPool,
                stats: stats,
                challengeStats: challengeStats,
                count: max(1, pending.count),
                workspacePath: practiceWorkspace,
                constraintIndex: constraintIndex,
                confirmCheckEnabled: confirmCheckEnabled,
                confirmSolutionEnabled: confirmSolutionEnabled,
                enableConstraintProfiles: enableConstraintProfiles,
                enforceConstraints: enforceConstraints,
                enableDiMockHeuristics: enableDiMockHeuristics
            )
            clearPendingPractice(workspacePath: "workspace")
            adaptiveCooldownRemaining = adaptiveCooldownSteps
            justRanAdaptivePractice = true
        }
    }

    while currentIndex < steps.count {
        let step = steps[currentIndex]

        switch step {
        case .challenge(let challenge):
            loadChallenge(challenge)
            print("Type 'b' to go back one step (rewinds progress).")
            var hintIndex = 0
            var challengeComplete = false
            var solutionViewedBeforePass = false
            var backRequested = false
            while !challengeComplete {
                print("> ", terminator: "")
                let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

                if input == "b" {
                    if let previousIndex = previousChallengeIndex(from: steps, before: currentIndex) {
                        if confirmBackAccess() {
                            saveProgress(previousIndex + 1)
                            currentIndex = previousIndex
                            backRequested = true
                            clearScreen()
                            break
                        }
                        continue
                    }
                    print("No previous challenge to go back to.\n")
                    continue
                }

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

                if input == "l" {
                    showLesson(for: challenge)
                    continue
                }

                if input == "s" {
                    let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
                    if solution.isEmpty {
                        print("Solution not available yet.\n")
                    } else {
                        if adaptiveEnabled {
                            if !solutionViewedBeforePass {
                                let prompt = "Viewing the solution now will mark this attempt as assisted and queue a short practice set after completion."
                                if !confirmSolutionEnabled || confirmSolutionAccess(prompt: prompt) {
                                    solutionViewedBeforePass = true
                                    logSolutionViewed(
                                        id: challenge.displayId,
                                        number: layerIndex(for: challenge),
                                        mode: "main",
                                        assisted: true,
                                        workspacePath: "workspace"
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
                    print("Unknown command. Press Enter to check, 'b' to go back, 'h' for hint, 'c' for cheatsheet, 'l' for lesson, 's' for solution.\n")
                    continue
                }

                if !confirmCheckIfNeeded(confirmCheckEnabled) {
                    continue
                }

                if challenge.manualCheck {
                    print("\n--- Manual check ---\n")
                } else {
                    print("\n--- Testing your code... ---\n")
                }

                let nextStepIndex = currentIndex + 2
                let didPass = validateChallenge(
                    challenge,
                    nextStepIndex: nextStepIndex,
                    constraintIndex: constraintIndex,
                    enableConstraintProfiles: enableConstraintProfiles,
                    enforceConstraints: enforceConstraints,
                    enableDiMockHeuristics: enableDiMockHeuristics,
                    assistedPass: solutionViewedBeforePass,
                    saveProgressOnPass: false
                )
                if didPass {
                    if shouldRepeatChallenge() {
                        hintIndex = 0
                        solutionViewedBeforePass = false
                        clearScreen()
                        loadChallenge(challenge)
                        continue
                    }
                    saveProgress(nextStepIndex)
                    if solutionViewedBeforePass, adaptiveEnabled {
                        if pendingAdaptiveTopic == challenge.topic {
                            pendingAdaptiveTopic = nil
                            pendingAdaptivePool = []
                        }
                        let practiceCount = max(1, min(2, adaptiveCount))
                        let scopedPool = adaptivePracticePool(for: challenge, from: practicePoolFiltered)
                        let eligiblePool = steps.prefix(currentIndex + 1).compactMap { step -> Challenge? in
                            if case .challenge(let stepChallenge) = step {
                                return stepChallenge
                            }
                            return nil
                        }
                        let pool = scopedPool.isEmpty ? eligiblePool : scopedPool
                        if !pool.isEmpty {
                            savePendingPractice(challenge: challenge, count: practiceCount, workspacePath: "workspace")
                            logPracticeQueued(
                                challenge: challenge,
                                mode: "main",
                                count: practiceCount,
                                workspacePath: "workspace"
                            )
                            let stats = loadAdaptiveStats(workspacePath: "workspace")
                            let challengeStats = loadAdaptiveChallengeStats(workspacePath: "workspace")
                            print("Assisted practice for \(challenge.topic.rawValue). Press Enter to start.")
                            _ = readLine()
                            clearScreen()
                            runAdaptiveGate(
                                topic: challenge.topic,
                                pool: pool,
                                stats: stats,
                                challengeStats: challengeStats,
                                count: practiceCount,
                                workspacePath: practiceWorkspace,
                                constraintIndex: constraintIndex,
                                confirmCheckEnabled: confirmCheckEnabled,
                                confirmSolutionEnabled: confirmSolutionEnabled,
                                enableConstraintProfiles: enableConstraintProfiles,
                                enforceConstraints: enforceConstraints,
                                enableDiMockHeuristics: enableDiMockHeuristics
                            )
                            clearPendingPractice(workspacePath: "workspace")
                            adaptiveCooldownRemaining = adaptiveCooldownSteps
                            justRanAdaptivePractice = true
                        }
                    }
                    challengeFailureCounts[challenge.displayId] = 0
                    if lastFailedTopic == challenge.topic {
                        lastFailedTopic = nil
                        topicFailureStreak = 0
                    }
                    if adaptiveCooldownRemaining > 0 {
                        adaptiveCooldownRemaining -= 1
                    }
                    if !solutionViewedBeforePass, adaptiveEnabled, pendingAdaptiveTopic == challenge.topic {
                        let practicePool = pendingAdaptivePool
                        pendingAdaptiveTopic = nil
                        pendingAdaptivePool = []
                        let stats = loadAdaptiveStats(workspacePath: "workspace")
                        let challengeStats = loadAdaptiveChallengeStats(workspacePath: "workspace")
                        print("Adaptive practice for \(challenge.topic.rawValue). Press Enter to start.")
                        _ = readLine()
                        clearScreen()
                        runAdaptiveGate(
                            topic: challenge.topic,
                            pool: practicePool,
                            stats: stats,
                            challengeStats: challengeStats,
                            count: adaptiveCount,
                            workspacePath: practiceWorkspace,
                            constraintIndex: constraintIndex,
                            confirmCheckEnabled: confirmCheckEnabled,
                            confirmSolutionEnabled: confirmSolutionEnabled,
                            enableConstraintProfiles: enableConstraintProfiles,
                            enforceConstraints: enforceConstraints,
                            enableDiMockHeuristics: enableDiMockHeuristics
                        )
                        adaptiveCooldownRemaining = adaptiveCooldownSteps
                        justRanAdaptivePractice = true
                    }
                    challengeComplete = true
                    currentIndex += 1

                    if currentIndex < steps.count {
                        let prompt = nextStepPrompt(for: steps[currentIndex])
                        if !prompt.isEmpty {
                            print(prompt)
                        }
                        switch steps[currentIndex] {
                        case .challenge, .stageGate:
                            if justRanAdaptivePractice {
                                justRanAdaptivePractice = false
                            } else {
                                clearScreen()
                            }
                        case .project:
                            break
                        }
                    } else {
                        saveProgress(999)
                        print("🎉 You've completed everything!")
                        print("Run 'swift run forge reset' to start over.\n")
                    }
                } else if adaptiveEnabled {
                    let currentFailures = (challengeFailureCounts[challenge.displayId] ?? 0) + 1
                    challengeFailureCounts[challenge.displayId] = currentFailures
                    if lastFailedTopic == challenge.topic {
                        topicFailureStreak += 1
                    } else {
                        lastFailedTopic = challenge.topic
                        topicFailureStreak = 1
                    }
                    let meetsStability = topicFailureStreak >= adaptiveMinTopicFailures
                        || currentFailures >= adaptiveMinChallengeFailures
                    guard meetsStability, adaptiveCooldownRemaining == 0 else {
                        continue
                    }
                    let stats = loadAdaptiveStats(workspacePath: "workspace")
                    if let score = shouldTriggerAdaptiveGate(
                        topic: challenge.topic,
                        stats: stats,
                        lastTriggered: &adaptiveGateScores,
                        threshold: adaptiveThreshold
                    ) {
                        if pendingAdaptiveTopic == nil {
                            let eligiblePool = steps.prefix(currentIndex + 1).compactMap { step -> Challenge? in
                                if case .challenge(let stepChallenge) = step {
                                    return stepChallenge
                                }
                                return nil
                            }
                            let scopedPool = adaptivePracticePool(for: challenge, from: practicePoolFiltered)
                            pendingAdaptiveTopic = challenge.topic
                            pendingAdaptivePool = scopedPool.isEmpty ? eligiblePool : scopedPool
                            print("Adaptive practice queued for \(challenge.topic.rawValue) (score \(score)).")
                            print("Finish this challenge to start practice.\n")
                        }
                    }
                }
            }
            if backRequested {
                continue
            }
        case .project(let project):
            if runProject(
                project,
                confirmCheckEnabled: confirmCheckEnabled,
                confirmSolutionEnabled: confirmSolutionEnabled,
                trackAssisted: adaptiveEnabled
            ) {
                currentIndex += 1
                if currentIndex < steps.count {
                    saveProgress(currentIndex + 1)
                    print(project.completionTitle)
                    print("\(project.completionMessage)\n")
                    let prompt = nextStepPrompt(for: steps[currentIndex])
                    if !prompt.isEmpty {
                        print(prompt)
                    }
                    switch steps[currentIndex] {
                    case .project:
                        sleep(2)
                        clearScreen()
                    case .challenge, .stageGate:
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
        case .stageGate(let gate):
            runStageGate(
                gate,
                progressWorkspacePath: "workspace",
                reviewWorkspacePath: "workspace_review",
                constraintIndex: constraintIndex,
                adaptiveEnabled: adaptiveEnabled,
                confirmCheckEnabled: confirmCheckEnabled,
                confirmSolutionEnabled: confirmSolutionEnabled,
                enableConstraintProfiles: enableConstraintProfiles,
                enforceConstraints: enforceConstraints,
                enableDiMockHeuristics: enableDiMockHeuristics
            )
            currentIndex += 1
            if currentIndex < steps.count {
                saveProgress(currentIndex + 1)
                let prompt = nextStepPrompt(for: steps[currentIndex])
                if !prompt.isEmpty {
                    print(prompt)
                }
                switch steps[currentIndex] {
                case .project:
                    print("Press Enter to start your project.")
                    _ = readLine()
                    clearScreen()
                case .challenge, .stageGate:
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
    bridgeChallenges: (coreToMantle: [Challenge], mantleToCrust: [Challenge]),
    projects: [Project],
    gatePasses: Int,
    gateCount: Int
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
    if let gate = makeStageGate(id: "core1", title: "Core 1", challenges: core1Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let core1Project = firstProject(forPass: 1, in: projects) {
        steps.append(.project(core1Project))
    }
    steps.append(contentsOf: core2Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "core2", title: "Core 2", challenges: core2Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let core2Project = firstProject(forPass: 2, in: projects) {
        steps.append(.project(core2Project))
    }
    steps.append(contentsOf: core3Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "core3", title: "Core 3", challenges: core3Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let core3Project = firstProject(forPass: 3, in: projects) {
        steps.append(.project(core3Project))
    }
    steps.append(contentsOf: bridgeChallenges.coreToMantle.map { Step.challenge($0) })
    steps.append(contentsOf: mantle1Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "mantle1", title: "Mantle 1", challenges: mantle1Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let mantle1Project = firstProject(forPass: 4, in: projects) {
        steps.append(.project(mantle1Project))
    }
    steps.append(contentsOf: mantle2Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "mantle2", title: "Mantle 2", challenges: mantle2Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let mantle2Project = firstProject(forPass: 5, in: projects) {
        steps.append(.project(mantle2Project))
    }
    steps.append(contentsOf: mantle3Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "mantle3", title: "Mantle 3", challenges: mantle3Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let mantle3Project = firstProject(forPass: 6, in: projects) {
        steps.append(.project(mantle3Project))
    }
    steps.append(contentsOf: bridgeChallenges.mantleToCrust.map { Step.challenge($0) })
    steps.append(contentsOf: crust1Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "crust1", title: "Crust 1", challenges: crust1Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let crust1Project = firstProject(forPass: 7, in: projects) {
        steps.append(.project(crust1Project))
    }
    steps.append(contentsOf: crust2Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "crust2", title: "Crust 2", challenges: crust2Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let crust2Project = firstProject(forPass: 8, in: projects) {
        steps.append(.project(crust2Project))
    }
    steps.append(contentsOf: crust3Only.map { Step.challenge($0) })
    if let gate = makeStageGate(id: "crust3", title: "Crust 3", challenges: crust3Only, requiredPasses: gatePasses, count: gateCount) {
        steps.append(.stageGate(gate))
    }
    if let crust3Project = firstProject(forPass: 9, in: projects) {
        steps.append(.project(crust3Project))
    }
    return steps
}

func stageReviewPool(for id: String, challenges: [Challenge]) -> [Challenge] {
    let curated: [String: [Int]] = [
        "core1": [5, 8, 9, 10, 12, 13, 14, 15, 16, 18, 19, 20],
        "core2": [21, 22, 23, 24, 25, 29, 30, 33, 35, 37, 39, 41, 42],
        "core3": [43, 47, 48, 49, 51, 53, 59, 63, 64, 70, 72, 77, 81],
        "mantle1": [124, 126, 128, 131, 132, 133, 135],
        "mantle2": [136, 138, 140, 141, 143, 145],
        "mantle3": [146, 148, 150, 151, 152, 154],
        "crust1": [175, 176, 177, 180, 181, 182, 186, 188, 191, 192],
        "crust2": [193, 194, 195, 196, 197, 198, 199, 200, 201, 210],
        "crust3": [211, 212, 214, 215, 217, 219, 220, 222, 225, 228]
    ]
    guard let numbers = curated[id] else { return challenges }
    let index = Dictionary(uniqueKeysWithValues: challenges.map { ($0.number, $0) })
    let pool = numbers.compactMap { index[$0] }
    return pool.isEmpty ? challenges : pool
}

func makeStageGate(id: String, title: String, challenges: [Challenge], requiredPasses: Int, count: Int) -> StageGate? {
    let pool = stageReviewPool(for: id, challenges: challenges)
    guard !pool.isEmpty else { return nil }
    return StageGate(id: id, title: title, pool: pool, requiredPasses: requiredPasses, count: count)
}

func nextStepPrompt(for step: Step) -> String {
    switch step {
    case .challenge:
        return ""
    case .project:
        return "→ Time for your project...\n"
    case .stageGate(let gate):
        return "→ Stage review: \(gate.title)\n"
    }
}

func waitForEnterToContinue() {
    print("Press Enter to continue.")
    _ = readLine()
}

func shouldRepeatChallenge() -> Bool {
    print("Press Enter to continue, or type 'r' to repeat this challenge.")
    let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    return input == "r"
}

func confirmCheckIfNeeded(_ enabled: Bool) -> Bool {
    if !enabled {
        return true
    }
    print("Press Enter again to run the check, or type anything to cancel.")
    let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return input.isEmpty
}

func confirmSolutionAccess(prompt: String) -> Bool {
    print(prompt)
    print("Press 's' again to confirm, or press Enter to cancel.")
    let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    if input == "s" {
        return true
    }
    print("Solution not shown.\n")
    return false
}

func confirmBackAccess() -> Bool {
    print("Go back one step and rewind progress? (y/n)")
    let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    if input == "y" {
        return true
    }
    print("Back cancelled.\n")
    return false
}

func logSolutionViewed(
    id: String,
    number: Int?,
    mode: String,
    assisted: Bool,
    workspacePath: String
) {
    let fields: [String: String] = ["id": id, "mode": mode, "assisted": assisted ? "true" : "false"]
    var intFields: [String: Int] = [:]
    if let number = number {
        intFields["number"] = number
    }
    logEvent("solution_viewed", fields: fields, intFields: intFields, workspacePath: workspacePath)
}

func logPracticeQueued(
    challenge: Challenge,
    mode: String,
    count: Int,
    workspacePath: String
) {
    logEvent(
        "practice_queued",
        fields: ["id": challenge.displayId, "mode": mode, "reason": "solution"],
        intFields: ["number": layerIndex(for: challenge), "count": count],
        workspacePath: workspacePath
    )
}
