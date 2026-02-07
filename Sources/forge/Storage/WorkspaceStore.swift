import Foundation

func setupWorkspace(at workspacePath: String = "workspace") {
    let fileManager = FileManager.default

    // Create workspace directory if it doesn't exist
    if !fileManager.fileExists(atPath: workspacePath) {
        try? fileManager.createDirectory(atPath: workspacePath, withIntermediateDirectories: true)
    }
}

func clearWorkspaceContents(at workspacePath: String) {
    if let files = try? FileManager.default.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            try? FileManager.default.removeItem(atPath: "\(workspacePath)/\(file)")
        }
    }
}

func resetWorkspaceContents(at workspacePath: String, removeAll: Bool) {
    let fileManager = FileManager.default
    if let files = try? fileManager.contentsOfDirectory(atPath: workspacePath) {
        for file in files {
            if removeAll || !file.hasPrefix(".") {
                try? fileManager.removeItem(atPath: "\(workspacePath)/\(file)")
            }
        }
    }
}
