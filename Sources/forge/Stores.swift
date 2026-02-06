import Foundation

// MARK: - ProgressStore

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

func resetProgress(workspacePath: String = "workspace", removeAll: Bool = false, quiet: Bool = false) {
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
    
    if !quiet {
        print("✓ Progress reset! Starting from Challenge 1.\n")
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

// MARK: - StageGateStore

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

// MARK: - AdaptiveStatsStore

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

func resetAdaptiveStats(workspacePath: String = "workspace", quiet: Bool = false) {
    let path = adaptiveStatsFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
    if !quiet {
        print("✓ Adaptive stats reset.")
    }
}

func resetAllStats(workspacePath: String = "workspace", quiet: Bool = false) {
    resetAdaptiveStats(workspacePath: workspacePath, quiet: quiet)
    let challengePath = adaptiveChallengeStatsFilePath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: challengePath)
    try? FileManager.default.removeItem(atPath: constraintMasteryPath(workspacePath: workspacePath))
    clearPendingPractice(workspacePath: workspacePath)
    resetPerformanceLog(workspacePath: workspacePath, quiet: quiet)
    if !quiet {
        print("✓ Performance log reset.")
    }
}

// MARK: - PerformanceLogStore

func performanceLogPath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.performance_log"
}

func resetPerformanceLog(workspacePath: String = "workspace", quiet: Bool = false) {
    let path = performanceLogPath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
    _ = quiet
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

// MARK: - StoreMigrations

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

