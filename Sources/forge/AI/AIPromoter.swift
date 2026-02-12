import Foundation

typealias AISwiftCommandRunner = (_ swiftArguments: [String]) -> (output: String, exitCode: Int32)
typealias AIVerifyRunner = (_ settings: AIVerifySettings, _ enableDiMockHeuristics: Bool) -> Bool

private struct AIPromoteBridgeDocument: Codable {
    var coreToMantle: [Challenge]
    var mantleToCrust: [Challenge]
}

private let promotionStatusAllowlist: Set<String> = [
    "scaffold",
    "dry_run_scaffold",
    "live_success",
    "live_fallback_scaffold",
]

enum AIPromoteError: LocalizedError {
    case readFailed(String, Error)
    case decodeFailed(String)
    case invalidReportStatus(String)
    case candidatePathMismatch(report: String, input: String)
    case missingBridgeSection
    case unexpectedBridgeSection(String)
    case unsupportedTargetFormat(String)
    case duplicateProgressId(String)
    case layerMismatch(expected: String, actual: String)
    case malformedTargetArray(String)
    case writeFailed(String, Error)
    case restoreFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .readFailed(let path, let error):
            return "Failed to read file \(path): \(error.localizedDescription)"
        case .decodeFailed(let detail):
            return "Failed to decode artifact: \(detail)"
        case .invalidReportStatus(let status):
            return "Unsupported report status for promotion: \(status)"
        case .candidatePathMismatch(let report, let input):
            return "Report candidate path does not match input candidate path. report=\(report) input=\(input)"
        case .missingBridgeSection:
            return "Target bridge_challenges.json requires --bridge-section."
        case .unexpectedBridgeSection(let path):
            return "--bridge-section is only valid when target is bridge_challenges.json (target: \(path))."
        case .unsupportedTargetFormat(let path):
            return "Target curriculum file is not a supported challenge JSON format: \(path)"
        case .duplicateProgressId(let id):
            return "Candidate progress id already exists: \(id)"
        case .layerMismatch(let expected, let actual):
            return "Candidate layer does not match target. expected=\(expected) actual=\(actual)"
        case .malformedTargetArray(let path):
            return "Target curriculum array file is malformed: \(path)"
        case .writeFailed(let path, let error):
            return "Failed to write target file \(path): \(error.localizedDescription)"
        case .restoreFailed(let path, let error):
            return "Failed to restore target file \(path): \(error.localizedDescription)"
        }
    }
}

func runAIPromote(
    settings: AIPromoteSettings,
    enableDiMockHeuristics: Bool = true,
    commandRunner: AISwiftCommandRunner = runSwiftToolCommand,
    verifyRunner: AIVerifyRunner = { verifySettings, heuristics in
        runAIVerify(settings: verifySettings, enableDiMockHeuristics: heuristics)
    }
) -> Bool {
    print("AI promote candidate: \(settings.candidatePath)")
    print("AI promote report: \(settings.reportPath)")
    print("AI promote target: \(settings.targetPath)")

    let report: AIGenerationReportArtifact
    do {
        report = try loadAIGenerationReportArtifact(from: settings.reportPath)
    } catch {
        print("✗ \(error.localizedDescription)")
        return false
    }

    guard promotionStatusAllowlist.contains(report.status) else {
        print("✗ \(AIPromoteError.invalidReportStatus(report.status).localizedDescription)")
        return false
    }

    let reportCandidatePath = normalizedFilePath(report.candidatePath)
    let requestedCandidatePath = normalizedFilePath(settings.candidatePath)
    guard reportCandidatePath == requestedCandidatePath else {
        print("✗ \(AIPromoteError.candidatePathMismatch(report: report.candidatePath, input: settings.candidatePath).localizedDescription)")
        return false
    }

    let verifySettings = AIVerifySettings(
        candidatePath: settings.candidatePath,
        constraintsOnly: false,
        compileOnly: false
    )
    let verifyPassed = verifyRunner(verifySettings, enableDiMockHeuristics)
    guard verifyPassed else {
        print("Promotion aborted: ai-verify did not pass.")
        return false
    }

    let draft: AIChallengeDraft
    do {
        draft = try loadAIDraftFromCandidateFile(settings.candidatePath)
    } catch {
        print("✗ \(error.localizedDescription)")
        return false
    }

    let challenge: Challenge
    do {
        challenge = try makeChallengeFromAIDraft(draft)
    } catch {
        print("✗ \(error.localizedDescription)")
        return false
    }

    let expectedLayer = expectedLayerForPromotionTarget(
        targetPath: settings.targetPath,
        bridgeSection: settings.bridgeSection
    )
    if let expectedLayer, challenge.layer != expectedLayer {
        print("✗ \(AIPromoteError.layerMismatch(expected: expectedLayer.rawValue, actual: challenge.layer.rawValue).localizedDescription)")
        return false
    }

    let targetFileName = URL(fileURLWithPath: settings.targetPath).lastPathComponent.lowercased()
    if targetFileName == "bridge_challenges.json", settings.bridgeSection == nil {
        print("✗ \(AIPromoteError.missingBridgeSection.localizedDescription)")
        return false
    }
    if targetFileName != "bridge_challenges.json", settings.bridgeSection != nil {
        print("✗ \(AIPromoteError.unexpectedBridgeSection(settings.targetPath).localizedDescription)")
        return false
    }

    let allChallenges: [Challenge]
    do {
        allChallenges = try loadAllCurriculumChallengesFromDisk()
    } catch {
        print("✗ \(error.localizedDescription)")
        return false
    }

    let nextNumber = (allChallenges.map { $0.number }.max() ?? 0) + 1
    let promotedChallenge = promotedChallengeFromDraft(
        challenge,
        nextNumber: nextNumber,
        layerOverride: expectedLayer
    )

    let existingProgressIds = Set(allChallenges.map { $0.progressId.lowercased() })
    let promotedProgressId = promotedChallenge.progressId.lowercased()
    if existingProgressIds.contains(promotedProgressId) {
        print("✗ \(AIPromoteError.duplicateProgressId(promotedChallenge.progressId).localizedDescription)")
        return false
    }

    let targetURL = URL(fileURLWithPath: settings.targetPath)
    let originalData: Data
    do {
        originalData = try Data(contentsOf: targetURL)
    } catch {
        print("✗ \(AIPromoteError.readFailed(settings.targetPath, error).localizedDescription)")
        return false
    }

    let updatedData: Data
    do {
        updatedData = try appendChallengeToTarget(
            promotedChallenge,
            targetPath: settings.targetPath,
            originalData: originalData,
            bridgeSection: settings.bridgeSection
        )
    } catch {
        print("✗ \(error.localizedDescription)")
        return false
    }

    do {
        try updatedData.write(to: targetURL, options: .atomic)
    } catch {
        print("✗ \(AIPromoteError.writeFailed(settings.targetPath, error).localizedDescription)")
        return false
    }

    print("Appended challenge \(promotedChallenge.progressId) as number \(promotedChallenge.number).")
    print("Running gate checks: swift test")
    let testResult = commandRunner(["test"])
    if testResult.exitCode != 0 {
        print("✗ swift test failed. Reverting promotion.")
        if !testResult.output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print(testResult.output)
        }
        restorePromotionTarget(originalData: originalData, targetURL: targetURL, targetPath: settings.targetPath)
        return false
    }

    print("Running gate checks: swift run forge verify-solutions --constraints-only")
    let verifyResult = commandRunner(["run", "forge", "verify-solutions", "--constraints-only"])
    if verifyResult.exitCode != 0 {
        print("✗ verify-solutions --constraints-only failed. Reverting promotion.")
        if !verifyResult.output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print(verifyResult.output)
        }
        restorePromotionTarget(originalData: originalData, targetURL: targetURL, targetPath: settings.targetPath)
        return false
    }

    print("✅ ai-promote passed all gates.")
    return true
}

func runSwiftToolCommand(_ swiftArguments: [String]) -> (output: String, exitCode: Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["swift"] + swiftArguments
    process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return (output, process.terminationStatus)
    } catch {
        return ("Failed to run swift \(swiftArguments.joined(separator: " ")): \(error.localizedDescription)", -1)
    }
}

func loadAIGenerationReportArtifact(from path: String) throws -> AIGenerationReportArtifact {
    let data: Data
    do {
        data = try Data(contentsOf: URL(fileURLWithPath: path))
    } catch {
        throw AIPromoteError.readFailed(path, error)
    }

    do {
        return try JSONDecoder().decode(AIGenerationReportArtifact.self, from: data)
    } catch {
        let detail = String(data: data.prefix(200), encoding: .utf8) ?? "<non-utf8>"
        throw AIPromoteError.decodeFailed(detail)
    }
}

func loadAllCurriculumChallengesFromDisk(
    curriculumDirectory: String = "Sources/forge/Curriculum"
) throws -> [Challenge] {
    let standardFiles = [
        "core1_challenges.json",
        "core2_challenges.json",
        "core3_challenges.json",
        "mantle_challenges.json",
        "crust_challenges.json",
    ]
    var all: [Challenge] = []

    for file in standardFiles {
        let path = "\(curriculumDirectory)/\(file)"
        let data: Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            throw AIPromoteError.readFailed(path, error)
        }
        do {
            let decoded = try JSONDecoder().decode([Challenge].self, from: data)
            all += decoded
        } catch {
            throw AIPromoteError.decodeFailed("Failed to decode \(path): \(error.localizedDescription)")
        }
    }

    let bridgePath = "\(curriculumDirectory)/bridge_challenges.json"
    let bridgeData: Data
    do {
        bridgeData = try Data(contentsOf: URL(fileURLWithPath: bridgePath))
    } catch {
        throw AIPromoteError.readFailed(bridgePath, error)
    }
    do {
        let bridge = try JSONDecoder().decode(AIPromoteBridgeDocument.self, from: bridgeData)
        all += bridge.coreToMantle
        all += bridge.mantleToCrust
    } catch {
        throw AIPromoteError.decodeFailed("Failed to decode \(bridgePath): \(error.localizedDescription)")
    }

    return all
}

func promotedChallengeFromDraft(
    _ challenge: Challenge,
    nextNumber: Int,
    layerOverride: ChallengeLayer?
) -> Challenge {
    return Challenge(
        number: nextNumber,
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        starterCode: challenge.starterCode,
        expectedOutput: challenge.expectedOutput,
        hints: challenge.hints,
        cheatsheet: challenge.cheatsheet,
        lesson: challenge.lesson,
        solution: challenge.solution,
        manualCheck: challenge.manualCheck,
        stdinFixture: challenge.stdinFixture,
        argsFixture: challenge.argsFixture,
        fixtureFiles: challenge.fixtureFiles,
        constraintProfile: challenge.constraintProfile,
        introduces: challenge.introduces,
        requires: challenge.requires,
        topic: challenge.topic,
        tier: challenge.tier,
        layer: layerOverride ?? challenge.layer,
        canonicalId: ""
    )
}

func appendChallengeToTarget(
    _ challenge: Challenge,
    targetPath: String,
    originalData: Data,
    bridgeSection: AIPromoteBridgeSection?
) throws -> Data {
    let decoder = JSONDecoder()
    if let challengeList = try? decoder.decode([Challenge].self, from: originalData) {
        guard let originalText = String(data: originalData, encoding: .utf8) else {
            var updated = challengeList
            updated.append(challenge)
            return try encodeJSONFile(updated)
        }
        let objectText = try renderChallengeObject(challenge)
        let updatedText = try appendObjectTextToTopLevelArray(
            originalText: originalText,
            objectText: objectText,
            hadExistingElements: !challengeList.isEmpty,
            targetPath: targetPath
        )
        return Data(updatedText.utf8)
    }

    if var bridge = try? decoder.decode(AIPromoteBridgeDocument.self, from: originalData) {
        guard let bridgeSection else {
            throw AIPromoteError.missingBridgeSection
        }
        switch bridgeSection {
        case .coreToMantle:
            bridge.coreToMantle.append(challenge)
        case .mantleToCrust:
            bridge.mantleToCrust.append(challenge)
        }
        return try encodeJSONFile(bridge)
    }

    throw AIPromoteError.unsupportedTargetFormat(targetPath)
}

func encodeJSONFile<T: Encodable>(_ value: T) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return try encoder.encode(value)
}

func appendObjectTextToTopLevelArray(
    originalText: String,
    objectText: String,
    hadExistingElements: Bool,
    targetPath: String
) throws -> String {
    guard let closeIndex = originalText.lastIndex(where: { !$0.isWhitespace }),
          originalText[closeIndex] == "]" else {
        throw AIPromoteError.malformedTargetArray(targetPath)
    }

    var prefix = String(originalText[..<closeIndex])
    while let last = prefix.last, last.isWhitespace {
        prefix.removeLast()
    }
    let suffix = String(originalText[closeIndex...])

    if hadExistingElements {
        return prefix + ",\n" + objectText + "\n" + suffix
    }
    return prefix + "\n" + objectText + "\n" + suffix
}

func renderChallengeObject(_ challenge: Challenge) throws -> String {
    let indent = "  "
    let fieldIndent = "    "
    var fields: [String] = []

    func appendString(_ key: String, _ value: String) throws {
        fields.append("\(fieldIndent)\"\(key)\": \(try jsonLiteral(for: value))")
    }

    func appendStringArray(_ key: String, _ values: [String]) throws {
        if values.isEmpty {
            fields.append("\(fieldIndent)\"\(key)\": []")
            return
        }
        var lines: [String] = ["\(fieldIndent)\"\(key)\": ["]
        for (index, value) in values.enumerated() {
            let suffix = index == values.count - 1 ? "" : ","
            lines.append("\(fieldIndent)  \(try jsonLiteral(for: value))\(suffix)")
        }
        lines.append("\(fieldIndent)]")
        fields.append(lines.joined(separator: "\n"))
    }

    try appendString("canonicalId", challenge.canonicalId)
    try appendString("cheatsheet", challenge.cheatsheet)
    if let profile = challenge.constraintProfile {
        fields.append(try renderConstraintProfile(profile, indent: fieldIndent, key: "constraintProfile"))
    }
    try appendString("description", challenge.description)
    try appendString("expectedOutput", challenge.expectedOutput)
    try appendStringArray("fixtureFiles", challenge.fixtureFiles)
    try appendStringArray("hints", challenge.hints)
    try appendString("id", challenge.id)
    try appendStringArray("introduces", challenge.introduces.map(\.rawValue))
    try appendString("layer", challenge.layer.rawValue)
    try appendString("lesson", challenge.lesson)
    fields.append("\(fieldIndent)\"manualCheck\": \(challenge.manualCheck ? "true" : "false")")
    fields.append("\(fieldIndent)\"number\": \(challenge.number)")
    try appendStringArray("requires", challenge.requires.map(\.rawValue))
    try appendString("solution", challenge.solution)
    try appendString("starterCode", challenge.starterCode)
    try appendString("tier", challenge.tier.rawValue)
    try appendString("title", challenge.title)
    try appendString("topic", challenge.topic.rawValue)

    var lines: [String] = ["\(indent){"]
    for (index, field) in fields.enumerated() {
        let suffix = index == fields.count - 1 ? "" : ","
        if field.contains("\n") {
            let split = field.split(separator: "\n", omittingEmptySubsequences: false)
            for (lineIndex, line) in split.enumerated() {
                let isLastLine = lineIndex == split.count - 1
                let trailing = isLastLine ? suffix : ""
                lines.append("\(line)\(trailing)")
            }
        } else {
            lines.append("\(field)\(suffix)")
        }
    }
    lines.append("\(indent)}")
    return lines.joined(separator: "\n")
}

func renderConstraintProfile(_ profile: ConstraintProfile, indent: String, key: String) throws -> String {
    let nested = indent + "  "
    var lines: [String] = ["\(indent)\"\(key)\": {"]
    lines.append("\(nested)\"allowConcurrency\": \(profile.allowConcurrency ? "true" : "false"),")
    lines.append("\(nested)\"allowFileIO\": \(profile.allowFileIO ? "true" : "false"),")
    lines.append("\(nested)\"allowNetwork\": \(profile.allowNetwork ? "true" : "false"),")
    lines.append("\(nested)\"allowedImports\": \(try jsonLiteral(for: profile.allowedImports)),")
    lines.append("\(nested)\"disallowedTokens\": \(try jsonLiteral(for: profile.disallowedTokens)),")
    lines.append("\(nested)\"requiredTokens\": \(try jsonLiteral(for: profile.requiredTokens))")
    if let maxRuntimeMs = profile.maxRuntimeMs {
        lines.append("\(nested),\"maxRuntimeMs\": \(maxRuntimeMs)")
    }
    if let requireOptionalUsage = profile.requireOptionalUsage {
        lines.append("\(nested),\"requireOptionalUsage\": \(requireOptionalUsage ? "true" : "false")")
    }
    if let requireCollectionUsage = profile.requireCollectionUsage {
        lines.append("\(nested),\"requireCollectionUsage\": \(requireCollectionUsage ? "true" : "false")")
    }
    if let requireClosureUsage = profile.requireClosureUsage {
        lines.append("\(nested),\"requireClosureUsage\": \(requireClosureUsage ? "true" : "false")")
    }
    lines.append("\(indent)}")
    return lines.joined(separator: "\n")
}

func jsonLiteral(for value: some Encodable) throws -> String {
    let data = try JSONEncoder().encode(AnyEncodable(value))
    return String(data: data, encoding: .utf8) ?? "null"
}

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        encodeClosure = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}

func expectedLayerForPromotionTarget(
    targetPath: String,
    bridgeSection: AIPromoteBridgeSection?
) -> ChallengeLayer? {
    let file = URL(fileURLWithPath: targetPath).lastPathComponent.lowercased()
    switch file {
    case "core1_challenges.json", "core2_challenges.json", "core3_challenges.json":
        return .core
    case "mantle_challenges.json":
        return .mantle
    case "crust_challenges.json":
        return .crust
    case "bridge_challenges.json":
        switch bridgeSection {
        case .coreToMantle:
            return .mantle
        case .mantleToCrust:
            return .crust
        case nil:
            return nil
        }
    default:
        return nil
    }
}

func restorePromotionTarget(originalData: Data, targetURL: URL, targetPath: String) {
    do {
        try originalData.write(to: targetURL, options: .atomic)
        print("Target file restored: \(targetPath)")
    } catch {
        print("✗ \(AIPromoteError.restoreFailed(targetPath, error).localizedDescription)")
    }
}

func normalizedFilePath(_ raw: String) -> String {
    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    let url = URL(fileURLWithPath: raw, relativeTo: cwd).standardizedFileURL
    return url.path
}
