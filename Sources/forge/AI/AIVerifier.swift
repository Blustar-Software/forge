import Foundation

enum AIVerifyError: LocalizedError {
    case readFailed(String, Error)
    case decodeFailed(String)
    case invalidTopic(String)
    case invalidTier(String)
    case invalidLayer(String)
    case invalidField(String)
    case writeFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .readFailed(let path, let error):
            return "Failed to read candidate file \(path): \(error.localizedDescription)"
        case .decodeFailed(let detail):
            return "Failed to decode candidate file: \(detail)"
        case .invalidTopic(let value):
            return "Unsupported topic value: \(value)"
        case .invalidTier(let value):
            return "Unsupported tier value: \(value)"
        case .invalidLayer(let value):
            return "Unsupported layer value: \(value)"
        case .invalidField(let name):
            return "Candidate field is missing or empty: \(name)"
        case .writeFailed(let path, let error):
            return "Failed to write temporary verify file \(path): \(error.localizedDescription)"
        }
    }
}

func runAIVerify(settings: AIVerifySettings, enableDiMockHeuristics: Bool = true) -> Bool {
    print("AI verify target: \(settings.candidatePath)")

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

    print("Draft id: \(challenge.id)")
    print("Draft title: \(challenge.title)")
    print("Draft topic/layer/tier: \(challenge.topic.rawValue)/\(challenge.layer.rawValue)/\(challenge.tier.rawValue)")

    var overallOK = true
    let source = sourceForAIVerification(challenge: challenge)
    let workspacePath = "workspace_verify/ai_verify_run"
    setupWorkspace(at: workspacePath)
    clearWorkspaceContents(at: workspacePath)

    if !settings.constraintsOnly {
        let compileResult = verifyAICandidateCompileAndOutput(
            challenge: challenge,
            source: source,
            workspacePath: workspacePath
        )
        if compileResult.ok {
            print("✓ Compile/run check passed.")
        } else {
            overallOK = false
            print("✗ Compile/run check failed: \(compileResult.message)")
        }
    } else {
        print("Compile/run check skipped (--constraints-only).")
    }

    if !settings.compileOnly {
        let constraintResult = verifyAICandidateConstraints(challenge: challenge, source: source)
        if constraintResult.ok {
            print("✓ Constraint check passed.")
        } else {
            overallOK = false
            print("✗ Constraint check failed.")
            for item in constraintResult.violations {
                print("- \(item)")
            }
        }

        let reviewChallenge = challengeForReview(challenge: challenge, source: source)
        let reviewOK = reviewProgression(
            [reviewChallenge],
            constraintIndex: buildConstraintIndex(from: buildChallengeSets().allChallenges),
            enableDiMockHeuristics: enableDiMockHeuristics
        )
        if !reviewOK {
            overallOK = false
        }

        let auditOK = auditFixtures([challenge])
        if !auditOK {
            overallOK = false
        }
    } else {
        print("Constraint/review/audit checks skipped (--compile-only).")
    }

    if overallOK {
        print("✅ ai-verify passed.")
    } else {
        print("❌ ai-verify failed.")
    }
    return overallOK
}

func loadAIDraftFromCandidateFile(_ path: String) throws -> AIChallengeDraft {
    let data: Data
    do {
        data = try Data(contentsOf: URL(fileURLWithPath: path))
    } catch {
        throw AIVerifyError.readFailed(path, error)
    }

    if let wrapped = try? JSONDecoder().decode(AIGeneratedCandidateArtifact.self, from: data) {
        return wrapped.challenge
    }
    if let draft = try? JSONDecoder().decode(AIChallengeDraft.self, from: data) {
        return draft
    }
    let detail = String(data: data.prefix(200), encoding: .utf8) ?? "<non-utf8>"
    throw AIVerifyError.decodeFailed(detail)
}

func makeChallengeFromAIDraft(_ draft: AIChallengeDraft) throws -> Challenge {
    let trimmedId = draft.id.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedId.isEmpty else {
        throw AIVerifyError.invalidField("id")
    }
    let trimmedTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedTitle.isEmpty else {
        throw AIVerifyError.invalidField("title")
    }
    let trimmedDescription = draft.description.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedDescription.isEmpty else {
        throw AIVerifyError.invalidField("description")
    }
    let trimmedStarter = draft.starterCode.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedStarter.isEmpty else {
        throw AIVerifyError.invalidField("starterCode")
    }
    let trimmedExpected = draft.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedExpected.isEmpty else {
        throw AIVerifyError.invalidField("expectedOutput")
    }

    guard let topic = ChallengeTopic(rawValue: draft.topic) else {
        throw AIVerifyError.invalidTopic(draft.topic)
    }
    guard let tier = ChallengeTier(rawValue: draft.tier) else {
        throw AIVerifyError.invalidTier(draft.tier)
    }
    guard let layer = ChallengeLayer(rawValue: draft.layer) else {
        throw AIVerifyError.invalidLayer(draft.layer)
    }

    return Challenge(
        number: 10_000,
        id: trimmedId,
        title: trimmedTitle,
        description: trimmedDescription,
        starterCode: draft.starterCode,
        expectedOutput: draft.expectedOutput,
        hints: draft.hints,
        solution: draft.solution ?? "",
        topic: topic,
        tier: tier,
        layer: layer,
        canonicalId: "ai:\(trimmedId.lowercased())"
    )
}

func sourceForAIVerification(challenge: Challenge) -> String {
    let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
    if solution.isEmpty {
        return challenge.starterCode
    }
    return applySolutionToStarter(starterCode: challenge.starterCode, solution: solution)
}

func verifyAICandidateCompileAndOutput(
    challenge: Challenge,
    source: String,
    workspacePath: String
) -> (ok: Bool, message: String) {
    let filePath = "\(workspacePath)/ai_verify_candidate.swift"
    do {
        try source.write(toFile: filePath, atomically: true, encoding: .utf8)
    } catch {
        return (false, AIVerifyError.writeFailed(filePath, error).localizedDescription)
    }

    let runResult = runSwiftProcess(file: filePath)
    if runResult.exitCode != 0 {
        let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        return (false, output.isEmpty ? "swift exited with code \(runResult.exitCode)." : output)
    }

    let solution = challenge.solution.trimmingCharacters(in: .whitespacesAndNewlines)
    if solution.isEmpty {
        return (true, "compiled (output check skipped; no solution)")
    }

    if isExpectedOutput(runResult.output, expected: challenge.expectedOutput) {
        return (true, "compiled and matched expected output")
    }

    let output = runResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
    let expected = challenge.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
    return (false, "output mismatch (expected: \"\(expected)\", got: \"\(output)\")")
}

func verifyAICandidateConstraints(
    challenge: Challenge,
    source: String
) -> (ok: Bool, violations: [String]) {
    let index = buildConstraintIndex(from: buildChallengeSets().allChallenges)
    let violations = constraintViolations(
        for: source,
        challenge: challenge,
        enabled: true,
        index: index
    )
    return (violations.isEmpty, violations)
}

func challengeForReview(challenge: Challenge, source: String) -> Challenge {
    return Challenge(
        number: challenge.number,
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        starterCode: challenge.starterCode,
        expectedOutput: challenge.expectedOutput,
        hints: challenge.hints,
        cheatsheet: challenge.cheatsheet,
        lesson: challenge.lesson,
        solution: source,
        manualCheck: challenge.manualCheck,
        stdinFixture: challenge.stdinFixture,
        argsFixture: challenge.argsFixture,
        fixtureFiles: challenge.fixtureFiles,
        constraintProfile: challenge.constraintProfile,
        introduces: challenge.introduces,
        requires: challenge.requires,
        topic: challenge.topic,
        tier: challenge.tier,
        layer: challenge.layer,
        layerNumber: challenge.layerNumber,
        extraParent: challenge.extraParent,
        extraIndex: challenge.extraIndex,
        canonicalId: challenge.canonicalId
    )
}
