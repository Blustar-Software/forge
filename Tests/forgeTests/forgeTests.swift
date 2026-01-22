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
            XCTAssertFalse(FileManager.default.fileExists(atPath: otherPath.path))
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testResetAllStatsClearsFiles() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workspacePath = tempDir.path

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let adaptivePath = tempDir.appendingPathComponent(".adaptive_stats")
            let challengePath = tempDir.appendingPathComponent(".adaptive_challenge_stats")
            let logPath = tempDir.appendingPathComponent(".performance_log")
            let masteryPath = tempDir.appendingPathComponent(".constraint_mastery")

            try "topic,pass=1".write(to: adaptivePath, atomically: true, encoding: .utf8)
            try "1|pass=1,fail=0,last=1".write(to: challengePath, atomically: true, encoding: .utf8)
            try "{\"event\":\"constraint_violation\"}".write(to: logPath, atomically: true, encoding: .utf8)
            try "conditionals|state=block,warn=1,clean=0".write(to: masteryPath, atomically: true, encoding: .utf8)

            resetAllStats(workspacePath: workspacePath)

            XCTAssertFalse(FileManager.default.fileExists(atPath: adaptivePath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: challengePath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: logPath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: masteryPath.path))
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testStatsLimitAppliesToSummaryTable() {
        let violationsByTopic: [String: Int] = [
            "strings": 3,
            "loops": 2,
            "general": 1,
        ]

        let lines = constraintTopicTableLines(violationsByTopic, limit: 1)
        XCTAssertEqual(lines.count, 3)
        XCTAssertTrue(lines[0].contains("Topic"))
        XCTAssertTrue(lines[0].contains("Count"))
        XCTAssertTrue(lines[2].contains("strings"))
    }

    func testConstraintProfileRespectsCollectionOverride() {
        let challenge = Challenge(
            number: 1,
            title: "Override Collection Requirement",
            description: "",
            starterCode: "",
            expectedOutput: "",
            constraintProfile: ConstraintProfile(requireCollectionUsage: false),
            topic: .collections
        )
        let source = "let value = 1"
        let violations = constraintViolations(for: source, challenge: challenge, enabled: true)
        XCTAssertFalse(violations.contains("✗ Collection usage required."))
    }

    func testConstraintProfileRequiresCollectionUsage() {
        let challenge = Challenge(
            number: 1,
            title: "Collection Requirement",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .collections
        )
        let source = "let value = 1"
        let violations = constraintViolations(for: source, challenge: challenge, enabled: true)
        XCTAssertTrue(violations.contains("✗ Collection usage required."))
    }

    func testConstraintProfileRequiresOptionalUsage() {
        let challenge = Challenge(
            number: 1,
            title: "Optional Requirement",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .optionals
        )
        let source = "let value = 1"
        let violations = constraintViolations(for: source, challenge: challenge, enabled: true)
        XCTAssertTrue(violations.contains("✗ Optional usage required."))
    }

    func testConstraintProfileRequiresClosureUsage() {
        let challenge = Challenge(
            number: 1,
            title: "Closure Requirement",
            description: "",
            starterCode: "",
            expectedOutput: "",
            constraintProfile: ConstraintProfile(requireClosureUsage: true),
            topic: .general
        )
        let source = "func greet() { }"
        let violations = constraintViolations(for: source, challenge: challenge, enabled: true)
        XCTAssertTrue(violations.contains("✗ Closure usage required."))
    }

    func testOptionalUsageIgnoresTernary() {
        let source = "let value = condition ? 1 : 2"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertFalse(hasOptionalUsage(tokens))
    }

    func testOptionalUsageDetectsOptionalType() {
        let source = "let value: String? = nil"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertTrue(hasOptionalUsage(tokens))
    }

    func testCollectionUsageIgnoresCaptureList() {
        let source = "{ [weak self] in print(\"Hi\") }"
        let cleaned = stripCommentsAndStrings(from: source)
        let tokens = tokenizeSource(cleaned)
        XCTAssertFalse(hasCollectionUsage(tokens: tokens, source: cleaned))
    }

    func testCollectionUsageDetectsArrayLiteral() {
        let source = "let values = [1, 2, 3]"
        let cleaned = stripCommentsAndStrings(from: source)
        let tokens = tokenizeSource(cleaned)
        XCTAssertTrue(hasCollectionUsage(tokens: tokens, source: cleaned))
    }

    func testCollectionUsageDetectsDictionaryLiteral() {
        let source = "let values = [\"a\": 1, \"b\": 2]"
        let cleaned = stripCommentsAndStrings(from: source)
        let tokens = tokenizeSource(cleaned)
        XCTAssertTrue(hasCollectionUsage(tokens: tokens, source: cleaned))
    }

    func testOptionalUsageDetectsIfLet() {
        let source = "if let value = maybe { print(value) }"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertTrue(hasOptionalUsage(tokens))
    }

    func testClosureUsageDetectsAssignment() {
        let source = "let work = { print(\"Hi\") }"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertTrue(hasClosureUsage(tokens))
    }

    func testTupleUsageWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Tuple Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.tuples],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Tuple",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "func pair() -> (Int, Int) { return (1, 2) }"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("tuples") })
    }

    func testFileIOWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "File Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.fileIO],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early File IO",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let data = try? Data(contentsOf: URL(fileURLWithPath: \"a\"))"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("file IO") })
    }

    func testCommandLineArgsWarnBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Args Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.commandLineArguments],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Args",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let count = ProcessInfo.processInfo.arguments.count"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("CommandLine.arguments") })
    }

    func testTaskUsageWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Task Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.task],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Task",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let task = Task { print(\"hi\") }"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("Task") })
    }

    func testTaskGroupWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Task Group Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.taskGroup],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Task Group",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "withThrowingTaskGroup(of: Int.self) { _ in }"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("withTaskGroup") })
    }

    func testErrorTypeWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Error Type Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.errorTypes],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Error Type",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let result: Result<Int, Error> = .success(1)"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("error types") })
    }

    func testGenericsWhereClauseWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Generics Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.generics],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Generics",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "extension Array where Element: Equatable {}"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("generics") })
    }

    func testProtocolConformanceWarnsInExtension() {
        let introChallenge = Challenge(
            number: 20,
            title: "Conformance Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.protocolConformance],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Conformance",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "extension Tool: Repairable {}"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("protocol conformance") })
    }

    func testProtocolExtensionWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Protocol Extension Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.protocolExtensions],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Protocol Extension",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "protocol Forgeable {} extension Forgeable { func forge() {} }"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("protocol extensions") })
    }

    func testAccessControlWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Access Control Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.accessControl],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Access",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "public struct Tool { }"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("access control") })
    }

    func testMacroWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Macros Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.macros],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Macros",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let value = #forgeMacro()"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("macros") })
    }

    func testSwiftPMBasicsWarnBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "SwiftPM Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.swiftpmBasics],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early SwiftPM",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "import PackageDescription\nlet package = Package(name: \"Forge\")"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("SwiftPM basics") })
    }

    func testBuildConfigWarnsBeforeIntro() {
        let introChallenge = Challenge(
            number: 20,
            title: "Build Config Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.buildConfigs],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Build Config",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "#if DEBUG\nprint(\"debug\")\n#endif"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertTrue(warnings.contains { $0.contains("build configs") })
    }

    func testAdaptivePracticePoolFiltersByTopicLayerAndExcludesCurrent() {
        let current = Challenge(
            number: 10,
            title: "Current",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops,
            layer: .core
        )
        let extraSameNumber = Challenge(
            number: 10,
            title: "Extra Same Number",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops,
            tier: .extra,
            layer: .core
        )
        let futureSameTopic = Challenge(
            number: 12,
            title: "Future",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops,
            layer: .core
        )
        let otherTopic = Challenge(
            number: 9,
            title: "Other Topic",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .strings,
            layer: .core
        )
        let otherLayer = Challenge(
            number: 9,
            title: "Other Layer",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops,
            layer: .mantle
        )

        let pool = [current, extraSameNumber, futureSameTopic, otherTopic, otherLayer]
        let filtered = adaptivePracticePool(for: current, from: pool)

        XCTAssertTrue(filtered.contains { $0.progressId == extraSameNumber.progressId })
        XCTAssertFalse(filtered.contains { $0.progressId == current.progressId })
        XCTAssertFalse(filtered.contains { $0.progressId == futureSameTopic.progressId })
        XCTAssertFalse(filtered.contains { $0.progressId == otherTopic.progressId })
        XCTAssertFalse(filtered.contains { $0.progressId == otherLayer.progressId })
    }

    func testAdaptivePracticePoolAppliesWindow() {
        let current = Challenge(
            number: 20,
            title: "Current",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .conditionals,
            layer: .core
        )
        let withinWindow = Challenge(
            number: 14,
            title: "Within Window",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .conditionals,
            layer: .core
        )
        let outsideWindow = Challenge(
            number: 10,
            title: "Outside Window",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .conditionals,
            layer: .core
        )

        let pool = [current, withinWindow, outsideWindow]
        let filtered = adaptivePracticePool(for: current, from: pool, windowSize: 8)

        XCTAssertTrue(filtered.contains { $0.progressId == withinWindow.progressId })
        XCTAssertFalse(filtered.contains { $0.progressId == outsideWindow.progressId })
    }

    func testAdaptiveChallengeWeightRewardsRecencyAndFailures() {
        let challenge = Challenge(
            number: 10,
            title: "Weighted",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops
        )
        let topicStats: [String: [String: Int]] = [
            "loops": ["fail": 2, "pass": 0]
        ]
        let now = 10_000
        var stats: [String: ChallengeStats] = [:]
        stats[challenge.displayId] = ChallengeStats(
            pass: 0,
            fail: 2,
            compileFail: 0,
            manualPass: 0,
            lastAttempt: now - 200
        )

        let weight = adaptiveChallengeWeight(
            challenge: challenge,
            topicStats: topicStats,
            challengeStats: stats,
            now: now
        )

        XCTAssertGreaterThanOrEqual(weight, 3)
    }

    func testLoadAdaptiveChallengeStatsParsesCounts() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workspacePath = tempDir.path

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let path = tempDir.appendingPathComponent(".adaptive_challenge_stats")
            try "1|pass=1,fail=2,compile_fail=3,manual_pass=4,last=5\n"
                .write(to: path, atomically: true, encoding: .utf8)

            let stats = loadAdaptiveChallengeStats(workspacePath: workspacePath)
            let entry = stats["1"] ?? ChallengeStats()

            XCTAssertEqual(entry.pass, 1)
            XCTAssertEqual(entry.fail, 2)
            XCTAssertEqual(entry.compileFail, 3)
            XCTAssertEqual(entry.manualPass, 4)
            XCTAssertEqual(entry.lastAttempt, 5)
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testTopicDisallowBlocksMapBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Map Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.map],
            topic: .collections
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Collections",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .collections
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let values = [1, 2, 3].map { $0 }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("map") })
    }

    func testTopicDisallowAllowsMapAtIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Map Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.map],
            topic: .collections
        )
        let index = buildConstraintIndex(from: [introChallenge])
        let source = "let values = [1, 2, 3].map { $0 }"
        let violations = constraintViolations(
            for: source,
            challenge: introChallenge,
            enabled: true,
            index: index
        )
        XCTAssertFalse(violations.contains { $0.contains("map") })
    }

    func testTopicDisallowBlocksStringInterpolationBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Interpolation Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.stringInterpolation],
            topic: .strings
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Strings",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .strings
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "print(\"Value: \\(value)\")"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("string interpolation") })
    }

    func testTopicDisallowBlocksTryOptionalBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Try? Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.tryOptional],
            topic: .optionals
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Optionals",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .optionals
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let value = try? read()"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("try?") })
    }

    func testTopicDisallowBlocksMapInStringsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Map Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.map],
            topic: .collections
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Strings",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .strings
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let letters = name.map { $0 }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("map") })
    }

    func testTopicDisallowBlocksFilterInStringsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Filter Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.filter],
            topic: .collections
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Strings",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .strings
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let letters = name.filter { $0 != \"a\" }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("filter") })
    }

    func testTopicDisallowBlocksReduceInStringsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Reduce Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.reduce],
            topic: .collections
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Strings",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .strings
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "let total = name.reduce(0) { $0 + $1.asciiValue! }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("reduce") })
    }

    func testTopicDisallowBlocksTryKeywordInGeneralBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Try Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            constraintProfile: ConstraintProfile(),
            introduces: [.tryKeyword],
            topic: .general
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early General",
            description: "",
            starterCode: "",
            expectedOutput: "",
            constraintProfile: ConstraintProfile(),
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "try work()"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("try") })
    }

    func testTopicDisallowBlocksSwitchInConditionalsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Switch Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.switchStatement],
            topic: .conditionals
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Conditionals",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .conditionals
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "switch value { default: break }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("switch") })
    }

    func testTopicDisallowBlocksBreakContinueInConditionalsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Break Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.breakContinue],
            topic: .conditionals
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Conditionals",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .conditionals
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "if condition { break }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("break/continue") })
    }

    func testTopicDisallowBlocksRangesInConditionalsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Ranges Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.ranges],
            topic: .conditionals
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Conditionals",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .conditionals
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "if (1...3).contains(value) { print(value) }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("ranges") })
    }

    func testTopicDisallowBlocksForLoopBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "For Loop Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.forInLoop],
            topic: .loops
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Loops",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "for value in [1, 2] { print(value) }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("for-in loops") })
    }

    func testTopicDisallowBlocksRangesInLoopsBeforeIntro() {
        let introChallenge = Challenge(
            number: 10,
            title: "Ranges Intro",
            description: "",
            starterCode: "",
            expectedOutput: "",
            introduces: [.ranges],
            topic: .loops
        )
        let earlyChallenge = Challenge(
            number: 5,
            title: "Early Loops",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .loops
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = "for value in 1...3 { print(value) }"
        let violations = constraintViolations(
            for: source,
            challenge: earlyChallenge,
            enabled: true,
            index: index
        )
        XCTAssertTrue(violations.contains { $0.contains("ranges") })
    }

    func testDiagnosticsDetectOptionalPrint() {
        let challenge = Challenge(
            number: 1,
            title: "Optional Print",
            description: "",
            starterCode: "",
            expectedOutput: "value",
            topic: .optionals
        )
        let diagnostics = diagnosticsForMismatch(
            DiagnosticContext(
                challenge: challenge,
                output: "Optional(5)",
                expected: "value",
                source: nil
            )
        )
        XCTAssertTrue(diagnostics.contains { $0.contains("optional") })
    }

    func testDiagnosticsDetectMissingFunctionCall() {
        let challenge = Challenge(
            number: 1,
            title: "Function Call",
            description: "",
            starterCode: "",
            expectedOutput: "ok",
            topic: .functions
        )
        let source = """
        func forge() {
            print("ok")
        }
        """
        let diagnostics = diagnosticsForMismatch(
            DiagnosticContext(
                challenge: challenge,
                output: "",
                expected: "ok",
                source: source
            )
        )
        XCTAssertTrue(diagnostics.contains { $0.contains("may not be called") })
    }

    func testParseAdaptiveSettingsIncludesStabilityFlags() {
        let args = [
            "--adaptive-on",
            "--adaptive-threshold", "2",
            "--adaptive-count", "4",
            "--adaptive-topic-failures", "3",
            "--adaptive-challenge-failures", "5",
            "--adaptive-cooldown", "1",
            "extra"
        ]
        let parsed = parseAdaptiveSettings(args)
        XCTAssertTrue(parsed.enabled)
        XCTAssertEqual(parsed.threshold, 2)
        XCTAssertEqual(parsed.count, 4)
        XCTAssertEqual(parsed.minTopicFailures, 3)
        XCTAssertEqual(parsed.minChallengeFailures, 5)
        XCTAssertEqual(parsed.cooldownSteps, 1)
        XCTAssertEqual(parsed.remaining, ["extra"])
    }

    func testConstraintMasteryTransitions() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let workspacePath = tempDir.path

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let topic = ChallengeTopic.conditionals
            XCTAssertTrue(effectiveConstraintEnforcement(for: topic, enforceConstraints: true, workspacePath: workspacePath))

            recordConstraintMastery(topic: topic, hadWarnings: false, passed: true, workspacePath: workspacePath)
            recordConstraintMastery(topic: topic, hadWarnings: false, passed: true, workspacePath: workspacePath)
            recordConstraintMastery(topic: topic, hadWarnings: false, passed: true, workspacePath: workspacePath)
            XCTAssertFalse(effectiveConstraintEnforcement(for: topic, enforceConstraints: true, workspacePath: workspacePath))

            recordConstraintMastery(topic: topic, hadWarnings: true, passed: false, workspacePath: workspacePath)
            recordConstraintMastery(topic: topic, hadWarnings: true, passed: false, workspacePath: workspacePath)
            XCTAssertTrue(effectiveConstraintEnforcement(for: topic, enforceConstraints: true, workspacePath: workspacePath))
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }
}
