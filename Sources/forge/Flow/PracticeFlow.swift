import Foundation

func pickStageReviewChallenges(from challenges: [Challenge], count: Int) -> [Challenge] {
    let total = challenges.count
    guard total > 0 else { return [] }
    let selectionCount = min(count, total)

    if selectionCount == 1 {
        return [challenges[0]]
    }
    if selectionCount == 2 {
        return [challenges[0], challenges[total - 1]]
    }

    let middleIndex = total / 2
    let indexes = [0, middleIndex, total - 1].sorted()
    return indexes.map { challenges[$0] }
}

func pickStageReviewChallengesAdaptive(
    from challenges: [Challenge],
    count: Int,
    stats: [String: [String: Int]],
    challengeStats: [String: ChallengeStats]
) -> [Challenge] {
    let selectionCount = min(count, challenges.count)
    if selectionCount <= 1 {
        return Array(challenges.prefix(selectionCount))
    }
    let now = Int(Date().timeIntervalSince1970)
    return weightedRandomSelection(
        from: challenges,
        weight: { adaptiveChallengeWeight(challenge: $0, topicStats: stats, challengeStats: challengeStats, now: now) },
        count: selectionCount
    )
}

func adaptiveTopicRanking(
    from challenges: [Challenge],
    stats: [String: [String: Int]]
) -> [(topic: ChallengeTopic, score: Int, count: Int)] {
    guard !stats.isEmpty else { return [] }
    let topics = Set(challenges.map { $0.topic })
    let counts = Dictionary(grouping: challenges, by: { $0.topic }).mapValues { $0.count }
    return topics.map { topic in
        (topic, topicScore(for: topic, stats: stats), counts[topic] ?? 0)
    }.sorted {
        if $0.score != $1.score { return $0.score > $1.score }
        if $0.count != $1.count { return $0.count > $1.count }
        return $0.topic.rawValue < $1.topic.rawValue
    }
}

func pickAdaptivePracticeSet(
    from challenges: [Challenge],
    stats: [String: [String: Int]],
    challengeStats: [String: ChallengeStats],
    count: Int
) -> [Challenge] {
    let now = Int(Date().timeIntervalSince1970)
    let basePool: [Challenge]
    var preferredTopics: [ChallengeTopic] = []
    if stats.isEmpty {
        basePool = challenges
    } else {
        let ranked = adaptiveTopicRanking(from: challenges, stats: stats)
        if ranked.isEmpty {
            basePool = challenges
        } else {
            let topScore = ranked[0].score
            let allSameScore = ranked.allSatisfy { $0.score == topScore }
            let limit = allSameScore ? min(4, ranked.count) : min(2, ranked.count)
            preferredTopics = ranked.prefix(limit).map { $0.topic }
            basePool = challenges.filter { preferredTopics.contains($0.topic) }
        }
    }
    if basePool.isEmpty {
        return Array(challenges.shuffled().prefix(count))
    }
    return pickPracticeSetWithSpread(
        from: basePool,
        stats: stats,
        challengeStats: challengeStats,
        count: count,
        now: now,
        preferredTopics: preferredTopics
    )
}

func pickPracticeSetWithSpread(
    from challenges: [Challenge],
    stats: [String: [String: Int]],
    challengeStats: [String: ChallengeStats],
    count: Int,
    now: Int,
    preferredTopics: [ChallengeTopic] = []
) -> [Challenge] {
    let selectionCount = min(count, challenges.count)
    guard selectionCount > 0 else { return [] }

    func practiceIndex(for challenge: Challenge) -> Int {
        let base = layerIndex(for: challenge)
        return challenge.extraParent ?? base
    }

    let maxIndex = challenges.map(practiceIndex).max() ?? 1
    let lowCutoff = max(1, maxIndex / 3)
    let midCutoff = max(1, (maxIndex * 2) / 3)
    var buckets: [[Challenge]] = [[], [], []]
    for challenge in challenges {
        let index = practiceIndex(for: challenge)
        if index <= lowCutoff {
            buckets[0].append(challenge)
        } else if index <= midCutoff {
            buckets[1].append(challenge)
        } else {
            buckets[2].append(challenge)
        }
    }

    var remaining = challenges
    var selection: [Challenge] = []
    var usedParents: Set<String> = []

    func parentKey(for challenge: Challenge) -> String? {
        guard challenge.tier == .extra else { return nil }
        let parent = challenge.extraParent ?? layerIndex(for: challenge)
        return "\(challenge.layer.rawValue):\(parent)"
    }

    func rangeBonus(for challenge: Challenge, maxIndex: Int) -> Int {
        let index = practiceIndex(for: challenge)
        if maxIndex <= 0 { return 0 }
        let lowCutoff = max(1, maxIndex / 3)
        let midCutoff = max(1, (maxIndex * 2) / 3)
        if index <= lowCutoff { return 0 }
        if index <= midCutoff { return 1 }
        return 2
    }

    func pickOne(from pool: [Challenge]) -> Challenge? {
        if pool.isEmpty { return nil }
        let filtered = pool.filter { candidate in
            guard let key = parentKey(for: candidate) else { return true }
            return !usedParents.contains(key)
        }
        let candidates = filtered.isEmpty ? pool : filtered
        let maxIndex = candidates.map(practiceIndex).max() ?? 1
        return weightedRandomSelection(
            from: candidates,
            weight: {
                adaptiveChallengeWeight(challenge: $0, topicStats: stats, challengeStats: challengeStats, now: now)
                + rangeBonus(for: $0, maxIndex: maxIndex)
            },
            count: 1
        ).first
    }

    if selectionCount >= 2 {
        let topicsToSeed = preferredTopics.isEmpty
            ? Array(Set(challenges.map { $0.topic })).sorted { $0.rawValue < $1.rawValue }
            : preferredTopics
        for topic in topicsToSeed {
            if selection.count >= selectionCount { break }
            let topicPool = remaining.filter { $0.topic == topic }
            if let picked = pickOne(from: topicPool) {
                selection.append(picked)
                if let key = parentKey(for: picked) { usedParents.insert(key) }
                remaining.removeAll { $0.displayId == picked.displayId }
                for index in buckets.indices {
                    buckets[index].removeAll { $0.displayId == picked.displayId }
                }
            }
        }
    }

    if selectionCount >= 3 {
        for bucket in buckets {
            if selection.count >= selectionCount { break }
            if let picked = pickOne(from: bucket) {
                selection.append(picked)
                if let key = parentKey(for: picked) { usedParents.insert(key) }
                remaining.removeAll { $0.displayId == picked.displayId }
                for index in buckets.indices {
                    buckets[index].removeAll { $0.displayId == picked.displayId }
                }
            }
        }
    }

    while selection.count < selectionCount {
        if let picked = pickOne(from: remaining) {
            selection.append(picked)
            if let key = parentKey(for: picked) { usedParents.insert(key) }
            remaining.removeAll { $0.displayId == picked.displayId }
        } else {
            break
        }
    }

    return selection
}

func practiceAdaptiveSummary(
    from pool: [Challenge],
    stats: [String: [String: Int]],
    limit: Int = 2
) -> String? {
    guard !stats.isEmpty else { return nil }
    let ranked = adaptiveTopicRanking(from: pool, stats: stats)
    let topTopics = ranked.prefix(limit).map { $0.topic }
    guard !topTopics.isEmpty else { return nil }
    let parts = topTopics.map { topic in
        "\(topic.rawValue) (score \(topicScore(for: topic, stats: stats)))"
    }
    return "Adaptive focus: \(parts.joined(separator: ", "))."
}

func printPracticeReport(
    pool: [Challenge],
    stats: [String: [String: Int]],
    challengeStats: [String: ChallengeStats]
) {
    let counts = Dictionary(grouping: pool, by: { $0.topic }).mapValues { $0.count }
    let sortedCounts = counts.sorted {
        if $0.value != $1.value { return $0.value > $1.value }
        return $0.key.rawValue < $1.key.rawValue
    }
    print("Practice report")
    print("Eligible challenges: \(pool.count)")
    print("Adaptive stats entries: \(stats.count)")
    print("Challenge stats entries: \(challengeStats.count)")
    print("Topic counts + scores:")
    for (topic, count) in sortedCounts {
        let score = topicScore(for: topic, stats: stats)
        print("- \(topic.rawValue): \(count) (score \(score))")
    }
    if let summary = practiceAdaptiveSummary(from: pool, stats: stats, limit: 3) {
        print(summary)
    }
}

func shouldTriggerAdaptiveGate(
    topic: ChallengeTopic,
    stats: [String: [String: Int]],
    lastTriggered: inout [ChallengeTopic: Int],
    threshold: Int
) -> Int? {
    let score = topicScore(for: topic, stats: stats)
    let previous = lastTriggered[topic] ?? 0
    if score >= threshold && score > previous {
        lastTriggered[topic] = score
        return score
    }
    return nil
}

func runAdaptiveGate(
    topic: ChallengeTopic,
    pool: [Challenge],
    stats: [String: [String: Int]],
    challengeStats: [String: ChallengeStats],
    count: Int,
    workspacePath: String,
    constraintIndex: ConstraintIndex,
    confirmCheckEnabled: Bool,
    confirmSolutionEnabled: Bool,
    enableConstraintProfiles: Bool,
    enforceConstraints: Bool,
    enableDiMockHeuristics: Bool
) {
    let filtered = pool.filter { $0.topic == topic }
    guard !filtered.isEmpty else { return }
    let now = Int(Date().timeIntervalSince1970)
    let selection = weightedRandomSelection(
        from: filtered,
        weight: { adaptiveChallengeWeight(challenge: $0, topicStats: stats, challengeStats: challengeStats, now: now) },
        count: min(count, filtered.count)
    )

    print("Adaptive practice: focusing on \(topic.rawValue).")
    print("Workspace: \(workspacePath)\n")
    setupWorkspace(at: workspacePath)
    clearWorkspaceContents(at: workspacePath)
    runPracticeChallenges(
        selection,
        workspacePath: workspacePath,
        statsWorkspacePath: "workspace",
        constraintIndex: constraintIndex,
        confirmCheckEnabled: confirmCheckEnabled,
        confirmSolutionEnabled: confirmSolutionEnabled,
        enableConstraintProfiles: enableConstraintProfiles,
        trackAssisted: true,
        enforceConstraints: enforceConstraints,
        enableDiMockHeuristics: enableDiMockHeuristics,
        completionTitle: "Adaptive practice complete!",
        finishPrompt: "Press Enter to return.\n"
    )
    clearScreen()
}

func printAdaptiveStats(workspacePath: String = "workspace", statsLimit: Int?) {
    let stats = loadAdaptiveStats(workspacePath: workspacePath)
    if stats.isEmpty {
        print("No adaptive stats recorded yet.")
    } else {
        print("Adaptive stats:")
        var topicScores: [(topic: String, score: Int)] = []
        for topic in stats.keys.sorted() {
            let counts = stats[topic, default: [:]]
            let pass = counts["pass", default: 0]
            let passAssisted = counts["pass_assisted", default: 0]
            let fail = counts["fail", default: 0]
            let compileFail = counts["compile_fail", default: 0]
            let manualPass = counts["manual_pass", default: 0]
            let score = max(1, 1 + (fail + compileFail) - (pass + manualPass))
            topicScores.append((topic, score))
            print("- \(topic): pass=\(pass), pass_assisted=\(passAssisted), fail=\(fail), compile_fail=\(compileFail), manual_pass=\(manualPass)")
        }
        let weakTopics = topicScores.sorted { $0.score > $1.score }.prefix(3)
        if !weakTopics.isEmpty {
            let summary = weakTopics.map { "\($0.topic)(\($0.score))" }.joined(separator: ", ")
            print("Top weak topics: \(summary)")
        }
    }

    let challengeStats = loadAdaptiveChallengeStats(workspacePath: workspacePath)
    if !challengeStats.isEmpty {
        let titleIndex = buildChallengeTitleIndex()
        let sortedFailures = challengeStats
            .map { (id: $0.key, entry: $0.value) }
            .filter { $0.entry.fail + $0.entry.compileFail > 0 }
            .sorted {
                let leftFails = $0.entry.fail + $0.entry.compileFail
                let rightFails = $1.entry.fail + $1.entry.compileFail
                if leftFails == rightFails {
                    return $0.id < $1.id
                }
                return leftFails > rightFails
            }
        if !sortedFailures.isEmpty {
            let limit = statsLimit ?? 5
            print("Top failing challenges:")
            for item in sortedFailures.prefix(limit) {
                let title = titleIndex[item.id] ?? "Unknown"
                let entry = item.entry
                let failCount = entry.fail + entry.compileFail
                print("- \(item.id): \(title) (fail=\(entry.fail), compile_fail=\(entry.compileFail), pass=\(entry.pass), pass_assisted=\(entry.passAssisted), total_fail=\(failCount))")
            }
        }
    }

    let entries = loadPerformanceLogEntries(workspacePath: workspacePath)
    var totalViolations = 0
    var violationsByMode: [String: Int] = [:]
    var violationsById: [String: Int] = [:]
    var violationsByTopic: [String: Int] = [:]
    let topicIndex = buildChallengeTopicIndex()
    let titleIndex = buildChallengeTitleIndex()
    for line in entries {
        guard extractLogField(line, key: "event") == "constraint_violation" else { continue }
        totalViolations += 1
        if let mode = extractLogField(line, key: "mode") {
            violationsByMode[mode, default: 0] += 1
        }
        if let id = extractLogField(line, key: "id") {
            violationsById[id, default: 0] += 1
            if let topic = topicIndex[id] {
                violationsByTopic[topic, default: 0] += 1
            }
        }
    }

    if totalViolations > 0 {
        print("Constraint violations: \(totalViolations)")
        if !violationsByMode.isEmpty {
            let modeSummary = violationsByMode
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ", ")
            print("- By mode: \(modeSummary)")
        }
        if !violationsByTopic.isEmpty {
            let sortedTopics = violationsByTopic.sorted { $0.value > $1.value }
            let topicSummary = sortedTopics
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ", ")
            print("- By topic: \(topicSummary)")
            print("Top topics:")
            for (topic, count) in sortedTopics.prefix(5) {
                print("- \(topic): \(count)")
            }
            print("Topic summary:")
            let lines = constraintTopicTableLines(violationsByTopic, limit: statsLimit)
            for line in lines {
                print(line)
            }
        }
        let sortedIds = violationsById.sorted { $0.value > $1.value }
        let limit = statsLimit ?? 5
        if !sortedIds.isEmpty {
            let idSummary = sortedIds.prefix(3).map { "\($0.key)(\($0.value))" }.joined(separator: ", ")
            print("- Top challenges: \(idSummary)")
            print("Challenge detail:")
            for (id, count) in sortedIds.prefix(limit) {
                let title = titleIndex[id] ?? "Unknown"
                print("- \(id): \(title) (\(count))")
            }
        }
    }
}

func filteredPracticePool(
    from pool: [Challenge],
    steps: [Step],
    progressStep: Int,
    topic: ChallengeTopic?,
    tier: ChallengeTier?,
    layer: ChallengeLayer?,
    range: ClosedRange<Int>?,
    includeAll: Bool,
    bridgeOnly: Bool
) -> [Challenge] {
    var filtered = pool
    if bridgeOnly {
        filtered = filtered.filter { $0.displayId.hasPrefix("bridge:") }
    } else {
        filtered = filtered.filter { !$0.displayId.hasPrefix("bridge:") }
    }
    if let topic = topic {
        filtered = filtered.filter { $0.topic == topic }
    }
    if let tier = tier {
        filtered = filtered.filter { $0.tier == tier }
    }
    if let layer = layer {
        filtered = filtered.filter { $0.layer == layer }
    }
    guard !includeAll else {
        return filtered
    }

    let coveredSteps = progressStep > 1 ? steps.prefix(progressStep - 1) : []
    let currentStep = (1...steps.count).contains(progressStep) ? steps[progressStep - 1] : nil
    var maxCoveredByLayer: [ChallengeLayer: Int] = [:]
    for step in coveredSteps {
        if case .challenge(let challenge) = step {
            let index = layerIndex(for: challenge)
            guard index > 0 else { continue }
            let currentMax = maxCoveredByLayer[challenge.layer] ?? 0
            maxCoveredByLayer[challenge.layer] = max(currentMax, index)
        }
    }
    var eligibleExtraLayers: Set<ChallengeLayer> = Set(maxCoveredByLayer.keys)
    if progressStep > 1, let currentStep = currentStep, case .challenge(let challenge) = currentStep {
        if layerIndex(for: challenge) > 0 {
            eligibleExtraLayers.insert(challenge.layer)
        }
    }
    if progressStep > steps.count {
        eligibleExtraLayers = [.core, .mantle, .crust]
    }

    return filtered.filter { challenge in
        let challengeIndex = layerIndex(for: challenge)
        let maxCovered = maxCoveredByLayer[challenge.layer] ?? 0
        if challenge.tier == .extra {
            guard eligibleExtraLayers.contains(challenge.layer) else { return false }
            let parentIndex = challenge.extraParent ?? challengeIndex
            guard parentIndex <= maxCovered else { return false }
            if range != nil {
                return challenge.layer == layer
            }
            return true
        }
        if let range = range {
            return challengeIndex <= maxCovered && range.contains(challengeIndex)
        }
        return challengeIndex <= maxCovered
    }
}

func runPracticeChallenges(
    _ challenges: [Challenge],
    workspacePath: String,
    statsWorkspacePath: String = "workspace",
    constraintIndex: ConstraintIndex,
    confirmCheckEnabled: Bool,
    confirmSolutionEnabled: Bool,
    enableConstraintProfiles: Bool,
    trackAssisted: Bool = false,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true,
    completionTitle: String = "✅ Random set complete!",
    finishPrompt: String = "Press Enter to finish.\n"
) {
    var completedFiles: [String] = []

    for (index, challenge) in challenges.enumerated() {
        clearScreen()
        loadChallenge(challenge, workspacePath: workspacePath)
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
                                    mode: "random",
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
                recordAdaptiveChallengeStat(challenge: challenge, result: result, workspacePath: statsWorkspacePath)
                logEvent(
                    "challenge_manual_complete",
                    fields: ["id": challenge.displayId, "mode": "random", "result": result],
                    intFields: ["number": layerIndex(for: challenge)],
                    workspacePath: statsWorkspacePath
                )
                completedFiles.append("\(workspacePath)/\(challenge.filename)")
                challengeComplete = true
            } else {
                print("\n--- Testing your code... ---\n")
                let filePath = "\(workspacePath)/\(challenge.filename)"
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
                        logConstraintViolation(challenge, mode: "random", workspacePath: statsWorkspacePath)
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
                let (stdin, args, copiedFixturePaths) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
                let runResult = runSwiftProcess(file: filePath, arguments: args, stdin: stdin)
                if runResult.exitCode != 0 {
                    let errorOutput = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !errorOutput.isEmpty {
                        print(errorOutput)
                        print("")
                    }
                    print("✗ Compile/runtime error. Check your code.")
                    recordAdaptiveStat(topic: challenge.topic, result: "compile_fail", workspacePath: statsWorkspacePath)
                    recordAdaptiveChallengeStat(challenge: challenge, result: "compile_fail", workspacePath: statsWorkspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "compile_fail", "mode": "random"],
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
                    recordAdaptiveChallengeStat(challenge: challenge, result: result, workspacePath: statsWorkspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": result, "mode": "random"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: statsWorkspacePath
                    )
                    removePreparedFixtureFiles(copiedFixturePaths)
                    completedFiles.append("\(workspacePath)/\(challenge.filename)")
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
                    recordAdaptiveChallengeStat(challenge: challenge, result: "fail", workspacePath: statsWorkspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "fail", "mode": "random"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: statsWorkspacePath
                    )
                }
            }
        }

        if index < challenges.count - 1 {
            print("Press Enter for the next random challenge.")
            _ = readLine()
        }
    }

    print(completionTitle)
    print(finishPrompt)
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
