import Foundation

enum AIGenerationPipelineError: LocalizedError {
    case liveModeUnavailable
    case unsupportedProvider(String)
    case createDirectoryFailed(String, Error)
    case writeFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .liveModeUnavailable:
            return "Live mode is not implemented yet. Re-run without --live."
        case .unsupportedProvider(let provider):
            return "Unsupported provider: \(provider)"
        case .createDirectoryFailed(let path, let error):
            return "Failed to create output directory \(path): \(error.localizedDescription)"
        case .writeFailed(let path, let error):
            return "Failed to write \(path): \(error.localizedDescription)"
        }
    }
}

func runAIGenerateScaffold(settings: AIGenerateSettings) throws -> AIGenerateRunResult {
    if settings.live {
        throw AIGenerationPipelineError.liveModeUnavailable
    }

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

    let draft = provider.scaffoldDraft(model: settings.model)
    let mode = settings.dryRun ? "dry-run" : "scaffold"
    let candidateArtifact = AIGeneratedCandidateArtifact(
        schemaVersion: 1,
        generatedAt: generatedAt,
        provider: provider.key,
        model: settings.model,
        mode: mode,
        challenge: draft
    )

    let warnings: [String] = settings.dryRun
        ? ["Dry run enabled: no provider API calls were made."]
        : ["Provider API integration is not implemented yet; generated candidate is scaffolded."]
    let status = settings.dryRun ? "dry_run_scaffold" : "scaffold"

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
