import Foundation

struct AIGenerationRequestArtifact: Codable {
    let schemaVersion: Int
    let generatedAt: String
    let provider: String
    let model: String?
    let dryRun: Bool
    let outputPath: String
}

struct AIGeneratedCandidateArtifact: Codable {
    let schemaVersion: Int
    let generatedAt: String
    let provider: String
    let model: String?
    let mode: String
    let challenge: AIChallengeDraft
}

struct AIGenerationReportArtifact: Codable {
    let schemaVersion: Int
    let generatedAt: String
    let status: String
    let provider: String
    let model: String?
    let dryRun: Bool
    let requestPath: String
    let candidatePath: String
    let reportPath: String
    let warnings: [String]
}

struct AIGenerateRunResult {
    let provider: String
    let model: String?
    let dryRun: Bool
    let outputPath: String
    let requestPath: String
    let candidatePath: String
    let reportPath: String
    let status: String
    let warnings: [String]
}
