import Foundation

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
