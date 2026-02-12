// forge.swift

import Foundation

enum Step {
    case challenge(Challenge)
    case project(Project)
    case stageGate(StageGate)
}

enum ProgressTarget {
    case challenge(Int)
    case challengeId(String)
    case step(Int)
    case project(String)
    case completed
}

enum ProgressInput {
    case challenge(Int)
    case challengeId(String)
    case project(String)
    case step(Int)
}

enum RemapProgressOutcome {
    case success(startIndex: Int, messagePrefix: String)
    case info(message: String)
    case error(message: String, showUsage: Bool)
}

struct ConstraintIndex {
    let introByConcept: [ConstraintConcept: Int]
    let legacyMinByConcept: [ConstraintConcept: Int]
}

struct StageGate {
    let id: String
    let title: String
    let pool: [Challenge]
    let requiredPasses: Int
    let count: Int
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



func layerIndex(for challenge: Challenge) -> Int {
    if challenge.displayId.hasPrefix("bridge:") {
        return 0
    }
    return challenge.layerNumber ?? challenge.number
}


func previousChallengeIndex(from steps: [Step], before index: Int) -> Int? {
    guard index > 0 else { return nil }
    for i in stride(from: index - 1, through: 0, by: -1) {
        if case .challenge = steps[i] {
            return i
        }
    }
    return nil
}



func topicScore(for topic: ChallengeTopic, stats: [String: [String: Int]]) -> Int {
    let topicStats = stats[topic.rawValue] ?? [:]
    let failures = (topicStats["fail"] ?? 0) + (topicStats["compile_fail"] ?? 0)
    let passes = (topicStats["pass"] ?? 0) + (topicStats["manual_pass"] ?? 0)
    return max(1, 1 + failures - passes)
}

func challengeScore(for challenge: Challenge, stats: [String: ChallengeStats]) -> Int {
    let entry = stats[challenge.displayId] ?? ChallengeStats()
    let failures = entry.fail + entry.compileFail
    let passes = entry.pass + entry.manualPass
    return max(0, failures - passes)
}

func recencyBonus(for challenge: Challenge, stats: [String: ChallengeStats], now: Int) -> Int {
    let entry = stats[challenge.displayId] ?? ChallengeStats()
    guard entry.lastAttempt > 0 else { return 2 }
    let age = max(0, now - entry.lastAttempt)
    if age < 300 {
        return 0
    }
    if age < 1800 {
        return 1
    }
    if age < 7200 {
        return 2
    }
    return 3
}

func adaptiveChallengeWeight(
    challenge: Challenge,
    topicStats: [String: [String: Int]],
    challengeStats: [String: ChallengeStats],
    now: Int
) -> Int {
    let base = topicScore(for: challenge.topic, stats: topicStats)
    let failures = challengeScore(for: challenge, stats: challengeStats)
    let recency = recencyBonus(for: challenge, stats: challengeStats, now: now)
    let extraBonus = challenge.tier == .extra ? 1 : 0
    return max(1, base + failures + recency + extraBonus)
}

func adaptivePracticePool(
    for challenge: Challenge,
    from pool: [Challenge],
    windowSize: Int = 8
) -> [Challenge] {
    let challengeIndex = max(1, layerIndex(for: challenge))
    let minNumber = max(1, challengeIndex - windowSize)
    return pool.filter { candidate in
        guard candidate.topic == challenge.topic else { return false }
        guard candidate.layer == challenge.layer else { return false }
        let candidateIndex = max(1, layerIndex(for: candidate))
        guard candidateIndex <= challengeIndex else { return false }
        guard candidateIndex >= minNumber else { return false }
        return candidate.progressId != challenge.progressId
    }
}

func weightedRandomSelection<T>(
    from items: [T],
    weight: (T) -> Int,
    count: Int
) -> [T] {
    guard count > 0 else { return [] }
    var remaining = items
    var selection: [T] = []
    for _ in 0..<min(count, remaining.count) {
        let weights = remaining.map { max(1, weight($0)) }
        let total = weights.reduce(0, +)
        let roll = Int.random(in: 0..<total)
        var cursor = 0
        var pickedIndex = 0
        for (index, value) in weights.enumerated() {
            cursor += value
            if roll < cursor {
                pickedIndex = index
                break
            }
        }
        selection.append(remaining.remove(at: pickedIndex))
    }
    return selection
}

func printStageReviewDebrief(startedAt: Date, workspacePath: String = "workspace") {
    let entries = loadPerformanceLogEntries(workspacePath: workspacePath)
    var attempts: [String: Int] = [:]
    var violationsByTopic: [String: Int] = [:]
    let topicIndex = buildChallengeTopicIndex()

    for line in entries {
        guard let timestampValue = extractLogField(line, key: "timestamp"),
              let timestamp = parseLogTimestamp(timestampValue),
              timestamp >= startedAt else { continue }

        if extractLogField(line, key: "mode") != "stage_review" {
            continue
        }

        if let event = extractLogField(line, key: "event"), event == "challenge_attempt" {
            if let result = extractLogField(line, key: "result") {
                attempts[result, default: 0] += 1
            }
        } else if let event = extractLogField(line, key: "event"), event == "constraint_violation" {
            if let id = extractLogField(line, key: "id"), let topic = topicIndex[id] {
                violationsByTopic[topic, default: 0] += 1
            }
        }
    }

    if attempts.isEmpty && violationsByTopic.isEmpty {
        return
    }

    print("Stage review debrief:")
    if !attempts.isEmpty {
        let pass = attempts["pass", default: 0]
        let fail = attempts["fail", default: 0]
        let compileFail = attempts["compile_fail", default: 0]
        let total = pass + fail + compileFail
        print("- Attempts: \(total) (pass=\(pass), fail=\(fail), compile_fail=\(compileFail))")
    }
    if !violationsByTopic.isEmpty {
        let topTopics = violationsByTopic.sorted { $0.value > $1.value }.prefix(3)
        let summary = topTopics.map { "\($0.key)(\($0.value))" }.joined(separator: ", ")
        print("- Constraint warnings: \(summary)")
    }
    print("")
}

func buildChallengeTopicIndex() -> [String: String] {
    let sets = buildChallengeSets()
    let allChallenges = sets.allChallenges

    var index: [String: String] = [:]
    for challenge in allChallenges {
        index[challenge.displayId] = challenge.topic.rawValue
    }
    return index
}

func buildChallengeTitleIndex() -> [String: String] {
    let sets = buildChallengeSets()
    let allChallenges = sets.allChallenges

    var index: [String: String] = [:]
    for challenge in allChallenges {
        index[challenge.displayId] = challenge.title
    }
    return index
}

struct ChallengeSets {
    let core1Challenges: [Challenge]
    let core2Challenges: [Challenge]
    let core3Challenges: [Challenge]
    let mantleChallenges: [Challenge]
    let crustChallenges: [Challenge]
    let bridgeChallenges: (coreToMantle: [Challenge], mantleToCrust: [Challenge])
    let allChallenges: [Challenge]
}

func assignCanonicalIds(
    for challenges: [Challenge],
    layer: ChallengeLayer,
    overrideParents: [Int: Int] = [:]
) -> [Challenge] {
    var nextLayerNumber = 0
    var mainlineEntries: [(index: Int, topic: ChallengeTopic, number: Int)] = []
    var baseNumbers: [Int?] = Array(repeating: nil, count: challenges.count)

    for (index, challenge) in challenges.enumerated() {
        if challenge.tier == .mainline, overrideParents[challenge.number] == nil {
            nextLayerNumber += 1
            let baseNumber = nextLayerNumber
            baseNumbers[index] = baseNumber
            mainlineEntries.append((index: index, topic: challenge.topic, number: baseNumber))
        }
    }

    func nearestPriorMainlineNumber(for index: Int, topic: ChallengeTopic) -> Int? {
        let priorTopic = mainlineEntries
            .filter { $0.topic == topic && $0.index < index }
            .max(by: { $0.index < $1.index })
        if let candidate = priorTopic {
            return candidate.number
        }
        let priorAny = mainlineEntries
            .filter { $0.index < index }
            .max(by: { $0.index < $1.index })
        if let candidate = priorAny {
            return candidate.number
        }
        return mainlineEntries.first?.number
    }

    var extraCounts: [Int: Int] = [:]
    return challenges.enumerated().map { index, challenge in
        if challenge.tier == .mainline, overrideParents[challenge.number] == nil {
            let baseNumber = baseNumbers[index] ?? 1
            let canonicalId = "\(layer.rawValue):\(baseNumber)"
            return challenge.withCanonicalId(
                canonicalId,
                layerNumber: baseNumber,
                extraParent: nil,
                extraIndex: nil
            )
        }
        let overrideParent = overrideParents[challenge.number]
        let parent = overrideParent ?? nearestPriorMainlineNumber(for: index, topic: challenge.topic) ?? 1
        let nextIndex = (extraCounts[parent] ?? 0) + 1
        extraCounts[parent] = nextIndex
        let canonicalId = "\(layer.rawValue):\(parent).\(nextIndex)"
        return challenge.withCanonicalId(
            canonicalId,
            layerNumber: parent,
            extraParent: parent,
            extraIndex: nextIndex
        )
    }
}

func assignBridgeIds(
    for challenges: [Challenge],
    layer: ChallengeLayer
) -> [Challenge] {
    return challenges.enumerated().map { index, challenge in
        let ordinal = index + 1
        let canonicalId = "bridge:\(layer.rawValue):\(ordinal)"
        return challenge.withCanonicalId(
            canonicalId,
            layerNumber: 0,
            extraParent: nil,
            extraIndex: nil
        )
    }
}

func buildChallengeSets() -> ChallengeSets {
    let core1Challenges = makeCore1Challenges()
    let core2Challenges = makeCore2Challenges()
    let core3Challenges = makeCore3Challenges()
    let mantleChallenges = makeMantleChallenges()
    let crustChallenges = makeCrustChallenges()
    let bridgeChallenges = makeBridgeChallenges()

    let coreAll = core1Challenges + core2Challenges + core3Challenges
    let mantleAll = mantleChallenges
    let crustAll = crustChallenges

    let extraParentOverridesCore: [Int: Int] = [:]
    let extraParentOverridesMantle: [Int: Int] = [:]
    let extraParentOverridesCrust: [Int: Int] = [:]

    let canonicalCore = assignCanonicalIds(for: coreAll, layer: .core, overrideParents: extraParentOverridesCore)
    let canonicalMantle = assignCanonicalIds(for: mantleAll, layer: .mantle, overrideParents: extraParentOverridesMantle)
    let canonicalCrust = assignCanonicalIds(for: crustAll, layer: .crust, overrideParents: extraParentOverridesCrust)
    let canonicalBridgeMantle = assignBridgeIds(for: bridgeChallenges.coreToMantle, layer: .mantle)
    let canonicalBridgeCrust = assignBridgeIds(for: bridgeChallenges.mantleToCrust, layer: .crust)

    let canonicalMap = Dictionary(
        uniqueKeysWithValues: (canonicalCore + canonicalMantle + canonicalCrust + canonicalBridgeMantle + canonicalBridgeCrust)
            .map { ($0.number, $0) }
    )

    let mappedCore1 = core1Challenges.map { canonicalMap[$0.number] ?? $0 }
    let mappedCore2 = core2Challenges.map { canonicalMap[$0.number] ?? $0 }
    let mappedCore3 = core3Challenges.map { canonicalMap[$0.number] ?? $0 }
    let mappedMantle = mantleChallenges.map { canonicalMap[$0.number] ?? $0 }
    let mappedCrust = crustChallenges.map { canonicalMap[$0.number] ?? $0 }
    let mappedBridge = (
        coreToMantle: bridgeChallenges.coreToMantle.map { canonicalMap[$0.number] ?? $0 },
        mantleToCrust: bridgeChallenges.mantleToCrust.map { canonicalMap[$0.number] ?? $0 }
    )
    let allChallenges = mappedCore1
        + mappedCore2
        + mappedCore3
        + mappedMantle
        + mappedCrust
        + mappedBridge.coreToMantle
        + mappedBridge.mantleToCrust

    return ChallengeSets(
        core1Challenges: mappedCore1,
        core2Challenges: mappedCore2,
        core3Challenges: mappedCore3,
        mantleChallenges: mappedMantle,
        crustChallenges: mappedCrust,
        bridgeChallenges: mappedBridge,
        allChallenges: allChallenges
    )
}


func constraintTopicTableLines(
    _ violationsByTopic: [String: Int],
    limit: Int?
) -> [String] {
    func padded(_ text: String, width: Int) -> String {
        if text.count >= width {
            return String(text.prefix(width))
        }
        return text + String(repeating: " ", count: width - text.count)
    }

    let sortedTopics = violationsByTopic.sorted { $0.value > $1.value }
    let header = "\(padded("Topic", width: 16)) \(padded("Count", width: 5))"
    let separator = String(repeating: "-", count: header.count)
    let maxRows = limit ?? sortedTopics.count
    let rows = sortedTopics.prefix(maxRows).map { topic, count in
        "\(padded(topic, width: 16)) \(padded(String(count), width: 5))"
    }
    return [header, separator] + rows
}

func runSwiftProcess(file: String, arguments: [String] = [], stdin: String? = nil) -> (output: String, exitCode: Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    let fileURL = URL(fileURLWithPath: file).standardizedFileURL
    process.arguments = [fileURL.path] + arguments
    process.currentDirectoryURL = fileURL.deletingLastPathComponent()

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    let inputPipe = Pipe()
    if stdin != nil {
        process.standardInput = inputPipe
    }

    do {
        try process.run()
        if let stdin = stdin, let data = stdin.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
        if stdin != nil {
            inputPipe.fileHandleForWriting.closeFile()
        }
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return (output, process.terminationStatus)
    } catch {
        return ("", -1)
    }
}

func compileAndRunWithTimeout(
    file: String,
    arguments: [String] = [],
    stdin: String? = nil,
    timeoutSeconds: TimeInterval
) -> (output: String?, timedOut: Bool, exitCode: Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    let fileURL = URL(fileURLWithPath: file).standardizedFileURL
    process.arguments = [fileURL.path] + arguments
    process.currentDirectoryURL = fileURL.deletingLastPathComponent()

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    let inputPipe = Pipe()
    if stdin != nil {
        process.standardInput = inputPipe
    }

    do {
        try process.run()
        if let stdin = stdin, let data = stdin.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
        if stdin != nil {
            inputPipe.fileHandleForWriting.closeFile()
        }
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

func loadFixtureContents(_ name: String) -> String? {
    let path = "fixtures/\(name)"
    return try? String(contentsOfFile: path, encoding: .utf8)
}

func copyFixtureFile(named name: String, to workspacePath: String) {
    let sourcePath = "fixtures/\(name)"
    let destinationPath = "\(workspacePath)/\(name)"
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: destinationPath) {
        try? fileManager.removeItem(atPath: destinationPath)
    }
    try? fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
}

func prepareChallengeEnvironment(
    _ challenge: Challenge,
    workspacePath: String
) -> (stdin: String?, args: [String], copiedFixturePaths: [String]) {
    var stdin: String? = nil
    if let fixture = challenge.stdinFixture {
        stdin = loadFixtureContents(fixture)
    }

    var args: [String] = []
    if let fixture = challenge.argsFixture {
        let contents = loadFixtureContents(fixture) ?? ""
        args = contents.split { $0 == " " || $0 == "\n" || $0 == "\t" }.map { String($0) }
    }

    var copiedFixturePaths: [String] = []
    for file in challenge.fixtureFiles {
        copyFixtureFile(named: file, to: workspacePath)
        copiedFixturePaths.append("\(workspacePath)/\(file)")
    }

    return (stdin, args, copiedFixturePaths)
}

func removePreparedFixtureFiles(_ paths: [String]) {
    let fileManager = FileManager.default
    for path in paths {
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
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

func skipReasonForVerification(challenge: Challenge) -> String? {
    let combined = challenge.starterCode + "\n" + challenge.solution
    if combined.contains("readLine("), challenge.stdinFixture == nil {
        return "requires stdin"
    }
    if combined.contains("CommandLine.arguments"), challenge.argsFixture == nil {
        return "requires arguments"
    }
    if (combined.contains("contentsOfFile") || combined.contains("FileHandle") || combined.contains("FileManager")),
       challenge.fixtureFiles.isEmpty {
        return "requires file IO"
    }
    return nil
}

func verifyChallengeSolutions(
    _ challenges: [Challenge],
    enableConstraintProfiles: Bool
) -> Bool {
    let workspacePath = "workspace_verify"
    setupWorkspace(at: workspacePath)
    clearWorkspaceContents(at: workspacePath)
    let constraintIndex = buildConstraintIndex(from: challenges)

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
        if let reason = skipReasonForVerification(challenge: challenge) {
            skipped += 1
            skippedReasons[reason, default: 0] += 1
            continue
        }

        let filePath = "\(workspacePath)/\(challenge.filename)"
        let expected = challenge.expectedOutput

        var passed = false
        var lastExitCode: Int32 = 0
        clearWorkspaceContents(at: workspacePath)
        let (stdin, args, _) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
        try? solution.write(toFile: filePath, atomically: true, encoding: .utf8)
        if let source = try? String(contentsOfFile: filePath, encoding: .utf8) {
            let violations = constraintViolations(
                for: source,
                challenge: challenge,
                enabled: enableConstraintProfiles,
                index: constraintIndex
            )
            if !violations.isEmpty {
                failures.append((challenge.displayId, "constraint violation"))
                continue
            }
        }
        let firstRun = compileAndRunWithTimeout(
            file: filePath,
            arguments: args,
            stdin: stdin,
            timeoutSeconds: 2.0
        )
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
            let secondRun = compileAndRunWithTimeout(
                file: filePath,
                arguments: args,
                stdin: stdin,
                timeoutSeconds: 2.0
            )
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

func verifyConstraintProfiles(
    _ challenges: [Challenge],
    enableConstraintProfiles: Bool
) -> Bool {
    if !enableConstraintProfiles {
        print("Constraint profiles disabled; skipping verification.")
        return true
    }

    let constraintIndex = buildConstraintIndex(from: challenges)
    var failures: [(id: String, reason: String)] = []
    var skipped = 0
    var skippedReasons: [String: Int] = [:]
    var checked = 0

    print("Verifying constraint profiles for \(challenges.count) challenge(s)...")

    for (index, challenge) in challenges.enumerated() {
        if challenge.constraintProfile == nil && topicConstraintProfiles[challenge.topic] == nil {
            skipped += 1
            skippedReasons["no profile", default: 0] += 1
            continue
        }
        let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
        if solution.isEmpty {
            skipped += 1
            skippedReasons["missing solution", default: 0] += 1
            continue
        }
        let combined = applySolutionToStarter(starterCode: challenge.starterCode, solution: solution)
        let violations = constraintViolations(
            for: combined,
            challenge: challenge,
            enabled: enableConstraintProfiles,
            index: constraintIndex
        )
        if !violations.isEmpty {
            let reason = violations.first ?? "constraint violation"
            failures.append((challenge.displayId, reason))
        } else {
            checked += 1
        }

        if (index + 1) % 25 == 0 {
            print("Checked \(index + 1)/\(challenges.count)...")
        }
    }

    if failures.isEmpty {
        print("✓ Verified constraint profiles: \(checked)")
        if skipped > 0 {
            let reasons = skippedReasons.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", ")
            print("Skipped: \(skipped) (\(reasons))")
        }
        return true
    }

    print("✗ Constraint profile verification failed for \(failures.count) challenge(s).")
    for failure in failures {
        print("- \(failure.id): \(failure.reason)")
    }
    return false
}

func isExpectedOutput(_ output: String, expected: String) -> Bool {
    let normalizedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalizedOutput == normalizedExpected
}

func legacyConstraintMinimums() -> [ConstraintConcept: Int] {
    return [
        .ifElse: 19,
        .switchStatement: 21,
        .forInLoop: 23,
        .whileLoop: 24,
        .repeatWhileLoop: 25,
        .breakContinue: 26,
        .ranges: 22,
        .functionsBasics: 14,
        .optionals: 37,
        .nilLiteral: 37,
        .optionalBinding: 37,
        .guardStatement: 39,
        .nilCoalescing: 40,
        .collections: 28,
        .closures: 50,
        .shorthandClosureArgs: 54,
        .map: 61,
        .filter: 62,
        .reduce: 63,
        .compactMap: 65,
        .flatMap: 66,
        .typeAlias: 67,
        .enums: 68,
        .doCatch: 72,
        .throwKeyword: 72,
        .tryKeyword: 72,
        .tryOptional: 73,
        .readLine: 74,
        .commandLineArguments: 75,
        .fileIO: 76,
        .tuples: 35,
        .asyncAwait: 172,
        .actors: 177,
        .propertyWrappers: 180,
        .protocols: 135,
        .structs: 121,
        .classes: 127,
        .properties: 121,
        .initializers: 124,
        .mutatingMethods: 125,
        .selfKeyword: 123,
        .extensions: 140,
        .whereClauses: 149,
        .associatedTypes: 148,
        .generics: 145,
        .task: 173,
        .mainActor: 178,
        .sendable: 179,
        .protocolConformance: 136,
        .protocolExtensions: 141,
        .defaultImplementations: 141,
        .taskSleep: 226,
        .taskGroup: 174,
        .accessControl: 142,
        .accessControlOpen: 143,
        .accessControlFileprivate: 142,
        .accessControlInternal: 142,
        .accessControlSetter: 142,
        .errorTypes: 72,
        .throwingFunctions: 72,
        .doTryCatch: 72,
        .tryForce: 73,
        .resultBuilders: 202,
        .macros: 203,
        .projectedValues: 182,
        .swiftpmBasics: 204,
        .swiftpmDependencies: 205,
        .buildConfigs: 206,
        .dependencyInjection: 212,
        .protocolMocking: 215,
        .comparisons: 12,
        .booleanLogic: 13,
        .compoundAssignment: 8,
        .stringInterpolation: 10,
    ]
}

func constraintConceptName(_ concept: ConstraintConcept) -> String {
    switch concept {
    case .ifElse:
        return "if/else"
    case .switchStatement:
        return "switch"
    case .forInLoop:
        return "for-in loops"
    case .whileLoop:
        return "while loops"
    case .repeatWhileLoop:
        return "repeat-while loops"
    case .breakContinue:
        return "break/continue"
    case .ranges:
        return "ranges"
    case .functionsBasics:
        return "functions"
    case .optionals:
        return "optionals"
    case .nilLiteral:
        return "nil"
    case .optionalBinding:
        return "optional binding"
    case .guardStatement:
        return "guard"
    case .nilCoalescing:
        return "nil coalescing"
    case .collections:
        return "collections"
    case .closures:
        return "closures"
    case .shorthandClosureArgs:
        return "shorthand closure args"
    case .map:
        return "map"
    case .filter:
        return "filter"
    case .reduce:
        return "reduce"
    case .compactMap:
        return "compactMap"
    case .flatMap:
        return "flatMap"
    case .typeAlias:
        return "typealias"
    case .enums:
        return "enums"
    case .doCatch:
        return "do/catch"
    case .throwKeyword:
        return "throw"
    case .tryKeyword:
        return "try"
    case .tryOptional:
        return "try?"
    case .readLine:
        return "readLine"
    case .commandLineArguments:
        return "CommandLine.arguments"
    case .fileIO:
        return "file IO"
    case .tuples:
        return "tuples"
    case .asyncAwait:
        return "async/await"
    case .actors:
        return "actors"
    case .propertyWrappers:
        return "property wrappers"
    case .protocols:
        return "protocols"
    case .structs:
        return "structs"
    case .classes:
        return "classes"
    case .properties:
        return "properties"
    case .initializers:
        return "initializers"
    case .mutatingMethods:
        return "mutating methods"
    case .selfKeyword:
        return "self"
    case .extensions:
        return "extensions"
    case .whereClauses:
        return "where clauses"
    case .associatedTypes:
        return "associated types"
    case .generics:
        return "generics"
    case .task:
        return "Task"
    case .mainActor:
        return "MainActor"
    case .sendable:
        return "Sendable"
    case .protocolConformance:
        return "protocol conformance"
    case .protocolExtensions:
        return "protocol extensions"
    case .defaultImplementations:
        return "default implementations"
    case .taskSleep:
        return "Task.sleep"
    case .taskGroup:
        return "withTaskGroup"
    case .accessControl:
        return "access control"
    case .accessControlOpen:
        return "public/open access"
    case .accessControlFileprivate:
        return "fileprivate access"
    case .accessControlInternal:
        return "internal access"
    case .accessControlSetter:
        return "private(set)"
    case .errorTypes:
        return "error types"
    case .throwingFunctions:
        return "throwing functions"
    case .doTryCatch:
        return "do/try/catch"
    case .tryForce:
        return "try!"
    case .resultBuilders:
        return "result builders"
    case .macros:
        return "macros"
    case .projectedValues:
        return "projected values"
    case .swiftpmBasics:
        return "SwiftPM basics"
    case .swiftpmDependencies:
        return "SwiftPM dependencies"
    case .buildConfigs:
        return "build configs"
    case .dependencyInjection:
        return "dependency injection"
    case .protocolMocking:
        return "protocol mocking"
    case .comparisons:
        return "comparisons"
    case .booleanLogic:
        return "boolean logic"
    case .compoundAssignment:
        return "compound assignment"
    case .stringInterpolation:
        return "string interpolation"
    }
}

func missingPrerequisites(for challenge: Challenge, index: ConstraintIndex) -> [ConstraintConcept] {
    return challenge.requires.filter { concept in
        introductionNumber(for: concept, index: index) > challenge.number
    }
}

func prerequisiteLine(for challenge: Challenge) -> String? {
    guard !challenge.requires.isEmpty else { return nil }
    let names = challenge.requires.map(constraintConceptName).joined(separator: ", ")
    return "Prereqs: \(names)"
}

func lessonText(for challenge: Challenge) -> String? {
    let explicit = challenge.lesson.trimmingCharacters(in: .whitespacesAndNewlines)
    return explicit.isEmpty ? nil : explicit
}

func renderLessonManPage(title: String, synopsis: String, lesson: String, width: Int = 78) -> [String] {
    func normalizeLessonText(_ lesson: String, title: String) -> String {
        var text = lesson.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = text.lowercased()
        if lowercased.hasPrefix("lesson:") {
            let startIndex = text.index(text.startIndex, offsetBy: "lesson:".count)
            text = String(text[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        if let firstLine = lines.first,
            firstLine.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == title.lowercased()
        {
            text = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        } else if lines.count >= 2 {
            let first = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let second = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
            if !first.isEmpty,
                second.lowercased().hasPrefix(first.lowercased() + " "),
                first.split(separator: " ").count == 1
            {
                text = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        if let range = text.range(of: "Progression:") {
            let before = String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let after = String(text[range.upperBound...])
            let normalizedAfter = after.replacingOccurrences(of: "\n", with: " ")
            let rawItems = normalizedAfter
                .split(separator: " ", omittingEmptySubsequences: false)
                .joined(separator: " ")
                .components(separatedBy: " - ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            var progression = "Progression:"
            if !rawItems.isEmpty {
                progression += "\n" + rawItems.map { "  - \($0)" }.joined(separator: "\n")
            }
            if before.isEmpty {
                text = progression
            } else {
                text = "\(before)\n\n\(progression)"
            }
        }

        return text
    }

    func centeredHeader(left: String, center: String, right: String, width: Int) -> String {
        let minWidth = max(width, left.count + right.count + 2)
        let available = minWidth - left.count - right.count
        let centerStart = max(0, (available - center.count) / 2)
        let leftPadding = String(repeating: " ", count: max(1, centerStart))
        let rightPadding = String(repeating: " ", count: max(1, available - centerStart - center.count))
        return left + leftPadding + center + rightPadding + right
    }

    func wrapParagraph(_ paragraph: String, width: Int, indent: String) -> [String] {
        let words = paragraph.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return [indent] }
        var lines: [String] = []
        var current = indent
        for word in words {
            if current.count + word.count + 1 > width {
                lines.append(current)
                current = indent + word
            } else {
                if current == indent {
                    current += word
                } else {
                    current += " " + word
                }
            }
        }
        lines.append(current)
        return lines
    }

    func wrapBullet(_ bullet: String, width: Int, indent: String) -> [String] {
        let trimmed = bullet.trimmingCharacters(in: .whitespacesAndNewlines)
        let bulletPrefix = indent + "- "
        let hangingIndent = indent + "  "
        let content = trimmed.replacingOccurrences(of: "- ", with: "", options: .anchored)
        let isCodeLike = content.contains("{")
            || content.contains("}")
            || content.contains("->")
            || content.contains("$")
            || content.contains("()")
            || content.contains("[]")
            || content.contains("`")
        if isCodeLike {
            return [bulletPrefix + content]
        }
        let words = content.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return [bulletPrefix] }
        var lines: [String] = []
        var current = bulletPrefix
        for word in words {
            if current.count + word.count + 1 > width {
                lines.append(current)
                current = hangingIndent + word
            } else {
                if current == bulletPrefix {
                    current += word
                } else {
                    current += " " + word
                }
            }
        }
        lines.append(current)
        return lines
    }

    func wrapText(_ text: String, width: Int, indent: String) -> [String] {
        let rawLines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var lines: [String] = []
        var paragraph: [String] = []

        func flushParagraph() {
            guard !paragraph.isEmpty else { return }
            let joined = paragraph.joined(separator: " ")
            lines.append(contentsOf: wrapParagraph(joined, width: width, indent: indent))
            paragraph.removeAll(keepingCapacity: true)
        }

        for rawLine in rawLines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                flushParagraph()
                lines.append("")
                continue
            }

            if rawLine.hasPrefix(" ") || rawLine.hasPrefix("\t") {
                flushParagraph()
                lines.append(indent + rawLine)
                continue
            }

            if trimmed.hasPrefix("- ") {
                flushParagraph()
                lines.append(contentsOf: wrapBullet(trimmed, width: width, indent: indent))
                continue
            }

            paragraph.append(trimmed)
        }

        flushParagraph()
        return lines
    }

    let header = centeredHeader(left: "FORGE(1)", center: "Lesson Manual", right: "FORGE(1)", width: width)
    var lines: [String] = [header, ""]
    lines.append("NAME")
    lines.append("    \(title)")
    lines.append("")
    lines.append("SYNOPSIS")
    lines.append("    \(synopsis)")
    lines.append("")
    lines.append("DESCRIPTION")
    let normalizedLesson = normalizeLessonText(lesson, title: title)
    lines.append(contentsOf: wrapText(normalizedLesson, width: width, indent: "    "))
    return lines
}

func pageLines(_ lines: [String], pageSize: Int = 22) {
    guard !lines.isEmpty else { return }
    for index in 0..<lines.count {
        print(lines[index])
        if (index + 1) % pageSize == 0, index < lines.count - 1 {
            let current = lines[index]
            let next = lines[index + 1]
            let inCodeBlock = current.hasPrefix("    ") || current.hasPrefix("\t")
            let nextIsCode = next.hasPrefix("    ") || next.hasPrefix("\t")
            if inCodeBlock || nextIsCode {
                continue
            }
            print("--More-- (Enter to continue, q to quit)")
            let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            if input == "q" {
                print("")
                break
            }
        }
    }
}

func showLesson(for challenge: Challenge) {
    guard let lesson = lessonText(for: challenge),
        !lesson.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
        print("Lesson not available yet.\n")
        return
    }
    let lines = renderLessonManPage(title: challenge.title, synopsis: challenge.topic.rawValue, lesson: lesson)
    pageLines(lines)
    print("")
}

func showLesson(for project: Project) {
    let lesson = project.lesson.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !lesson.isEmpty else {
        print("Lesson not available yet.\n")
        return
    }
    let lines = renderLessonManPage(title: project.title, synopsis: "project", lesson: lesson)
    pageLines(lines)
    print("")
}

func validateOutputLines(output: String, expected: String) -> Bool {
    let outputLines = output.components(separatedBy: "\n")
    let expectedLines = expected.components(separatedBy: "\n")

    func displayLine(_ line: String) -> String {
        return line.isEmpty ? "<empty>" : line
    }

    func printLineList(label: String, lines: [String]) {
        print(label)
        for (index, line) in lines.enumerated() {
            print("  \(index + 1): \(displayLine(line))")
        }
    }

    guard outputLines.count == expectedLines.count else {
        print("✗ Expected \(expectedLines.count) lines, got \(outputLines.count)")
        printLineList(label: "Expected:", lines: expectedLines)
        printLineList(label: "Actual:", lines: outputLines)
        return false
    }

    var allPassed = true
    for (index, expectedLine) in expectedLines.enumerated() {
        let actualLine = outputLines[index]
        let expectedTrimmed = expectedLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let actualTrimmed = actualLine.trimmingCharacters(in: .whitespacesAndNewlines)
        if actualTrimmed != expectedTrimmed {
            print("✗ Line \(index + 1) failed")
            print("  expected: \(expectedTrimmed)")
            print("       got: \(actualTrimmed)")
            allPassed = false
        }
    }

    return allPassed
}

struct DiagnosticContext {
    let challenge: Challenge
    let output: String
    let expected: String
    let source: String?
}

func definedFunctionNames(tokens: [String]) -> [String] {
    var names: [String] = []
    for index in 0..<(tokens.count - 1) where tokens[index] == "func" {
        let name = tokens[index + 1]
        if name != "init" {
            names.append(name)
        }
    }
    return names
}

func hasFunctionCall(named name: String, tokens: [String]) -> Bool {
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) {
        if tokens[index] == name, tokens[index + 1] == "(" {
            let prev = index > 0 ? tokens[index - 1] : ""
            if prev != "func" {
                return true
            }
        }
    }
    return false
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

func stepLabel(for steps: [Step], index: Int) -> String {
    guard index >= 1, index <= steps.count else {
        return "end"
    }
    switch steps[index - 1] {
    case .challenge(let challenge):
        return "challenge \(challenge.progressId): \(challenge.title)"
    case .project(let project):
        return "project \(project.id): \(project.title)"
    case .stageGate(let gate):
        return "stage review \(gate.title)"
    }
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

func remapLegacyChallengeNumber(_ number: Int) -> Int {
    if number >= 14 {
        return number + 2
    }
    return number
}

func remapProgressToken(
    _ tokenRaw: String,
    challengeIndexMap: [Int: Int],
    challengeIdIndexMap: [String: Int],
    allChallengeIdMap: [String: Challenge],
    allChallengeNumberMap: [Int: Challenge],
    projectIndexMap: [String: Int],
    projects: [Project],
    stepsCount: Int
) -> RemapProgressOutcome {
    let token = tokenRaw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !token.isEmpty else {
        return .error(message: "Invalid remap target.", showUsage: true)
    }
    let lowered = token.lowercased()
    if lowered.hasPrefix("challenge:") {
        let value = String(token.dropFirst("challenge:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(value) {
            let remapped = remapLegacyChallengeNumber(number)
            if let extraChallenge = allChallengeNumberMap[remapped], extraChallenge.tier == .extra {
                return .info(message: "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
            }
            guard let index = challengeIndexMap[remapped] else {
                return .error(message: "Unknown challenge number: \(remapped)", showUsage: false)
            }
            return .success(startIndex: index, messagePrefix: "Progress remapped from challenge \(number) -> \(remapped)")
        }
        if !value.isEmpty {
            let id = value.lowercased()
            if let extraChallenge = allChallengeIdMap[id], extraChallenge.tier == .extra {
                return .info(message: "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
            }
            guard let index = challengeIdIndexMap[id] else {
                return .error(message: "Unknown challenge id: \(value)", showUsage: false)
            }
            return .success(startIndex: index, messagePrefix: "Progress set to challenge \(value)")
        }
        return .error(message: "Invalid remap target.", showUsage: true)
    }
    if lowered.hasPrefix("project:") {
        let value = String(token.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        let id = value.lowercased()
        if let index = projectIndexMap[id] {
            return .success(startIndex: index, messagePrefix: "Progress set to project \(id)")
        }
        if let project = projects.first(where: { $0.id.lowercased() == id }), project.tier == .extra {
            return .info(message: "Project \(id) is not part of the main flow. Use project mode instead.")
        }
        return .error(message: "Unknown project id: \(value)", showUsage: false)
    }
    if lowered.hasPrefix("step:") {
        let value = String(token.dropFirst("step:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let number = Int(value) else {
            return .error(message: "Invalid step number.", showUsage: true)
        }
        let startIndex = normalizedStepIndex(number, stepsCount: stepsCount)
        return .success(startIndex: startIndex, messagePrefix: "Progress set to step \(startIndex)")
    }
    if let number = Int(token) {
        let remapped = remapLegacyChallengeNumber(number)
        if let extraChallenge = allChallengeNumberMap[remapped], extraChallenge.tier == .extra {
            return .info(message: "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
        }
        guard let index = challengeIndexMap[remapped] else {
            return .error(message: "Unknown challenge number: \(remapped)", showUsage: false)
        }
        return .success(startIndex: index, messagePrefix: "Progress remapped from challenge \(number) -> \(remapped)")
    }
    if let index = projectIndexMap[lowered] {
        return .success(startIndex: index, messagePrefix: "Progress set to project \(lowered)")
    }
    if let extraChallenge = allChallengeIdMap[lowered], extraChallenge.tier == .extra {
        return .info(message: "Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
    }
    if let index = challengeIdIndexMap[lowered] {
        return .success(startIndex: index, messagePrefix: "Progress set to challenge \(lowered)")
    }
    return .error(message: "Invalid remap target.", showUsage: true)
}

@main
struct Forge {
    static func main() {
        let paths = CLIPaths()
        let parsed = parseGlobalFlags(Array(CommandLine.arguments.dropFirst()))
        let flags = parsed.flags
        let args = parsed.remaining

        if !flags.enforceConstraints {
            print("Note: Early-concept usage will warn only (--allow-early-concepts).\n")
        }
        if !flags.enableDiMockHeuristics {
            print("Note: DI/mock heuristics disabled (--disable-di-mock-heuristics).\n")
        }
        if !flags.enableConstraintProfiles {
            print("Note: Constraint profiles disabled (--disable-constraint-profiles).\n")
        }

        let command = parseTopLevelCommand(args)

        switch command {
        case .help:
            printMainUsage()
            return
        case .aiGenerate(let commandArgs):
            handleAIGenerateCommand(commandArgs)
            return
        case .aiVerify(let commandArgs):
            handleAIVerifyCommand(commandArgs)
            return
        case .reset(let resetArgs):
            let startAfterReset = handleResetCommand(resetArgs)
            if !startAfterReset {
                return
            }
        default:
            break
        }

        let runtime = bootstrapRuntime(gatePasses: flags.gatePasses, gateCount: flags.gateCount)

        switch command {
        case .help:
            return
        case .aiGenerate:
            return
        case .aiVerify:
            return
        case .reset:
            handleRunCommand(overrideToken: nil, runtime: runtime, paths: paths, flags: flags)
        case .stats(let commandArgs):
            handleStatsCommand(commandArgs)
        case .reportOverrides(let commandArgs):
            handleReportOverridesCommand(commandArgs, sets: runtime.sets)
        case .catalog(let commandArgs):
            handleCatalogCommand(commandArgs, allChallenges: runtime.allChallenges)
        case .catalogProjects(let commandArgs):
            handleCatalogProjectsCommand(commandArgs, projects: runtime.projects)
        case .report(let commandArgs):
            handleReportCommand(commandArgs)
        case .verify(let commandArgs):
            handleVerifyCommand(
                commandArgs,
                allChallenges: runtime.allChallenges,
                enableConstraintProfiles: flags.enableConstraintProfiles
            )
        case .review(let commandArgs):
            handleReviewCommand(
                commandArgs,
                sets: runtime.sets,
                constraintIndex: runtime.constraintIndex,
                enableDiMockHeuristics: flags.enableDiMockHeuristics
            )
        case .practice(let commandArgs):
            handlePracticeCommand(commandArgs, runtime: runtime, paths: paths, flags: flags)
        case .audit(let commandArgs):
            handleAuditCommand(
                commandArgs,
                allChallenges: runtime.allChallenges,
                constraintIndex: runtime.constraintIndex,
                enableDiMockHeuristics: flags.enableDiMockHeuristics,
                enableConstraintProfiles: flags.enableConstraintProfiles
            )
        case .random(let commandArgs):
            handleRandomCommand(
                commandArgs,
                allChallenges: runtime.allChallenges,
                constraintIndex: runtime.constraintIndex,
                paths: paths,
                flags: flags
            )
        case .project(let commandArgs):
            handleProjectCommand(commandArgs, projects: runtime.projects, paths: paths, flags: flags)
        case .remapProgress(let commandArgs):
            handleRemapProgressCommand(commandArgs, runtime: runtime)
        case .progress(let commandArgs):
            handleProgressCommand(commandArgs, runtime: runtime)
        case .run(let overrideToken):
            handleRunCommand(overrideToken: overrideToken, runtime: runtime, paths: paths, flags: flags)
        }
    }
}
