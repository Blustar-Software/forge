import Foundation

typealias ConstraintDetector = @Sendable (_ tokens: [String], _ source: String, _ rawSource: String) -> Bool

let constraintConceptDetectors: [(concept: ConstraintConcept, detector: ConstraintDetector)] = [
    (.ifElse, { tokens, _, _ in hasToken(tokens, "if") }),
    (.switchStatement, { tokens, _, _ in hasToken(tokens, "switch") }),
    (.forInLoop, { tokens, _, _ in hasToken(tokens, "for") }),
    (.whileLoop, { tokens, _, _ in hasToken(tokens, "while") }),
    (.repeatWhileLoop, { tokens, _, _ in hasToken(tokens, "repeat") }),
    (.breakContinue, { tokens, _, _ in hasToken(tokens, "break") || hasToken(tokens, "continue") }),
    (.ranges, { tokens, _, _ in hasToken(tokens, "...") || hasToken(tokens, "..<") }),
    (.functionsBasics, { tokens, _, _ in hasToken(tokens, "func") }),
    (.optionals, { tokens, _, _ in hasOptionalUsage(tokens) }),
    (.nilLiteral, { tokens, _, _ in hasToken(tokens, "nil") }),
    (.optionalBinding, { tokens, _, _ in hasSequence(tokens, ["if", "let"]) }),
    (.guardStatement, { tokens, _, _ in hasToken(tokens, "guard") }),
    (.nilCoalescing, { tokens, _, _ in hasToken(tokens, "??") }),
    (.collections, { tokens, source, _ in hasCollectionUsage(tokens: tokens, source: source) }),
    (.closures, { tokens, _, _ in hasClosureToken(tokens) || hasClosureAssignment(tokens) }),
    (.shorthandClosureArgs, { tokens, _, _ in hasShorthandClosureArg(tokens) }),
    (.map, { tokens, _, _ in hasDotMember(tokens, "map") }),
    (.filter, { tokens, _, _ in hasDotMember(tokens, "filter") }),
    (.reduce, { tokens, _, _ in hasDotMember(tokens, "reduce") }),
    (.compactMap, { tokens, _, _ in hasDotMember(tokens, "compactMap") }),
    (.flatMap, { tokens, _, _ in hasDotMember(tokens, "flatMap") }),
    (.typeAlias, { tokens, _, _ in hasToken(tokens, "typealias") }),
    (.enums, { tokens, _, _ in hasToken(tokens, "enum") }),
    (.doCatch, { tokens, _, _ in hasToken(tokens, "do") || hasToken(tokens, "catch") }),
    (.throwKeyword, { tokens, _, _ in hasToken(tokens, "throw") }),
    (.tryKeyword, { tokens, _, _ in hasToken(tokens, "try") }),
    (.tryOptional, { tokens, _, _ in hasTryOptional(tokens) }),
    (.readLine, { tokens, _, _ in hasToken(tokens, "readLine") }),
    (.commandLineArguments, { tokens, _, _ in hasCommandLineArguments(tokens) }),
    (.fileIO, { tokens, _, _ in hasFileIO(tokens) }),
    (.tuples, { tokens, _, _ in hasTupleUsage(tokens) }),
    (.asyncAwait, { tokens, _, _ in hasToken(tokens, "async") || hasToken(tokens, "await") }),
    (.actors, { tokens, _, _ in hasToken(tokens, "actor") }),
    (.propertyWrappers, { tokens, _, _ in hasPropertyWrapperUsage(tokens) }),
    (.protocols, { tokens, _, _ in hasToken(tokens, "protocol") }),
    (.structs, { tokens, _, _ in hasToken(tokens, "struct") }),
    (.classes, { tokens, _, _ in hasToken(tokens, "class") }),
    (.properties, { tokens, _, _ in hasPropertyDeclaration(tokens) }),
    (.initializers, { tokens, _, _ in hasToken(tokens, "init") }),
    (.mutatingMethods, { tokens, _, _ in hasToken(tokens, "mutating") }),
    (.selfKeyword, { tokens, _, _ in hasToken(tokens, "self") }),
    (.extensions, { tokens, _, _ in hasExtensionClause(tokens) }),
    (.whereClauses, { tokens, _, _ in hasWhereClause(tokens) }),
    (.associatedTypes, { tokens, _, _ in hasAssociatedType(tokens) }),
    (.generics, { tokens, _, _ in hasGenericDefinition(tokens) }),
    (.task, { tokens, _, _ in hasTaskUsage(tokens) }),
    (.mainActor, { tokens, _, _ in hasMainActorUsage(tokens) }),
    (.sendable, { tokens, _, _ in hasSendableUsage(tokens) }),
    (.protocolConformance, { tokens, _, _ in hasProtocolConformance(tokens) }),
    (.protocolExtensions, { tokens, _, _ in hasProtocolExtension(tokens) }),
    (.defaultImplementations, { tokens, _, _ in hasProtocolExtension(tokens) && hasToken(tokens, "func") }),
    (.taskSleep, { tokens, _, _ in hasTaskSleepUsage(tokens) }),
    (.taskGroup, { tokens, _, _ in hasTaskGroupUsage(tokens) }),
    (.accessControl, { tokens, _, _ in hasAccessControlKeyword(tokens) }),
    (.accessControlOpen, { tokens, _, _ in hasAccessControlOpen(tokens) }),
    (.accessControlFileprivate, { tokens, _, _ in hasAccessControlFileprivate(tokens) }),
    (.accessControlInternal, { tokens, _, _ in hasAccessControlInternal(tokens) }),
    (.accessControlSetter, { tokens, _, _ in hasAccessControlSetter(tokens) }),
    (.errorTypes, { tokens, _, _ in hasErrorType(tokens) }),
    (.throwingFunctions, { tokens, _, _ in hasThrowingFunction(tokens) }),
    (.doTryCatch, { tokens, _, _ in hasDoTryCatch(tokens) }),
    (.tryForce, { tokens, _, _ in hasTryForce(tokens) }),
    (.resultBuilders, { tokens, _, _ in hasResultBuilder(tokens) }),
    (.macros, { tokens, _, _ in hasMacroUsage(tokens) }),
    (.projectedValues, { tokens, _, _ in hasProjectedValues(tokens) }),
    (.swiftpmBasics, { tokens, _, _ in hasSwiftPMBasics(tokens) }),
    (.swiftpmDependencies, { tokens, _, _ in hasSwiftPMDependencies(tokens) }),
    (.buildConfigs, { tokens, _, _ in hasBuildConfigs(tokens) }),
    (.dependencyInjection, { tokens, _, _ in hasDependencyInjection(tokens) }),
    (.protocolMocking, { tokens, _, _ in hasProtocolMocking(tokens) }),
    (.comparisons, { tokens, _, _ in hasComparisonOperator(tokens) }),
    (.booleanLogic, { tokens, _, _ in hasLogicalOperator(tokens) }),
    (.compoundAssignment, { tokens, _, _ in hasCompoundAssignment(tokens) }),
    (.stringInterpolation, { _, _, rawSource in containsStringInterpolation(in: rawSource) }),
]

let constraintConceptDetectorMap: [ConstraintConcept: ConstraintDetector] = Dictionary(
    uniqueKeysWithValues: constraintConceptDetectors.map { ($0.concept, $0.detector) }
)

let allConstraintConcepts: [ConstraintConcept] = constraintConceptDetectors.map(\.concept)

func usesConcept(_ concept: ConstraintConcept, tokens: [String], source: String, rawSource: String) -> Bool {
    guard let detector = constraintConceptDetectorMap[concept] else {
        return false
    }
    return detector(tokens, source, rawSource)
}

func buildConstraintIndex(from challenges: [Challenge]) -> ConstraintIndex {
    var intro: [ConstraintConcept: Int] = [:]
    for challenge in challenges {
        for concept in challenge.introduces {
            if let existing = intro[concept] {
                intro[concept] = min(existing, challenge.number)
            } else {
                intro[concept] = challenge.number
            }
        }
    }
    return ConstraintIndex(introByConcept: intro, legacyMinByConcept: legacyConstraintMinimums())
}

func introductionNumber(for concept: ConstraintConcept, index: ConstraintIndex) -> Int {
    return index.introByConcept[concept] ?? index.legacyMinByConcept[concept] ?? Int.max
}

func mapDisallowConcepts(for topic: ChallengeTopic) -> [ConstraintConcept] {
    let errorHandlingConcepts: [ConstraintConcept] = [
        .errorTypes,
        .throwingFunctions,
        .throwKeyword,
        .tryKeyword,
        .tryOptional,
        .tryForce,
        .doCatch,
    ]

    switch topic {
    case .collections:
        return [.map, .filter, .reduce, .compactMap, .flatMap, .closures] + errorHandlingConcepts
    case .optionals:
        return [.optionalBinding, .guardStatement, .nilCoalescing] + errorHandlingConcepts
    case .functions:
        return [.closures, .shorthandClosureArgs] + errorHandlingConcepts
    case .strings:
        return [.stringInterpolation, .map, .filter, .reduce, .compactMap, .flatMap] + errorHandlingConcepts
    case .conditionals:
        return [.switchStatement, .breakContinue, .ranges] + errorHandlingConcepts
    case .loops:
        return [.forInLoop, .whileLoop, .repeatWhileLoop, .breakContinue, .ranges] + errorHandlingConcepts
    case .structs,
         .classes,
         .properties,
         .protocols,
         .extensions,
         .accessControl,
         .errors,
         .generics,
         .memory,
         .concurrency,
         .actors,
         .keyPaths,
         .sequences,
         .propertyWrappers,
         .macros,
         .swiftpm,
         .testing,
         .interop,
         .performance,
         .advancedFeatures,
         .general:
        return errorHandlingConcepts
    }
}

func topicDisallowConceptViolations(
    tokens: [String],
    source: String,
    rawSource: String,
    challenge: Challenge,
    index: ConstraintIndex
) -> [String] {
    let concepts = Set(mapDisallowConcepts(for: challenge.topic))
    guard !concepts.isEmpty else { return [] }
    var violations: [String] = []

    for concept in concepts {
        let introNumber = introductionNumber(for: concept, index: index)
        if challenge.number < introNumber,
           usesConcept(concept, tokens: tokens, source: source, rawSource: rawSource) {
            violations.append("✗ Uses \(constraintConceptName(concept)) before Challenge \(introNumber).")
        }
    }

    return violations
}

func extractImports(from source: String) -> [String] {
    var imports: [String] = []
    for line in source.components(separatedBy: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("import ") else { continue }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2 {
            imports.append(String(parts[1]))
        }
    }
    return imports
}


func mergedConstraintProfile(
    base: ConstraintProfile?,
    topic: ConstraintProfile?
) -> ConstraintProfile? {
    guard base != nil || topic != nil else { return nil }
    let baseProfile = base ?? ConstraintProfile()
    let topicProfile = topic ?? ConstraintProfile()

    func mergedTokens(_ first: [String], _ second: [String]) -> [String] {
        var seen = Set<String>()
        var merged: [String] = []
        for token in first + second where !seen.contains(token) {
            seen.insert(token)
            merged.append(token)
        }
        return merged
    }

    return ConstraintProfile(
        allowedImports: mergedTokens(baseProfile.allowedImports, topicProfile.allowedImports),
        disallowedTokens: mergedTokens(baseProfile.disallowedTokens, topicProfile.disallowedTokens),
        requiredTokens: mergedTokens(baseProfile.requiredTokens, topicProfile.requiredTokens),
        allowFileIO: baseProfile.allowFileIO && topicProfile.allowFileIO,
        allowNetwork: baseProfile.allowNetwork && topicProfile.allowNetwork,
        allowConcurrency: baseProfile.allowConcurrency && topicProfile.allowConcurrency,
        maxRuntimeMs: baseProfile.maxRuntimeMs ?? topicProfile.maxRuntimeMs,
        requireOptionalUsage: baseProfile.requireOptionalUsage ?? topicProfile.requireOptionalUsage,
        requireCollectionUsage: baseProfile.requireCollectionUsage ?? topicProfile.requireCollectionUsage,
        requireClosureUsage: baseProfile.requireClosureUsage ?? topicProfile.requireClosureUsage
    )
}
