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

func resetWorkspaceContents(at workspacePath: String, removeAll: Bool) {
    let fileManager = FileManager.default
    if let files = try? fileManager.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            if removeAll || !file.hasPrefix(".") {
                try? fileManager.removeItem(atPath: "\(workspacePath)/\(file)")
            }
        }
    }
}

func resetProgress(workspacePath: String = "workspace", removeAll: Bool = false) {
    let progressFile = progressFilePath(workspacePath: workspacePath)
    let fileManager = FileManager.default
    let stageGateFile = stageGateFilePath(workspacePath: workspacePath)
    
    // Delete progress file
    try? fileManager.removeItem(atPath: progressFile)
    try? fileManager.removeItem(atPath: stageGateFile)
    
    resetWorkspaceContents(at: workspacePath, removeAll: removeAll)
    setupWorkspace(at: "workspace_random")
    setupWorkspace(at: "workspace_projects")
    setupWorkspace(at: "workspace_verify")
    setupWorkspace(at: "workspace_review")
    setupWorkspace(at: "workspace_practice")
    resetWorkspaceContents(at: "workspace_random", removeAll: removeAll)
    resetWorkspaceContents(at: "workspace_projects", removeAll: removeAll)
    resetWorkspaceContents(at: "workspace_verify", removeAll: removeAll)
    resetWorkspaceContents(at: "workspace_review", removeAll: removeAll)
    resetWorkspaceContents(at: "workspace_practice", removeAll: removeAll)
    
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

    let idLabel = challenge.id.isEmpty || challenge.id == challenge.displayId ? "" : " (\(challenge.id))"
    print(
        """

        Challenge \(challenge.displayId)\(idLabel): \(challenge.title)
        └─ \(challenge.description)

        Edit: \(filePath)

        \(prereqBlock)
        \(checkMessage)
        Type 'h' for a hint, 'c' for a cheatsheet, 'l' for a lesson, or 's' for the solution.
        Viewing the solution may queue practice when adaptive is enabled.
        """)
}

func layerIndex(for challenge: Challenge) -> Int {
    if challenge.displayId.hasPrefix("bridge:") {
        return 0
    }
    return challenge.layerNumber ?? challenge.number
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

func adaptiveChallengeStatsFilePath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.adaptive_challenge_stats"
}

func pendingPracticeFilePath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.pending_practice"
}

struct PendingPractice {
    let topic: ChallengeTopic
    let count: Int
    let challengeId: String
    let challengeNumber: Int
    let layer: ChallengeLayer
}

struct ChallengeStats {
    var pass: Int = 0
    var passAssisted: Int = 0
    var fail: Int = 0
    var compileFail: Int = 0
    var manualPass: Int = 0
    var lastAttempt: Int = 0
}

func parseStatCounts(_ raw: String) -> [String: Int] {
    var result: [String: Int] = [:]
    for entry in raw.split(separator: ",") {
        let parts = entry.split(separator: "=", maxSplits: 1).map(String.init)
        guard parts.count == 2, let value = Int(parts[1]) else { continue }
        result[parts[0]] = value
    }
    return result
}

func parseKeyValues(_ raw: String) -> [String: String] {
    var result: [String: String] = [:]
    for entry in raw.split(separator: ",") {
        let parts = entry.split(separator: "=", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { continue }
        result[parts[0]] = parts[1]
    }
    return result
}

func loadPendingPractice(workspacePath: String = "workspace") -> PendingPractice? {
    let path = pendingPracticeFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return nil
    }
    let kv = parseKeyValues(content)
    guard
        let topicRaw = kv["topic"],
        let topic = ChallengeTopic(rawValue: topicRaw),
        let countRaw = kv["count"],
        let count = Int(countRaw),
        let challengeId = kv["id"],
        let numberRaw = kv["number"],
        let number = Int(numberRaw),
        let layerRaw = kv["layer"],
        let layer = ChallengeLayer(rawValue: layerRaw)
    else {
        return nil
    }
    return PendingPractice(
        topic: topic,
        count: count,
        challengeId: challengeId,
        challengeNumber: number,
        layer: layer
    )
}

func savePendingPractice(
    challenge: Challenge,
    count: Int,
    workspacePath: String = "workspace"
) {
    let path = pendingPracticeFilePath(workspacePath: workspacePath)
    let layerNumber = layerIndex(for: challenge)
    let content = [
        "topic=\(challenge.topic.rawValue)",
        "count=\(count)",
        "id=\(challenge.displayId)",
        "number=\(layerNumber)",
        "legacy=\(challenge.number)",
        "layer=\(challenge.layer.rawValue)",
    ].joined(separator: ",")
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}

func clearPendingPractice(workspacePath: String = "workspace") {
    let path = pendingPracticeFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
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

func loadAdaptiveChallengeStats(workspacePath: String = "workspace") -> [String: ChallengeStats] {
    let path = adaptiveChallengeStatsFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return [:]
    }
    var stats: [String: ChallengeStats] = [:]
    for line in content.split(separator: "\n") {
        let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { continue }
        let counts = parseStatCounts(parts[1])
        var entry = ChallengeStats()
        entry.pass = counts["pass", default: 0]
        entry.passAssisted = counts["pass_assisted", default: 0]
        entry.fail = counts["fail", default: 0]
        entry.compileFail = counts["compile_fail", default: 0]
        entry.manualPass = counts["manual_pass", default: 0]
        entry.lastAttempt = counts["last", default: 0]
        stats[parts[0]] = entry
    }
    return stats
}

func saveAdaptiveChallengeStats(
    _ stats: [String: ChallengeStats],
    workspacePath: String = "workspace"
) {
    let path = adaptiveChallengeStatsFilePath(workspacePath: workspacePath)
    let lines = stats.keys.sorted().map { id in
        let entry = stats[id] ?? ChallengeStats()
        let entries: [String] = [
            "pass=\(entry.pass)",
            "pass_assisted=\(entry.passAssisted)",
            "fail=\(entry.fail)",
            "compile_fail=\(entry.compileFail)",
            "manual_pass=\(entry.manualPass)",
            "last=\(entry.lastAttempt)",
        ]
        return "\(id)|\(entries.joined(separator: ","))"
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

func recordAdaptiveChallengeStat(
    challenge: Challenge,
    result: String,
    workspacePath: String = "workspace"
) {
    var stats = loadAdaptiveChallengeStats(workspacePath: workspacePath)
    let id = challenge.displayId
    var entry = stats[id] ?? ChallengeStats()
    switch result {
    case "pass":
        entry.pass += 1
    case "pass_assisted":
        entry.passAssisted += 1
    case "fail":
        entry.fail += 1
    case "compile_fail":
        entry.compileFail += 1
    case "manual_pass":
        entry.manualPass += 1
    default:
        break
    }
    entry.lastAttempt = Int(Date().timeIntervalSince1970)
    stats[id] = entry
    saveAdaptiveChallengeStats(stats, workspacePath: workspacePath)
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

func constraintMasteryPath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.constraint_mastery"
}

enum ConstraintMasteryState: String {
    case warn
    case block
    case relax
}

struct ConstraintMasteryEntry {
    var state: ConstraintMasteryState
    var warnCount: Int
    var cleanCount: Int
}

func loadConstraintMastery(workspacePath: String = "workspace") -> [String: ConstraintMasteryEntry] {
    let path = constraintMasteryPath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return [:]
    }
    var entries: [String: ConstraintMasteryEntry] = [:]
    for line in content.split(separator: "\n") {
        let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { continue }
        let topic = parts[0]
        let kvs = parseKeyValues(parts[1])
        let stateRaw = kvs["state"].flatMap { ConstraintMasteryState(rawValue: $0) } ?? .block
        let warnCount = Int(kvs["warn"] ?? "") ?? 0
        let cleanCount = Int(kvs["clean"] ?? "") ?? 0
        entries[topic] = ConstraintMasteryEntry(state: stateRaw, warnCount: warnCount, cleanCount: cleanCount)
    }
    return entries
}

func saveConstraintMastery(_ entries: [String: ConstraintMasteryEntry], workspacePath: String = "workspace") {
    let lines = entries.keys.sorted().map { topic -> String in
        let entry = entries[topic] ?? ConstraintMasteryEntry(state: .block, warnCount: 0, cleanCount: 0)
        return "\(topic)|state=\(entry.state.rawValue),warn=\(entry.warnCount),clean=\(entry.cleanCount)"
    }
    let content = lines.joined(separator: "\n")
    try? content.write(toFile: constraintMasteryPath(workspacePath: workspacePath), atomically: true, encoding: .utf8)
}

func effectiveConstraintEnforcement(
    for topic: ChallengeTopic,
    enforceConstraints: Bool,
    workspacePath: String = "workspace"
) -> Bool {
    guard enforceConstraints else { return false }
    let entries = loadConstraintMastery(workspacePath: workspacePath)
    let entry = entries[topic.rawValue] ?? ConstraintMasteryEntry(state: .block, warnCount: 0, cleanCount: 0)
    return entry.state == .block
}

func recordConstraintMastery(
    topic: ChallengeTopic,
    hadWarnings: Bool,
    passed: Bool,
    workspacePath: String = "workspace"
) {
    let warnToBlockThreshold = 2
    let blockToRelaxThreshold = 3
    let relaxToWarnThreshold = 3

    var entries = loadConstraintMastery(workspacePath: workspacePath)
    var entry = entries[topic.rawValue] ?? ConstraintMasteryEntry(state: .block, warnCount: 0, cleanCount: 0)

    if hadWarnings {
        entry.cleanCount = 0
        if entry.state != .block {
            entry.warnCount += 1
            if entry.warnCount >= warnToBlockThreshold {
                entry.state = .block
                entry.warnCount = 0
                entry.cleanCount = 0
            }
        }
    } else if passed {
        entry.warnCount = 0
        if entry.state == .block {
            entry.cleanCount += 1
            if entry.cleanCount >= blockToRelaxThreshold {
                entry.state = .relax
                entry.cleanCount = 0
            }
        } else if entry.state == .relax {
            entry.cleanCount += 1
            if entry.cleanCount >= relaxToWarnThreshold {
                entry.state = .warn
                entry.cleanCount = 0
            }
        }
    }

    entries[topic.rawValue] = entry
    saveConstraintMastery(entries, workspacePath: workspacePath)
}

func resetPerformanceLog(workspacePath: String = "workspace") {
    let path = performanceLogPath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
}

func loadPerformanceLogEntries(workspacePath: String = "workspace") -> [String] {
    let path = performanceLogPath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return []
    }
    return content.split(separator: "\n").map(String.init)
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

func extractLogField(_ line: String, key: String) -> String? {
    let needle = "\"\(key)\":\""
    guard let range = line.range(of: needle) else { return nil }
    let start = range.upperBound
    guard let end = line[start...].firstIndex(of: "\"") else { return nil }
    return String(line[start..<end])
}

func parseLogTimestamp(_ value: String) -> Date? {
    return ISO8601DateFormatter().date(from: value)
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

func legacyChallengeIdMap(for challenges: [Challenge]) -> [String: String] {
    var map: [String: String] = [:]
    for challenge in challenges {
        let canonical = challenge.displayId
        map[String(challenge.number)] = canonical
        if !challenge.id.isEmpty {
            map[challenge.id.lowercased()] = canonical
        } else if challenge.tier == .extra {
            map["\(challenge.number)a"] = canonical
        }
    }
    return map
}

func mergeChallengeStats(_ base: ChallengeStats, _ incoming: ChallengeStats) -> ChallengeStats {
    var merged = ChallengeStats()
    merged.pass = base.pass + incoming.pass
    merged.passAssisted = base.passAssisted + incoming.passAssisted
    merged.fail = base.fail + incoming.fail
    merged.compileFail = base.compileFail + incoming.compileFail
    merged.manualPass = base.manualPass + incoming.manualPass
    merged.lastAttempt = max(base.lastAttempt, incoming.lastAttempt)
    return merged
}

func migrateAdaptiveChallengeStatsIfNeeded(
    legacyIdMap: [String: String],
    workspacePath: String = "workspace"
) {
    let path = adaptiveChallengeStatsFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return
    }
    var migrated: [String: ChallengeStats] = [:]
    var changed = false
    for line in content.split(separator: "\n") {
        let parts = line.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { continue }
        let rawId = parts[0]
        let mappedId = legacyIdMap[rawId.lowercased()] ?? rawId
        if mappedId != rawId {
            changed = true
        }
        let counts = parseStatCounts(parts[1])
        var entry = ChallengeStats()
        entry.pass = counts["pass", default: 0]
        entry.passAssisted = counts["pass_assisted", default: 0]
        entry.fail = counts["fail", default: 0]
        entry.compileFail = counts["compile_fail", default: 0]
        entry.manualPass = counts["manual_pass", default: 0]
        entry.lastAttempt = counts["last", default: 0]
        let existing = migrated[mappedId] ?? ChallengeStats()
        migrated[mappedId] = mergeChallengeStats(existing, entry)
    }
    guard changed else { return }
    let backupPath = "\(path).bak"
    if !FileManager.default.fileExists(atPath: backupPath) {
        try? content.write(toFile: backupPath, atomically: true, encoding: .utf8)
    }
    saveAdaptiveChallengeStats(migrated, workspacePath: workspacePath)
}

func migratePendingPracticeIfNeeded(
    legacyIdMap: [String: String],
    legacyNumberMap: [Int: Challenge],
    workspacePath: String = "workspace"
) {
    let path = pendingPracticeFilePath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return
    }
    var kv = parseKeyValues(content)
    var changed = false
    if let rawId = kv["id"], let mapped = legacyIdMap[rawId.lowercased()], mapped != rawId {
        kv["id"] = mapped
        changed = true
    }
    if let numberRaw = kv["number"], let number = Int(numberRaw), let challenge = legacyNumberMap[number] {
        let mappedNumber = layerIndex(for: challenge)
        if mappedNumber != number {
            kv["number"] = String(mappedNumber)
            kv["legacy"] = String(challenge.number)
            changed = true
        }
    }
    guard changed else { return }
    let updated = kv.keys.sorted().map { "\($0)=\(kv[$0] ?? "")" }.joined(separator: ",")
    try? updated.write(toFile: path, atomically: true, encoding: .utf8)
}

func migratePerformanceLogIfNeeded(
    legacyIdMap: [String: String],
    legacyNumberMap: [Int: Challenge],
    workspacePath: String = "workspace"
) {
    let path = performanceLogPath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return
    }
    var changed = false
    var outputLines: [String] = []
    for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
        guard let data = line.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              var object = json as? [String: Any]
        else {
            outputLines.append(String(line))
            continue
        }
        if let rawId = object["id"] as? String, let mapped = legacyIdMap[rawId.lowercased()], mapped != rawId {
            object["id"] = mapped
            changed = true
        }
        if let number = object["number"] as? Int, let challenge = legacyNumberMap[number] {
            let mappedNumber = layerIndex(for: challenge)
            if mappedNumber != number {
                object["number"] = mappedNumber
                object["legacy_number"] = challenge.number
                changed = true
            }
        }
        if let dataOut = try? JSONSerialization.data(withJSONObject: object, options: []),
           let lineOut = String(data: dataOut, encoding: .utf8) {
            outputLines.append(lineOut)
        } else {
            outputLines.append(String(line))
        }
    }
    guard changed else { return }
    let backupPath = "\(path).bak"
    if !FileManager.default.fileExists(atPath: backupPath) {
        try? content.write(toFile: backupPath, atomically: true, encoding: .utf8)
    }
    let output = outputLines.joined(separator: "\n")
    try? output.write(toFile: path, atomically: true, encoding: .utf8)
}

func migrateProgressTokenIfNeeded(
    token: String?,
    steps: [Step],
    challengeIndexMap: [Int: Int],
    challengeIdIndexMap: [String: Int],
    projectIndexMap: [String: Int],
    maxChallengeNumber: Int,
    legacyIdMap: [String: String],
    allChallengeIdMap: [String: Challenge],
    allChallengeNumberMap: [Int: Challenge]
) {
    guard let raw = token?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
        return
    }
    if Int(raw) != nil {
        return
    }
    let lowered = raw.lowercased()
    var startIndex: Int? = nil

    if lowered.hasPrefix("challenge:") {
        let value = String(raw.dropFirst("challenge:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(value) {
            let remapped = remapLegacyChallengeNumber(number)
            startIndex = challengeIndexMap[remapped]
        } else if !value.isEmpty {
            let id = value.lowercased()
            let mappedId = legacyIdMap[id] ?? id
            startIndex = challengeIdIndexMap[mappedId]
        }
    } else if lowered.hasPrefix("project:") {
        let value = String(raw.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        startIndex = projectIndexMap[value.lowercased()]
    } else if lowered.hasPrefix("step:") {
        let value = String(raw.dropFirst("step:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(value) {
            startIndex = normalizedStepIndex(number, stepsCount: steps.count)
        }
    } else if let number = Int(raw) {
        startIndex = stepIndexForChallenge(
            number,
            challengeStepIndex: challengeIndexMap,
            maxChallengeNumber: maxChallengeNumber,
            stepsCount: steps.count
        )
    } else if let index = projectIndexMap[lowered] {
        startIndex = index
    } else if let mappedId = legacyIdMap[lowered], let index = challengeIdIndexMap[mappedId] {
        startIndex = index
    } else if let index = challengeIdIndexMap[lowered] {
        startIndex = index
    } else if let extraChallenge = allChallengeIdMap[lowered], extraChallenge.tier == .extra {
        startIndex = nil
    } else if let number = Int(raw), allChallengeNumberMap[number]?.tier == .extra {
        startIndex = nil
    }

    guard let resolved = startIndex else { return }
    saveProgress(resolved)
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

func logConstraintViolation(
    _ challenge: Challenge,
    mode: String? = nil,
    workspacePath: String = "workspace"
) {
    var fields: [String: String] = ["id": challenge.displayId]
    if let mode = mode {
        fields["mode"] = mode
    }
    logEvent(
        "constraint_violation",
        fields: fields,
        intFields: ["number": layerIndex(for: challenge)],
        workspacePath: workspacePath
    )
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
        let (stdin, args) = prepareChallengeEnvironment(challenge, workspacePath: workspacePath)
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

func isIdentifierToken(_ token: String) -> Bool {
    guard let first = token.first else { return false }
    guard first.isLetter || first == "_" else { return false }
    for ch in token.dropFirst() where !(ch.isLetter || ch.isNumber || ch == "_") {
        return false
    }
    return true
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
    guard tokens.count >= 2 else { return false }
    let typeContextTokens: Set<String> = [":", "->", "[", ",", "("]
    for index in 1..<tokens.count where tokens[index] == "?" {
        let prev = tokens[index - 1]
        guard isIdentifierToken(prev) else { continue }
        let prevPrev = index >= 2 ? tokens[index - 2] : ""
        if typeContextTokens.contains(prevPrev) {
            return true
        }
    }
    return false
}

func hasOptionalUsage(_ tokens: [String]) -> Bool {
    return hasOptionalType(tokens)
        || hasToken(tokens, "nil")
        || hasToken(tokens, "??")
        || hasSequence(tokens, ["if", "let"])
        || hasSequence(tokens, ["guard", "let"])
        || hasSequence(tokens, ["as", "?"])
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

func hasClosureAssignment(_ tokens: [String]) -> Bool {
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) {
        let token = tokens[index]
        let next = tokens[index + 1]
        if (token == "=" || token == "return") && next == "{" {
            return true
        }
    }
    return false
}

func hasClosureUsage(_ tokens: [String]) -> Bool {
    return hasClosureToken(tokens) || hasShorthandClosureArg(tokens) || hasClosureAssignment(tokens)
}

func hasCollectionUsage(tokens: [String], source: String) -> Bool {
    if tokens.contains("Array") || tokens.contains("Dictionary") || tokens.contains("Set") {
        return true
    }
    if hasCollectionLiteral(tokens: tokens) {
        return true
    }
    return false
}

func hasCollectionLiteral(tokens: [String]) -> Bool {
    let starterTokens: Set<String> = [":", "=", "return", "in", ",", "(", "["]
    var index = 0
    while index < tokens.count {
        if tokens[index] == "[" {
            let prev = index > 0 ? tokens[index - 1] : ""
            if prev == "{" {
                index += 1
                continue
            }
            var j = index + 1
            while j < tokens.count && tokens[j] != "]" {
                j += 1
            }
            if j < tokens.count {
                if starterTokens.contains(prev) {
                    return true
                }
                let innerTokens = tokens[(index + 1)..<j]
                if innerTokens.contains(where: { $0 == "," || $0 == ":" }) {
                    return true
                }
            }
        }
        index += 1
    }
    return false
}

func hasTupleUsage(_ tokens: [String]) -> Bool {
    let anchors: Set<String> = ["=", ":", "->", "return"]
    var index = 0
    while index < tokens.count - 1 {
        let token = tokens[index]
        if anchors.contains(token), tokens[index + 1] == "(" {
            if hasTupleParens(tokens, startIndex: index + 1) {
                return true
            }
        }
        index += 1
    }
    return false
}

func hasTupleParens(_ tokens: [String], startIndex: Int) -> Bool {
    var depth = 0
    var sawComma = false
    var index = startIndex
    while index < tokens.count {
        let token = tokens[index]
        if token == "(" {
            depth += 1
        } else if token == ")" {
            depth -= 1
            if depth == 0 {
                return sawComma
            }
        } else if token == "," && depth == 1 {
            sawComma = true
        }
        index += 1
    }
    return false
}

func hasTryOptional(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["try", "?"])
}

func hasCommandLineArguments(_ tokens: [String]) -> Bool {
    if hasSequence(tokens, ["CommandLine", ".", "arguments"]) {
        return true
    }
    if hasSequence(tokens, ["ProcessInfo", ".", "processInfo", ".", "arguments"]) {
        return true
    }
    return false
}

func hasFileIO(_ tokens: [String]) -> Bool {
    if tokens.contains("contentsOfFile") || tokens.contains("FileHandle") || tokens.contains("FileManager") {
        return true
    }
    if hasSequence(tokens, ["Data", ".", "contentsOf"]) {
        return true
    }
    if hasSequence(tokens, ["String", ".", "contentsOf"]) {
        return true
    }
    if hasSequence(tokens, ["URL", ".", "fileURLWithPath"]) {
        return true
    }
    if tokens.contains("URL") || tokens.contains("Path") {
        return true
    }
    return false
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
    if let whereIndex = tokens.firstIndex(of: "where") {
        for index in 0..<whereIndex where anchors.contains(tokens[index]) {
            return true
        }
    }
    return false
}

func hasTaskUsage(_ tokens: [String]) -> Bool {
    let nextTokens: Set<String> = ["{", "(", ".", "<", "?", "!"]
    let prevTokens: Set<String> = [":", "->"]
    for (index, token) in tokens.enumerated() where token == "Task" {
        if index > 0, prevTokens.contains(tokens[index - 1]) {
            return true
        }
        let nextIndex = index + 1
        if nextIndex < tokens.count, nextTokens.contains(tokens[nextIndex]) {
            return true
        }
    }
    return false
}

func hasMainActorUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "MainActor") || hasSequence(tokens, ["@", "MainActor"])
}

func hasSendableUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "Sendable") || hasSequence(tokens, ["@", "Sendable"])
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
    for (index, token) in tokens.enumerated() where token == "extension" {
        var j = index + 1
        while j < tokens.count && tokens[j] != "{" {
            if tokens[j] == ":" {
                var hasConformance = false
                var k = j + 1
                while k < tokens.count && tokens[k] != "{" {
                    let next = tokens[k]
                    if next == "," {
                        k += 1
                        continue
                    }
                    if !ignoredTypes.contains(next) && next != "where" {
                        hasConformance = true
                        break
                    }
                    k += 1
                }
                if hasConformance {
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
    let protocols = protocolNames(in: tokens)
    guard !protocols.isEmpty else { return false }

    func isIdentifierToken(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        return first.isLetter || first == "_"
    }

    var index = 0
    while index < tokens.count - 1 {
        if tokens[index] == "extension" {
            var j = index + 1
            while j < tokens.count && tokens[j] != "{" && tokens[j] != ":" && tokens[j] != "where" {
                let name = tokens[j]
                if isIdentifierToken(name), protocols.contains(name) {
                    return true
                }
                if tokens[j] == "<" {
                    break
                }
                j += 1
            }
        }
        index += 1
    }
    return false
}

func hasTaskSleepUsage(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["Task", ".", "sleep"])
}

func hasTaskGroupUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "withTaskGroup")
        || hasToken(tokens, "withThrowingTaskGroup")
        || hasToken(tokens, "TaskGroup")
        || hasToken(tokens, "ThrowingTaskGroup")
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
    if hasSequence(tokens, [":", "Error"]) || hasToken(tokens, "Error") {
        return true
    }
    var index = 0
    while index < tokens.count - 1 {
        if tokens[index] == "Result", tokens[index + 1] == "<" {
            return true
        }
        index += 1
    }
    return false
}

func hasThrowingFunction(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "throws") || hasToken(tokens, "rethrows")
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
    if hasToken(tokens, "macro") {
        return true
    }
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) where tokens[index] == "#" {
        let next = tokens[index + 1]
        guard let first = next.first else { continue }
        if first.isLetter || first == "_" {
            return true
        }
    }
    return false
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
    return hasToken(tokens, "Package")
        || hasToken(tokens, "Target")
        || hasToken(tokens, "PackageDescription")
}

func hasSwiftPMDependencies(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "dependencies") || hasToken(tokens, "package")
}

func hasBuildConfigs(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["#", "if"]) || hasSequence(tokens, ["#", "elseif"]) || hasSequence(tokens, ["#", "else"])
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
        return hasOptionalUsage(tokens)
    case .nilLiteral:
        return hasToken(tokens, "nil")
    case .optionalBinding:
        return hasSequence(tokens, ["if", "let"])
    case .guardStatement:
        return hasToken(tokens, "guard")
    case .nilCoalescing:
        return hasToken(tokens, "??")
    case .collections:
        return hasCollectionUsage(tokens: tokens, source: source)
    case .closures:
        return hasClosureToken(tokens) || hasClosureAssignment(tokens)
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
        return hasTupleUsage(tokens)
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
        .collections,
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

func mapDisallowConcepts(for topic: ChallengeTopic) -> [ConstraintConcept] {
    let errorHandlingConcepts: [ConstraintConcept] = [
        .errorTypes,
        .throwingFunctions,
        .throwKeyword,
        .tryKeyword,
        .tryOptional,
        .tryForce,
        .doCatch,
    ]

    switch topic {
    case .collections:
        return [.map, .filter, .reduce, .compactMap, .flatMap, .closures] + errorHandlingConcepts
    case .optionals:
        return [.optionalBinding, .guardStatement, .nilCoalescing] + errorHandlingConcepts
    case .functions:
        return [.closures, .shorthandClosureArgs] + errorHandlingConcepts
    case .strings:
        return [.stringInterpolation, .map, .filter, .reduce, .compactMap, .flatMap] + errorHandlingConcepts
    case .conditionals:
        return [.switchStatement, .breakContinue, .ranges] + errorHandlingConcepts
    case .loops:
        return [.forInLoop, .whileLoop, .repeatWhileLoop, .breakContinue, .ranges] + errorHandlingConcepts
    case .structs, .general:
        return errorHandlingConcepts
    }
}

func topicDisallowConceptViolations(
    tokens: [String],
    source: String,
    rawSource: String,
    challenge: Challenge,
    index: ConstraintIndex
) -> [String] {
    let concepts = Set(mapDisallowConcepts(for: challenge.topic))
    guard !concepts.isEmpty else { return [] }
    var violations: [String] = []

    for concept in concepts {
        let introNumber = introductionNumber(for: concept, index: index)
        if challenge.number < introNumber,
           usesConcept(concept, tokens: tokens, source: source, rawSource: rawSource) {
            violations.append("✗ Uses \(constraintConceptName(concept)) before Challenge \(introNumber).")
        }
    }

    return violations
}

func extractImports(from source: String) -> [String] {
    var imports: [String] = []
    for line in source.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("import ") else { continue }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            imports.append(String(parts[1]))
        }
    }
    return imports
}

func hasNetworkUsage(tokens: [String], source: String) -> Bool {
    if source.contains("http://") || source.contains("https://") {
        return true
    }
    return tokens.contains("URLSession") || tokens.contains("URLRequest")
}

func hasConcurrencyUsage(tokens: [String]) -> Bool {
    return tokens.contains("async")
        || tokens.contains("await")
        || tokens.contains("Task")
        || tokens.contains("actor")
        || tokens.contains("MainActor")
        || tokens.contains("Sendable")
        || tokens.contains("withTaskGroup")
        || tokens.contains("withThrowingTaskGroup")
        || tokens.contains("TaskGroup")
        || tokens.contains("ThrowingTaskGroup")
}

func constraintViolations(
    for source: String,
    challenge: Challenge,
    enabled: Bool,
    index: ConstraintIndex? = nil
) -> [String] {
    guard enabled else { return [] }
    guard let profile = mergedConstraintProfile(
        base: challenge.constraintProfile,
        topic: topicConstraintProfiles[challenge.topic]
    ) else { return [] }
    let cleanedSource = stripCommentsAndStrings(from: source)
    let tokens = tokenizeSource(cleanedSource)
    var violations: [String] = []

    if !profile.allowedImports.isEmpty {
        let imports = extractImports(from: cleanedSource)
        for item in imports where !profile.allowedImports.contains(item) {
            violations.append("✗ Import not allowed: \(item)")
        }
    }

    for token in profile.disallowedTokens where hasToken(tokens, token) {
        violations.append("✗ Token not allowed: \(token)")
    }

    for token in profile.requiredTokens where !hasToken(tokens, token) {
        violations.append("✗ Required token missing: \(token)")
    }

    if !profile.allowFileIO, hasFileIO(tokens) {
        violations.append("✗ File IO not allowed.")
    }

    if !profile.allowNetwork, hasNetworkUsage(tokens: tokens, source: cleanedSource) {
        violations.append("✗ Network usage not allowed.")
    }

    if !profile.allowConcurrency, hasConcurrencyUsage(tokens: tokens) {
        violations.append("✗ Concurrency not allowed.")
    }

    if let index = index {
        let topicViolations = topicDisallowConceptViolations(
            tokens: tokens,
            source: cleanedSource,
            rawSource: source,
            challenge: challenge,
            index: index
        )
        violations.append(contentsOf: topicViolations)
    }

    if profile.requireOptionalUsage == true, !hasOptionalUsage(tokens) {
        violations.append("✗ Optional usage required.")
    }

    if profile.requireCollectionUsage == true, !hasCollectionUsage(tokens: tokens, source: cleanedSource) {
        violations.append("✗ Collection usage required.")
    }

    if profile.requireClosureUsage == true, !hasClosureUsage(tokens) {
        violations.append("✗ Closure usage required.")
    }

    return violations
}

func mergedConstraintProfile(
    base: ConstraintProfile?,
    topic: ConstraintProfile?
) -> ConstraintProfile? {
    guard base != nil || topic != nil else { return nil }
    let baseProfile = base ?? ConstraintProfile()
    let topicProfile = topic ?? ConstraintProfile()

    func mergedTokens(_ first: [String], _ second: [String]) -> [String] {
        var seen = Set<String>()
        var merged: [String] = []
        for token in first + second where !seen.contains(token) {
            seen.insert(token)
            merged.append(token)
        }
        return merged
    }

    return ConstraintProfile(
        allowedImports: mergedTokens(baseProfile.allowedImports, topicProfile.allowedImports),
        disallowedTokens: mergedTokens(baseProfile.disallowedTokens, topicProfile.disallowedTokens),
        requiredTokens: mergedTokens(baseProfile.requiredTokens, topicProfile.requiredTokens),
        allowFileIO: baseProfile.allowFileIO && topicProfile.allowFileIO,
        allowNetwork: baseProfile.allowNetwork && topicProfile.allowNetwork,
        allowConcurrency: baseProfile.allowConcurrency && topicProfile.allowConcurrency,
        maxRuntimeMs: baseProfile.maxRuntimeMs ?? topicProfile.maxRuntimeMs,
        requireOptionalUsage: baseProfile.requireOptionalUsage ?? topicProfile.requireOptionalUsage,
        requireCollectionUsage: baseProfile.requireCollectionUsage ?? topicProfile.requireCollectionUsage,
        requireClosureUsage: baseProfile.requireClosureUsage ?? topicProfile.requireClosureUsage
    )
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
    assistedPass: Bool = false
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
        saveProgress(nextStepIndex)
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

    // Show what the code printed
    print("Output: \(output)\n")

    if validateOutputLines(output: output, expected: challenge.expectedOutput) {
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

        // Save progress to next step
        saveProgress(nextStepIndex)

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
                let lesson = challenge.lesson.trimmingCharacters(in: .whitespacesAndNewlines)
                if lesson.isEmpty {
                    print("Lesson not available yet.\n")
                } else {
                    print("Lesson:\n\(lesson)\n")
                }
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

                print("Output: \(output)\n")

                if validateOutputLines(output: output, expected: challenge.expectedOutput) {
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
        let fallbackPool = practicePool.filter { candidate in
            guard candidate.topic == pending.topic else { return false }
            guard candidate.layer == pending.layer else { return false }
            guard layerIndex(for: candidate) <= pendingIndex else { return false }
            return candidate.progressId != pending.challengeId
        }
        let scopedPool: [Challenge]
        if let pendingChallenge = pendingChallenge {
            let scoped = adaptivePracticePool(for: pendingChallenge, from: practicePool)
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
            var hintIndex = 0
            var challengeComplete = false
            var solutionViewedBeforePass = false
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
                    let lesson = challenge.lesson.trimmingCharacters(in: .whitespacesAndNewlines)
                    if lesson.isEmpty {
                        print("Lesson not available yet.\n")
                    } else {
                        print("Lesson:\n\(lesson)\n")
                    }
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
                    print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 'l' for lesson, 's' for solution.\n")
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
                    assistedPass: solutionViewedBeforePass
                )
                if didPass {
                    if solutionViewedBeforePass, adaptiveEnabled {
                        if pendingAdaptiveTopic == challenge.topic {
                            pendingAdaptiveTopic = nil
                            pendingAdaptivePool = []
                        }
                        let practiceCount = max(1, min(2, adaptiveCount))
                        let scopedPool = adaptivePracticePool(for: challenge, from: practicePool)
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
                                waitForEnterToContinue()
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
                            let scopedPool = adaptivePracticePool(for: challenge, from: practicePool)
                            pendingAdaptiveTopic = challenge.topic
                            pendingAdaptivePool = scopedPool.isEmpty ? eligiblePool : scopedPool
                            print("Adaptive practice queued for \(challenge.topic.rawValue) (score \(score)).")
                            print("Finish this challenge to start practice.\n")
                        }
                    }
                }
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
        Type 'h' for a hint, 'c' for a cheatsheet, 'l' for a lesson, or 's' for the solution.
        Viewing the solution is allowed.
        """)
    return filePath
}

func validateProject(
    _ project: Project,
    workspacePath: String = "workspace",
    assistedPass: Bool = false
) -> Bool {
    let filePath = "\(workspacePath)/\(project.filename)"

    let start = Date()
    let runResult = runSwiftProcess(file: filePath)
    if runResult.exitCode != 0 {
        let errorOutput = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        if !errorOutput.isEmpty {
            print(errorOutput)
            print("")
        }
        print("✗ Compile/runtime error. Check your code.")
        logEvent(
            "project_attempt",
            fields: ["id": project.id, "result": "compile_fail"],
            intFields: ["seconds": Int(Date().timeIntervalSince(start))],
            workspacePath: workspacePath
        )
        return false
    }
    let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)

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

func stageReviewPool(for id: String, challenges: [Challenge]) -> [Challenge] {
    let curated: [String: [Int]] = [
        "core1": [5, 8, 9, 10, 12, 13, 14, 15, 16, 18, 19, 20],
        "core2": [21, 22, 23, 24, 25, 29, 30, 33, 35, 37, 39, 41, 42],
        "core3": [43, 46, 47, 48, 50, 52, 58, 62, 63, 69, 71, 76, 80],
        "mantle1": [123, 125, 127, 130, 131, 132, 134],
        "mantle2": [135, 137, 139, 140, 142, 144],
        "mantle3": [145, 147, 149, 150, 151, 153],
        "crust1": [174, 175, 176, 179, 180, 181, 185, 187, 190, 191],
        "crust2": [192, 193, 194, 195, 196, 197, 198, 199, 200, 209],
        "crust3": [210, 211, 213, 214, 216, 218, 219, 221, 224, 227]
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
    challengeStats: [String: ChallengeStats],
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
    let now = Int(Date().timeIntervalSince1970)
    return weightedRandomSelection(
        from: filtered,
        weight: { adaptiveChallengeWeight(challenge: $0, topicStats: stats, challengeStats: challengeStats, now: now) },
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

func printMainUsage() {
    print("""
    Usage:
      swift run forge

    Core commands:
      swift run forge reset [--all] [--start]
      swift run forge stats [--reset]
      swift run forge remap-progress [target]
      swift run forge practice [count] [topic] [tier] [layer]
      swift run forge random [count] [topic] [tier] [layer]
      swift run forge project <id>
      swift run forge progress <target>
      swift run forge report
      swift run forge report-overrides


    Progress shortcuts:
      swift run forge challenge:<layer>:<number>
      swift run forge challenge:<layer>:<number>.<extra>
      swift run forge challenge:<id>
      swift run forge project:<id>
      swift run forge <project-id>

    Flow + behavior flags:
      --gate-passes <n>
      --gate-count <n>
      --allow-early-concepts
      --confirm-check
      --confirm-solution
      --disable-constraint-profiles
      --disable-di-mock-heuristics

    Adaptive flags:
      --adaptive-on
      --adaptive-threshold <n>
      --adaptive-count <n>
      --adaptive-topic-failures <n>
      --adaptive-challenge-failures <n>
      --adaptive-cooldown <n>

    Help:
      swift run forge --help
      swift run forge remap-progress --help
      swift run forge practice --help
      swift run forge random --help
      swift run forge project --help
      swift run forge stats --help
      swift run forge report --help
      swift run forge report-overrides --help

    Examples:
      swift run forge practice 8
      swift run forge practice optionals
      swift run forge practice core2
      swift run forge practice --all
      swift run forge random 8
      swift run forge random adaptive
      swift run forge project --list core
      swift run forge project:core2a
      swift run forge challenge:core:36
      swift run forge challenge:core:18.1
      swift run forge progress challenge:core:36
      swift run forge progress project:core2a
      swift run forge progress step:19
      swift run forge remap-progress challenge:18
      swift run forge verify-solutions crust
      swift run forge verify-solutions core --constraints-only
      swift run forge review-progression core 1-80
      swift run forge audit core
      swift run forge report

    Notes:
      - Random mode uses workspace_random/. Project mode uses workspace_projects/.
      - Stage review uses workspace_review/.
      - Adaptive gating is off by default; enable with --adaptive-on.
      - Adaptive practice is weighted by per-topic performance and per-challenge recency.
      - Practice mode uses workspace_practice/ and adaptive weighting when stats are available.
      - Viewing a solution may queue short practice when adaptive is enabled.
      - Assisted practice resumes after restart if it was interrupted.
      - Use --confirm-check to require a second Enter before running checks.
      - Use --confirm-solution to require confirmation before showing solutions.
      - Use --disable-constraint-profiles to skip Phase 2 constraint profiles.
      - Constraint profiles can require specific constructs (like functions or collections).

    Testing commands:
      swift run forge verify-solutions [filters] [bridge] [--constraints-only]
      swift run forge review-progression [filters] [bridge]
      swift run forge audit [filters] [bridge]
      swift run forge verify-solutions --help
      swift run forge review-progression --help
      swift run forge audit --help
    """)
}

func printProgressUsage() {
    print("""
    Usage:
      swift run forge progress <target>

    Targets:
      challenge:<layer>:<number>
      challenge:<layer>:<number>.<extra>
      challenge:<id>
      project:<id>
      step:<number>

    Examples:
      swift run forge progress challenge:core:20
      swift run forge progress challenge:core:18.1
      swift run forge progress project:core1a
      swift run forge progress step:19
      swift run forge progress 20
    """)
}

func printRemapProgressUsage() {
    print("""
    Usage:
      swift run forge remap-progress [target]

    Targets:
      challenge:<number>
      challenge:<layer>:<number>
      challenge:<layer>:<number>.<extra>
      challenge:<id>
      project:<id>
      step:<number>

    Notes:
      - This helper is intended to translate legacy challenge numbers after renumbering.
      - If no target is provided, the command will read workspace/.progress.
      - If workspace/.progress is a plain number, it may be a step index; provide an explicit target to avoid ambiguity.

    Examples:
      swift run forge remap-progress challenge:18
      swift run forge remap-progress challenge:core:18.1
      swift run forge remap-progress project:core1a
      swift run forge remap-progress step:42
    """)
}

func printRandomUsage() {
    print("""
    Usage: swift run forge random [count] [topic] [tier] [layer] [bridge]

    Topics: conditionals, loops, optionals, collections, functions, strings, structs, general
    Tiers: mainline, extra
    Layers: core, mantle, crust
    Bridge: use 'bridge' to focus on bridge challenges
    Adaptive: use 'adaptive' to bias toward weaker topics and stale challenges

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
      swift run forge stats --reset-all
      swift run forge stats --stats-limit <n>
      swift run forge stats --help

    Prints per-topic adaptive stats from workspace/.adaptive_stats.
    Per-challenge adaptive stats are stored in workspace/.adaptive_challenge_stats.
    Also shows top failing challenges when per-challenge stats are available.
    Also summarizes constraint violations from workspace/.performance_log with per-challenge detail.
    Use --reset to clear the stats file.
    Use --reset-all to clear stats, constraint mastery, and the performance log.
    Use --stats-limit to limit the number of topics shown in the summary table.
    """)
}

func printPracticeUsage() {
    print("""
    Usage:
      swift run forge practice [count] [topic] [tier] [layer] [core1|core2|core3|mantle1|mantle2|mantle3|crust1|crust2|crust3] [bridge] [--all]
      swift run forge practice --help

    Practice mode always uses adaptive weighting when stats are available.
    Filters match random mode: topics, tiers, layers, bridge.
    By default, practice is limited to challenges you've already reached in the main flow,
    plus relevant extra challenges for layers you've reached.
    Use --all to practice across the entire curriculum.
    """)
}

func printReportUsage() {
    print("""
    Usage:
      swift run forge report

    Prints a summary of stage review results, constraint mastery state, and adaptive stats.
    """)
}

func printOverrideReportUsage() {
    print("""
    Usage:
      swift run forge report-overrides [--threshold <n>]

    Prints suggested extra parent overrides when an extra is far from its parent.
    """)
}

func printAuditUsage() {
    print("""
    Usage:
      swift run forge audit [filters] [bridge]

    Runs:
      - Sequencing review (early-concept warnings)
      - Constraint profile verification
      - Fixture presence audit
    Filters match verify-solutions/review-progression (range/topic/tier/layer/bridge).
    """)
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

func resetAdaptiveStats(workspacePath: String = "workspace") {
    let path = adaptiveStatsFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
    print("✓ Adaptive stats reset.")
}

func resetAllStats(workspacePath: String = "workspace") {
    resetAdaptiveStats(workspacePath: workspacePath)
    let challengePath = adaptiveChallengeStatsFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: challengePath)
    try? FileManager.default.removeItem(atPath: constraintMasteryPath(workspacePath: workspacePath))
    clearPendingPractice(workspacePath: workspacePath)
    resetPerformanceLog(workspacePath: workspacePath)
    print("✓ Performance log reset.")
}

func parseStatsSettings(_ args: [String]) -> (reset: Bool, resetAll: Bool, limit: Int?) {
    var reset = false
    var resetAll = false
    var limit: Int?

    var index = 0
    while index < args.count {
        let lowered = args[index].lowercased()
        if lowered == "--reset" {
            reset = true
            index += 1
            continue
        }
        if lowered == "--reset-all" {
            resetAll = true
            index += 1
            continue
        }
        if lowered == "--stats-limit", index + 1 < args.count, let value = Int(args[index + 1]) {
            limit = max(value, 1)
            index += 2
            continue
        }
        index += 1
    }

    return (reset, resetAll, limit)
}

func parseRandomArguments(
    _ args: [String]
) -> (count: Int, topic: ChallengeTopic?, tier: ChallengeTier?, layer: ChallengeLayer?, adaptive: Bool, bridge: Bool) {
    var count = 5
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?
    var adaptive = false
    var bridge = false

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
        if lowered == "bridge" {
            bridge = true
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

    return (count, topic, tier, layer, adaptive, bridge)
}

func practiceRangeToken(_ raw: String) -> (layer: ChallengeLayer, range: ClosedRange<Int>)? {
    switch raw.lowercased() {
    case "core1":
        return (.core, 1...20)
    case "core2":
        return (.core, 21...42)
    case "core3":
        return (.core, 43...80)
    case "mantle1":
        return (.mantle, 1...11)
    case "mantle2":
        return (.mantle, 12...22)
    case "mantle3":
        return (.mantle, 23...33)
    case "crust1":
        return (.crust, 1...18)
    case "crust2":
        return (.crust, 19...36)
    case "crust3":
        return (.crust, 37...54)
    default:
        return nil
    }
}

func parsePracticeArguments(
    _ args: [String]
) -> (
    count: Int,
    topic: ChallengeTopic?,
    tier: ChallengeTier?,
    layer: ChallengeLayer?,
    range: ClosedRange<Int>?,
    includeAll: Bool,
    bridge: Bool
) {
    var count = 5
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?
    var range: ClosedRange<Int>?
    var includeAll = false
    var bridge = false

    for value in args {
        if let number = Int(value) {
            count = max(number, 1)
            continue
        }
        let lowered = value.lowercased()
        if lowered == "help" || lowered == "-h" || lowered == "--help" {
            continue
        }
        if lowered == "--all" {
            includeAll = true
            continue
        }
        if lowered == "bridge" {
            bridge = true
            continue
        }
        if let sublayer = practiceRangeToken(lowered) {
            range = sublayer.range
            if layer == nil {
                layer = sublayer.layer
            }
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

    return (count, topic, tier, layer, range, includeAll, bridge)
}

func parseGateSettings(
    _ args: [String]
) -> (passes: Int, count: Int, remaining: [String]) {
    var passes = 1
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
) -> (
    threshold: Int,
    count: Int,
    enabled: Bool,
    minTopicFailures: Int,
    minChallengeFailures: Int,
    cooldownSteps: Int,
    remaining: [String]
) {
    var threshold = 3
    var count = 3
    var enabled = false
    var minTopicFailures = 2
    var minChallengeFailures = 2
    var cooldownSteps = 2
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--adaptive-on" {
            enabled = true
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
        if arg == "--adaptive-topic-failures", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                minTopicFailures = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-challenge-failures", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                minChallengeFailures = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-cooldown", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                cooldownSteps = max(0, value)
            }
            index += 2
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (threshold, count, enabled, minTopicFailures, minChallengeFailures, cooldownSteps, remaining)
}

func parseConfirmSettings(
    _ args: [String]
) -> (enabled: Bool, confirmSolution: Bool, remaining: [String]) {
    var enabled = false
    var confirmSolution = false
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--confirm-check" {
            enabled = true
            index += 1
            continue
        }
        if arg == "--confirm-solution" {
            confirmSolution = true
            index += 1
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (enabled, confirmSolution, remaining)
}

func enforceAdaptiveConfirmPolicy(adaptiveEnabled: Bool, confirmSolutionEnabled: Bool) -> Bool {
    if adaptiveEnabled {
        return true
    }
    return confirmSolutionEnabled
}

func parseConstraintSettings(
    _ args: [String]
) -> (enforce: Bool, enableDiMockHeuristics: Bool, enableConstraintProfiles: Bool, remaining: [String]) {
    var enforce = true
    var enableDiMockHeuristics = true
    var enableConstraintProfiles = true
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
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
        if arg == "--disable-constraint-profiles" {
            enableConstraintProfiles = false
            index += 1
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (enforce, enableDiMockHeuristics, enableConstraintProfiles, remaining)
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

func parseVerifySettings(_ args: [String]) -> (constraintsOnly: Bool, remaining: [String]) {
    var constraintsOnly = false
    var remaining: [String] = []

    for value in args {
        let lowered = value.lowercased()
        if lowered == "--constraints-only" {
            constraintsOnly = true
            continue
        }
        remaining.append(value)
    }

    return (constraintsOnly, remaining)
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

func auditFixtures(_ challenges: [Challenge]) -> Bool {
    var missing: [String] = []
    for challenge in challenges {
        if let stdinFixture = challenge.stdinFixture {
            let path = "fixtures/\(stdinFixture)"
            if !FileManager.default.fileExists(atPath: path) {
                missing.append("\(challenge.displayId): missing stdin fixture \(stdinFixture)")
            }
        }
        if let argsFixture = challenge.argsFixture {
            let path = "fixtures/\(argsFixture)"
            if !FileManager.default.fileExists(atPath: path) {
                missing.append("\(challenge.displayId): missing args fixture \(argsFixture)")
            }
        }
        if !challenge.fixtureFiles.isEmpty {
            for file in challenge.fixtureFiles {
                let path = "fixtures/\(file)"
                if !FileManager.default.fileExists(atPath: path) {
                    missing.append("\(challenge.displayId): missing fixture file \(file)")
                }
            }
        }
    }

    if missing.isEmpty {
        print("✓ Fixture audit passed.")
        return true
    }

    print("✗ Fixture audit found \(missing.count) issue(s):")
    for item in missing {
        print("- \(item)")
    }
    return false
}

func printForgeReport(workspacePath: String = "workspace") {
    print("Forge report:\n")

    let summary = loadStageGateSummary(workspacePath: workspacePath)
    if summary.isEmpty {
        print("Stage review summary: none")
    } else {
        print("Stage review summary:")
        for key in summary.keys.sorted() {
            let value = summary[key] ?? ""
            print("- \(key):\(value)")
        }
    }

    let mastery = loadConstraintMastery(workspacePath: workspacePath)
    if mastery.isEmpty {
        print("\nConstraint mastery: none")
    } else {
        print("\nConstraint mastery:")
        for key in mastery.keys.sorted() {
            let entry = mastery[key] ?? ConstraintMasteryEntry(state: .block, warnCount: 0, cleanCount: 0)
            print("- \(key): \(entry.state.rawValue) (warn=\(entry.warnCount), clean=\(entry.cleanCount))")
        }
    }

    print("")
    printAdaptiveStats(workspacePath: workspacePath, statsLimit: 5)
}

func reportOverrideSuggestions(
    sets: ChallengeSets,
    threshold: Int
) {
    struct LayerReport {
        let name: String
        let challenges: [Challenge]
    }

    let layers = [
        LayerReport(name: "core", challenges: sets.core1Challenges + sets.core2Challenges + sets.core3Challenges),
        LayerReport(name: "mantle", challenges: sets.mantleChallenges),
        LayerReport(name: "crust", challenges: sets.crustChallenges),
    ]

    var findings: [String] = []

    for layer in layers {
        var mainlinePositions: [Int: Int] = [:]
        var topicPositions: [ChallengeTopic: [(index: Int, number: Int)]] = [:]
        for (index, challenge) in layer.challenges.enumerated() {
            if challenge.tier == .mainline, let layerNumber = challenge.layerNumber {
                mainlinePositions[layerNumber] = index
                topicPositions[challenge.topic, default: []].append((index: index, number: layerNumber))
            }
        }

        for (index, challenge) in layer.challenges.enumerated() where challenge.tier == .extra {
            guard let parent = challenge.extraParent else { continue }
            guard let parentIndex = mainlinePositions[parent] else { continue }
            let distance = abs(index - parentIndex)
            guard distance >= threshold else { continue }
            var suggestion = ""
            if let topicList = topicPositions[challenge.topic] {
                let priorTopic = topicList.last(where: { $0.index < index })
                if priorTopic == nil, let nextTopic = topicList.first(where: { $0.index > index }), nextTopic.number != parent {
                    suggestion = " (suggest \(layer.name):\(nextTopic.number))"
                } else if let priorTopic = priorTopic {
                    let priorDistance = abs(index - priorTopic.index)
                    if priorDistance < distance && priorTopic.number != parent {
                        suggestion = " (suggest \(layer.name):\(priorTopic.number))"
                    }
                }
            }
            findings.append(
                "\(layer.name): \(challenge.displayId) (topic \(challenge.topic.rawValue)) -> parent \(layer.name):\(parent) distance \(distance)\(suggestion)"
            )
        }
    }

    if findings.isEmpty {
        print("No override suggestions (threshold \(threshold)).")
        return
    }
    print("Override suggestions (threshold \(threshold)):")
    for line in findings {
        print("- \(line)")
    }
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
                let lesson = challenge.lesson.trimmingCharacters(in: .whitespacesAndNewlines)
                if lesson.isEmpty {
                    print("Lesson not available yet.\n")
                } else {
                    print("Lesson:\n\(lesson)\n")
                }
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
                recordConstraintMastery(topic: challenge.topic, hadWarnings: false, passed: true, workspacePath: workspacePath)
                let result = solutionViewedBeforePass ? "pass_assisted" : "manual_pass"
                recordAdaptiveStat(topic: challenge.topic, result: result, workspacePath: workspacePath)
                recordAdaptiveChallengeStat(challenge: challenge, result: result, workspacePath: workspacePath)
                logEvent(
                    "challenge_manual_complete",
                    fields: ["id": challenge.displayId, "mode": "random", "result": result],
                    intFields: ["number": layerIndex(for: challenge)],
                    workspacePath: workspacePath
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
                        logConstraintViolation(challenge, mode: "random", workspacePath: workspacePath)
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
                        if effectiveConstraintEnforcement(for: challenge.topic, enforceConstraints: enforceConstraints, workspacePath: workspacePath) {
                            print("✗ Constraint violation. Remove early concepts and retry.")
                            continue
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
                        fields: ["id": challenge.displayId, "result": "compile_fail", "mode": "random"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
                    continue
                }
                let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)

                print("Output: \(output)\n")

                if validateOutputLines(output: output, expected: challenge.expectedOutput) {
                    let completionLabel = solutionViewedBeforePass
                        ? "✓ Challenge Complete! (assisted)\n"
                        : "✓ Challenge Complete! Well done.\n"
                    print(completionLabel)
                    recordConstraintMastery(topic: challenge.topic, hadWarnings: hadWarnings, passed: true, workspacePath: workspacePath)
                    let result = solutionViewedBeforePass ? "pass_assisted" : "pass"
                    recordAdaptiveStat(topic: challenge.topic, result: result, workspacePath: workspacePath)
                    recordAdaptiveChallengeStat(challenge: challenge, result: result, workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": result, "mode": "random"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
                        workspacePath: workspacePath
                    )
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
                    recordConstraintMastery(topic: challenge.topic, hadWarnings: hadWarnings, passed: false, workspacePath: workspacePath)
                    recordAdaptiveStat(topic: challenge.topic, result: "fail", workspacePath: workspacePath)
                    recordAdaptiveChallengeStat(challenge: challenge, result: "fail", workspacePath: workspacePath)
                    logEvent(
                        "challenge_attempt",
                        fields: ["id": challenge.displayId, "result": "fail", "mode": "random"],
                        intFields: ["number": layerIndex(for: challenge), "seconds": Int(Date().timeIntervalSince(start))],
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
            let lesson = project.lesson.trimmingCharacters(in: .whitespacesAndNewlines)
            if lesson.isEmpty {
                print("Lesson not available yet.\n")
            } else {
                print("Lesson:\n\(lesson)\n")
            }
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
            print("Unknown command. Press Enter to check, 'h' for hint, 'c' for cheatsheet, 'l' for lesson, 's' for solution.\n")
            continue
        }

        if !confirmCheckIfNeeded(confirmCheckEnabled) {
            continue
        }

        print("\n--- Testing your project... ---\n")

        if validateProject(project, workspacePath: workspacePath, assistedPass: solutionViewedBeforePass) {
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
    if lowered.hasPrefix("core:") || lowered.hasPrefix("mantle:") || lowered.hasPrefix("crust:") {
        return .challengeId(lowered)
    }
    return .step(1)
}

func parseProgressInput(_ args: [String]) -> ProgressInput? {
    guard let raw = args.first?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
        return nil
    }
    let lowered = raw.lowercased()
    if lowered.hasPrefix("challenge:") {
        let value = String(raw.dropFirst("challenge:".count))
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(trimmedValue) {
            return .challenge(number)
        }
        if !trimmedValue.isEmpty {
            return .challengeId(trimmedValue.lowercased())
        }
        return nil
    }
    if lowered.hasPrefix("project:") {
        let value = String(raw.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty {
            return nil
        }
        return .project(value.lowercased())
    }
    if lowered.hasPrefix("step:") {
        let value = String(raw.dropFirst("step:".count))
        if let number = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return .step(number)
        }
        return nil
    }
    if let number = Int(raw) {
        return .challenge(number)
    }
    if lowered.hasPrefix("core:") || lowered.hasPrefix("mantle:") || lowered.hasPrefix("crust:") {
        return .challengeId(lowered)
    }
    return nil
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
        let practiceWorkspace = "workspace_random"
        let projectWorkspace = "workspace_projects"
        let explicitPracticeWorkspace = "workspace_practice"
        let parsed = parseGateSettings(Array(CommandLine.arguments.dropFirst()))
        let gatePasses = parsed.passes
        let gateCount = parsed.count
        let constraintParsed = parseConstraintSettings(parsed.remaining)
        let enforceConstraints = constraintParsed.enforce
        let enableDiMockHeuristics = constraintParsed.enableDiMockHeuristics
        let enableConstraintProfiles = constraintParsed.enableConstraintProfiles
        let adaptiveParsed = parseAdaptiveSettings(constraintParsed.remaining)
        let adaptiveThreshold = adaptiveParsed.threshold
        let adaptiveCount = adaptiveParsed.count
        let adaptiveEnabled = adaptiveParsed.enabled
        let adaptiveMinTopicFailures = adaptiveParsed.minTopicFailures
        let adaptiveMinChallengeFailures = adaptiveParsed.minChallengeFailures
        let adaptiveCooldownSteps = adaptiveParsed.cooldownSteps
        let confirmParsed = parseConfirmSettings(adaptiveParsed.remaining)
        let confirmCheckEnabled = confirmParsed.enabled
        let confirmSolutionEnabled = enforceAdaptiveConfirmPolicy(
            adaptiveEnabled: adaptiveEnabled,
            confirmSolutionEnabled: confirmParsed.confirmSolution
        )
        let args = confirmParsed.remaining
        if !enforceConstraints {
            print("Note: Early-concept usage will warn only (--allow-early-concepts).\n")
        }
        if !enableDiMockHeuristics {
            print("Note: DI/mock heuristics disabled (--disable-di-mock-heuristics).\n")
        }
        if !enableConstraintProfiles {
            print("Note: Constraint profiles disabled (--disable-constraint-profiles).\n")
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
            if ["reset", "practice", "random", "project", "progress", "remap-progress", "verify-solutions", "verify", "review-progression", "review", "stats", "audit", "report"].contains(lowered) {
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

        let sets = buildChallengeSets()
        let core1Challenges = sets.core1Challenges
        let core2Challenges = sets.core2Challenges
        let core3Challenges = sets.core3Challenges
        let mantleChallenges = sets.mantleChallenges
        let crustChallenges = sets.crustChallenges
        let bridgeChallenges = sets.bridgeChallenges
        let projects = makeProjects()
        let allChallenges = sets.allChallenges
        let constraintIndex = buildConstraintIndex(from: allChallenges)
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
        let legacyIdMap = legacyChallengeIdMap(for: allChallenges)
        migrateAdaptiveChallengeStatsIfNeeded(legacyIdMap: legacyIdMap)
        migratePendingPracticeIfNeeded(legacyIdMap: legacyIdMap, legacyNumberMap: allChallengeNumberMap)
        migratePerformanceLogIfNeeded(legacyIdMap: legacyIdMap, legacyNumberMap: allChallengeNumberMap)
        migrateProgressTokenIfNeeded(
            token: getProgressToken(),
            steps: steps,
            challengeIndexMap: challengeIndexMap,
            challengeIdIndexMap: challengeIdIndexMap,
            projectIndexMap: projectIndexMap,
            maxChallengeNumber: maxChallengeNumber,
            legacyIdMap: legacyIdMap,
            allChallengeIdMap: allChallengeIdMap,
            allChallengeNumberMap: allChallengeNumberMap
        )

        if !args.isEmpty && args[0] == "stats" {
            if args.count > 1 {
                let flag = args[1].lowercased()
                if ["--help", "-h", "help"].contains(flag) {
                    printStatsUsage()
                    return
                }
            }
            let settings = parseStatsSettings(Array(args.dropFirst()))
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
            return
        }

        if !args.isEmpty && args[0] == "report-overrides" {
            if args.count > 1 {
                let flag = args[1].lowercased()
                if ["--help", "-h", "help"].contains(flag) {
                    printOverrideReportUsage()
                    return
                }
            }
            var threshold = 12
            if args.count > 2 {
                let lowerArgs = args.map { $0.lowercased() }
                if let idx = lowerArgs.firstIndex(of: "--threshold"), idx + 1 < lowerArgs.count {
                    if let value = Int(lowerArgs[idx + 1]) {
                        threshold = max(1, value)
                    }
                }
            }
            reportOverrideSuggestions(sets: sets, threshold: threshold)
            return
        }

        if !args.isEmpty && args[0] == "report" {
            if args.count > 1 {
                let flag = args[1].lowercased()
                if ["--help", "-h", "help"].contains(flag) {
                    printReportUsage()
                    return
                }
            }
            clearScreen()
            printForgeReport()
            return
        }

        if !args.isEmpty {
            let firstArg = args[0].lowercased()
            if ["verify-solutions", "verify"].contains(firstArg) {
                let verifyArgs = Array(args.dropFirst())
                let bridgeOnly = verifyArgs.contains { $0.lowercased() == "bridge" }
                let verifySettings = parseVerifySettings(verifyArgs)
                let (range, topic, tier, layer) = parseVerifyArguments(verifySettings.remaining)
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
                if pool.isEmpty {
                    print("No challenges match those filters.")
                    return
                }
                if verifySettings.constraintsOnly {
                    _ = verifyConstraintProfiles(pool, enableConstraintProfiles: enableConstraintProfiles)
                } else {
                    _ = verifyChallengeSolutions(pool, enableConstraintProfiles: enableConstraintProfiles)
                }
                return
            }
            if ["review-progression", "review"].contains(firstArg) {
                let reviewArgs = Array(args.dropFirst())
                let bridgeOnly = reviewArgs.contains { $0.lowercased() == "bridge" }
                let (range, topic, tier, layer) = parseVerifyArguments(reviewArgs)
                var pool = core1Challenges + core2Challenges + core3Challenges + mantleChallenges + crustChallenges + bridgeChallenges.coreToMantle + bridgeChallenges.mantleToCrust
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
                return
            }
            if ["practice"].contains(firstArg) {
                let practiceArgs = Array(args.dropFirst())
                if practiceArgs.first?.lowercased() == "help" || practiceArgs.first == "--help" {
                    printPracticeUsage()
                    return
                }
                setupWorkspace(at: explicitPracticeWorkspace)
                clearWorkspaceContents(at: explicitPracticeWorkspace)
                let (count, topic, tier, layer, range, includeAll, bridgeOnly) = parsePracticeArguments(practiceArgs)
                var pool = allChallenges
                if bridgeOnly {
                    pool = pool.filter { $0.displayId.hasPrefix("bridge:") }
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
                if !includeAll {
                    let progressStep = normalizedStepIndex(getCurrentProgress(), stepsCount: steps.count)
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
                    pool = pool.filter { challenge in
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
                if pool.isEmpty {
                    print("No challenges match those filters.")
                    return
                }
                let selectionCount = min(count, pool.count)
                let stats = loadAdaptiveStats(workspacePath: "workspace")
                let challengeStats = loadAdaptiveChallengeStats(workspacePath: "workspace")
                let selection = pickAdaptivePracticeSet(
                    from: pool,
                    stats: stats,
                    challengeStats: challengeStats,
                    count: selectionCount
                )
                print("Practice mode: \(selection.count) challenge(s).")
                print("Workspace: \(explicitPracticeWorkspace)\n")
                runPracticeChallenges(
                    selection,
                    workspacePath: explicitPracticeWorkspace,
                    constraintIndex: constraintIndex,
                    confirmCheckEnabled: confirmCheckEnabled,
                    confirmSolutionEnabled: confirmSolutionEnabled,
                    enableConstraintProfiles: enableConstraintProfiles,
                    trackAssisted: false,
                    enforceConstraints: enforceConstraints,
                    enableDiMockHeuristics: enableDiMockHeuristics,
                    completionTitle: "✅ Practice set complete!",
                    finishPrompt: "Press Enter to finish."
                )
                return
            }
            if ["audit"].contains(firstArg) {
                let auditArgs = Array(args.dropFirst())
                let bridgeOnly = auditArgs.contains { $0.lowercased() == "bridge" }
                if auditArgs.first?.lowercased() == "help" || auditArgs.first == "--help" {
                    printAuditUsage()
                    return
                }
                let (range, topic, tier, layer) = parseVerifyArguments(auditArgs)
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
            let (count, topic, tier, layer, adaptive, bridgeOnly) = parseRandomArguments(randomArgs)
            var pool = allChallenges
            if bridgeOnly {
                pool = pool.filter { $0.displayId.hasPrefix("bridge:") }
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
            print("Workspace: \(practiceWorkspace)\n")
            runPracticeChallenges(
                selection,
                workspacePath: practiceWorkspace,
                constraintIndex: constraintIndex,
                confirmCheckEnabled: confirmCheckEnabled,
                confirmSolutionEnabled: confirmSolutionEnabled,
                enableConstraintProfiles: enableConstraintProfiles,
                trackAssisted: false,
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
                let completed = runProject(
                    project,
                    workspacePath: projectWorkspace,
                    confirmCheckEnabled: confirmCheckEnabled,
                    confirmSolutionEnabled: confirmSolutionEnabled,
                    trackAssisted: false
                )
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
            let completed = runProject(
                project,
                workspacePath: projectWorkspace,
                confirmCheckEnabled: confirmCheckEnabled,
                confirmSolutionEnabled: confirmSolutionEnabled,
                trackAssisted: false
            )
            print("Press Enter to finish.\n")
            _ = readLine()
            if completed {
                try? FileManager.default.removeItem(atPath: "\(projectWorkspace)/\(project.filename)")
            }
            return
        }

        if !args.isEmpty && args[0].lowercased() == "remap-progress" {
            let remapArgs = Array(args.dropFirst())
            if remapArgs.first?.lowercased() == "help" || remapArgs.first == "--help" || remapArgs.first == "-h" {
                printRemapProgressUsage()
                return
            }
            let rawToken: String? = remapArgs.first ?? getProgressToken()
            guard let tokenRaw = rawToken?.trimmingCharacters(in: .whitespacesAndNewlines), !tokenRaw.isEmpty else {
                print("No progress token found.")
                printRemapProgressUsage()
                return
            }
            if remapArgs.isEmpty, Int(tokenRaw) != nil {
                print("Progress file contains a step index. Provide an explicit target to remap (e.g., challenge:core:18).")
                printRemapProgressUsage()
                return
            }

            let lowered = tokenRaw.lowercased()
            let startIndex: Int
            var messagePrefix = ""

            if lowered.hasPrefix("challenge:") {
                let value = String(tokenRaw.dropFirst("challenge:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                if let number = Int(value) {
                    let remapped = remapLegacyChallengeNumber(number)
                    if let extraChallenge = allChallengeNumberMap[remapped], extraChallenge.tier == .extra {
                        print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
                        return
                    }
                    guard let index = challengeIndexMap[remapped] else {
                        print("Unknown challenge number: \(remapped)")
                        return
                    }
                    startIndex = index
                    messagePrefix = "Progress remapped from challenge \(number) -> \(remapped)"
                } else if !value.isEmpty {
                    let id = value.lowercased()
                    if let extraChallenge = allChallengeIdMap[id], extraChallenge.tier == .extra {
                        print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
                        return
                    }
                    guard let index = challengeIdIndexMap[id] else {
                        print("Unknown challenge id: \(value)")
                        return
                    }
                    startIndex = index
                    messagePrefix = "Progress set to challenge \(value)"
                } else {
                    print("Invalid remap target.")
                    printRemapProgressUsage()
                    return
                }
            } else if lowered.hasPrefix("project:") {
                let value = String(tokenRaw.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                let id = value.lowercased()
                if let index = projectIndexMap[id] {
                    startIndex = index
                    messagePrefix = "Progress set to project \(id)"
                } else if projects.contains(where: { $0.id.lowercased() == id }) {
                    print("Project \(id) is not part of the main flow. Use project mode instead.")
                    return
                } else {
                    print("Unknown project id: \(value)")
                    return
                }
            } else if lowered.hasPrefix("step:") {
                let value = String(tokenRaw.dropFirst("step:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                guard let number = Int(value) else {
                    print("Invalid step number.")
                    printRemapProgressUsage()
                    return
                }
                startIndex = normalizedStepIndex(number, stepsCount: steps.count)
                messagePrefix = "Progress set to step \(startIndex)"
            } else if let number = Int(tokenRaw) {
                let remapped = remapLegacyChallengeNumber(number)
                if let extraChallenge = allChallengeNumberMap[remapped], extraChallenge.tier == .extra {
                    print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
                    return
                }
                guard let index = challengeIndexMap[remapped] else {
                    print("Unknown challenge number: \(remapped)")
                    return
                }
                startIndex = index
                messagePrefix = "Progress remapped from challenge \(number) -> \(remapped)"
            } else if let index = projectIndexMap[lowered] {
                startIndex = index
                messagePrefix = "Progress set to project \(lowered)"
            } else if let extraChallenge = allChallengeIdMap[lowered], extraChallenge.tier == .extra {
                print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
                return
            } else if let index = challengeIdIndexMap[lowered] {
                startIndex = index
                messagePrefix = "Progress set to challenge \(lowered)"
            } else {
                print("Invalid remap target.")
                printRemapProgressUsage()
                return
            }

            setupWorkspace()
            saveProgress(startIndex)
            print("\(messagePrefix) (step \(startIndex): \(stepLabel(for: steps, index: startIndex))).")
            return
        }
        if !args.isEmpty && args[0].lowercased() == "progress" {
            let progressArgs = Array(args.dropFirst())
            if progressArgs.isEmpty || ["help", "-h", "--help"].contains(progressArgs[0].lowercased()) {
                printProgressUsage()
                return
            }
            guard let input = parseProgressInput(progressArgs) else {
                print("Invalid progress target.")
                printProgressUsage()
                return
            }
            let startIndex: Int
            switch input {
            case .step(let rawStep):
                startIndex = normalizedStepIndex(rawStep, stepsCount: steps.count)
            case .project(let projectId):
                if let index = projectIndexMap[projectId] {
                    startIndex = index
                } else if projects.contains(where: { $0.id.lowercased() == projectId }) {
                    print("Project \(projectId) is not part of the main flow. Use project mode instead.")
                    return
                } else {
                    print("Unknown project id: \(projectId)")
                    return
                }
            case .challenge(let number):
                if let index = challengeIndexMap[number] {
                    startIndex = index
                } else if let extraChallenge = allChallengeNumberMap[number], extraChallenge.tier == .extra {
                    print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
                    return
                } else {
                    startIndex = stepIndexForChallenge(
                        number,
                        challengeStepIndex: challengeIndexMap,
                        maxChallengeNumber: maxChallengeNumber,
                        stepsCount: steps.count
                    )
                }
            case .challengeId(let rawId):
                let id = rawId.lowercased()
                if let extraChallenge = allChallengeIdMap[id], extraChallenge.tier == .extra {
                    print("Challenge \(extraChallenge.progressId) is an extra. Use random/adaptive mode to practice extras.")
                    return
                }
                guard let index = challengeIdIndexMap[id] else {
                    print("Unknown challenge id: \(rawId)")
                    return
                }
                startIndex = index
            }
            setupWorkspace()
            saveProgress(startIndex)
            print("Progress set to step \(startIndex) (\(stepLabel(for: steps, index: startIndex))).")
            return
        }

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
        print("Heat. Pressure. Repetition.\n")
        if adaptiveEnabled, let pending = loadPendingPractice(workspacePath: "workspace") {
            print("Pending assisted practice detected for \(pending.topic.rawValue). You'll resume it before continuing.\n")
        }

        if startIndex <= steps.count {
            runSteps(
                steps,
                startingAt: startIndex,
                constraintIndex: constraintIndex,
                practicePool: allChallenges,
                practiceWorkspace: practiceWorkspace,
                adaptiveThreshold: adaptiveThreshold,
                adaptiveCount: adaptiveCount,
                adaptiveMinTopicFailures: adaptiveMinTopicFailures,
                adaptiveMinChallengeFailures: adaptiveMinChallengeFailures,
                adaptiveCooldownSteps: adaptiveCooldownSteps,
                adaptiveEnabled: adaptiveEnabled,
                enableConstraintProfiles: enableConstraintProfiles,
                confirmCheckEnabled: confirmCheckEnabled,
                confirmSolutionEnabled: confirmSolutionEnabled,
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
