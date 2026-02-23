import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

enum TutorBridgeSubjectKind: String, Codable {
    case challenge
    case project
}

struct TutorBridgeProjectTestCase: Codable {
    let input: String
    let expectedOutput: String
}

struct TutorBridgeSubjectSnapshot: Codable {
    let kind: TutorBridgeSubjectKind
    let id: String
    let title: String
    let description: String
    let filename: String
    let workspacePath: String
    let hints: [String]
    let cheatsheet: String
    let lesson: String
    let solution: String
    let expectedOutput: String?
    let testCases: [TutorBridgeProjectTestCase]?
}

struct TutorBridgeSessionSnapshot: Codable {
    let sessionId: String
    let ownerPid: Int32
    let startedAt: String
    var updatedAt: String
    var contextRevision: Int
    var subject: TutorBridgeSubjectSnapshot?
    var lastDiagnostics: String?

    init(
        sessionId: String,
        ownerPid: Int32,
        startedAt: String,
        updatedAt: String,
        contextRevision: Int,
        subject: TutorBridgeSubjectSnapshot?,
        lastDiagnostics: String?
    ) {
        self.sessionId = sessionId
        self.ownerPid = ownerPid
        self.startedAt = startedAt
        self.updatedAt = updatedAt
        self.contextRevision = contextRevision
        self.subject = subject
        self.lastDiagnostics = lastDiagnostics
    }

    enum CodingKeys: String, CodingKey {
        case sessionId
        case ownerPid
        case startedAt
        case updatedAt
        case contextRevision
        case subject
        case lastDiagnostics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        ownerPid = try container.decode(Int32.self, forKey: .ownerPid)
        startedAt = try container.decode(String.self, forKey: .startedAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        contextRevision = try container.decodeIfPresent(Int.self, forKey: .contextRevision) ?? 0
        subject = try container.decodeIfPresent(TutorBridgeSubjectSnapshot.self, forKey: .subject)
        lastDiagnostics = try container.decodeIfPresent(String.self, forKey: .lastDiagnostics)
    }
}

func tutorBridgeSessionPath(workspacePath: String = "workspace") -> String {
    return "\(workspacePath)/.tutor_session"
}

func processIsAlive(pid: Int32) -> Bool {
    if pid <= 0 {
        return false
    }
    if kill(pid, 0) == 0 {
        return true
    }
    #if canImport(Darwin)
    return errno == EPERM
    #else
    return errno == EPERM
    #endif
}

func loadTutorBridgeSession(workspacePath: String = "workspace") -> TutorBridgeSessionSnapshot? {
    let path = tutorBridgeSessionPath(workspacePath: workspacePath)
    guard let content = try? String(contentsOfFile: path, encoding: .utf8),
          let data = content.data(using: .utf8),
          let session = try? JSONDecoder().decode(TutorBridgeSessionSnapshot.self, from: data)
    else {
        return nil
    }

    guard processIsAlive(pid: session.ownerPid) else {
        try? FileManager.default.removeItem(atPath: path)
        return nil
    }

    return session
}

func saveTutorBridgeSession(_ session: TutorBridgeSessionSnapshot, workspacePath: String = "workspace") {
    setupWorkspace(at: workspacePath)
    let path = tutorBridgeSessionPath(workspacePath: workspacePath)
    guard let data = try? JSONEncoder().encode(session),
          let text = String(data: data, encoding: .utf8)
    else {
        return
    }
    try? text.write(toFile: path, atomically: true, encoding: .utf8)
}

func startTutorBridgeSession(workspacePath: String = "workspace") {
    let now = ISO8601DateFormatter().string(from: Date())
    let session = TutorBridgeSessionSnapshot(
        sessionId: UUID().uuidString,
        ownerPid: getpid(),
        startedAt: now,
        updatedAt: now,
        contextRevision: 0,
        subject: nil,
        lastDiagnostics: nil
    )
    saveTutorBridgeSession(session, workspacePath: workspacePath)
}

func stopTutorBridgeSession(workspacePath: String = "workspace") {
    let path = tutorBridgeSessionPath(workspacePath: workspacePath)
    try? FileManager.default.removeItem(atPath: path)
}

private func updateTutorBridgeSession(
    workspacePath: String = "workspace",
    mutate: (inout TutorBridgeSessionSnapshot) -> Void
) {
    guard var session = loadTutorBridgeSession(workspacePath: workspacePath) else { return }
    mutate(&session)
    session.updatedAt = ISO8601DateFormatter().string(from: Date())
    saveTutorBridgeSession(session, workspacePath: workspacePath)
}

func publishTutorBridgeChallengeContext(
    _ challenge: Challenge,
    challengeWorkspacePath: String = "workspace",
    sessionWorkspacePath: String = "workspace"
) {
    updateTutorBridgeSession(workspacePath: sessionWorkspacePath) { session in
        session.contextRevision += 1
        session.subject = TutorBridgeSubjectSnapshot(
            kind: .challenge,
            id: challenge.displayId,
            title: challenge.title,
            description: challenge.description,
            filename: challenge.filename,
            workspacePath: challengeWorkspacePath,
            hints: challenge.hints,
            cheatsheet: challenge.cheatsheet,
            lesson: challenge.lesson,
            solution: challenge.solution,
            expectedOutput: challenge.expectedOutput,
            testCases: nil
        )
        session.lastDiagnostics = nil
    }
}

func publishTutorBridgeProjectContext(
    _ project: Project,
    projectWorkspacePath: String = "workspace",
    sessionWorkspacePath: String = "workspace"
) {
    updateTutorBridgeSession(workspacePath: sessionWorkspacePath) { session in
        session.contextRevision += 1
        session.subject = TutorBridgeSubjectSnapshot(
            kind: .project,
            id: project.id,
            title: project.title,
            description: project.description,
            filename: project.filename,
            workspacePath: projectWorkspacePath,
            hints: project.hints,
            cheatsheet: project.cheatsheet,
            lesson: project.lesson,
            solution: project.solution,
            expectedOutput: nil,
            testCases: project.testCases.map { TutorBridgeProjectTestCase(input: $0.input, expectedOutput: $0.expectedOutput) }
        )
        session.lastDiagnostics = nil
    }
}

func publishTutorBridgeDiagnostics(_ diagnostics: String?, workspacePath: String = "workspace") {
    updateTutorBridgeSession(workspacePath: workspacePath) { session in
        let trimmed = diagnostics?.trimmingCharacters(in: .whitespacesAndNewlines)
        session.lastDiagnostics = (trimmed?.isEmpty == false) ? trimmed : nil
    }
}
