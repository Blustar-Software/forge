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

func resetProgress(workspacePath: String = "workspace", removeAll: Bool = false) {
    let progressFile = progressFilePath(workspacePath: workspacePath)
    let fileManager = FileManager.default
    let stageGateFile = stageGateFilePath(workspacePath: workspacePath)
    
    // Delete progress file
    try? fileManager.removeItem(atPath: progressFile)
    try? fileManager.removeItem(atPath: stageGateFile)
    
    // Delete generated files in workspace
    if let files = try? fileManager.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            if removeAll {
                try? fileManager.removeItem(atPath: "\(workspacePath)/\(file)")
            } else if file.hasSuffix(".swift") {
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
    let prereqLine = prerequisiteLine(for: challenge) ?? ""
    let prereqBlock = prereqLine.isEmpty ? "" : "\n\(prereqLine)\n"

    print(
        """

        Challenge \(challenge.displayId): \(challenge.title)
        └─ \(challenge.description)

        Edit: \(filePath)

        \(prereqBlock)
        \(checkMessage)
        Type 'h' for a hint, 'c' for a cheatsheet, or 's' for the solution.
        """)
}

func stageGateFilePath(workspacePath: String) -> String {
    return "\(workspacePath)/.stage_gate"
}

func loadStageGateProgress(workspacePath: String = "workspace") -> (id: String, passes: Int)? {
    let path = stageGateFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return nil
    }
    let parts = content.split(separator: ":", maxSplits: 1).map(String.init)
    guard parts.count == 2, let passes = Int(parts[1]) else {
        return nil
    }
    return (parts[0], passes)
}

func saveStageGateProgress(id: String, passes: Int, workspacePath: String = "workspace") {
    let path = stageGateFilePath(workspacePath: workspacePath)
    let content = "\(id):\(passes)"
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}

func clearStageGateProgress(workspacePath: String = "workspace") {
    let path = stageGateFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
}

func stageGateSummaryFilePath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.stage_gate_summary"
}

func adaptiveStatsFilePath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.adaptive_stats"
}

func loadAdaptiveStats(workspacePath: String = "workspace") -> [String: [String: Int]] {
    let path = adaptiveStatsFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return [:]
    }
    var stats: [String: [String: Int]] = [:]
    for line in content.split(separator: "\n") {
        let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { continue }
        let topic = parts[0]
        var counts: [String: Int] = [:]
        for entry in parts[1].split(separator: ",") {
            let kv = entry.split(separator: "=", maxSplits: 1).map(String.init)
            if kv.count == 2, let value = Int(kv[1]) {
                counts[kv[0]] = value
            }
        }
        stats[topic] = counts
    }
    return stats
}

func saveAdaptiveStats(_ stats: [String: [String: Int]], workspacePath: String = "workspace") {
    let path = adaptiveStatsFilePath(workspacePath: workspacePath)
    let lines = stats.keys.sorted().map { topic -> String in
        let counts = stats[topic, default: [:]]
        let entries = counts.keys.sorted().map { key in
            "\(key)=\(counts[key, default: 0])"
        }
        return "\(topic)|\(entries.joined(separator: ","))"
    }
    let content = lines.joined(separator: "\n")
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}

func recordAdaptiveStat(
    topic: ChallengeTopic,
    result: String,
    workspacePath: String = "workspace"
) {
    var stats = loadAdaptiveStats(workspacePath: workspacePath)
    var topicStats = stats[topic.rawValue] ?? [:]
    topicStats[result, default: 0] += 1
    stats[topic.rawValue] = topicStats
    saveAdaptiveStats(stats, workspacePath: workspacePath)
}

func topicScore(for topic: ChallengeTopic, stats: [String: [String: Int]]) -> Int {
    let topicStats = stats[topic.rawValue] ?? [:]
    let failures = (topicStats["fail"] ?? 0) + (topicStats["compile_fail"] ?? 0)
    let passes = (topicStats["pass"] ?? 0) + (topicStats["manual_pass"] ?? 0)
    return max(1, 1 + failures - passes)
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

func loadStageGateSummary(workspacePath: String = "workspace") -> [String: String] {
    let path = stageGateSummaryFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return [:]
    }
    var summary: [String: String] = [:]
    for line in content.split(separator: "\n") {
        let parts = line.split(separator: ":", maxSplits: 1).map(String.init)
        if parts.count == 2 {
            summary[parts[0]] = parts[1]
        }
    }
    return summary
}

func saveStageGateSummary(_ summary: [String: String], workspacePath: String = "workspace") {
    let path = stageGateSummaryFilePath(workspacePath: workspacePath)
    let lines = summary.map { "\($0.key):\($0.value)" }.sorted()
    let content = lines.joined(separator: "\n")
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}

func performanceLogPath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.performance_log"
}

func appendPerformanceLogEntry(_ entry: String, workspacePath: String = "workspace") {
    let path = performanceLogPath(workspacePath: workspacePath)
    let existing = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
    let content = existing.isEmpty ? entry : "\(existing)\n\(entry)"
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}

func jsonEscaped(_ value: String) -> String {
    var escaped = value.replacingOccurrences(of: "\\", with: "\\\\")
    escaped = escaped.replacingOccurrences(of: "\"", with: "\\\"")
    escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
    escaped = escaped.replacingOccurrences(of: "\r", with: "\\r")
    escaped = escaped.replacingOccurrences(of: "\t", with: "\\t")
    return escaped
}

func logEvent(
    _ name: String,
    fields: [String: String] = [:],
    intFields: [String: Int] = [:],
    workspacePath: String = "workspace"
) {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    var parts: [String] = []
    parts.append("\"event\":\"\(jsonEscaped(name))\"")
    parts.append("\"timestamp\":\"\(jsonEscaped(timestamp))\"")

    for key in fields.keys.sorted() {
        if let value = fields[key] {
            parts.append("\"\(jsonEscaped(key))\":\"\(jsonEscaped(value))\"")
        }
    }

    for key in intFields.keys.sorted() {
        if let value = intFields[key] {
            parts.append("\"\(jsonEscaped(key))\":\(value)")
        }
    }

    let entry = "{\(parts.joined(separator: ","))}"
    appendPerformanceLogEntry(entry, workspacePath: workspacePath)
}

func compileAndRun(file: String, arguments: [String] = [], stdin: String? = nil) -> String? {
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
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
        return nil
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
) -> (stdin: String?, args: [String]) {
    var stdin: String? = nil
    if let fixture = challenge.stdinFixture {
        stdin = loadFixtureContents(fixture)
    }

    var args: [String] = []
    if let fixture = challenge.argsFixture {
        let contents = loadFixtureContents(fixture) ?? ""
        args = contents.split { $0 == " " || $0 == "\n" || $0 == "\t" }.map { String($0) }
    }

    for file in challenge.fixtureFiles {
        copyFixtureFile(named: file, to: workspacePath)
    }

    return (stdin, args)
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
        let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
        try? solution.write(toFile: filePath, atomically: true, encoding: .utf8)
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

func tokenizeSource(_ source: String) -> [String] {
    let chars = Array(source)
    var tokens: [String] = []
    var i = 0

    func isIdentifierStart(_ ch: Character) -> Bool {
        return ch.isLetter || ch == "_"
    }

    func isIdentifierPart(_ ch: Character) -> Bool {
        return ch.isLetter || ch.isNumber || ch == "_"
    }

    while i < chars.count {
        let current = chars[i]

        if current.isWhitespace {
            i += 1
            continue
        }

        if isIdentifierStart(current) {
            var j = i + 1
            while j < chars.count && isIdentifierPart(chars[j]) {
                j += 1
            }
            tokens.append(String(chars[i..<j]))
            i = j
            continue
        }

        if current == "$" {
            var j = i + 1
            if j < chars.count && isIdentifierStart(chars[j]) {
                j += 1
                while j < chars.count && isIdentifierPart(chars[j]) {
                    j += 1
                }
            } else {
                while j < chars.count && chars[j].isNumber {
                    j += 1
                }
            }
            tokens.append(String(chars[i..<j]))
            i = j
            continue
        }

        if current == "." {
            if i + 2 < chars.count, chars[i + 1] == ".", chars[i + 2] == "." {
                tokens.append("...")
                i += 3
                continue
            }
            if i + 2 < chars.count, chars[i + 1] == ".", chars[i + 2] == "<" {
                tokens.append("..<")
                i += 3
                continue
            }
            tokens.append(".")
            i += 1
            continue
        }

        if current == "=" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("==")
                i += 2
                continue
            }
            tokens.append("=")
            i += 1
            continue
        }

        if current == "!" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("!=")
                i += 2
                continue
            }
            tokens.append("!")
            i += 1
            continue
        }

        if current == "<" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("<=")
                i += 2
                continue
            }
            tokens.append("<")
            i += 1
            continue
        }

        if current == ">" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append(">=")
                i += 2
                continue
            }
            tokens.append(">")
            i += 1
            continue
        }

        if current == "&" {
            if i + 1 < chars.count, chars[i + 1] == "&" {
                tokens.append("&&")
                i += 2
                continue
            }
            tokens.append("&")
            i += 1
            continue
        }

        if current == "|" {
            if i + 1 < chars.count, chars[i + 1] == "|" {
                tokens.append("||")
                i += 2
                continue
            }
            tokens.append("|")
            i += 1
            continue
        }

        if current == "+" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("+=")
                i += 2
                continue
            }
            tokens.append("+")
            i += 1
            continue
        }

        if current == "-" {
            if i + 1 < chars.count, chars[i + 1] == ">" {
                tokens.append("->")
                i += 2
                continue
            }
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("-=")
                i += 2
                continue
            }
            tokens.append("-")
            i += 1
            continue
        }

        if current == "*" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("*=")
                i += 2
                continue
            }
            tokens.append("*")
            i += 1
            continue
        }

        if current == "/" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("/=")
                i += 2
                continue
            }
            tokens.append("/")
            i += 1
            continue
        }

        if current == "%" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("%=")
                i += 2
                continue
            }
            tokens.append("%")
            i += 1
            continue
        }

        if current == "?" {
            if i + 1 < chars.count, chars[i + 1] == "?" {
                tokens.append("??")
                i += 2
                continue
            }
            tokens.append("?")
            i += 1
            continue
        }

        if current == "{" || current == "}" || current == "(" || current == ")" || current == "," || current == "@" || current == "#" {
            tokens.append(String(current))
            i += 1
            continue
        }

        tokens.append(String(current))
        i += 1
    }

    return tokens
}

func hasToken(_ tokens: [String], _ token: String) -> Bool {
    return tokens.contains(token)
}

func hasSequence(_ tokens: [String], _ sequence: [String]) -> Bool {
    guard !sequence.isEmpty, tokens.count >= sequence.count else { return false }
    let lastStart = tokens.count - sequence.count
    for index in 0...lastStart {
        let slice = Array(tokens[index..<index + sequence.count])
        if slice == sequence {
            return true
        }
    }
    return false
}

func hasDotMember(_ tokens: [String], _ member: String) -> Bool {
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) where tokens[index] == "." && tokens[index + 1] == member {
        return true
    }
    return false
}

func hasOptionalType(_ tokens: [String]) -> Bool {
    let typeNames = ["Int", "String", "Bool", "Double"]
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) {
        if typeNames.contains(tokens[index]) && tokens[index + 1] == "?" {
            return true
        }
    }
    return false
}

func hasShorthandClosureArg(_ tokens: [String]) -> Bool {
    for token in tokens where token.first == "$" && token.count > 1 {
        let suffix = token.dropFirst()
        if suffix.allSatisfy({ $0.isNumber }) {
            return true
        }
    }
    return false
}

func hasTryOptional(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["try", "?"])
}

func hasCommandLineArguments(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["CommandLine", ".", "arguments"])
}

func hasFileIO(_ tokens: [String]) -> Bool {
    return tokens.contains("contentsOfFile") || tokens.contains("FileHandle") || tokens.contains("FileManager")
}

func hasPropertyWrapperUsage(_ tokens: [String]) -> Bool {
    let ignoredAttributes: Set<String> = ["MainActor"]
    guard tokens.count >= 3 else { return false }
    for index in 0..<(tokens.count - 2) where tokens[index] == "@" {
        let next = tokens[index + 1]
        if ignoredAttributes.contains(next) {
            continue
        }
        let limit = min(index + 4, tokens.count)
        for j in (index + 1)..<limit {
            if tokens[j] == "var" || tokens[j] == "let" {
                return true
            }
        }
    }
    return false
}

func hasPropertyDeclaration(_ tokens: [String]) -> Bool {
    guard hasToken(tokens, "struct") || hasToken(tokens, "class") else { return false }
    return hasToken(tokens, "var") || hasToken(tokens, "let")
}

func hasExtensionClause(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "extension")
}

func hasWhereClause(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "where")
}

func hasAssociatedType(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "associatedtype")
}

func hasGenericDefinition(_ tokens: [String]) -> Bool {
    guard tokens.count >= 4 else { return false }
    let anchors = Set(["func", "struct", "class", "enum", "protocol", "extension"])
    for (index, token) in tokens.enumerated() where anchors.contains(token) {
        let next = index + 1
        guard next < tokens.count else { continue }
        var j = next
        if tokens[j] == "<" {
            return true
        }
        while j < tokens.count && tokens[j] != "<" && tokens[j] != "{" && tokens[j] != "(" {
            j += 1
        }
        if j < tokens.count && tokens[j] == "<" {
            return true
        }
    }
    return false
}

func hasTaskUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "Task")
}

func hasMainActorUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "MainActor")
}

func hasSendableUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "Sendable")
}

func hasProtocolConformance(_ tokens: [String]) -> Bool {
    let ignoredTypes: Set<String> = ["String", "Int", "Double", "Bool", "Error"]
    guard tokens.count >= 3 else { return false }

    for (index, token) in tokens.enumerated() where token == "struct" || token == "class" || token == "enum" {
        var j = index + 1
        while j < tokens.count && tokens[j] != "{" {
            if tokens[j] == ":" {
                var hasNonIgnored = false
                var k = j + 1
                while k < tokens.count && tokens[k] != "{" {
                    let next = tokens[k]
                    if next == "," {
                        k += 1
                        continue
                    }
                    if !ignoredTypes.contains(next) && next != "where" {
                        hasNonIgnored = true
                        break
                    }
                    k += 1
                }
                if hasNonIgnored {
                    return true
                }
            }
            j += 1
        }
    }
    return false
}

func protocolNames(in tokens: [String]) -> Set<String> {
    var names: Set<String> = []
    var index = 0

    func isIdentifierToken(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        return first.isLetter || first == "_"
    }

    while index < tokens.count - 1 {
        if tokens[index] == "protocol" {
            let name = tokens[index + 1]
            if isIdentifierToken(name) {
                names.insert(name)
            }
        }
        index += 1
    }

    return names
}

func hasDependencyInjection(_ tokens: [String]) -> Bool {
    let protocols = protocolNames(in: tokens)
    guard !protocols.isEmpty else { return false }

    var scopeStack: [Bool] = []
    var pendingTypeScope = false

    func isInsideType() -> Bool {
        return scopeStack.last == true
    }

    var index = 0
    while index < tokens.count {
        let token = tokens[index]

        if token == "struct" || token == "class" || token == "actor" {
            pendingTypeScope = true
            index += 1
            continue
        }

        if token == "{" {
            scopeStack.append(pendingTypeScope)
            pendingTypeScope = false
            index += 1
            continue
        }

        if token == "}" {
            _ = scopeStack.popLast()
            index += 1
            continue
        }

        if (token == "let" || token == "var") && isInsideType() {
            var j = index + 1
            while j < tokens.count {
                let next = tokens[j]
                if next == "let" || next == "var" || next == "func" || next == "}" || next == "{" {
                    break
                }
                if next == ":" {
                    let typeIndex = j + 1
                    if typeIndex < tokens.count, tokens[typeIndex] == "any" {
                        let protoIndex = typeIndex + 1
                        if protoIndex < tokens.count, protocols.contains(tokens[protoIndex]) {
                            return true
                        }
                    }
                }
                j += 1
            }
        }

        index += 1
    }

    return false
}

func hasProtocolMocking(_ tokens: [String]) -> Bool {
    let protocols = protocolNames(in: tokens)
    guard !protocols.isEmpty else { return false }

    var index = 0
    while index < tokens.count {
        let token = tokens[index]
        if token == "struct" || token == "class" || token == "enum" {
            guard index + 1 < tokens.count else { break }
            let name = tokens[index + 1]
            if name.hasPrefix("Mock") {
                var j = index + 2
                while j < tokens.count && tokens[j] != "{" {
                    if tokens[j] == ":" {
                        var k = j + 1
                        while k < tokens.count && tokens[k] != "{" {
                            let next = tokens[k]
                            if next == "," {
                                k += 1
                                continue
                            }
                            if protocols.contains(next) {
                                return true
                            }
                            k += 1
                        }
                    }
                    j += 1
                }
            }
        }
        index += 1
    }

    return false
}

func hasProtocolExtension(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "protocol") && hasToken(tokens, "extension")
}

func hasTaskSleepUsage(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["Task", ".", "sleep"])
}

func hasTaskGroupUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "withTaskGroup")
}

func hasAccessControlKeyword(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "private") || hasToken(tokens, "fileprivate")
        || hasToken(tokens, "internal") || hasToken(tokens, "public")
        || hasToken(tokens, "open")
}

func hasAccessControlOpen(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "public") || hasToken(tokens, "open")
}

func hasAccessControlFileprivate(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "fileprivate")
}

func hasAccessControlInternal(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "internal")
}

func hasAccessControlSetter(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["private", "(", "set", ")"])
}

func hasErrorType(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, [":", "Error"]) || hasToken(tokens, "Error")
}

func hasThrowingFunction(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "throws")
}

func hasDoTryCatch(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "do") && hasToken(tokens, "catch") && hasToken(tokens, "try")
}

func hasTryForce(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["try", "!"])
}

func hasResultBuilder(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "resultBuilder")
}

func hasMacroUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "macro")
}

func hasProjectedValues(_ tokens: [String]) -> Bool {
    for token in tokens where token.hasPrefix("$") && token.count > 1 {
        let suffix = token.dropFirst()
        if suffix.allSatisfy({ $0.isNumber }) {
            continue
        }
        return true
    }
    return false
}

func hasSwiftPMBasics(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "Package") || hasToken(tokens, "Target")
}

func hasSwiftPMDependencies(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "dependencies") || hasToken(tokens, "package")
}

func hasBuildConfigs(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["#", "if", "DEBUG"])
}

func containsStringInterpolation(in source: String) -> Bool {
    let chars = Array(source)
    var i = 0
    var inLineComment = false
    var inBlockComment = false
    var inString = false
    var stringHashCount = 0
    var stringQuoteCount = 0
    var stringIsRaw = false

    func hasHashes(from index: Int, count: Int) -> Bool {
        if count == 0 {
            return true
        }
        guard index + count <= chars.count else {
            return false
        }
        for offset in 0..<count where chars[index + offset] != "#" {
            return false
        }
        return true
    }

    while i < chars.count {
        let current = chars[i]
        let next = i + 1 < chars.count ? chars[i + 1] : "\0"

        if inLineComment {
            if current == "\n" {
                inLineComment = false
            }
            i += 1
            continue
        }

        if inBlockComment {
            if current == "*" && next == "/" {
                inBlockComment = false
                i += 2
                continue
            }
            i += 1
            continue
        }

        if inString {
            if current == "\\" {
                let startIndex = i + 1
                if startIndex < chars.count {
                    var hashCount = 0
                    var j = startIndex
                    while j < chars.count && chars[j] == "#" {
                        hashCount += 1
                        j += 1
                    }
                    if !stringIsRaw && hashCount == 0 && j < chars.count && chars[j] == "(" {
                        return true
                    }
                    if stringIsRaw && hashCount == stringHashCount && j < chars.count && chars[j] == "(" {
                        return true
                    }
                }
                i += stringIsRaw ? 1 : 2
                continue
            }

            if current == "\"" {
                if stringQuoteCount == 3 {
                    if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                        let endIndex = i + 3
                        if hasHashes(from: endIndex, count: stringHashCount) {
                            i = endIndex + stringHashCount
                            inString = false
                            continue
                        }
                    }
                } else if stringQuoteCount == 1 {
                    let endIndex = i + 1
                    if hasHashes(from: endIndex, count: stringHashCount) {
                        i = endIndex + stringHashCount
                        inString = false
                        continue
                    }
                }
            }
            i += 1
            continue
        }

        if current == "/" && next == "/" {
            inLineComment = true
            i += 2
            continue
        }

        if current == "/" && next == "*" {
            inBlockComment = true
            i += 2
            continue
        }

        if current == "#" {
            var hashCount = 0
            var j = i
            while j < chars.count, chars[j] == "#" {
                hashCount += 1
                j += 1
            }
            if j < chars.count, chars[j] == "\"" {
                if j + 2 < chars.count, chars[j + 1] == "\"", chars[j + 2] == "\"" {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 3
                    stringIsRaw = true
                    i = j + 3
                    continue
                } else {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 1
                    stringIsRaw = true
                    i = j + 1
                    continue
                }
            }
        }

        if current == "\"" {
            if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 3
                stringIsRaw = false
                i += 3
                continue
            } else {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 1
                stringIsRaw = false
                i += 1
                continue
            }
        }

        i += 1
    }

    return false
}

func hasComparisonOperator(_ tokens: [String]) -> Bool {
    let operators: Set<String> = ["==", "!=", "<", ">", "<=", ">="]
    return tokens.contains(where: { operators.contains($0) })
}

func hasLogicalOperator(_ tokens: [String]) -> Bool {
    let operators: Set<String> = ["&&", "||", "!"]
    return tokens.contains(where: { operators.contains($0) })
}

func hasCompoundAssignment(_ tokens: [String]) -> Bool {
    let operators: Set<String> = ["+=", "-=", "*=", "/=", "%="]
    return tokens.contains(where: { operators.contains($0) })
}

func hasStringInterpolation(_ tokens: [String]) -> Bool {
    return tokens.contains("\\(")
}

func hasClosureToken(_ tokens: [String]) -> Bool {
    var index = 0
    while index < tokens.count {
        if tokens[index] == "{" {
            var depth = 1
            var j = index + 1
            while j < tokens.count && depth > 0 {
                let token = tokens[j]
                if token == "{" {
                    depth += 1
                } else if token == "}" {
                    depth -= 1
                    if depth == 0 {
                        break
                    }
                } else if token == "in" && depth == 1 {
                    let windowStart = max(index + 1, j - 4)
                    if tokens[windowStart..<j].contains("for") {
                        j += 1
                        continue
                    }
                    return true
                }
                j += 1
            }
            index = j
            continue
        }
        index += 1
    }
    return false
}

func usesConcept(_ concept: ConstraintConcept, tokens: [String], source: String, rawSource: String) -> Bool {
    switch concept {
    case .ifElse:
        return hasToken(tokens, "if")
    case .switchStatement:
        return hasToken(tokens, "switch")
    case .forInLoop:
        return hasToken(tokens, "for")
    case .whileLoop:
        return hasToken(tokens, "while")
    case .repeatWhileLoop:
        return hasToken(tokens, "repeat")
    case .breakContinue:
        return hasToken(tokens, "break") || hasToken(tokens, "continue")
    case .ranges:
        return hasToken(tokens, "...") || hasToken(tokens, "..<")
    case .functionsBasics:
        return hasToken(tokens, "func")
    case .optionals:
        return hasOptionalType(tokens)
    case .nilLiteral:
        return hasToken(tokens, "nil")
    case .optionalBinding:
        return hasSequence(tokens, ["if", "let"])
    case .guardStatement:
        return hasToken(tokens, "guard")
    case .nilCoalescing:
        return hasToken(tokens, "??")
    case .closures:
        return hasClosureToken(tokens)
    case .shorthandClosureArgs:
        return hasShorthandClosureArg(tokens)
    case .map:
        return hasDotMember(tokens, "map")
    case .filter:
        return hasDotMember(tokens, "filter")
    case .reduce:
        return hasDotMember(tokens, "reduce")
    case .compactMap:
        return hasDotMember(tokens, "compactMap")
    case .flatMap:
        return hasDotMember(tokens, "flatMap")
    case .typeAlias:
        return hasToken(tokens, "typealias")
    case .enums:
        return hasToken(tokens, "enum")
    case .doCatch:
        return hasToken(tokens, "do") || hasToken(tokens, "catch")
    case .throwKeyword:
        return hasToken(tokens, "throw")
    case .tryKeyword:
        return hasToken(tokens, "try")
    case .tryOptional:
        return hasTryOptional(tokens)
    case .readLine:
        return hasToken(tokens, "readLine")
    case .commandLineArguments:
        return hasCommandLineArguments(tokens)
    case .fileIO:
        return hasFileIO(tokens)
    case .tuples:
        if let tupleRegex = try? NSRegularExpression(pattern: "=\\s*\\([^\\n\\)]*,[^\\n\\)]*\\)", options: []) {
            let range = NSRange(location: 0, length: source.utf16.count)
            return tupleRegex.firstMatch(in: source, options: [], range: range) != nil
        }
        return false
    case .asyncAwait:
        return hasToken(tokens, "async") || hasToken(tokens, "await")
    case .actors:
        return hasToken(tokens, "actor")
    case .propertyWrappers:
        return hasPropertyWrapperUsage(tokens)
    case .protocols:
        return hasToken(tokens, "protocol")
    case .structs:
        return hasToken(tokens, "struct")
    case .classes:
        return hasToken(tokens, "class")
    case .properties:
        return hasPropertyDeclaration(tokens)
    case .initializers:
        return hasToken(tokens, "init")
    case .mutatingMethods:
        return hasToken(tokens, "mutating")
    case .selfKeyword:
        return hasToken(tokens, "self")
    case .extensions:
        return hasExtensionClause(tokens)
    case .whereClauses:
        return hasWhereClause(tokens)
    case .associatedTypes:
        return hasAssociatedType(tokens)
    case .generics:
        return hasGenericDefinition(tokens)
    case .task:
        return hasTaskUsage(tokens)
    case .mainActor:
        return hasMainActorUsage(tokens)
    case .sendable:
        return hasSendableUsage(tokens)
    case .protocolConformance:
        return hasProtocolConformance(tokens)
    case .protocolExtensions:
        return hasProtocolExtension(tokens)
    case .defaultImplementations:
        return hasProtocolExtension(tokens) && hasToken(tokens, "func")
    case .taskSleep:
        return hasTaskSleepUsage(tokens)
    case .taskGroup:
        return hasTaskGroupUsage(tokens)
    case .accessControl:
        return hasAccessControlKeyword(tokens)
    case .accessControlOpen:
        return hasAccessControlOpen(tokens)
    case .accessControlFileprivate:
        return hasAccessControlFileprivate(tokens)
    case .accessControlInternal:
        return hasAccessControlInternal(tokens)
    case .accessControlSetter:
        return hasAccessControlSetter(tokens)
    case .errorTypes:
        return hasErrorType(tokens)
    case .throwingFunctions:
        return hasThrowingFunction(tokens)
    case .doTryCatch:
        return hasDoTryCatch(tokens)
    case .tryForce:
        return hasTryForce(tokens)
    case .resultBuilders:
        return hasResultBuilder(tokens)
    case .macros:
        return hasMacroUsage(tokens)
    case .projectedValues:
        return hasProjectedValues(tokens)
    case .swiftpmBasics:
        return hasSwiftPMBasics(tokens)
    case .swiftpmDependencies:
        return hasSwiftPMDependencies(tokens)
    case .buildConfigs:
        return hasBuildConfigs(tokens)
    case .dependencyInjection:
        return hasDependencyInjection(tokens)
    case .protocolMocking:
        return hasProtocolMocking(tokens)
    case .comparisons:
        return hasComparisonOperator(tokens)
    case .booleanLogic:
        return hasLogicalOperator(tokens)
    case .compoundAssignment:
        return hasCompoundAssignment(tokens)
    case .stringInterpolation:
        return containsStringInterpolation(in: rawSource)
    }
}

func buildConstraintIndex(from challenges: [Challenge]) -> ConstraintIndex {
    var intro: [ConstraintConcept: Int] = [:]
    for challenge in challenges {
        for concept in challenge.introduces {
            if let existing = intro[concept] {
                intro[concept] = min(existing, challenge.number)
            } else {
                intro[concept] = challenge.number
            }
        }
    }
    return ConstraintIndex(introByConcept: intro, legacyMinByConcept: legacyConstraintMinimums())
}

func introductionNumber(for concept: ConstraintConcept, index: ConstraintIndex) -> Int {
    return index.introByConcept[concept] ?? index.legacyMinByConcept[concept] ?? Int.max
}

func stripCommentsAndStrings(from source: String) -> String {
    let chars = Array(source)
    var output = ""
    var i = 0
    var inLineComment = false
    var inBlockComment = false
    var inString = false
    var stringHashCount = 0
    var stringQuoteCount = 0
    var stringIsRaw = false

    func hasHashes(from index: Int, count: Int) -> Bool {
        if count == 0 {
            return true
        }
        guard index + count <= chars.count else {
            return false
        }
        for offset in 0..<count where chars[index + offset] != "#" {
            return false
        }
        return true
    }

    while i < chars.count {
        let current = chars[i]
        let next = i + 1 < chars.count ? chars[i + 1] : "\0"

        if inLineComment {
            if current == "\n" {
                inLineComment = false
                output.append("\n")
            }
            i += 1
            continue
        }

        if inBlockComment {
            if current == "*" && next == "/" {
                inBlockComment = false
                i += 2
                output.append(" ")
                continue
            }
            i += 1
            continue
        }

        if inString {
            if !stringIsRaw && current == "\\" {
                i += 2
                continue
            }
            if current == "\"" {
                if stringQuoteCount == 3 {
                    if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                        let endIndex = i + 3
                        if hasHashes(from: endIndex, count: stringHashCount) {
                            i = endIndex + stringHashCount
                            inString = false
                            output.append(" ")
                            continue
                        }
                    }
                } else if stringQuoteCount == 1 {
                    let endIndex = i + 1
                    if hasHashes(from: endIndex, count: stringHashCount) {
                        i = endIndex + stringHashCount
                        inString = false
                        output.append(" ")
                        continue
                    }
                }
            }
            i += 1
            continue
        }

        if current == "/" && next == "/" {
            inLineComment = true
            i += 2
            continue
        }

        if current == "/" && next == "*" {
            inBlockComment = true
            i += 2
            continue
        }

        if current == "#" {
            var hashCount = 0
            var j = i
            while j < chars.count, chars[j] == "#" {
                hashCount += 1
                j += 1
            }
            if j < chars.count, chars[j] == "\"" {
                if j + 2 < chars.count, chars[j + 1] == "\"", chars[j + 2] == "\"" {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 3
                    stringIsRaw = true
                    i = j + 3
                    output.append(" ")
                    continue
                } else {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 1
                    stringIsRaw = true
                    i = j + 1
                    output.append(" ")
                    continue
                }
            }
        }

        if current == "\"" {
            if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 3
                stringIsRaw = false
                i += 3
                output.append(" ")
                continue
            } else {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 1
                stringIsRaw = false
                i += 1
                output.append(" ")
                continue
            }
        }

        output.append(current)
        i += 1
    }

    return output
}

func constraintWarnings(
    for source: String,
    challenge: Challenge,
    index: ConstraintIndex,
    enableDiMockHeuristics: Bool
) -> [String] {
    let cleanedSource = stripCommentsAndStrings(from: source)
    let tokens = tokenizeSource(cleanedSource)
    var warnings: [String] = []
    let allConcepts: [ConstraintConcept] = [
        .ifElse,
        .switchStatement,
        .forInLoop,
        .whileLoop,
        .repeatWhileLoop,
        .breakContinue,
        .ranges,
        .functionsBasics,
        .optionals,
        .nilLiteral,
        .optionalBinding,
        .guardStatement,
        .nilCoalescing,
        .closures,
        .shorthandClosureArgs,
        .map,
        .filter,
        .reduce,
        .compactMap,
        .flatMap,
        .typeAlias,
        .enums,
        .doCatch,
        .throwKeyword,
        .tryKeyword,
        .tryOptional,
        .readLine,
        .commandLineArguments,
        .fileIO,
        .tuples,
        .asyncAwait,
        .actors,
        .propertyWrappers,
        .protocols,
        .structs,
        .classes,
        .properties,
        .initializers,
        .mutatingMethods,
        .selfKeyword,
        .extensions,
        .whereClauses,
        .associatedTypes,
        .generics,
        .task,
        .mainActor,
        .sendable,
        .protocolConformance,
        .protocolExtensions,
        .defaultImplementations,
        .taskSleep,
        .taskGroup,
        .accessControl,
        .accessControlOpen,
        .accessControlFileprivate,
        .accessControlInternal,
        .accessControlSetter,
        .errorTypes,
        .throwingFunctions,
        .doTryCatch,
        .tryForce,
        .resultBuilders,
        .macros,
        .projectedValues,
        .swiftpmBasics,
        .swiftpmDependencies,
        .buildConfigs,
        .dependencyInjection,
        .protocolMocking,
        .comparisons,
        .booleanLogic,
        .compoundAssignment,
        .stringInterpolation,
    ]
    for concept in allConcepts {
        if !enableDiMockHeuristics && (concept == .dependencyInjection || concept == .protocolMocking) {
            continue
        }
        let introNumber = introductionNumber(for: concept, index: index)
        if challenge.number >= introNumber {
            continue
        }
        if usesConcept(concept, tokens: tokens, source: cleanedSource, rawSource: source) {
            warnings.append("⚠️ Possible early use of \(constraintConceptName(concept)) (introduced in Challenge \(introNumber)).")
        }
    }
    return warnings
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
            print("✗ Line \(index + 1) failed: expected \(expectedTrimmed), got \(actualTrimmed)")
            allPassed = false
        }
    }

    return allPassed
}

func validateChallenge(
    _ challenge: Challenge,
    nextStepIndex: Int,
    workspacePath: String = "workspace",
    constraintIndex: ConstraintIndex,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true
) -> Bool {
    let filePath = "\(workspacePath)/\(challenge.filename)"
    let missingPrereqs = missingPrerequisites(for: challenge, index: constraintIndex)
    if !missingPrereqs.isEmpty {
        let names = missingPrereqs.map(constraintConceptName).joined(separator: ", ")
        print("✗ Prerequisites not introduced yet: \(names).")
        return false
    }

    if challenge.manualCheck {
        print("Manual check: forge does not auto-validate this challenge.")
        recordAdaptiveStat(topic: challenge.topic, result: "manual_pass", workspacePath: workspacePath)
        logEvent(
            "challenge_manual_complete",
            fields: ["id": challenge.displayId],
            intFields: ["number": challenge.number],
            workspacePath: workspacePath
        )
        saveProgress(nextStepIndex)
        print("✓ Challenge marked complete.\n")
        return true
    }

    if let source = try? String(contentsOfFile: filePath, encoding: .utf8) {
        let warnings = constraintWarnings(
            for: source,
            challenge: challenge,
            index: constraintIndex,
            enableDiMockHeuristics: enableDiMockHeuristics
        )
        if !warnings.isEmpty {
            for warning in warnings {
                print(warning)
            }
            print("")
            if enforceConstraints {
                print("✗ Constraint violation. Remove early concepts and retry.")
                return false
            }
        }
    }

    let start = Date()
    let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
    guard let output = compileAndRun(file: filePath, arguments: args, stdin: stdin) else {
        print("✗ Compilation failed. Check your code.")
        recordAdaptiveStat(topic: challenge.topic, result: "compile_fail", workspacePath: workspacePath)
        logEvent(
            "challenge_attempt",
            fields: ["id": challenge.displayId, "result": "compile_fail"],
            intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }

    // Show what the code printed
    print("Output: \(output)\n")

    if validateOutputLines(output: output, expected: challenge.expectedOutput) {
        print("✓ Challenge Complete! Well done.\n")
        recordAdaptiveStat(topic: challenge.topic, result: "pass", workspacePath: workspacePath)
        logEvent(
            "challenge_attempt",
            fields: ["id": challenge.displayId, "result": "pass"],
            intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )

        // Save progress to next step
        saveProgress(nextStepIndex)

        return true
    } else {
        print("✗ Output doesn't match.")
        recordAdaptiveStat(topic: challenge.topic, result: "fail", workspacePath: workspacePath)
        logEvent(
            "challenge_attempt",
            fields: ["id": challenge.displayId, "result": "fail"],
            intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }
}

func runGateChallenges(
    _ challenges: [Challenge],
    workspacePath: String = "workspace",
    constraintIndex: ConstraintIndex,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true
) -> Bool {
    for (index, challenge) in challenges.enumerated() {
        loadChallenge(challenge, workspacePath: workspacePath)
        var hintIndex = 0
        var challengeComplete = false
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

            if !missingPrereqs.isEmpty {
                print("✗ Prerequisites not introduced yet: \(missingPrereqNames).")
                continue
            }

            if challenge.manualCheck {
                print("\n--- Manual check ---\n")
                print("Manual check: forge does not auto-validate this challenge.")
                print("✓ Challenge marked complete.\n")
                recordAdaptiveStat(topic: challenge.topic, result: "manual_pass", workspacePath: workspacePath)
                logEvent(
                    "challenge_manual_complete",
                    fields: ["id": challenge.displayId, "mode": "stage_review"],
                    intFields: ["number": challenge.number],
                    workspacePath: workspacePath
                )
                challengeComplete = true
            } else {
                print("\n--- Testing your code... ---\n")
                let filePath = "\(workspacePath)/\(challenge.filename)"
                if let source = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    let warnings = constraintWarnings(
                        for: source,
                        challenge: challenge,
                        index: constraintIndex,
                        enableDiMockHeuristics: enableDiMockHeuristics
                    )
                    if !warnings.isEmpty {
                        for warning in warnings {
                            print(warning)
                        }
                        print("")
                        if enforceConstraints {
                            print("✗ Constraint violation. Remove early concepts and retry.")
                            continue
                        }
                    }
                }
                let start = Date()
                let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
                guard let output = compileAndRun(file: filePath, arguments: args, stdin: stdin) else {
                    print("✗ Compilation failed. Check your code.")
                    recordAdaptiveStat(topic: challenge.topic, result: "compile_fail", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "compile_fail", "mode": "stage_review"],
                        intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
                    continue
                }

                print("Output: \(output)\n")

                if validateOutputLines(output: output, expected: challenge.expectedOutput) {
                    print("✓ Challenge Complete! Well done.\n")
                    recordAdaptiveStat(topic: challenge.topic, result: "pass", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "pass", "mode": "stage_review"],
                        intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
                    challengeComplete = true
                } else {
                    print("✗ Output doesn't match.")
                    recordAdaptiveStat(topic: challenge.topic, result: "fail", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "fail", "mode": "stage_review"],
                        intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
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
    workspacePath: String = "workspace",
    constraintIndex: ConstraintIndex,
    adaptiveEnabled: Bool,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true
) {
    let current = loadStageGateProgress(workspacePath: workspacePath)
    var passes = current?.id == gate.id ? current?.passes ?? 0 : 0
    let startedAt = Date()
    let review: [Challenge]
    if adaptiveEnabled {
        let stats = loadAdaptiveStats(workspacePath: workspacePath)
        review = pickStageReviewChallengesAdaptive(from: gate.pool, count: gate.count, stats: stats)
    } else {
        review = pickStageReviewChallenges(from: gate.pool, count: gate.count)
    }

    while passes < gate.requiredPasses {
        print("Stage review: \(gate.title)")
        print("Pass \(passes + 1)/\(gate.requiredPasses)")
        print("Complete each review challenge without errors.\n")

        _ = runGateChallenges(
            review,
            workspacePath: workspacePath,
            constraintIndex: constraintIndex,
            enforceConstraints: enforceConstraints,
            enableDiMockHeuristics: enableDiMockHeuristics
        )
        passes += 1
        saveStageGateProgress(id: gate.id, passes: passes, workspacePath: workspacePath)
        if passes < gate.requiredPasses {
            print("Stage review pass complete. Press Enter to repeat.\n")
            _ = readLine()
            clearScreen()
        }
    }

    let elapsed = Date().timeIntervalSince(startedAt)
    var summary = loadStageGateSummary(workspacePath: workspacePath)
    summary[gate.id] = "passes=\(gate.requiredPasses), seconds=\(Int(elapsed))"
    saveStageGateSummary(summary, workspacePath: workspacePath)
    print("Stage review complete: \(gate.title)")
    print("Total passes: \(gate.requiredPasses)")
    print("Time: \(Int(elapsed))s\n")

    logEvent(
        "stage_review",
        fields: ["stage": gate.id],
        intFields: ["passes": gate.requiredPasses, "seconds": Int(elapsed)],
        workspacePath: workspacePath
    )

    clearStageGateProgress(workspacePath: workspacePath)
}

func runSteps(
    _ steps: [Step],
    startingAt: Int,
    constraintIndex: ConstraintIndex,
    practicePool: [Challenge],
    practiceWorkspace: String,
    adaptiveThreshold: Int,
    adaptiveCount: Int,
    adaptiveEnabled: Bool,
    enforceConstraints: Bool,
    enableDiMockHeuristics: Bool
) {
    var adaptiveGateScores: [ChallengeTopic: Int] = [:]
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
                let didPass = validateChallenge(
                    challenge,
                    nextStepIndex: nextStepIndex,
                    constraintIndex: constraintIndex,
                    enforceConstraints: enforceConstraints,
                    enableDiMockHeuristics: enableDiMockHeuristics
                )
                if didPass {
                    challengeComplete = true
                    currentIndex += 1

                    if currentIndex < steps.count {
                        let prompt = nextStepPrompt(for: steps[currentIndex])
                        if !prompt.isEmpty {
                            print(prompt)
                        }
                        switch steps[currentIndex] {
                        case .challenge, .stageGate:
                            waitForEnterToContinue()
                            clearScreen()
                        case .project:
                            break
                        }
                    } else {
                        saveProgress(999)
                        print("🎉 You've completed everything!")
                        print("Run 'swift run forge reset' to start over.\n")
                    }
                } else if adaptiveEnabled {
                    let stats = loadAdaptiveStats(workspacePath: "workspace")
                    if let score = shouldTriggerAdaptiveGate(
                        topic: challenge.topic,
                        stats: stats,
                        lastTriggered: &adaptiveGateScores,
                        threshold: adaptiveThreshold
                    ) {
                        print("Adaptive gate triggered for \(challenge.topic.rawValue) (score \(score)).")
                        print("Press Enter to start practice.")
                        _ = readLine()
                        runAdaptiveGate(
                            topic: challenge.topic,
                            pool: practicePool,
                            stats: stats,
                            count: adaptiveCount,
                            workspacePath: practiceWorkspace,
                            constraintIndex: constraintIndex,
                            enforceConstraints: enforceConstraints,
                            enableDiMockHeuristics: enableDiMockHeuristics
                        )
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
                constraintIndex: constraintIndex,
                adaptiveEnabled: adaptiveEnabled,
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
                    sleep(2)
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

    let start = Date()
    guard let output = compileAndRun(file: filePath) else {
        print("✗ Compilation failed. Check your code.")
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": "compile_fail"],
            intFields: ["seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }

    // Show what the code printed
    print("Output: \(output)\n")
    
    // Parse output lines
    let outputLines = output.components(separatedBy: "\n")
    
    // Check if all test cases pass
    guard outputLines.count == project.testCases.count else {
        print("✗ Expected \(project.testCases.count) outputs, got \(outputLines.count)")
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
    for (index, testCase) in project.testCases.enumerated() {
        let expected = testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let actual = outputLines[index].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if actual != expected {
            print("✗ Test \(index + 1) failed: expected \(expected), got \(actual)")
            allPassed = false
            failedCount += 1
        }
    }
    
    if allPassed {
        print("✓ Project Complete! Excellent work.\n")
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": "pass"],
            intFields: ["seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return true
    } else {
        print("✗ Some tests failed. Keep working!")
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

func makeStageGate(id: String, title: String, challenges: [Challenge], requiredPasses: Int, count: Int) -> StageGate? {
    guard !challenges.isEmpty else { return nil }
    return StageGate(id: id, title: title, pool: challenges, requiredPasses: requiredPasses, count: count)
}

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
    stats: [String: [String: Int]]
) -> [Challenge] {
    let selectionCount = min(count, challenges.count)
    if selectionCount <= 1 {
        return Array(challenges.prefix(selectionCount))
    }
    return weightedRandomSelection(
        from: challenges,
        weight: { topicScore(for: $0.topic, stats: stats) },
        count: selectionCount
    )
}

func topAdaptiveTopics(
    from challenges: [Challenge],
    stats: [String: [String: Int]],
    limit: Int = 2
) -> [ChallengeTopic] {
    let topics = Set(challenges.map { $0.topic })
    let ranked = topics.map { topic in
        (topic, topicScore(for: topic, stats: stats))
    }.sorted { $0.1 > $1.1 }
    return ranked.prefix(limit).map { $0.0 }
}

func pickAdaptivePracticeSet(
    from challenges: [Challenge],
    stats: [String: [String: Int]],
    count: Int
) -> [Challenge] {
    let topTopics = topAdaptiveTopics(from: challenges, stats: stats, limit: 2)
    guard !topTopics.isEmpty else {
        return Array(challenges.shuffled().prefix(count))
    }
    let filtered = challenges.filter { topTopics.contains($0.topic) }
    if filtered.isEmpty {
        return Array(challenges.shuffled().prefix(count))
    }
    return weightedRandomSelection(
        from: filtered,
        weight: { topicScore(for: $0.topic, stats: stats) },
        count: min(count, filtered.count)
    )
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
    count: Int,
    workspacePath: String,
    constraintIndex: ConstraintIndex,
    enforceConstraints: Bool,
    enableDiMockHeuristics: Bool
) {
    let filtered = pool.filter { $0.topic == topic }
    guard !filtered.isEmpty else { return }
    let selection = weightedRandomSelection(
        from: filtered,
        weight: { _ in 1 },
        count: min(count, filtered.count)
    )

    print("Adaptive practice: focusing on \(topic.rawValue).")
    print("Workspace: \(workspacePath)\n")
    setupWorkspace(at: workspacePath)
    clearWorkspaceContents(at: workspacePath)
    runPracticeChallenges(
        selection,
        workspacePath: workspacePath,
        constraintIndex: constraintIndex,
        enforceConstraints: enforceConstraints,
        enableDiMockHeuristics: enableDiMockHeuristics,
        completionTitle: "Adaptive practice complete!",
        finishPrompt: "Press Enter to return.\n"
    )
    clearScreen()
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

func printMainUsage() {
    print("""
    Usage:
      swift run forge
      swift run forge reset
      swift run forge reset --all
      swift run forge reset --start
      swift run forge stats
      swift run forge random [count] [topic] [tier] [layer]
      swift run forge project <id>
      swift run forge verify-solutions
      swift run forge review-progression
      swift run forge --allow-early-concepts
      swift run forge --disable-di-mock-heuristics
      swift run forge --adaptive-on
      swift run forge --adaptive-threshold <n>
      swift run forge --adaptive-count <n>
      swift run forge --adaptive-off
      swift run forge --help

    Try:
      swift run forge random --help
      swift run forge project --help
      swift run forge stats
      swift run forge stats --reset
      swift run forge verify-solutions crust
      swift run forge verify-solutions 190-237
      swift run forge review-progression core
      swift run forge review-progression 1-80
      swift run forge --gate-passes 1
      swift run forge --gate-count 2
      swift run forge --allow-early-concepts
      swift run forge --disable-di-mock-heuristics
      swift run forge --adaptive-on
      swift run forge --adaptive-threshold 2
      swift run forge --adaptive-count 4
      swift run forge --adaptive-off
    """)
}

func printRandomUsage() {
    print("""
    Usage: swift run forge random [count] [topic] [tier] [layer]

    Topics: conditionals, loops, optionals, collections, functions, strings, structs, general
    Tiers: mainline, extra
    Layers: core, mantle, crust
    Adaptive: use 'adaptive' to bias toward weaker topics

    Examples:
      swift run forge random 8
      swift run forge random conditionals
      swift run forge random 6 loops extra
      swift run forge random 10 mantle
      swift run forge random 12 mainline
      swift run forge random adaptive
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

func printStatsUsage() {
    print("""
    Usage:
      swift run forge stats
      swift run forge stats --reset
      swift run forge stats --help

    Prints per-topic adaptive stats from workspace/.adaptive_stats.
    Use --reset to clear the stats file.
    """)
}

func printAdaptiveStats(workspacePath: String = "workspace") {
    let stats = loadAdaptiveStats(workspacePath: workspacePath)
    if stats.isEmpty {
        print("No adaptive stats recorded yet.")
        return
    }
    print("Adaptive stats:")
    var topicScores: [(topic: String, score: Int)] = []
    for topic in stats.keys.sorted() {
        let counts = stats[topic, default: [:]]
        let pass = counts["pass", default: 0]
        let fail = counts["fail", default: 0]
        let compileFail = counts["compile_fail", default: 0]
        let manualPass = counts["manual_pass", default: 0]
        let score = max(1, 1 + (fail + compileFail) - (pass + manualPass))
        topicScores.append((topic, score))
        print("- \(topic): pass=\(pass), fail=\(fail), compile_fail=\(compileFail), manual_pass=\(manualPass)")
    }
    let weakTopics = topicScores.sorted { $0.score > $1.score }.prefix(3)
    if !weakTopics.isEmpty {
        let summary = weakTopics.map { "\($0.topic)(\($0.score))" }.joined(separator: ", ")
        print("Top weak topics: \(summary)")
    }
}

func resetAdaptiveStats(workspacePath: String = "workspace") {
    let path = adaptiveStatsFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
    print("✓ Adaptive stats reset.")
}

func parseRandomArguments(
    _ args: [String]
) -> (count: Int, topic: ChallengeTopic?, tier: ChallengeTier?, layer: ChallengeLayer?, adaptive: Bool) {
    var count = 5
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?
    var adaptive = false

    for value in args {
        if let number = Int(value) {
            count = max(number, 1)
            continue
        }
        let lowered = value.lowercased()
        if lowered == "help" || lowered == "-h" || lowered == "--help" {
            continue
        }
        if lowered == "adaptive" {
            adaptive = true
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

    return (count, topic, tier, layer, adaptive)
}

func parseGateSettings(
    _ args: [String]
) -> (passes: Int, count: Int, remaining: [String]) {
    var passes = 2
    var count = 3
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--gate-passes", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                passes = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--gate-count", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                count = max(1, value)
            }
            index += 2
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (passes, count, remaining)
}

func parseAdaptiveSettings(
    _ args: [String]
) -> (threshold: Int, count: Int, enabled: Bool, remaining: [String]) {
    var threshold = 3
    var count = 3
    var enabled = false
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--adaptive-on" {
            enabled = true
            index += 1
            continue
        }
        if arg == "--adaptive-off" {
            enabled = false
            index += 1
            continue
        }
        if arg == "--adaptive-threshold", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                threshold = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-count", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                count = max(1, value)
            }
            index += 2
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (threshold, count, enabled, remaining)
}

func parseConstraintSettings(
    _ args: [String]
) -> (enforce: Bool, enableDiMockHeuristics: Bool, remaining: [String]) {
    var enforce = true
    var enableDiMockHeuristics = true
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--enforce-constraints" {
            enforce = true
            index += 1
            continue
        }
        if arg == "--allow-early-concepts" {
            enforce = false
            index += 1
            continue
        }
        if arg == "--disable-di-mock-heuristics" {
            enableDiMockHeuristics = false
            index += 1
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (enforce, enableDiMockHeuristics, remaining)
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

func reviewProgression(
    _ challenges: [Challenge],
    constraintIndex: ConstraintIndex,
    enableDiMockHeuristics: Bool
) -> Bool {
    let sorted = challenges.sorted { $0.number < $1.number }
    var issues: [(id: String, detail: String)] = []
    var skipped = 0

    print("Reviewing \(sorted.count) challenge solution(s)...")

    for challenge in sorted {
        let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
        if solution.isEmpty {
            skipped += 1
            continue
        }
        let warnings = constraintWarnings(
            for: solution,
            challenge: challenge,
            index: constraintIndex,
            enableDiMockHeuristics: enableDiMockHeuristics
        )
        for warning in warnings {
            issues.append((challenge.displayId, warning))
        }
    }

    if issues.isEmpty {
        print("✓ No early-concept usage detected.")
        if skipped > 0 {
            print("Skipped: \(skipped) (missing solutions)")
        }
        return true
    }

    print("✗ Found \(issues.count) potential early-concept usage issue(s).")
    for issue in issues {
        print("- \(issue.id): \(issue.detail)")
    }
    if skipped > 0 {
        print("Skipped: \(skipped) (missing solutions)")
    }
    return false
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

func runPracticeChallenges(
    _ challenges: [Challenge],
    workspacePath: String,
    constraintIndex: ConstraintIndex,
    enforceConstraints: Bool = false,
    enableDiMockHeuristics: Bool = true,
    completionTitle: String = "✅ Random set complete!",
    finishPrompt: String = "Press Enter to finish.\n"
) {
    var completedFiles: [String] = []

    for (index, challenge) in challenges.enumerated() {
        loadChallenge(challenge, workspacePath: workspacePath)
        var hintIndex = 0
        var challengeComplete = false
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

            if !missingPrereqs.isEmpty {
                print("✗ Prerequisites not introduced yet: \(missingPrereqNames).")
                continue
            }

            if challenge.manualCheck {
                print("\n--- Manual check ---\n")
                print("Manual check: forge does not auto-validate this challenge.")
                print("✓ Challenge marked complete.\n")
                recordAdaptiveStat(topic: challenge.topic, result: "manual_pass", workspacePath: workspacePath)
                logEvent(
                    "challenge_manual_complete",
                    fields: ["id": challenge.displayId, "mode": "random"],
                    intFields: ["number": challenge.number],
                    workspacePath: workspacePath
                )
                completedFiles.append("\(workspacePath)/\(challenge.filename)")
                challengeComplete = true
            } else {
                print("\n--- Testing your code... ---\n")
                let filePath = "\(workspacePath)/\(challenge.filename)"
                if let source = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    let warnings = constraintWarnings(
                        for: source,
                        challenge: challenge,
                        index: constraintIndex,
                        enableDiMockHeuristics: enableDiMockHeuristics
                    )
                    if !warnings.isEmpty {
                        for warning in warnings {
                            print(warning)
                        }
                        print("")
                        if enforceConstraints {
                            print("✗ Constraint violation. Remove early concepts and retry.")
                            continue
                        }
                    }
                }
                let start = Date()
                let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
                guard let output = compileAndRun(file: filePath, arguments: args, stdin: stdin) else {
                    print("✗ Compilation failed. Check your code.")
                    recordAdaptiveStat(topic: challenge.topic, result: "compile_fail", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "compile_fail", "mode": "random"],
                        intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
                    continue
                }

                print("Output: \(output)\n")

                if validateOutputLines(output: output, expected: challenge.expectedOutput) {
                    print("✓ Challenge Complete! Well done.\n")
                    recordAdaptiveStat(topic: challenge.topic, result: "pass", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "pass", "mode": "random"],
                        intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
                    completedFiles.append("\(workspacePath)/\(challenge.filename)")
                    challengeComplete = true
                } else {
                    print("✗ Output doesn't match.")
                    recordAdaptiveStat(topic: challenge.topic, result: "fail", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "fail", "mode": "random"],
                        intFields: ["number": challenge.number, "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
                }
            }
        }

        if index < challenges.count - 1 {
            print("Press Enter for the next random challenge.")
            _ = readLine()
            clearScreen()
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
        let parsed = parseGateSettings(Array(CommandLine.arguments.dropFirst()))
        let gatePasses = parsed.passes
        let gateCount = parsed.count
        let constraintParsed = parseConstraintSettings(parsed.remaining)
        let enforceConstraints = constraintParsed.enforce
        let enableDiMockHeuristics = constraintParsed.enableDiMockHeuristics
        let adaptiveParsed = parseAdaptiveSettings(constraintParsed.remaining)
        let adaptiveThreshold = adaptiveParsed.threshold
        let adaptiveCount = adaptiveParsed.count
        let adaptiveEnabled = adaptiveParsed.enabled
        let args = adaptiveParsed.remaining
        if !enforceConstraints {
            print("Note: Early-concept usage will warn only (--allow-early-concepts).\n")
        }
        if !enableDiMockHeuristics {
            print("Note: DI/mock heuristics disabled (--disable-di-mock-heuristics).\n")
        }

        if !args.isEmpty {
            let firstArg = args[0].lowercased()
            if ["help", "-h", "--help"].contains(firstArg) {
                printMainUsage()
                return
            }
        }

        let overrideToken: String? = {
            guard !args.isEmpty else { return nil }
            let arg = args[0]
            let lowered = arg.lowercased()
            if ["reset", "random", "project", "verify-solutions", "verify", "review-progression", "review", "stats"].contains(lowered) {
                return nil
            }
            if ["help", "-h", "--help"].contains(lowered) {
                return nil
            }
            return arg
        }()

        // Check for reset command
        if !args.isEmpty && args[0] == "reset" {
            setupWorkspace()
            let flags = args.dropFirst().map { $0.lowercased() }
            let removeAll = flags.contains("--all")
            let startAfterReset = flags.contains("--start")
            resetProgress(removeAll: removeAll)
            if !startAfterReset {
                return
            }
        }

        if !args.isEmpty && args[0] == "stats" {
            if args.count > 1 {
                let flag = args[1].lowercased()
                if ["--help", "-h", "help"].contains(flag) {
                    printStatsUsage()
                    return
                }
                if flag == "--reset" {
                    resetAdaptiveStats()
                    return
                }
            }
            printAdaptiveStats()
            return
        }

        let core1Challenges = makeCore1Challenges()
        let core2Challenges = makeCore2Challenges()
        let core3Challenges = makeCore3Challenges()
        let mantleChallenges = makeMantleChallenges()
        let crustChallenges = makeCrustChallenges()
        let bridgeChallenges = makeBridgeChallenges()
        let projects = makeProjects()
        let allChallenges = core1Challenges
            + core2Challenges
            + core3Challenges
            + mantleChallenges
            + crustChallenges
            + bridgeChallenges.coreToMantle
            + bridgeChallenges.mantleToCrust
        let constraintIndex = buildConstraintIndex(from: allChallenges)

        if !args.isEmpty {
            let firstArg = args[0].lowercased()
            if ["verify-solutions", "verify"].contains(firstArg) {
                let verifyArgs = Array(args.dropFirst())
                let (range, topic, tier, layer) = parseVerifyArguments(verifyArgs)
                var pool = allChallenges
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
            if ["review-progression", "review"].contains(firstArg) {
                let reviewArgs = Array(args.dropFirst())
                let (range, topic, tier, layer) = parseVerifyArguments(reviewArgs)
                var pool = core1Challenges + core2Challenges + core3Challenges + mantleChallenges + crustChallenges + bridgeChallenges.coreToMantle + bridgeChallenges.mantleToCrust
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
                _ = reviewProgression(
                    pool,
                    constraintIndex: constraintIndex,
                    enableDiMockHeuristics: enableDiMockHeuristics
                )
                return
            }
        }

        if !args.isEmpty && args[0] == "random" {
            setupWorkspace(at: practiceWorkspace)
            setupWorkspace(at: projectWorkspace)
            clearWorkspaceContents(at: practiceWorkspace)
            clearWorkspaceContents(at: projectWorkspace)
            let randomArgs = Array(args.dropFirst())
            if randomArgs.contains(where: { ["help", "-h", "--help"].contains($0.lowercased()) }) {
                printRandomUsage()
                return
            }
            let (count, topic, tier, layer, adaptive) = parseRandomArguments(randomArgs)
            var pool = allChallenges

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
            let stats = loadAdaptiveStats(workspacePath: "workspace")
            let selection = adaptive
                ? pickAdaptivePracticeSet(from: pool, stats: stats, count: selectionCount)
                : weightedRandomSelection(
                    from: pool,
                    weight: { topicScore(for: $0.topic, stats: stats) },
                    count: selectionCount
                )
            clearScreen()
            print("Random mode: \(selectionCount) challenge(s).")
            print("Workspace: \(practiceWorkspace)\n")
            runPracticeChallenges(
                selection,
                workspacePath: practiceWorkspace,
                constraintIndex: constraintIndex,
                enforceConstraints: enforceConstraints,
                enableDiMockHeuristics: enableDiMockHeuristics
            )
            return
        }

        if !args.isEmpty && args[0] == "project" {
            setupWorkspace(at: projectWorkspace)
            setupWorkspace(at: practiceWorkspace)
            clearWorkspaceContents(at: projectWorkspace)
            clearWorkspaceContents(at: practiceWorkspace)
            guard args.count > 1 else {
                printProjectUsage()
                return
            }
            let projectCommand = args[1].lowercased()
            if ["--help", "-h", "help"].contains(projectCommand) {
                printProjectUsage()
                return
            }
            if ["--list", "-l", "list"].contains(projectCommand) {
                let listArgs = Array(args.dropFirst(2))
                let (tier, layer) = parseProjectListArguments(listArgs)
                printProjectList(projects, tier: tier, layer: layer)
                return
            }
            if ["--random", "-r", "random"].contains(projectCommand) {
                let randomArgs = Array(args.dropFirst(2))
                let (tier, layer) = parseProjectRandomArguments(randomArgs)
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
            bridgeChallenges: bridgeChallenges,
            projects: projects,
            gatePasses: gatePasses,
            gateCount: gateCount
        )
        let challengeIndexMap = challengeStepIndexMap(for: steps)
        let challengeIdIndexMap = challengeIdStepIndexMap(for: steps)
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
            runSteps(
                steps,
                startingAt: startIndex,
                constraintIndex: constraintIndex,
                practicePool: allChallenges,
                practiceWorkspace: practiceWorkspace,
                adaptiveThreshold: adaptiveThreshold,
                adaptiveCount: adaptiveCount,
                adaptiveEnabled: adaptiveEnabled,
                enforceConstraints: enforceConstraints,
                enableDiMockHeuristics: enableDiMockHeuristics
            )
        } else {
            if let extraNotice = extraNotice {
                print(extraNotice)
            }
            print("🎉 You've completed everything!")
            print("Run 'swift run forge reset' to start over.\n")
        }
    }
}
