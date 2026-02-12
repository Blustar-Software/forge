import Foundation

func handleResetCommand(_ args: [String]) -> Bool {
    setupWorkspace()
    let flags = args.map { $0.lowercased() }
    let removeAll = flags.contains("--all")
    let startAfterReset = flags.contains("--start")
    resetProgress(removeAll: removeAll)
    return startAfterReset
}

func handleStatsCommand(_ args: [String]) {
    if let flag = args.first?.lowercased(), ["--help", "-h", "help"].contains(flag) {
        printStatsUsage()
        return
    }
    let settings = parseStatsSettings(args)
    if settings.resetAll {
        resetAllStats()
        return
    }
    if settings.reset {
        resetAdaptiveStats()
        return
    }
    clearScreen()
    printAdaptiveStats(statsLimit: settings.limit)
}

func handleReportOverridesCommand(_ args: [String], sets: ChallengeSets) {
    if let flag = args.first?.lowercased(), ["--help", "-h", "help"].contains(flag) {
        printOverrideReportUsage()
        return
    }

    var threshold = 12
    if args.count > 1 {
        let lowerArgs = args.map { $0.lowercased() }
        if let idx = lowerArgs.firstIndex(of: "--threshold"), idx + 1 < lowerArgs.count {
            if let value = Int(lowerArgs[idx + 1]) {
                threshold = max(1, value)
            }
        }
    }
    reportOverrideSuggestions(sets: sets, threshold: threshold)
}

func handleCatalogCommand(_ args: [String], allChallenges: [Challenge]) {
    if args.contains("--help") || args.contains("-h") || args.contains("help") {
        printCatalogUsage()
        return
    }
    if !args.isEmpty {
        print("Catalog does not accept flags.")
        printCatalogUsage()
        return
    }
    printChallengeCatalogTable(allChallenges)
}

func handleCatalogProjectsCommand(_ args: [String], projects: [Project]) {
    if args.contains("--help") || args.contains("-h") || args.contains("help") {
        printProjectCatalogUsage()
        return
    }
    if !args.isEmpty {
        print("Catalog does not accept flags.")
        printProjectCatalogUsage()
        return
    }
    printProjectCatalogTable(projects)
}

func handleReportCommand(_ args: [String]) {
    if let flag = args.first?.lowercased(), ["--help", "-h", "help"].contains(flag) {
        printReportUsage()
        return
    }
    clearScreen()
    printForgeReport()
}

func handleAIGenerateCommand(_ args: [String]) {
    if args.contains(where: { helpTokens.contains($0.lowercased()) }) {
        printAIGenerateUsage()
        return
    }

    let parsed = parseAIGenerateSettings(args)
    guard let settings = parsed.settings else {
        if let error = parsed.error {
            print(error)
        } else {
            print("Invalid ai-generate options.")
        }
        printAIGenerateUsage()
        return
    }

    do {
        let result = try runAIGenerateScaffold(settings: settings)
        print("AI generation scaffold is active.")
        print("Provider: \(result.provider)")
        if let model = result.model {
            print("Model: \(model)")
        } else {
            print("Model: (not set)")
        }
        if result.live, result.status == "live_success" {
            print("Mode: live provider call.")
        } else if result.live {
            print("Mode: live fallback (scaffold).")
        } else if result.dryRun {
            print("Mode: dry-run (no model calls).")
        } else {
            print("Mode: scaffold-only (provider integration pending).")
        }
        print("Output path: \(result.outputPath)")
        print("Status: \(result.status)")
        print("Artifacts:")
        print("- \(result.requestPath)")
        print("- \(result.candidatePath)")
        print("- \(result.reportPath)")
        for warning in result.warnings {
            print("Warning: \(warning)")
        }
    } catch {
        print("ai-generate failed: \(error.localizedDescription)")
    }
}

func handleVerifyCommand(
    _ args: [String],
    allChallenges: [Challenge],
    enableConstraintProfiles: Bool
) {
    let bridgeOnly = args.contains { $0.lowercased() == "bridge" }
    let verifySettings = parseVerifySettings(args)
    let (range, topic, tier, layer) = parseVerifyArguments(verifySettings.remaining)
    var pool = allChallenges
    if bridgeOnly {
        pool = pool.filter { $0.displayId.hasPrefix("bridge:") }
    } else {
        pool = pool.filter { !$0.displayId.hasPrefix("bridge:") }
    }
    if let range = range {
        pool = pool.filter { range.contains(layerIndex(for: $0)) }
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
    if verifySettings.constraintsOnly {
        _ = verifyConstraintProfiles(pool, enableConstraintProfiles: enableConstraintProfiles)
    } else {
        _ = verifyChallengeSolutions(pool, enableConstraintProfiles: enableConstraintProfiles)
    }
}

func handleReviewCommand(
    _ args: [String],
    sets: ChallengeSets,
    constraintIndex: ConstraintIndex,
    enableDiMockHeuristics: Bool
) {
    let bridgeOnly = args.contains { $0.lowercased() == "bridge" }
    let (range, topic, tier, layer) = parseVerifyArguments(args)
    var pool =
        sets.core1Challenges
        + sets.core2Challenges
        + sets.core3Challenges
        + sets.mantleChallenges
        + sets.crustChallenges
        + sets.bridgeChallenges.coreToMantle
        + sets.bridgeChallenges.mantleToCrust
    if bridgeOnly {
        pool = pool.filter { $0.displayId.hasPrefix("bridge:") }
    }
    if let range = range {
        pool = pool.filter { range.contains(layerIndex(for: $0)) }
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
    _ = reviewProgression(
        pool,
        constraintIndex: constraintIndex,
        enableDiMockHeuristics: enableDiMockHeuristics
    )
}

func handlePracticeCommand(
    _ args: [String],
    runtime: RuntimeContext,
    paths: CLIPaths,
    flags: GlobalFlags
) {
    if args.first?.lowercased() == "help" || args.first == "--help" {
        printPracticeUsage()
        return
    }

    var practiceArgs = args
    let reportOnly = practiceArgs.contains { ["--report", "report"].contains($0.lowercased()) }
    practiceArgs = practiceArgs.filter { !["--report", "report"].contains($0.lowercased()) }

    setupWorkspace(at: paths.explicitPracticeWorkspace)
    clearWorkspaceContents(at: paths.explicitPracticeWorkspace)

    let (count, topic, tier, layer, range, includeAll, bridgeOnly) = parsePracticeArguments(practiceArgs)
    let progressStep = normalizedStepIndex(getCurrentProgress(), stepsCount: runtime.steps.count)
    let pool = filteredPracticePool(
        from: runtime.allChallenges,
        steps: runtime.steps,
        progressStep: progressStep,
        topic: topic,
        tier: tier,
        layer: layer,
        range: range,
        includeAll: includeAll,
        bridgeOnly: bridgeOnly
    )

    if pool.isEmpty {
        print("No challenges match those filters.")
        return
    }

    let selectionCount = min(count, pool.count)
    let stats = loadAdaptiveStats(workspacePath: "workspace")
    let challengeStats = loadAdaptiveChallengeStats(workspacePath: "workspace")

    if reportOnly {
        printPracticeReport(pool: pool, stats: stats, challengeStats: challengeStats)
        return
    }

    let selection = pickAdaptivePracticeSet(
        from: pool,
        stats: stats,
        challengeStats: challengeStats,
        count: selectionCount
    )
    print("Practice mode: \(selection.count) challenge(s).")
    if let summary = practiceAdaptiveSummary(from: pool, stats: stats) {
        print(summary)
    }
    print("Workspace: \(paths.explicitPracticeWorkspace)\n")
    runPracticeChallenges(
        selection,
        workspacePath: paths.explicitPracticeWorkspace,
        statsWorkspacePath: "workspace",
        constraintIndex: runtime.constraintIndex,
        confirmCheckEnabled: flags.confirmCheckEnabled,
        confirmSolutionEnabled: flags.confirmSolutionEnabled,
        enableConstraintProfiles: flags.enableConstraintProfiles,
        trackAssisted: false,
        enforceConstraints: flags.enforceConstraints,
        enableDiMockHeuristics: flags.enableDiMockHeuristics,
        completionTitle: "✅ Practice set complete!",
        finishPrompt: "Press Enter to finish."
    )
}

func handleAuditCommand(
    _ args: [String],
    allChallenges: [Challenge],
    constraintIndex: ConstraintIndex,
    enableDiMockHeuristics: Bool,
    enableConstraintProfiles: Bool
) {
    let bridgeOnly = args.contains { $0.lowercased() == "bridge" }
    if args.first?.lowercased() == "help" || args.first == "--help" {
        printAuditUsage()
        return
    }

    let (range, topic, tier, layer) = parseVerifyArguments(args)
    var pool = allChallenges
    if bridgeOnly {
        pool = pool.filter { $0.displayId.hasPrefix("bridge:") }
    }
    if let range = range {
        pool = pool.filter { range.contains(layerIndex(for: $0)) }
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
    if !bridgeOnly {
        pool = pool.filter { !$0.displayId.hasPrefix("bridge:") }
    }
    if pool.isEmpty {
        print("No challenges match those filters.")
        return
    }

    let reviewOk = reviewProgression(
        pool,
        constraintIndex: constraintIndex,
        enableDiMockHeuristics: enableDiMockHeuristics
    )
    let constraintsOk = verifyConstraintProfiles(pool, enableConstraintProfiles: enableConstraintProfiles)
    let fixturesOk = auditFixtures(pool)
    _ = reviewOk && constraintsOk && fixturesOk
}

func handleRandomCommand(
    _ args: [String],
    allChallenges: [Challenge],
    constraintIndex: ConstraintIndex,
    paths: CLIPaths,
    flags: GlobalFlags
) {
    setupWorkspace(at: paths.practiceWorkspace)
    setupWorkspace(at: paths.projectWorkspace)
    clearWorkspaceContents(at: paths.practiceWorkspace)
    clearWorkspaceContents(at: paths.projectWorkspace)

    if args.contains(where: { helpTokens.contains($0.lowercased()) }) {
        printRandomUsage()
        return
    }

    let (count, topic, tier, layer, adaptive, bridgeOnly) = parseRandomArguments(args)
    let pool = filteredPracticePool(
        from: allChallenges,
        steps: [],
        progressStep: 0,
        topic: topic,
        tier: tier,
        layer: layer,
        range: nil,
        includeAll: true,
        bridgeOnly: bridgeOnly
    )

    if pool.isEmpty {
        print("No challenges match those filters.")
        return
    }

    let selectionCount = min(count, pool.count)
    let stats = loadAdaptiveStats(workspacePath: "workspace")
    let challengeStats = loadAdaptiveChallengeStats(workspacePath: "workspace")
    let selection = adaptive
        ? pickAdaptivePracticeSet(from: pool, stats: stats, challengeStats: challengeStats, count: selectionCount)
        : weightedRandomSelection(
            from: pool,
            weight: { topicScore(for: $0.topic, stats: stats) },
            count: selectionCount
        )

    clearScreen()
    print("Random mode: \(selectionCount) challenge(s).")
    print("Workspace: \(paths.practiceWorkspace)\n")
    runPracticeChallenges(
        selection,
        workspacePath: paths.practiceWorkspace,
        statsWorkspacePath: "workspace",
        constraintIndex: constraintIndex,
        confirmCheckEnabled: flags.confirmCheckEnabled,
        confirmSolutionEnabled: flags.confirmSolutionEnabled,
        enableConstraintProfiles: flags.enableConstraintProfiles,
        trackAssisted: false,
        enforceConstraints: flags.enforceConstraints,
        enableDiMockHeuristics: flags.enableDiMockHeuristics
    )
}

func handleProjectCommand(_ args: [String], projects: [Project], paths: CLIPaths, flags: GlobalFlags) {
    setupWorkspace(at: paths.projectWorkspace)
    setupWorkspace(at: paths.practiceWorkspace)
    clearWorkspaceContents(at: paths.projectWorkspace)
    clearWorkspaceContents(at: paths.practiceWorkspace)

    guard !args.isEmpty else {
        printProjectUsage()
        return
    }

    let projectCommand = args[0].lowercased()
    if ["--help", "-h", "help"].contains(projectCommand) {
        printProjectUsage()
        return
    }

    if ["--list", "-l", "list"].contains(projectCommand) {
        let listArgs = Array(args.dropFirst())
        let (tier, layer) = parseProjectListArguments(listArgs)
        printProjectList(projects, tier: tier, layer: layer)
        return
    }

    if ["--random", "-r", "random"].contains(projectCommand) {
        let randomArgs = Array(args.dropFirst())
        let (tier, layer) = parseProjectRandomArguments(randomArgs)
        guard let project = pickRandomProject(projects, tier: tier, layer: layer) else {
            print("No projects match those filters.")
            return
        }

        clearScreen()
        print("Project mode: \(project.title)")
        print("Workspace: \(paths.projectWorkspace)\n")
        let completed = runProject(
            project,
            workspacePath: paths.projectWorkspace,
            confirmCheckEnabled: flags.confirmCheckEnabled,
            confirmSolutionEnabled: flags.confirmSolutionEnabled,
            trackAssisted: false
        )
        print("Press Enter to finish.\n")
        _ = readLine()
        if completed {
            try? FileManager.default.removeItem(atPath: "\(paths.projectWorkspace)/\(project.filename)")
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
    print("Workspace: \(paths.projectWorkspace)\n")
    let completed = runProject(
        project,
        workspacePath: paths.projectWorkspace,
        confirmCheckEnabled: flags.confirmCheckEnabled,
        confirmSolutionEnabled: flags.confirmSolutionEnabled,
        trackAssisted: false
    )
    print("Press Enter to finish.\n")
    _ = readLine()
    if completed {
        try? FileManager.default.removeItem(atPath: "\(paths.projectWorkspace)/\(project.filename)")
    }
}

func handleRemapProgressCommand(_ args: [String], runtime: RuntimeContext) {
    if args.first?.lowercased() == "help" || args.first == "--help" || args.first == "-h" {
        printRemapProgressUsage()
        return
    }

    let rawToken: String? = args.first ?? getProgressToken()
    guard let tokenRaw = rawToken?.trimmingCharacters(in: .whitespacesAndNewlines), !tokenRaw.isEmpty else {
        print("No progress token found.")
        printRemapProgressUsage()
        return
    }

    if args.isEmpty, Int(tokenRaw) != nil {
        print("Progress file contains a step index. Provide an explicit target to remap (e.g., challenge:core:18).")
        printRemapProgressUsage()
        return
    }

    switch remapProgressToken(
        tokenRaw,
        challengeIndexMap: runtime.challengeIndexMap,
        challengeIdIndexMap: runtime.challengeIdIndexMap,
        allChallengeIdMap: runtime.allChallengeIdMap,
        allChallengeNumberMap: runtime.allChallengeNumberMap,
        projectIndexMap: runtime.projectIndexMap,
        projects: runtime.projects,
        stepsCount: runtime.steps.count
    ) {
    case .success(let startIndex, let messagePrefix):
        setupWorkspace()
        saveProgress(startIndex)
        print("\(messagePrefix) (step \(startIndex): \(stepLabel(for: runtime.steps, index: startIndex))).")
    case .info(let message):
        print(message)
    case .error(let message, let showUsage):
        print(message)
        if showUsage {
            printRemapProgressUsage()
        }
    }
}

func handleProgressCommand(_ args: [String], runtime: RuntimeContext) {
    if args.isEmpty || helpTokens.contains(args[0].lowercased()) {
        printProgressUsage()
        return
    }
    guard let input = parseProgressInput(args) else {
        print("Invalid progress target.")
        printProgressUsage()
        return
    }

    let startIndex: Int
    switch input {
    case .step(let rawStep):
        startIndex = normalizedStepIndex(rawStep, stepsCount: runtime.steps.count)
    case .project(let projectId):
        if let index = runtime.projectIndexMap[projectId] {
            startIndex = index
        } else if runtime.projects.contains(where: { $0.id.lowercased() == projectId }) {
            print("Project \(projectId) is not part of the main flow. Use project mode instead.")
            return
        } else {
            print("Unknown project id: \(projectId)")
            return
        }
    case .challenge(let number):
        if let index = runtime.challengeIndexMap[number] {
            startIndex = index
        } else if let extraChallenge = runtime.allChallengeNumberMap[number], extraChallenge.tier == .extra {
            print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
            return
        } else {
            startIndex = stepIndexForChallenge(
                number,
                challengeStepIndex: runtime.challengeIndexMap,
                maxChallengeNumber: runtime.maxChallengeNumber,
                stepsCount: runtime.steps.count
            )
        }
    case .challengeId(let rawId):
        let id = rawId.lowercased()
        if let extraChallenge = runtime.allChallengeIdMap[id], extraChallenge.tier == .extra {
            print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
            return
        }
        guard let index = runtime.challengeIdIndexMap[id] else {
            print("Unknown challenge id: \(rawId)")
            return
        }
        startIndex = index
    }

    setupWorkspace()
    saveProgress(startIndex)
    print("Progress set to step \(startIndex) (\(stepLabel(for: runtime.steps, index: startIndex))).")
}

func handleRunCommand(
    overrideToken: String?,
    runtime: RuntimeContext,
    paths: CLIPaths,
    flags: GlobalFlags
) {
    setupWorkspace()
    setupWorkspace(at: paths.practiceWorkspace)
    setupWorkspace(at: paths.projectWorkspace)
    clearWorkspaceContents(at: paths.practiceWorkspace)
    clearWorkspaceContents(at: paths.projectWorkspace)

    let progressToken = overrideToken ?? getProgressToken() ?? "1"
    let progressTarget = parseProgressTarget(progressToken, projects: runtime.projects)
    let startIndex: Int
    var extraNotice: String? = nil

    switch progressTarget {
    case .completed:
        startIndex = runtime.steps.count + 1
    case .project(let projectId):
        startIndex = runtime.projectIndexMap[projectId] ?? 1
    case .challenge(let number):
        if let index = runtime.challengeIndexMap[number] {
            startIndex = index
        } else if let extraChallenge = runtime.allChallengeNumberMap[number], extraChallenge.tier == .extra {
            extraNotice = "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras."
            startIndex = runtime.steps.count + 1
        } else {
            startIndex = stepIndexForChallenge(
                number,
                challengeStepIndex: runtime.challengeIndexMap,
                maxChallengeNumber: runtime.maxChallengeNumber,
                stepsCount: runtime.steps.count
            )
        }
    case .challengeId(let id):
        if let index = runtime.challengeIdIndexMap[id.lowercased()] {
            startIndex = index
        } else if let extraChallenge = runtime.allChallengeIdMap[id.lowercased()], extraChallenge.tier == .extra {
            extraNotice = "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras."
            startIndex = runtime.steps.count + 1
        } else {
            startIndex = 1
        }
    case .step(let rawProgress):
        startIndex = normalizedStepIndex(rawProgress, stepsCount: runtime.steps.count)
    }

    if startIndex == 1 {
        clearScreen()
        displayWelcome()
    }

    clearScreen()
    print("The Will to Empower.\n")
    if flags.adaptiveEnabled, let pending = loadPendingPractice(workspacePath: "workspace") {
        print("Pending assisted practice detected for \(pending.topic.rawValue). You'll resume it before continuing.\n")
    }

    if startIndex <= runtime.steps.count {
        runSteps(
            runtime.steps,
            startingAt: startIndex,
            constraintIndex: runtime.constraintIndex,
            practicePool: runtime.allChallenges,
            practiceWorkspace: paths.practiceWorkspace,
            adaptiveThreshold: flags.adaptiveThreshold,
            adaptiveCount: flags.adaptiveCount,
            adaptiveMinTopicFailures: flags.adaptiveMinTopicFailures,
            adaptiveMinChallengeFailures: flags.adaptiveMinChallengeFailures,
            adaptiveCooldownSteps: flags.adaptiveCooldownSteps,
            adaptiveEnabled: flags.adaptiveEnabled,
            enableConstraintProfiles: flags.enableConstraintProfiles,
            confirmCheckEnabled: flags.confirmCheckEnabled,
            confirmSolutionEnabled: flags.confirmSolutionEnabled,
            enforceConstraints: flags.enforceConstraints,
            enableDiMockHeuristics: flags.enableDiMockHeuristics
        )
    } else {
        if let extraNotice = extraNotice {
            print(extraNotice)
        }
        print("🎉 You've completed everything!")
        print("Run 'swift run forge reset' to start over.\n")
    }
}
