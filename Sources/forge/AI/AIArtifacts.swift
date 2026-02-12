import Foundation

struct AIGenerationRequestArtifact: Codable {
    let schemaVersion: Int
    let generatedAt: String
    let provider: String
    let model: String?
    let live: Bool
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
    let live: Bool
    let dryRun: Bool
    let requestPath: String
    let candidatePath: String
    let reportPath: String
    let auditPath: String?
    let auditStatus: String?
    let warnings: [String]

    init(
        schemaVersion: Int,
        generatedAt: String,
        status: String,
        provider: String,
        model: String?,
        live: Bool,
        dryRun: Bool,
        requestPath: String,
        candidatePath: String,
        reportPath: String,
        warnings: [String],
        auditPath: String? = nil,
        auditStatus: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.status = status
        self.provider = provider
        self.model = model
        self.live = live
        self.dryRun = dryRun
        self.requestPath = requestPath
        self.candidatePath = candidatePath
        self.reportPath = reportPath
        self.auditPath = auditPath
        self.auditStatus = auditStatus
        self.warnings = warnings
    }
}

struct AIGenerationAuditArtifact: Codable {
    let schemaVersion: Int
    let generatedAt: String
    let provider: String
    let model: String?
    let candidatePath: String
    let status: String
    let approved: Bool?
    let risk: String?
    let summary: String
    let findings: [String]
    let recommendations: [String]
}

struct AIGenerateRunResult {
    let provider: String
    let model: String?
    let live: Bool
    let dryRun: Bool
    let outputPath: String
    let requestPath: String
    let candidatePath: String
    let reportPath: String
    let auditPath: String?
    let auditStatus: String?
    let status: String
    let warnings: [String]
}
