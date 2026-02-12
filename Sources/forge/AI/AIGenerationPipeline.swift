import Foundation

enum AIGenerationPipelineError: LocalizedError {
    case unsupportedProvider(String)
    case createDirectoryFailed(String, Error)
    case writeFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .unsupportedProvider(let provider):
            return "Unsupported provider: \(provider)"
        case .createDirectoryFailed(let path, let error):
            return "Failed to create output directory \(path): \(error.localizedDescription)"
        case .writeFailed(let path, let error):
            return "Failed to write \(path): \(error.localizedDescription)"
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

    if settings.live {
        do {
            let liveCandidate = try liveDraft(
                for: provider.key,
                model: settings.model,
                environment: environment,
                transport: transport
            )
            let normalized = normalizeAIDraft(liveCandidate)
            draft = normalized.draft
            warnings += normalized.warnings
            _ = try makeChallengeFromAIDraft(draft)
            mode = "live"
            status = "live_success"
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
        warnings: warnings
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
        status: status,
        warnings: warnings
    )
}

func liveDraft(
    for providerKey: String,
    model: String?,
    environment: [String: String],
    transport: PhiHTTPTransport?
) throws -> AIChallengeDraft {
    switch providerKey {
    case "ollama":
        return try fetchOllamaLiveDraft(modelOverride: model, environment: environment, transport: transport)
    case "phi":
        return try fetchPhiLiveDraft(modelOverride: model, environment: environment, transport: transport)
    default:
        throw AIGenerationPipelineError.unsupportedProvider(providerKey)
    }
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

func iso8601TimestampNow() -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: Date())
}
