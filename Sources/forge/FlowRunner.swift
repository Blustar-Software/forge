import Foundation


func reviewProgression(
    _ challenges: [Challenge],
    constraintIndex: ConstraintIndex,
    enableDiMockHeuristics: Bool
) -> Bool {
    let sorted = challenges.sorted { $0.number < $1.number }
    var issues: [(id: String, detail: String)] = []
    var skipped = 0

    print("Reviewing \(sorted.count) challenge solution(s)...")

    for challenge in challenges {
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
