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

            resetProgress(workspacePath: workspacePath, quiet: true)

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
            let pendingPath = tempDir.appendingPathComponent(".pending_practice")

            try "topic,pass=1".write(to: adaptivePath, atomically: true, encoding: .utf8)
            try "1|pass=1,fail=0,last=1".write(to: challengePath, atomically: true, encoding: .utf8)
            try "{\"event\":\"constraint_violation\"}".write(to: logPath, atomically: true, encoding: .utf8)
            try "conditionals|state=block,warn=1,clean=0".write(to: masteryPath, atomically: true, encoding: .utf8)
            try "topic=loops,count=2,id=5,number=5,layer=core".write(to: pendingPath, atomically: true, encoding: .utf8)

            resetAllStats(workspacePath: workspacePath, quiet: true)

            XCTAssertFalse(FileManager.default.fileExists(atPath: adaptivePath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: challengePath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: logPath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: masteryPath.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: pendingPath.path))
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testRemapLegacyChallengeNumber() {
        XCTAssertEqual(remapLegacyChallengeNumber(1), 1)
        XCTAssertEqual(remapLegacyChallengeNumber(13), 13)
        XCTAssertEqual(remapLegacyChallengeNumber(14), 16)
        XCTAssertEqual(remapLegacyChallengeNumber(100), 102)
    }

    func testParseProgressInput() {
        if case .challenge(let value)? = parseProgressInput(["challenge:18"]) {
            XCTAssertEqual(value, 18)
        } else {
            XCTFail("Expected challenge input")
        }

        if case .project(let value)? = parseProgressInput(["project:core2a"]) {
            XCTAssertEqual(value, "core2a")
        } else {
            XCTFail("Expected project input")
        }

        if case .step(let value)? = parseProgressInput(["step:42"]) {
            XCTAssertEqual(value, 42)
        } else {
            XCTFail("Expected step input")
        }

        if case .challenge(let value)? = parseProgressInput(["12"]) {
            XCTAssertEqual(value, 12)
        } else {
            XCTFail("Expected numeric input to be a challenge")
        }

        if case .challengeId(let value)? = parseProgressInput(["core:18.1"]) {
            XCTAssertEqual(value, "core:18.1")
        } else {
            XCTFail("Expected canonical challenge id input")
        }
    }

    func testParseProgressTarget() {
        let projects = [
            Project(
                id: "core1a",
                pass: 1,
                title: "Core 1 Project A",
                description: "",
                starterCode: "",
                testCases: [],
                completionTitle: "",
                completionMessage: ""
            )
        ]

        switch parseProgressTarget("999", projects: projects) {
        case .completed:
            break
        default:
            XCTFail("Expected completed token")
        }

        switch parseProgressTarget("challenge:18", projects: projects) {
        case .challenge(let number):
            XCTAssertEqual(number, 18)
        default:
            XCTFail("Expected challenge number token")
        }

        switch parseProgressTarget("challenge:crust-extra-async-sleep", projects: projects) {
        case .challengeId(let id):
            XCTAssertEqual(id, "crust-extra-async-sleep")
        default:
            XCTFail("Expected challenge id token")
        }

        switch parseProgressTarget("core:18.1", projects: projects) {
        case .challengeId(let id):
            XCTAssertEqual(id, "core:18.1")
        default:
            XCTFail("Expected canonical challenge id token")
        }

        switch parseProgressTarget("project:core1a", projects: projects) {
        case .project(let id):
            XCTAssertEqual(id, "core1a")
        default:
            XCTFail("Expected project token")
        }

        switch parseProgressTarget("core1a", projects: projects) {
        case .project(let id):
            XCTAssertEqual(id, "core1a")
        default:
            XCTFail("Expected bare project id to be recognized")
        }
    }

    func testStepIndexForChallengeBounds() {
        let map = [1: 1, 5: 5]
        XCTAssertEqual(stepIndexForChallenge(0, challengeStepIndex: map, maxChallengeNumber: 5, stepsCount: 10), 1)
        XCTAssertEqual(stepIndexForChallenge(6, challengeStepIndex: map, maxChallengeNumber: 5, stepsCount: 10), 11)
        XCTAssertEqual(stepIndexForChallenge(1, challengeStepIndex: map, maxChallengeNumber: 5, stepsCount: 10), 1)
        XCTAssertEqual(stepIndexForChallenge(3, challengeStepIndex: map, maxChallengeNumber: 5, stepsCount: 10), 1)
    }

    func testRemapProgressTokenChallengeRemap() {
        let mainChallenge = Challenge(
            number: 16,
            title: "Main",
            description: "",
            starterCode: "",
            expectedOutput: ""
        )
        let extraChallenge = Challenge(
            number: 200,
            id: "crust-extra-async-sleep",
            title: "Extra",
            description: "",
            starterCode: "",
            expectedOutput: "",
            tier: .extra
        )
        let challengeIndexMap = [16: 4]
        let challengeIdIndexMap = ["crust-extra-async-sleep": 9]
        let allChallengeIdMap = [
            mainChallenge.progressId.lowercased(): mainChallenge,
            extraChallenge.progressId.lowercased(): extraChallenge
        ]
        let allChallengeNumberMap = [16: mainChallenge, 200: extraChallenge]
        let projectIndexMap: [String: Int] = [:]
        let projects: [Project] = []

        let outcome = remapProgressToken(
            "challenge:14",
            challengeIndexMap: challengeIndexMap,
            challengeIdIndexMap: challengeIdIndexMap,
            allChallengeIdMap: allChallengeIdMap,
            allChallengeNumberMap: allChallengeNumberMap,
            projectIndexMap: projectIndexMap,
            projects: projects,
            stepsCount: 10
        )

        switch outcome {
        case .success(let startIndex, let messagePrefix):
            XCTAssertEqual(startIndex, 4)
            XCTAssertEqual(messagePrefix, "Progress remapped from challenge 14 -> 16")
        default:
            XCTFail("Expected success outcome")
        }
    }

    func testRemapProgressTokenRejectsExtraChallenge() {
        let extraChallenge = Challenge(
            number: 200,
            id: "crust-extra-async-sleep",
            title: "Extra",
            description: "",
            starterCode: "",
            expectedOutput: "",
            tier: .extra
        )
        let outcome = remapProgressToken(
            "challenge:crust-extra-async-sleep",
            challengeIndexMap: [:],
            challengeIdIndexMap: ["crust-extra-async-sleep": 2],
            allChallengeIdMap: [extraChallenge.progressId.lowercased(): extraChallenge],
            allChallengeNumberMap: [200: extraChallenge],
            projectIndexMap: [:],
            projects: [],
            stepsCount: 10
        )

        switch outcome {
        case .info(let message):
            XCTAssertTrue(message.contains("is an extra"))
        default:
            XCTFail("Expected info outcome")
        }
    }

    func testRemapProgressTokenRejectsExtraProject() {
        let extraProject = Project(
            id: "core1b",
            pass: 1,
            title: "Extra Project",
            description: "",
            starterCode: "",
            testCases: [],
            completionTitle: "",
            completionMessage: "",
            tier: .extra
        )
        let outcome = remapProgressToken(
            "project:core1b",
            challengeIndexMap: [:],
            challengeIdIndexMap: [:],
            allChallengeIdMap: [:],
            allChallengeNumberMap: [:],
            projectIndexMap: [:],
            projects: [extraProject],
            stepsCount: 10
        )

        switch outcome {
        case .info(let message):
            XCTAssertTrue(message.contains("not part of the main flow"))
        default:
            XCTFail("Expected info outcome")
        }
    }

    func testRemapProgressTokenInvalidStep() {
        let outcome = remapProgressToken(
            "step:abc",
            challengeIndexMap: [:],
            challengeIdIndexMap: [:],
            allChallengeIdMap: [:],
            allChallengeNumberMap: [:],
            projectIndexMap: [:],
            projects: [],
            stepsCount: 10
        )

        switch outcome {
        case .error(let message, let showUsage):
            XCTAssertEqual(message, "Invalid step number.")
            XCTAssertTrue(showUsage)
        default:
            XCTFail("Expected error outcome")
        }
    }

    func testRemapProgressTokenIntegrationWithSteps() {
        let challengeOne = Challenge(
            number: 1,
            title: "One",
            description: "",
            starterCode: "",
            expectedOutput: ""
        )
        let challengeTwo = Challenge(
            number: 2,
            title: "Two",
            description: "",
            starterCode: "",
            expectedOutput: ""
        )
        let project = Project(
            id: "core1a",
            pass: 1,
            title: "Core 1 Project A",
            description: "",
            starterCode: "",
            testCases: [],
            completionTitle: "",
            completionMessage: ""
        )
        let gate = StageGate(
            id: "gate1",
            title: "Gate 1",
            pool: [],
            requiredPasses: 1,
            count: 1
        )
        let steps: [Step] = [
            .challenge(challengeOne),
            .project(project),
            .stageGate(gate),
            .challenge(challengeTwo)
        ]
        let challengeIndexMap = challengeStepIndexMap(for: steps)
        let challengeIdIndexMap = challengeIdStepIndexMap(for: steps)
        let projectIndexMap = projectStepIndexMap(for: steps)
        let allChallengeIdMap = Dictionary(uniqueKeysWithValues: [challengeOne, challengeTwo].map {
            ($0.progressId.lowercased(), $0)
        })
        let allChallengeNumberMap = Dictionary(uniqueKeysWithValues: [challengeOne, challengeTwo].map {
            ($0.number, $0)
        })

        let projectOutcome = remapProgressToken(
            "project:core1a",
            challengeIndexMap: challengeIndexMap,
            challengeIdIndexMap: challengeIdIndexMap,
            allChallengeIdMap: allChallengeIdMap,
            allChallengeNumberMap: allChallengeNumberMap,
            projectIndexMap: projectIndexMap,
            projects: [project],
            stepsCount: steps.count
        )

        switch projectOutcome {
        case .success(let startIndex, _):
            XCTAssertEqual(startIndex, 2)
        default:
            XCTFail("Expected project remap success")
        }

        let stepOutcome = remapProgressToken(
            "step:999",
            challengeIndexMap: challengeIndexMap,
            challengeIdIndexMap: challengeIdIndexMap,
            allChallengeIdMap: allChallengeIdMap,
            allChallengeNumberMap: allChallengeNumberMap,
            projectIndexMap: projectIndexMap,
            projects: [project],
            stepsCount: steps.count
        )

        switch stepOutcome {
        case .success(let startIndex, _):
            XCTAssertEqual(startIndex, steps.count + 1)
        default:
            XCTFail("Expected step remap success")
        }

        let challengeOutcome = remapProgressToken(
            "challenge:2",
            challengeIndexMap: challengeIndexMap,
            challengeIdIndexMap: challengeIdIndexMap,
            allChallengeIdMap: allChallengeIdMap,
            allChallengeNumberMap: allChallengeNumberMap,
            projectIndexMap: projectIndexMap,
            projects: [project],
            stepsCount: steps.count
        )

        switch challengeOutcome {
        case .success(let startIndex, _):
            XCTAssertEqual(startIndex, 4)
        default:
            XCTFail("Expected challenge remap success")
        }
    }

    func testCurriculumIntegrity() {
        let core1 = makeCore1Challenges()
        let core2 = makeCore2Challenges()
        let core3 = makeCore3Challenges()
        let mantle = makeMantleChallenges()
        let crust = makeCrustChallenges()
        let bridge = makeBridgeChallenges()
        let allChallenges = core1 + core2 + core3 + mantle + crust + bridge.coreToMantle + bridge.mantleToCrust

        let numbers = allChallenges.map { $0.number }
        XCTAssertEqual(numbers.count, Set(numbers).count, "Duplicate challenge numbers found.")

        let progressIds = allChallenges.map { $0.progressId.lowercased() }
        XCTAssertEqual(progressIds.count, Set(progressIds).count, "Duplicate challenge progress ids found.")

        let maxNumber = numbers.max() ?? 0
        let numberSet = Set(numbers)
        for number in 1...maxNumber {
            XCTAssertTrue(numberSet.contains(number), "Missing challenge number \(number).")
        }

        let introIndex = buildConstraintIndex(from: allChallenges)
        for challenge in allChallenges {
            for concept in challenge.requires {
                let introNumber = introductionNumber(for: concept, index: introIndex)
                XCTAssertNotEqual(introNumber, Int.max, "No introduction found for \(concept).")
            }
        }
    }

    func testCurriculumResourcesAvailable() {
        let core1 = makeCore1Challenges()
        let core2 = makeCore2Challenges()
        let core3 = makeCore3Challenges()
        let mantle = makeMantleChallenges()
        let crust = makeCrustChallenges()
        let bridge = makeBridgeChallenges()
        let projects = makeProjects()

        XCTAssertFalse(core1.isEmpty)
        XCTAssertFalse(core2.isEmpty)
        XCTAssertFalse(core3.isEmpty)
        XCTAssertFalse(mantle.isEmpty)
        XCTAssertFalse(crust.isEmpty)
        XCTAssertFalse(bridge.coreToMantle.isEmpty)
        XCTAssertFalse(bridge.mantleToCrust.isEmpty)
        XCTAssertFalse(projects.isEmpty)

        XCTAssertEqual(core1.first?.number, 1)
        XCTAssertEqual(core2.first?.number, 21)
        XCTAssertEqual(core3.first?.number, 43)
        XCTAssertEqual(projects.first?.id, "core1a")
    }

    func testCanonicalChallengeIdsUnique() {
        let sets = buildChallengeSets()
        let ids = sets.allChallenges.map { $0.displayId.lowercased() }
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate canonical challenge ids found.")
    }

    func testParseGateSettingsAndRemaining() {
        let args = ["--gate-passes", "2", "--gate-count", "5", "random", "adaptive"]
        let parsed = parseGateSettings(args)
        XCTAssertEqual(parsed.passes, 2)
        XCTAssertEqual(parsed.count, 5)
        XCTAssertEqual(parsed.remaining, ["random", "adaptive"])
    }

    func testParseGlobalFlagsPipeline() {
        let parsed = parseGlobalFlags([
            "--gate-passes", "2",
            "--gate-count", "4",
            "--disable-constraint-profiles",
            "--adaptive-on",
            "--adaptive-threshold", "5",
            "--adaptive-count", "6",
            "--adaptive-topic-failures", "3",
            "--adaptive-challenge-failures", "4",
            "--adaptive-cooldown", "1",
            "--confirm-check",
            "--confirm-solution",
            "practice",
            "loops",
        ])

        XCTAssertEqual(parsed.flags.gatePasses, 2)
        XCTAssertEqual(parsed.flags.gateCount, 4)
        XCTAssertFalse(parsed.flags.enableConstraintProfiles)
        XCTAssertTrue(parsed.flags.adaptiveEnabled)
        XCTAssertEqual(parsed.flags.adaptiveThreshold, 5)
        XCTAssertEqual(parsed.flags.adaptiveCount, 6)
        XCTAssertEqual(parsed.flags.adaptiveMinTopicFailures, 3)
        XCTAssertEqual(parsed.flags.adaptiveMinChallengeFailures, 4)
        XCTAssertEqual(parsed.flags.adaptiveCooldownSteps, 1)
        XCTAssertTrue(parsed.flags.confirmCheckEnabled)
        XCTAssertTrue(parsed.flags.confirmSolutionEnabled)
        XCTAssertEqual(parsed.remaining, ["practice", "loops"])
    }

    func testParseTopLevelCommandRecognizesCommandsAndRunOverride() {
        switch parseTopLevelCommand(["stats"]) {
        case .stats(let args):
            XCTAssertTrue(args.isEmpty)
        default:
            XCTFail("Expected stats command")
        }

        switch parseTopLevelCommand(["verify", "core", "--constraints-only"]) {
        case .verify(let args):
            XCTAssertEqual(args, ["core", "--constraints-only"])
        default:
            XCTFail("Expected verify command")
        }

        switch parseTopLevelCommand(["project", "--list"]) {
        case .project(let args):
            XCTAssertEqual(args, ["--list"])
        default:
            XCTFail("Expected project command")
        }

        switch parseTopLevelCommand(["ai-generate", "--dry-run"]) {
        case .aiGenerate(let args):
            XCTAssertEqual(args, ["--dry-run"])
        default:
            XCTFail("Expected ai-generate command")
        }

        switch parseTopLevelCommand(["ai-verify", "workspace_verify/ai_candidates/candidate.json"]) {
        case .aiVerify(let args):
            XCTAssertEqual(args, ["workspace_verify/ai_candidates/candidate.json"])
        default:
            XCTFail("Expected ai-verify command")
        }

        switch parseTopLevelCommand(["ai-promote", "--target", "Sources/forge/Curriculum/core3_challenges.json"]) {
        case .aiPromote(let args):
            XCTAssertEqual(args, ["--target", "Sources/forge/Curriculum/core3_challenges.json"])
        default:
            XCTFail("Expected ai-promote command")
        }

        switch parseTopLevelCommand(["challenge:core:36"]) {
        case .run(let overrideToken):
            XCTAssertEqual(overrideToken, "challenge:core:36")
        default:
            XCTFail("Expected run override token")
        }

        switch parseTopLevelCommand(["--help"]) {
        case .help:
            break
        default:
            XCTFail("Expected help command")
        }
    }

    func testBootstrapRuntimeWritesCatalogFiles() {
        let fileManager = FileManager.default
        let originalCwd = fileManager.currentDirectoryPath
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer {
                _ = fileManager.changeCurrentDirectoryPath(originalCwd)
                try? fileManager.removeItem(at: tempDir)
            }

            XCTAssertTrue(fileManager.changeCurrentDirectoryPath(tempDir.path))

            _ = bootstrapRuntime(gatePasses: 1, gateCount: 3)

            XCTAssertTrue(fileManager.fileExists(atPath: tempDir.appendingPathComponent("challenge_catalog.txt").path))
            XCTAssertTrue(fileManager.fileExists(atPath: tempDir.appendingPathComponent("project_catalog.txt").path))
        } catch {
            XCTFail("Failed to set up temp workspace: \(error)")
        }
    }

    func testParseConstraintSettingsFlags() {
        let args = ["--allow-early-concepts", "--disable-constraint-profiles", "--disable-di-mock-heuristics", "extra"]
        let parsed = parseConstraintSettings(args)
        XCTAssertFalse(parsed.enforce)
        XCTAssertFalse(parsed.enableConstraintProfiles)
        XCTAssertFalse(parsed.enableDiMockHeuristics)
        XCTAssertEqual(parsed.remaining, ["extra"])
    }

    func testParseAdaptiveSettingsToggleOrder() {
        let args = ["--adaptive-on", "--adaptive-threshold", "5"]
        let parsed = parseAdaptiveSettings(args)
        XCTAssertTrue(parsed.enabled)
        XCTAssertEqual(parsed.threshold, 5)
    }

    func testParseConfirmSettingsAndRemaining() {
        let args = ["--confirm-check", "random", "--confirm-solution"]
        let parsed = parseConfirmSettings(args)
        XCTAssertTrue(parsed.enabled)
        XCTAssertTrue(parsed.confirmSolution)
        XCTAssertEqual(parsed.remaining, ["random"])
    }

    func testEnforceAdaptiveConfirmPolicy() {
        XCTAssertTrue(enforceAdaptiveConfirmPolicy(adaptiveEnabled: true, confirmSolutionEnabled: false))
        XCTAssertTrue(enforceAdaptiveConfirmPolicy(adaptiveEnabled: true, confirmSolutionEnabled: true))
        XCTAssertFalse(enforceAdaptiveConfirmPolicy(adaptiveEnabled: false, confirmSolutionEnabled: false))
        XCTAssertTrue(enforceAdaptiveConfirmPolicy(adaptiveEnabled: false, confirmSolutionEnabled: true))
    }

    func testParseRandomArgumentsAdaptiveAndFilters() {
        let parsed = parseRandomArguments(["10", "adaptive", "loops", "extra", "mantle", "bridge"])
        XCTAssertEqual(parsed.count, 10)
        XCTAssertTrue(parsed.adaptive)
        XCTAssertTrue(parsed.bridge)
        XCTAssertEqual(parsed.topic, .loops)
        XCTAssertEqual(parsed.tier, .extra)
        XCTAssertEqual(parsed.layer, .mantle)
    }

    func testParsePracticeArgumentsRangeAndAll() {
        let parsed = parsePracticeArguments(["core2", "optionals", "--all", "12", "bridge"])
        XCTAssertEqual(parsed.count, 12)
        XCTAssertEqual(parsed.topic, .optionals)
        XCTAssertEqual(parsed.layer, .core)
        XCTAssertEqual(parsed.range, 21...42)
        XCTAssertTrue(parsed.includeAll)
        XCTAssertTrue(parsed.bridge)
    }

    func testParseFlagPipelineRemainders() {
        let args = [
            "--gate-passes", "2",
            "--disable-constraint-profiles",
            "--adaptive-on",
            "--confirm-check",
            "random",
            "adaptive"
        ]
        let gateParsed = parseGateSettings(args)
        let constraintParsed = parseConstraintSettings(gateParsed.remaining)
        let adaptiveParsed = parseAdaptiveSettings(constraintParsed.remaining)
        let confirmParsed = parseConfirmSettings(adaptiveParsed.remaining)

        XCTAssertEqual(gateParsed.passes, 2)
        XCTAssertFalse(constraintParsed.enableConstraintProfiles)
        XCTAssertTrue(adaptiveParsed.enabled)
        XCTAssertTrue(confirmParsed.enabled)
        XCTAssertEqual(confirmParsed.remaining, ["random", "adaptive"])
    }

    func testParseVerifySettingsAndArguments() {
        let settings = parseVerifySettings(["--constraints-only", "10-12", "loops", "extra", "mantle"])
        XCTAssertTrue(settings.constraintsOnly)
        XCTAssertEqual(settings.remaining, ["10-12", "loops", "extra", "mantle"])

        let parsed = parseVerifyArguments(settings.remaining)
        XCTAssertEqual(parsed.range, 10...12)
        XCTAssertEqual(parsed.topic, .loops)
        XCTAssertEqual(parsed.tier, .extra)
        XCTAssertEqual(parsed.layer, .mantle)
    }

    func testParseVerifyArgumentsSingleNumber() {
        let parsed = parseVerifyArguments(["42"])
        XCTAssertEqual(parsed.range, 42...42)
    }

    func testParseStatsSettings() {
        let parsed = parseStatsSettings(["--reset", "--stats-limit", "5"])
        XCTAssertTrue(parsed.reset)
        XCTAssertFalse(parsed.resetAll)
        XCTAssertEqual(parsed.limit, 5)

        let parsedResetAll = parseStatsSettings(["--reset-all"])
        XCTAssertTrue(parsedResetAll.resetAll)
        XCTAssertFalse(parsedResetAll.reset)
    }

    func testParseAIGenerateSettingsDefaults() {
        let parsed = parseAIGenerateSettings([])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-generate settings")
            return
        }
        XCTAssertFalse(settings.live)
        XCTAssertFalse(settings.dryRun)
        XCTAssertEqual(settings.provider, "ollama")
        XCTAssertNil(settings.model)
        XCTAssertEqual(settings.outputPath, "workspace_verify/ai_candidates")
    }

    func testParseAIGenerateSettingsCustomFlags() {
        let parsed = parseAIGenerateSettings([
            "--dry-run",
            "--provider", "phi",
            "--model", "Phi-4-mini-instruct",
            "--out", "workspace_verify/custom_candidates",
        ])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-generate settings")
            return
        }
        XCTAssertFalse(settings.live)
        XCTAssertTrue(settings.dryRun)
        XCTAssertEqual(settings.provider, "phi")
        XCTAssertEqual(settings.model, "Phi-4-mini-instruct")
        XCTAssertEqual(settings.outputPath, "workspace_verify/custom_candidates")
    }

    func testParseAIGenerateSettingsLiveFlag() {
        let parsed = parseAIGenerateSettings(["--live", "--provider", "phi"])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-generate settings")
            return
        }
        XCTAssertTrue(settings.live)
        XCTAssertFalse(settings.dryRun)
    }

    func testParseAIGenerateSettingsLocalShortcut() {
        let parsed = parseAIGenerateSettings(["--local"])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-generate settings")
            return
        }
        XCTAssertTrue(settings.live)
        XCTAssertEqual(settings.provider, "ollama")
    }

    func testParseAIGenerateSettingsRejectsLocalWithNonOllamaProvider() {
        let parsed = parseAIGenerateSettings(["--local", "--provider", "phi"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Use --local with provider ollama only.")
    }

    func testParseAIGenerateSettingsUnknownOption() {
        let parsed = parseAIGenerateSettings(["--unknown"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Unknown ai-generate option: --unknown")
    }

    func testParseAIGenerateSettingsMissingValue() {
        let parsed = parseAIGenerateSettings(["--model"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Missing value for --model")
    }

    func testParseAIGenerateSettingsRejectsLiveAndDryRunTogether() {
        let parsed = parseAIGenerateSettings(["--live", "--dry-run"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Use either --dry-run or --live, not both.")
    }

    func testParseAIVerifySettingsDefaults() {
        let parsed = parseAIVerifySettings([])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-verify settings")
            return
        }
        XCTAssertEqual(settings.candidatePath, "workspace_verify/ai_candidates/candidate.json")
        XCTAssertFalse(settings.constraintsOnly)
        XCTAssertFalse(settings.compileOnly)
    }

    func testParseAIVerifySettingsCustomPathAndFlags() {
        let parsed = parseAIVerifySettings(["workspace_verify/custom/candidate.json", "--compile-only"])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-verify settings")
            return
        }
        XCTAssertEqual(settings.candidatePath, "workspace_verify/custom/candidate.json")
        XCTAssertFalse(settings.constraintsOnly)
        XCTAssertTrue(settings.compileOnly)
    }

    func testParseAIVerifySettingsRejectsConflictingFlags() {
        let parsed = parseAIVerifySettings(["--constraints-only", "--compile-only"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Use either --constraints-only or --compile-only, not both.")
    }

    func testParseAIVerifySettingsRejectsUnknownOption() {
        let parsed = parseAIVerifySettings(["--unknown"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Unknown ai-verify option: --unknown")
    }

    func testParseAIPromoteSettingsDefaults() {
        let parsed = parseAIPromoteSettings(["--target", "Sources/forge/Curriculum/core3_challenges.json"])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-promote settings")
            return
        }
        XCTAssertEqual(settings.candidatePath, "workspace_verify/ai_candidates/candidate.json")
        XCTAssertEqual(settings.reportPath, "workspace_verify/ai_candidates/report.json")
        XCTAssertEqual(settings.targetPath, "Sources/forge/Curriculum/core3_challenges.json")
        XCTAssertNil(settings.bridgeSection)
    }

    func testParseAIPromoteSettingsCustomValues() {
        let parsed = parseAIPromoteSettings([
            "workspace_verify/custom/candidate.json",
            "--report", "workspace_verify/custom/report.json",
            "--target", "Sources/forge/Curriculum/bridge_challenges.json",
            "--bridge-section", "core-to-mantle",
        ])
        XCTAssertNil(parsed.error)
        guard let settings = parsed.settings else {
            XCTFail("Expected ai-promote settings")
            return
        }
        XCTAssertEqual(settings.candidatePath, "workspace_verify/custom/candidate.json")
        XCTAssertEqual(settings.reportPath, "workspace_verify/custom/report.json")
        XCTAssertEqual(settings.targetPath, "Sources/forge/Curriculum/bridge_challenges.json")
        XCTAssertEqual(settings.bridgeSection, .coreToMantle)
    }

    func testParseAIPromoteSettingsRequiresTarget() {
        let parsed = parseAIPromoteSettings([])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "ai-promote requires --target <path>.")
    }

    func testParseAIPromoteSettingsRejectsUnknownOption() {
        let parsed = parseAIPromoteSettings(["--target", "file.json", "--unknown"])
        XCTAssertNil(parsed.settings)
        XCTAssertEqual(parsed.error, "Unknown ai-promote option: --unknown")
    }

    func testRunAIGenerateScaffoldWritesArtifacts() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let outputPath = tempDir.appendingPathComponent("ai_candidates").path
            let settings = AIGenerateSettings(
                live: false,
                dryRun: true,
                provider: "phi",
                model: "Phi-4-mini-instruct",
                outputPath: outputPath
            )
            let result = try runAIGenerateScaffold(settings: settings)

            XCTAssertTrue(FileManager.default.fileExists(atPath: result.requestPath))
            XCTAssertTrue(FileManager.default.fileExists(atPath: result.candidatePath))
            XCTAssertTrue(FileManager.default.fileExists(atPath: result.reportPath))

            let reportData = try Data(contentsOf: URL(fileURLWithPath: result.reportPath))
            let report = try JSONDecoder().decode(AIGenerationReportArtifact.self, from: reportData)
            XCTAssertEqual(report.status, "dry_run_scaffold")
            XCTAssertEqual(report.provider, "phi")
            XCTAssertEqual(report.model, "Phi-4-mini-instruct")
            XCTAssertFalse(report.live)
            XCTAssertTrue(report.dryRun)
        } catch {
            XCTFail("Failed to run ai-generate scaffold: \(error)")
        }
    }

    func testRunAIGenerateScaffoldRejectsUnknownProvider() {
        let settings = AIGenerateSettings(
            live: false,
            dryRun: true,
            provider: "unknown",
            model: nil,
            outputPath: "workspace_verify/invalid_provider"
        )

        XCTAssertThrowsError(try runAIGenerateScaffold(settings: settings))
    }

    func testLoadAIDraftFromCandidateFileSupportsWrappedArtifact() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let path = tempDir.appendingPathComponent("candidate.json").path
            let wrapped = AIGeneratedCandidateArtifact(
                schemaVersion: 1,
                generatedAt: "2026-02-12T00:00:00Z",
                provider: "phi",
                model: nil,
                mode: "scaffold",
                challenge: AIChallengeDraft(
                    id: "wrapped-id",
                    title: "Wrapped Draft",
                    description: "desc",
                    starterCode: "print(\"Hi\")",
                    solution: "print(\"Hi\")",
                    expectedOutput: "Hi",
                    hints: ["hint 1", "hint 2"],
                    topic: "general",
                    tier: "mainline",
                    layer: "core"
                )
            )
            try writeJSONArtifact(wrapped, to: path)

            let draft = try loadAIDraftFromCandidateFile(path)
            XCTAssertEqual(draft.id, "wrapped-id")
            XCTAssertEqual(draft.title, "Wrapped Draft")
        } catch {
            XCTFail("Failed wrapped candidate decode: \(error)")
        }
    }

    func testLoadAIDraftFromCandidateFileSupportsRawDraft() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let path = tempDir.appendingPathComponent("candidate_raw.json").path
            let draft = AIChallengeDraft(
                id: "raw-id",
                title: "Raw Draft",
                description: "desc",
                starterCode: "print(\"Ready\")",
                solution: "print(\"Ready\")",
                expectedOutput: "Ready",
                hints: ["hint 1", "hint 2"],
                topic: "general",
                tier: "mainline",
                layer: "core"
            )
            try writeJSONArtifact(draft, to: path)

            let loaded = try loadAIDraftFromCandidateFile(path)
            XCTAssertEqual(loaded.id, "raw-id")
            XCTAssertEqual(loaded.title, "Raw Draft")
        } catch {
            XCTFail("Failed raw draft decode: \(error)")
        }
    }

    func testRunAIGenerateScaffoldLiveFallsBackWhenMissingConfig() {
        let settings = AIGenerateSettings(
            live: true,
            dryRun: false,
            provider: "phi",
            model: nil,
            outputPath: "workspace_verify/live_mode_fallback"
        )
        do {
            let result = try runAIGenerateScaffold(settings: settings, environment: [:])
            XCTAssertEqual(result.status, "live_fallback_scaffold")
            XCTAssertTrue(result.warnings.contains { $0.contains("Live provider call failed:") })
        } catch {
            XCTFail("Expected fallback result, but got error: \(error)")
        }
    }

    func testRunAIGenerateScaffoldLiveSuccessWithStubTransport() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let outputPath = tempDir.appendingPathComponent("ai_candidates_live").path
            let settings = AIGenerateSettings(
                live: true,
                dryRun: false,
                provider: "phi",
                model: nil,
                outputPath: outputPath
            )
            let env: [String: String] = [
                "FORGE_AI_PHI_ENDPOINT": "https://example.com/v1",
                "FORGE_AI_PHI_API_KEY": "test-key",
                "FORGE_AI_PHI_MODEL": "phi-live-test",
            ]

            let transport: PhiHTTPTransport = { request in
                XCTAssertEqual(request.httpMethod, "POST")
                let body = """
                {
                  "choices": [
                    {
                      "message": {
                        "content": "{\\"id\\":\\"live-id\\",\\"title\\":\\"Live Draft\\",\\"description\\":\\"Live description\\",\\"starterCode\\":\\"print(\\\\\\"Ready\\\\\\")\\",\\"expectedOutput\\":\\"Ready\\",\\"hints\\":[\\"Use print.\\",\\"Match output exactly.\\"],\\"topic\\":\\"general\\",\\"tier\\":\\"mainline\\",\\"layer\\":\\"core\\"}"
                      }
                    }
                  ]
                }
                """
                let data = Data(body.utf8)
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/v1/chat/completions")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }

            let result = try runAIGenerateScaffold(settings: settings, environment: env, transport: transport)
            XCTAssertEqual(result.status, "live_success")
            XCTAssertEqual(result.warnings.count, 0)

            let candidateData = try Data(contentsOf: URL(fileURLWithPath: result.candidatePath))
            let candidate = try JSONDecoder().decode(AIGeneratedCandidateArtifact.self, from: candidateData)
            XCTAssertEqual(candidate.mode, "live")
            XCTAssertEqual(candidate.challenge.id, "live-id")
            XCTAssertEqual(candidate.challenge.title, "Live Draft")
        } catch {
            XCTFail("Expected live success, but got error: \(error)")
        }
    }

    func testRunAIGenerateScaffoldLiveSuccessWithOllamaStubWithoutAPIKey() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let outputPath = tempDir.appendingPathComponent("ai_candidates_ollama_live").path
            let settings = AIGenerateSettings(
                live: true,
                dryRun: false,
                provider: "ollama",
                model: nil,
                outputPath: outputPath
            )
            let env: [String: String] = [
                "FORGE_AI_OLLAMA_ENDPOINT": "http://127.0.0.1:11434/v1",
                "FORGE_AI_OLLAMA_MODEL": "ollama-local-test",
            ]

            let transport: PhiHTTPTransport = { request in
                XCTAssertEqual(request.httpMethod, "POST")
                XCTAssertEqual(request.url?.absoluteString, "http://127.0.0.1:11434/v1/chat/completions")
                XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
                let body = """
                {
                  "choices": [
                    {
                      "message": {
                        "content": "{\\"id\\":\\"ollama-live-id\\",\\"title\\":\\"Ollama Live Draft\\",\\"description\\":\\"Live description\\",\\"starterCode\\":\\"print(\\\\\\"Ready\\\\\\")\\",\\"expectedOutput\\":\\"Ready\\",\\"hints\\":[\\"Use print.\\",\\"Match output exactly.\\"],\\"topic\\":\\"general\\",\\"tier\\":\\"mainline\\",\\"layer\\":\\"core\\"}"
                      }
                    }
                  ]
                }
                """
                let data = Data(body.utf8)
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "http://127.0.0.1:11434/v1/chat/completions")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }

            let result = try runAIGenerateScaffold(settings: settings, environment: env, transport: transport)
            XCTAssertEqual(result.status, "live_success")

            let candidateData = try Data(contentsOf: URL(fileURLWithPath: result.candidatePath))
            let candidate = try JSONDecoder().decode(AIGeneratedCandidateArtifact.self, from: candidateData)
            XCTAssertEqual(candidate.mode, "live")
            XCTAssertEqual(candidate.challenge.id, "ollama-live-id")
            XCTAssertEqual(candidate.challenge.title, "Ollama Live Draft")
        } catch {
            XCTFail("Expected local ollama live success, but got error: \(error)")
        }
    }

    func testNormalizeAIDraftFixesCommonLocalModelIssues() {
        let draft = AIChallengeDraft(
            id: "001",
            title: "Hello",
            description: "desc",
            starterCode: "# TODO: Print output",
            solution: "import Foundation\nprint(\"Hello\")\n# End of solution",
            expectedOutput: "\"Hello\"",
            hints: ["Use print", "Don't forget to import Foundation"],
            topic: "core",
            tier: "mainline",
            layer: "crust"
        )

        let normalized = normalizeAIDraft(draft)
        XCTAssertEqual(normalized.draft.topic, "general")
        XCTAssertEqual(normalized.draft.expectedOutput, "Hello")
        XCTAssertTrue(normalized.draft.starterCode.contains("// TODO:"))
        XCTAssertFalse(normalized.draft.solution?.contains("import Foundation") ?? false)
        XCTAssertFalse(normalized.draft.hints.joined(separator: " ").contains("import Foundation"))
        XCTAssertTrue(normalized.warnings.contains { $0.contains("Topic") || $0.contains("topic") })
    }

    func testRunAIGenerateScaffoldLiveNormalizesInvalidTopicFromLocalModel() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let outputPath = tempDir.appendingPathComponent("ai_candidates_live_normalized").path
            let settings = AIGenerateSettings(
                live: true,
                dryRun: false,
                provider: "ollama",
                model: "phi4-mini:latest",
                outputPath: outputPath
            )
            let env: [String: String] = [
                "FORGE_AI_OLLAMA_ENDPOINT": "http://127.0.0.1:11434/v1",
            ]

            let transport: PhiHTTPTransport = { request in
                let body = """
                {
                  "choices": [
                    {
                      "message": {
                        "content": "{\\"id\\":\\"local-id\\",\\"title\\":\\"Local Draft\\",\\"description\\":\\"desc\\",\\"starterCode\\":\\"# TODO: Print \\\\\\"Hello\\\\\\"\\",\\"solution\\":\\"import Foundation\\\\nprint(\\\\\\"Hello\\\\\\")\\",\\"expectedOutput\\":\\"\\\\\\"Hello\\\\\\"\\",\\"hints\\":[\\"Use print\\",\\"Don't forget to import Foundation\\"],\\"topic\\":\\"core\\",\\"tier\\":\\"mainline\\",\\"layer\\":\\"core\\"}"
                      }
                    }
                  ]
                }
                """
                let data = Data(body.utf8)
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "http://127.0.0.1:11434/v1/chat/completions")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }

            let result = try runAIGenerateScaffold(settings: settings, environment: env, transport: transport)
            XCTAssertEqual(result.status, "live_success")
            XCTAssertTrue(result.warnings.contains { $0.contains("defaulted topic to 'general'") })

            let candidateData = try Data(contentsOf: URL(fileURLWithPath: result.candidatePath))
            let candidate = try JSONDecoder().decode(AIGeneratedCandidateArtifact.self, from: candidateData)
            XCTAssertEqual(candidate.challenge.topic, "general")
            XCTAssertEqual(candidate.challenge.expectedOutput, "Hello")
            XCTAssertTrue(candidate.challenge.starterCode.contains("// TODO:"))
        } catch {
            XCTFail("Expected normalization success, but got error: \(error)")
        }
    }

    func testRunAIGenerateScaffoldLiveSupportsLenientDraftShapeFromLocalModel() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }

            let outputPath = tempDir.appendingPathComponent("ai_candidates_live_lenient").path
            let settings = AIGenerateSettings(
                live: true,
                dryRun: false,
                provider: "ollama",
                model: "phi4-mini:latest",
                outputPath: outputPath
            )
            let env: [String: String] = [
                "FORGE_AI_OLLAMA_ENDPOINT": "http://127.0.0.1:11434/v1",
            ]

            let transport: PhiHTTPTransport = { request in
                let body = """
                {
                  "choices": [
                    {
                      "message": {
                        "content": "{\\"challenge\\":{\\"challenge_id\\":\\"x-1\\",\\"name\\":\\"Lenient Draft\\",\\"prompt\\":\\"desc\\",\\"starter_code\\":\\"# TODO: Print \\\\\\"Hello\\\\\\"\\",\\"answer\\":\\"import Foundation\\\\nprint(\\\\\\"Hello\\\\\\")\\",\\"expected_output\\":\\"\\\\\\"Hello\\\\\\"\\",\\"hints\\":\\"Use print\\\\nMatch exact output\\",\\"concept\\":\\"core\\",\\"difficulty_tier\\":\\"mainline\\",\\"stage\\":\\"core\\"}}"
                      }
                    }
                  ]
                }
                """
                let data = Data(body.utf8)
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "http://127.0.0.1:11434/v1/chat/completions")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (data, response)
            }

            let result = try runAIGenerateScaffold(settings: settings, environment: env, transport: transport)
            XCTAssertEqual(result.status, "live_success")

            let candidateData = try Data(contentsOf: URL(fileURLWithPath: result.candidatePath))
            let candidate = try JSONDecoder().decode(AIGeneratedCandidateArtifact.self, from: candidateData)
            XCTAssertEqual(candidate.challenge.id, "x-1")
            XCTAssertEqual(candidate.challenge.title, "Lenient Draft")
            XCTAssertEqual(candidate.challenge.topic, "general")
            XCTAssertTrue(candidate.challenge.starterCode.contains("// TODO:"))
            XCTAssertEqual(candidate.challenge.expectedOutput, "Hello")
        } catch {
            XCTFail("Expected lenient local decode success, but got error: \(error)")
        }
    }

    func testRunAIPromoteAppendsAndRunsGateCommands() {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer {
                try? fileManager.removeItem(at: tempDir)
            }

            let targetPath = tempDir.appendingPathComponent("target_challenges.json").path
            let existing = [
                Challenge(
                    number: 1,
                    id: "existing-ai-promote-test",
                    title: "Existing",
                    description: "desc",
                    starterCode: "print(\"Existing\")",
                    expectedOutput: "Existing",
                    solution: "print(\"Existing\")",
                    topic: .general,
                    tier: .mainline,
                    layer: .core
                )
            ]
            try encodeJSONFile(existing).write(to: URL(fileURLWithPath: targetPath), options: .atomic)

            let candidatePath = tempDir.appendingPathComponent("candidate.json").path
            let draft = AIChallengeDraft(
                id: "ai-promote-\(UUID().uuidString.lowercased())",
                title: "Promoted Draft",
                description: "Draft description",
                starterCode: "print(\"Promoted\")",
                solution: "print(\"Promoted\")",
                expectedOutput: "Promoted",
                hints: ["h1", "h2"],
                topic: "general",
                tier: "mainline",
                layer: "core"
            )
            try writeJSONArtifact(draft, to: candidatePath)

            let reportPath = tempDir.appendingPathComponent("report.json").path
            let report = AIGenerationReportArtifact(
                schemaVersion: 1,
                generatedAt: "2026-02-12T00:00:00Z",
                status: "live_success",
                provider: "phi",
                model: "Phi-4-mini-instruct",
                live: true,
                dryRun: false,
                requestPath: tempDir.appendingPathComponent("request.json").path,
                candidatePath: candidatePath,
                reportPath: reportPath,
                warnings: []
            )
            try writeJSONArtifact(report, to: reportPath)

            var commands: [[String]] = []
            let settings = AIPromoteSettings(
                candidatePath: candidatePath,
                reportPath: reportPath,
                targetPath: targetPath,
                bridgeSection: nil
            )
            let result = runAIPromote(
                settings: settings,
                commandRunner: { args in
                    commands.append(args)
                    return ("ok", 0)
                },
                verifyRunner: { _, _ in true }
            )

            XCTAssertTrue(result)
            XCTAssertEqual(commands, [
                ["test"],
                ["run", "forge", "verify-solutions", "--constraints-only"],
            ])

            let updatedData = try Data(contentsOf: URL(fileURLWithPath: targetPath))
            let updatedChallenges = try JSONDecoder().decode([Challenge].self, from: updatedData)
            XCTAssertEqual(updatedChallenges.count, 2)
            XCTAssertEqual(updatedChallenges.last?.id, draft.id)
        } catch {
            XCTFail("Failed ai-promote test setup: \(error)")
        }
    }

    func testParseProjectListAndRandomArguments() {
        let listParsed = parseProjectListArguments(["extra", "mantle"])
        XCTAssertEqual(listParsed.tier, .extra)
        XCTAssertEqual(listParsed.layer, .mantle)

        let randomParsed = parseProjectRandomArguments(["mainline", "core"])
        XCTAssertEqual(randomParsed.tier, .mainline)
        XCTAssertEqual(randomParsed.layer, .core)
    }

    func testDiagnosticsDetectMissingOutput() {
        let challenge = Challenge(
            number: 1,
            title: "Output",
            description: "",
            starterCode: "",
            expectedOutput: "Hello\n",
            topic: .general
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "",
            expected: challenge.expectedOutput,
            source: nil
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("No output detected") })
    }

    func testDiagnosticsDetectLineCountMismatch() {
        let challenge = Challenge(
            number: 1,
            title: "Lines",
            description: "",
            starterCode: "",
            expectedOutput: "A\nB",
            topic: .general
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "A",
            expected: challenge.expectedOutput,
            source: nil
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("Line count differs") })
    }

    func testDiagnosticsDetectOptionalPrinting() {
        let challenge = Challenge(
            number: 1,
            title: "Optional",
            description: "",
            starterCode: "",
            expectedOutput: "1",
            topic: .general
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "Optional(1)",
            expected: challenge.expectedOutput,
            source: nil
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("printing an optional") })
    }

    func testDiagnosticsDetectMissingPrintCall() {
        let challenge = Challenge(
            number: 1,
            title: "Print",
            description: "",
            starterCode: "",
            expectedOutput: "Hello",
            topic: .general
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "Hello",
            expected: challenge.expectedOutput,
            source: "let value = \"Hello\""
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("No print(") })
    }

    func testDiagnosticsLoopHint() {
        let challenge = Challenge(
            number: 1,
            title: "Loop",
            description: "Use a loop to print values.",
            starterCode: "",
            expectedOutput: "1\n2\n3",
            introduces: [.forInLoop],
            topic: .loops
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "1\n2\n3",
            expected: challenge.expectedOutput,
            source: "print(1)\nprint(2)\nprint(3)"
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("likely needs a loop") })
    }

    func testDiagnosticsBranchingHint() {
        let challenge = Challenge(
            number: 1,
            title: "Branch",
            description: "Use a conditional.",
            starterCode: "",
            expectedOutput: "Yes",
            introduces: [.ifElse],
            topic: .conditionals
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "Yes",
            expected: challenge.expectedOutput,
            source: "print(\"Yes\")"
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("expects branching") })
    }

    func testDiagnosticsFunctionCallHint() {
        let challenge = Challenge(
            number: 1,
            title: "Function",
            description: "",
            starterCode: "",
            expectedOutput: "Hi",
            topic: .functions
        )
        let context = DiagnosticContext(
            challenge: challenge,
            output: "Hi",
            expected: challenge.expectedOutput,
            source: "func greet() { print(\"Hi\") }"
        )
        let diagnostics = diagnosticsForMismatch(context)
        XCTAssertTrue(diagnostics.contains { $0.contains("may not be called") })
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

    func testFileIODetectorIgnoresNonFileURLUsage() {
        let source = "let endpoint = URL(string: \"https://example.com\")"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertFalse(hasFileIO(tokens))
    }

    func testFileIODetectorDetectsFileURLInitializer() {
        let source = "let fileURL = URL(fileURLWithPath: \"/tmp/forge.txt\")"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertTrue(hasFileIO(tokens))
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

    func testTaskUsageIgnoresTaskTypeDeclaration() {
        let source = "struct Task {}"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertFalse(hasTaskUsage(tokens))
    }

    func testSwiftPMDependenciesDetectorIgnoresVariableNamedPackage() {
        let source = "let package = \"starter\""
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertFalse(hasSwiftPMDependencies(tokens))
    }

    func testSwiftPMDependenciesDetectorDetectsPackageEntry() {
        let source = "let deps: [Package.Dependency] = [.package(url: \"https://example.com/repo\", from: \"1.0.0\")]"
        let tokens = tokenizeSource(stripCommentsAndStrings(from: source))
        XCTAssertTrue(hasSwiftPMDependencies(tokens))
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

    func testFileIOWarningDoesNotTriggerForNetworkURLInitializer() {
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
        let source = "let endpoint = URL(string: \"https://example.com\")"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertFalse(warnings.contains { $0.contains("file IO") })
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

    func testTaskTypeDeclarationDoesNotWarnBeforeIntro() {
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
        let source = "struct Task {}"
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertFalse(warnings.contains { $0.contains("Task") })
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

    func testSwitchCaseWhereClauseDoesNotWarnAsGenerics() {
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
            title: "Early Switch Where",
            description: "",
            starterCode: "",
            expectedOutput: "",
            topic: .general
        )
        let index = buildConstraintIndex(from: [introChallenge, earlyChallenge])
        let source = """
            enum Event {
                case temperature(Int)
                case error(String)
            }

            let event = Event.temperature(1600)
            switch event {
            case .temperature(let temp) where temp >= 1500:
                print("Overheated")
            case .temperature:
                print("Normal")
            case .error:
                print("Error")
            }
            """
        let warnings = constraintWarnings(
            for: source,
            challenge: earlyChallenge,
            index: index,
            enableDiMockHeuristics: true
        )
        XCTAssertFalse(warnings.contains { $0.contains("generics") })
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
