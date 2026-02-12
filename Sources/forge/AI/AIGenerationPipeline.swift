import Foundation

enum AIGenerationPipelineError: LocalizedError {
    case unsupportedProvider(String)
    case createDirectoryFailed(String, Error)
    case writeFailed(String, Error)
    case liveDraftRejected([String])

    var errorDescription: String? {
        switch self {
        case .unsupportedProvider(let provider):
            return "Unsupported provider: \(provider)"
        case .createDirectoryFailed(let path, let error):
            return "Failed to create output directory \(path): \(error.localizedDescription)"
        case .writeFailed(let path, let error):
            return "Failed to write \(path): \(error.localizedDescription)"
        case .liveDraftRejected(let reasons):
            let compact = reasons.joined(separator: " | ")
            return "Live draft failed quality checks: \(compact)"
        }
    }
}

func runAIGenerateScaffold(
    settings: AIGenerateSettings,
    environment: [String: String] = ProcessInfo.processInfo.environment,
    transport: PhiHTTPTransport? = nil
) throws -> AIGenerateRunResult {
    guard let provider = makeAIProvider(named: settings.provider) else {
        throw AIGenerationPipelineError.unsupportedProvider(settings.provider)
    }

    let outputPath = settings.outputPath
    do {
        try FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
    } catch {
        throw AIGenerationPipelineError.createDirectoryFailed(outputPath, error)
    }

    let generatedAt = iso8601TimestampNow()
    let requestPath = "\(outputPath)/request.json"
    let candidatePath = "\(outputPath)/candidate.json"
    let reportPath = "\(outputPath)/report.json"
    let auditPath = "\(outputPath)/audit.json"

    let requestArtifact = AIGenerationRequestArtifact(
        schemaVersion: 1,
        generatedAt: generatedAt,
        provider: provider.key,
        model: settings.model,
        live: settings.live,
        dryRun: settings.dryRun,
        outputPath: outputPath
    )

    var draft = provider.scaffoldDraft(model: settings.model)
    var mode = settings.dryRun ? "dry-run" : "scaffold"
    var status = settings.dryRun ? "dry_run_scaffold" : "scaffold"
    var warnings: [String] = []
    var auditStatus: String?
    var shouldWriteAudit = false

    if settings.live {
        do {
            let validation = try validatedLiveDraft(
                for: provider.key,
                model: settings.model,
                environment: environment,
                transport: transport
            )
            draft = validation.draft
            warnings += validation.warnings
            mode = "live"
            status = "live_success"

            if shouldRunLocalReasoningAudit(providerKey: provider.key, settings: settings, environment: environment) {
                shouldWriteAudit = true
                do {
                    let audit = try runLocalReasoningAudit(
                        draft: draft,
                        candidatePath: candidatePath,
                        generatedAt: generatedAt,
                        environment: environment,
                        transport: transport
                    )
                    auditStatus = audit.status
                    warnings += audit.warnings
                    try writeJSONArtifact(audit.artifact, to: auditPath)

                    if !audit.isApproved {
                        mode = "live-fallback-scaffold"
                        status = "live_fallback_scaffold"
                        draft = provider.scaffoldDraft(model: settings.model)
                        warnings.append("Reasoning audit rejected draft; reverted to scaffold candidate.")
                    }
                } catch {
                    auditStatus = "audit_error"
                    let errorArtifact = AIGenerationAuditArtifact(
                        schemaVersion: 1,
                        generatedAt: generatedAt,
                        provider: provider.key,
                        model: resolvedOllamaAuditModel(environment: environment),
                        candidatePath: candidatePath,
                        status: "audit_error",
                        approved: nil,
                        risk: nil,
                        summary: error.localizedDescription,
                        findings: [],
                        recommendations: []
                    )
                    try? writeJSONArtifact(errorArtifact, to: auditPath)
                    warnings.append("Reasoning audit failed: \(error.localizedDescription)")
                }
            }
        } catch {
            mode = "live-fallback-scaffold"
            status = "live_fallback_scaffold"
            warnings.append("Live provider call failed: \(error.localizedDescription)")
        }
    } else if settings.dryRun {
        warnings.append("Dry run enabled: no provider API calls were made.")
    } else {
        warnings.append("Provider API integration is not implemented yet; generated candidate is scaffolded.")
    }

    let candidateArtifact = AIGeneratedCandidateArtifact(
        schemaVersion: 1,
        generatedAt: generatedAt,
        provider: provider.key,
        model: settings.model,
        mode: mode,
        challenge: draft
    )

    let reportArtifact = AIGenerationReportArtifact(
        schemaVersion: 1,
        generatedAt: generatedAt,
        status: status,
        provider: provider.key,
        model: settings.model,
        live: settings.live,
        dryRun: settings.dryRun,
        requestPath: requestPath,
        candidatePath: candidatePath,
        reportPath: reportPath,
        warnings: warnings,
        auditPath: shouldWriteAudit ? auditPath : nil,
        auditStatus: auditStatus
    )

    try writeJSONArtifact(requestArtifact, to: requestPath)
    try writeJSONArtifact(candidateArtifact, to: candidatePath)
    try writeJSONArtifact(reportArtifact, to: reportPath)

    return AIGenerateRunResult(
        provider: provider.key,
        model: settings.model,
        live: settings.live,
        dryRun: settings.dryRun,
        outputPath: outputPath,
        requestPath: requestPath,
        candidatePath: candidatePath,
        reportPath: reportPath,
        auditPath: shouldWriteAudit ? auditPath : nil,
        auditStatus: auditStatus,
        status: status,
        warnings: warnings
    )
}

func liveDraft(
    for providerKey: String,
    model: String?,
    environment: [String: String],
    feedback: String? = nil,
    transport: PhiHTTPTransport?
) throws -> AIChallengeDraft {
    switch providerKey {
    case "ollama":
        return try fetchOllamaLiveDraft(
            modelOverride: model,
            environment: environment,
            retryFeedback: feedback,
            transport: transport
        )
    case "phi":
        return try fetchPhiLiveDraft(
            modelOverride: model,
            environment: environment,
            retryFeedback: feedback,
            transport: transport
        )
    default:
        throw AIGenerationPipelineError.unsupportedProvider(providerKey)
    }
}

func validatedLiveDraft(
    for providerKey: String,
    model: String?,
    environment: [String: String],
    transport: PhiHTTPTransport?,
    maxAttempts: Int = 2
) throws -> AIDraftNormalizationResult {
    let attemptCount = max(1, maxAttempts)
    var failureReasons: [String] = []
    var feedback: String? = nil

    for attempt in 1...attemptCount {
        do {
            let candidate = try liveDraft(
                for: providerKey,
                model: model,
                environment: environment,
                feedback: feedback,
                transport: transport
            )
            let normalized = normalizeAIDraft(candidate)
            var draft = normalized.draft
            var warnings = normalized.warnings

            let trimmedSolution = draft.solution?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimmedSolution.isEmpty {
                let hasTodo = draft.starterCode.contains("// TODO:")
                if hasTodo {
                    throw AIGenerationPipelineError.liveDraftRejected(["missing solution"])
                }
                warnings.append("Missing solution; moved starterCode into solution and replaced starter with TODO scaffold.")
                draft = AIChallengeDraft(
                    id: draft.id,
                    title: draft.title,
                    description: draft.description,
                    starterCode: "// TODO: Implement the solution.",
                    solution: draft.starterCode,
                    expectedOutput: draft.expectedOutput,
                    hints: draft.hints,
                    topic: draft.topic,
                    tier: draft.tier,
                    layer: draft.layer
                )
            }
            let challenge = try makeChallengeFromAIDraft(draft)

            if let skipReason = skipReasonForVerification(challenge: challenge) {
                throw AIGenerationPipelineError.liveDraftRejected(["requires unsupported runtime context (\(skipReason))"])
            }

            let source = sourceForAIVerification(challenge: challenge)
            let temporaryURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("forge_ai_generate_validation_\(UUID().uuidString)")
            let temporaryPath = temporaryURL.path

            setupWorkspace(at: temporaryPath)
            clearWorkspaceContents(at: temporaryPath)
            defer { try? FileManager.default.removeItem(atPath: temporaryPath) }

            let compileResult = verifyAICandidateCompileAndOutput(
                challenge: challenge,
                source: source,
                workspacePath: temporaryPath
            )
            guard compileResult.ok else {
                throw AIGenerationPipelineError.liveDraftRejected([compileResult.message])
            }

            if attempt > 1 {
                warnings.append("Live draft passed quality checks on retry \(attempt).")
            }
            return AIDraftNormalizationResult(draft: draft, warnings: warnings)
        } catch {
            let detail = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            let compact = detail.replacingOccurrences(of: "\n", with: " ")
            failureReasons.append("attempt \(attempt): \(compact)")
            feedback = compact
            if attempt == attemptCount {
                break
            }
        }
    }

    throw AIGenerationPipelineError.liveDraftRejected(failureReasons)
}

func writeJSONArtifact<T: Encodable>(_ value: T, to path: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(value)
    do {
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    } catch {
        throw AIGenerationPipelineError.writeFailed(path, error)
    }
}

func shouldRunLocalReasoningAudit(
    providerKey: String,
    settings: AIGenerateSettings,
    environment: [String: String]
) -> Bool {
    guard settings.live, providerKey == "ollama" else {
        return false
    }
    guard let raw = environment["FORGE_AI_LOCAL_AUDIT_ENABLED"]?.trimmingCharacters(in: .whitespacesAndNewlines),
          !raw.isEmpty else {
        return true
    }
    let lowered = raw.lowercased()
    return !["0", "false", "off", "no"].contains(lowered)
}

private struct LocalReasoningAuditResult {
    let artifact: AIGenerationAuditArtifact
    let warnings: [String]
    let isApproved: Bool
    let status: String
}

private func runLocalReasoningAudit(
    draft: AIChallengeDraft,
    candidatePath: String,
    generatedAt: String,
    environment: [String: String],
    transport: PhiHTTPTransport?
) throws -> LocalReasoningAuditResult {
    let decision = try fetchOllamaDraftAudit(
        draft: draft,
        environment: environment,
        transport: transport
    )

    let status = decision.approved ? "audit_passed" : "audit_rejected"
    let artifact = AIGenerationAuditArtifact(
        schemaVersion: 1,
        generatedAt: generatedAt,
        provider: "ollama",
        model: decision.model,
        candidatePath: candidatePath,
        status: status,
        approved: decision.approved,
        risk: decision.risk,
        summary: decision.summary,
        findings: decision.findings,
        recommendations: decision.recommendations
    )

    var warnings: [String] = []
    if decision.approved {
        warnings.append("Reasoning audit passed (\(decision.risk)).")
    } else {
        warnings.append("Reasoning audit rejected draft: \(decision.summary)")
    }

    return LocalReasoningAuditResult(
        artifact: artifact,
        warnings: warnings,
        isApproved: decision.approved,
        status: status
    )
}

func iso8601TimestampNow() -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: Date())
}
