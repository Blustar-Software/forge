import Foundation

private let forgeStateManagedFiles: [String] = [
    ".progress",
    ".stage_gate",
    ".stage_gate_summary",
    ".adaptive_stats",
    ".adaptive_challenge_stats",
    ".pending_practice",
    ".performance_log",
    ".constraint_mastery",
]

private let forgeStateManagedFileSet = Set(forgeStateManagedFiles)

struct ForgeStateSnapshot: Codable {
    let schemaVersion: Int
    let exportedAt: String
    let workspacePath: String
    let files: [ForgeStateFile]
}

struct ForgeStateFile: Codable {
    let name: String
    let base64Data: String
}

enum ForgeStateSyncError: LocalizedError {
    case readFailed(String, Error)
    case writeFailed(String, Error)
    case decodeFailed(String)
    case invalidFileName(String)
    case invalidFilePayload(String)

    var errorDescription: String? {
        switch self {
        case .readFailed(let path, let error):
            return "Failed to read \(path): \(error.localizedDescription)"
        case .writeFailed(let path, let error):
            return "Failed to write \(path): \(error.localizedDescription)"
        case .decodeFailed(let detail):
            return "Failed to decode state snapshot: \(detail)"
        case .invalidFileName(let name):
            return "State snapshot contains unsupported file: \(name)"
        case .invalidFilePayload(let name):
            return "State snapshot file has invalid base64 payload: \(name)"
        }
    }
}

func exportForgeState(
    to outputPath: String,
    workspacePath: String = "workspace"
) throws -> ForgeStateSnapshot {
    setupWorkspace(at: workspacePath)
    let fileManager = FileManager.default

    var files: [ForgeStateFile] = []
    for name in forgeStateManagedFiles {
        let path = "\(workspacePath)/\(name)"
        guard fileManager.fileExists(atPath: path) else { continue }
        let data: Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            throw ForgeStateSyncError.readFailed(path, error)
        }
        files.append(ForgeStateFile(name: name, base64Data: data.base64EncodedString()))
    }

    let snapshot = ForgeStateSnapshot(
        schemaVersion: 1,
        exportedAt: forgeStateTimestampNow(),
        workspacePath: workspacePath,
        files: files
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let encoded: Data
    do {
        encoded = try encoder.encode(snapshot)
    } catch {
        throw ForgeStateSyncError.writeFailed(outputPath, error)
    }

    do {
        try encoded.write(to: URL(fileURLWithPath: outputPath), options: .atomic)
    } catch {
        throw ForgeStateSyncError.writeFailed(outputPath, error)
    }

    return snapshot
}

func importForgeState(
    from inputPath: String,
    workspacePath: String = "workspace"
) throws -> ForgeStateSnapshot {
    let data: Data
    do {
        data = try Data(contentsOf: URL(fileURLWithPath: inputPath))
    } catch {
        throw ForgeStateSyncError.readFailed(inputPath, error)
    }

    let snapshot: ForgeStateSnapshot
    do {
        snapshot = try JSONDecoder().decode(ForgeStateSnapshot.self, from: data)
    } catch {
        let preview = String(data: data.prefix(200), encoding: .utf8) ?? "<non-utf8>"
        throw ForgeStateSyncError.decodeFailed(preview)
    }

    let fileManager = FileManager.default
    do {
        try fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
    } catch {
        throw ForgeStateSyncError.writeFailed(workspacePath, error)
    }

    var importedNames = Set<String>()
    for file in snapshot.files {
        guard forgeStateManagedFileSet.contains(file.name) else {
            throw ForgeStateSyncError.invalidFileName(file.name)
        }
        guard let decoded = Data(base64Encoded: file.base64Data) else {
            throw ForgeStateSyncError.invalidFilePayload(file.name)
        }
        let path = "\(workspacePath)/\(file.name)"
        do {
            try decoded.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            throw ForgeStateSyncError.writeFailed(path, error)
        }
        importedNames.insert(file.name)
    }

    // Mirror snapshot exactly for managed files.
    for name in forgeStateManagedFiles where !importedNames.contains(name) {
        let path = "\(workspacePath)/\(name)"
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }

    return snapshot
}

private func forgeStateTimestampNow() -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: Date())
}
