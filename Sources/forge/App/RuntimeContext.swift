import Foundation

struct RuntimeContext {
    let sets: ChallengeSets
    let projects: [Project]
    let allChallenges: [Challenge]
    let steps: [Step]
    let constraintIndex: ConstraintIndex
    let challengeIndexMap: [Int: Int]
    let challengeIdIndexMap: [String: Int]
    let allChallengeIdMap: [String: Challenge]
    let allChallengeNumberMap: [Int: Challenge]
    let projectIndexMap: [String: Int]
    let maxChallengeNumber: Int
}

func bootstrapRuntime(gatePasses: Int, gateCount: Int) -> RuntimeContext {
    let sets = buildChallengeSets()
    let projects = makeProjects()
    let allChallenges = sets.allChallenges
    let constraintIndex = buildConstraintIndex(from: allChallenges)

    // Preserve current behavior: keep catalog files refreshed on startup.
    writeChallengeCatalogText(allChallenges, path: "challenge_catalog.txt")
    writeProjectCatalogText(projects, path: "project_catalog.txt")

    let steps = makeSteps(
        core1Challenges: sets.core1Challenges,
        core2Challenges: sets.core2Challenges,
        core3Challenges: sets.core3Challenges,
        mantleChallenges: sets.mantleChallenges,
        crustChallenges: sets.crustChallenges,
        bridgeChallenges: sets.bridgeChallenges,
        projects: projects,
        gatePasses: gatePasses,
        gateCount: gateCount
    )

    let challengeIndexMap = challengeStepIndexMap(for: steps)
    let challengeIdIndexMap = challengeIdStepIndexMap(for: steps)
    let allChallengeIdMap = Dictionary(uniqueKeysWithValues: allChallenges.map { ($0.progressId.lowercased(), $0) })
    let allChallengeNumberMap = Dictionary(uniqueKeysWithValues: allChallenges.map { ($0.number, $0) })
    let projectIndexMap = projectStepIndexMap(for: steps)
    let maxChallengeNumber = max(
        steps.compactMap { step in
            if case .challenge(let challenge) = step { return challenge.number }
            return nil
        }.max() ?? 1,
        1
    )

    let legacyIdMap = legacyChallengeIdMap(for: allChallenges)
    migrateAdaptiveChallengeStatsIfNeeded(legacyIdMap: legacyIdMap)
    migratePendingPracticeIfNeeded(legacyIdMap: legacyIdMap, legacyNumberMap: allChallengeNumberMap)
    migratePerformanceLogIfNeeded(legacyIdMap: legacyIdMap, legacyNumberMap: allChallengeNumberMap)
    migrateProgressTokenIfNeeded(
        token: getProgressToken(),
        steps: steps,
        challengeIndexMap: challengeIndexMap,
        challengeIdIndexMap: challengeIdIndexMap,
        projectIndexMap: projectIndexMap,
        maxChallengeNumber: maxChallengeNumber,
        legacyIdMap: legacyIdMap,
        allChallengeIdMap: allChallengeIdMap,
        allChallengeNumberMap: allChallengeNumberMap
    )

    return RuntimeContext(
        sets: sets,
        projects: projects,
        allChallenges: allChallenges,
        steps: steps,
        constraintIndex: constraintIndex,
        challengeIndexMap: challengeIndexMap,
        challengeIdIndexMap: challengeIdIndexMap,
        allChallengeIdMap: allChallengeIdMap,
        allChallengeNumberMap: allChallengeNumberMap,
        projectIndexMap: projectIndexMap,
        maxChallengeNumber: maxChallengeNumber
    )
}
