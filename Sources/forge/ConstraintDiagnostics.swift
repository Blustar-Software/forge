import Foundation

func constraintWarnings(
    for source: String,
    challenge: Challenge,
    index: ConstraintIndex,
    enableDiMockHeuristics: Bool
) -> [String] {
    let cleanedSource = stripCommentsAndStrings(from: source)
    let tokens = tokenizeSource(cleanedSource)
    var warnings: [String] = []
    for concept in allConstraintConcepts {
        if !enableDiMockHeuristics && (concept == .dependencyInjection || concept == .protocolMocking) {
            continue
        }
        let introNumber = introductionNumber(for: concept, index: index)
        if challenge.number >= introNumber {
            continue
        }
        if usesConcept(concept, tokens: tokens, source: cleanedSource, rawSource: source) {
            warnings.append("⚠️ Possible early use of \(constraintConceptName(concept)) (introduced in Challenge \(introNumber)).")
        }
    }
    return warnings
}

func constraintViolations(
    for source: String,
    challenge: Challenge,
    enabled: Bool,
    index: ConstraintIndex? = nil
) -> [String] {
    guard enabled else { return [] }
    guard let profile = mergedConstraintProfile(
        base: challenge.constraintProfile,
        topic: topicConstraintProfiles[challenge.topic]
    ) else { return [] }
    let cleanedSource = stripCommentsAndStrings(from: source)
    let tokens = tokenizeSource(cleanedSource)
    var violations: [String] = []

    if !profile.allowedImports.isEmpty {
        let imports = extractImports(from: cleanedSource)
        for item in imports where !profile.allowedImports.contains(item) {
            violations.append("✗ Import not allowed: \(item)")
        }
    }

    for token in profile.disallowedTokens where hasToken(tokens, token) {
        violations.append("✗ Token not allowed: \(token)")
    }

    for token in profile.requiredTokens where !hasToken(tokens, token) {
        violations.append("✗ Required token missing: \(token)")
    }

    if !profile.allowFileIO, hasFileIO(tokens) {
        violations.append("✗ File IO not allowed.")
    }

    if !profile.allowNetwork, hasNetworkUsage(tokens: tokens, source: cleanedSource) {
        violations.append("✗ Network usage not allowed.")
    }

    if !profile.allowConcurrency, hasConcurrencyUsage(tokens: tokens) {
        violations.append("✗ Concurrency not allowed.")
    }

    if let index = index {
        let topicViolations = topicDisallowConceptViolations(
            tokens: tokens,
            source: cleanedSource,
            rawSource: source,
            challenge: challenge,
            index: index
        )
        violations.append(contentsOf: topicViolations)
    }

    if profile.requireOptionalUsage == true, !hasOptionalUsage(tokens) {
        violations.append("✗ Optional usage required.")
    }

    if profile.requireCollectionUsage == true, !hasCollectionUsage(tokens: tokens, source: cleanedSource) {
        violations.append("✗ Collection usage required.")
    }

    if profile.requireClosureUsage == true, !hasClosureUsage(tokens) {
        violations.append("✗ Closure usage required.")
    }

    return violations
}
