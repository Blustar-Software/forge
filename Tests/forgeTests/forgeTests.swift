import Foundation
import XCTest
@testable import forge

final class ForgeTests: XCTestCase {
    func testProgressDefaultsToOneWhenMissing() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workspacePath = tempDir.path

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let progress = getCurrentProgress(workspacePath: workspacePath)
            XCTAssertEqual(progress, 1)
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testSaveAndLoadProgress() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workspacePath = tempDir.path

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            saveProgress(3, workspacePath: workspacePath)
            let progress = getCurrentProgress(workspacePath: workspacePath)
            XCTAssertEqual(progress, 3)
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testIsExpectedOutput() {
        XCTAssertTrue(isExpectedOutput("Hello, Forge", expected: "Hello, Forge"))
        XCTAssertFalse(isExpectedOutput("Hello", expected: "Hello, Forge"))
        XCTAssertTrue(isExpectedOutput("Hello, Forge\n", expected: "Hello, Forge"))
        XCTAssertTrue(isExpectedOutput("  Hello, Forge  ", expected: "Hello, Forge"))
    }

    func testResetProgressRemovesProgressAndChallenges() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workspacePath = tempDir.path

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let progressPath = tempDir.appendingPathComponent(".progress")
            let challengePath = tempDir.appendingPathComponent("challenge1.swift")
            let otherPath = tempDir.appendingPathComponent("notes.txt")

            try "2".write(to: progressPath, atomically: true, encoding: .utf8)
            try "print(\"Hi\")".write(to: challengePath, atomically: true, encoding: .utf8)
            try "keep".write(to: otherPath, atomically: true, encoding: .utf8)

            resetProgress(workspacePath: workspacePath)

            XCTAssertFalse(FileManager.default.fileExists(atPath: progressPath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: challengePath.path))
            XCTAssertTrue(FileManager.default.fileExists(atPath: otherPath.path))
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }
}
