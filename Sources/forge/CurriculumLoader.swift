import Foundation

private struct BridgeChallengeResource: Codable {
    let coreToMantle: [Challenge]
    let mantleToCrust: [Challenge]
}

private func requiredCurriculumResource<T: Decodable>(_ name: String, as type: T.Type) -> T {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Curriculum") else {
        fatalError("Missing required curriculum resource: \(name).json")
    }
    guard let data = try? Data(contentsOf: url) else {
        fatalError("Unable to read curriculum resource: \(name).json")
    }
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        fatalError("Failed to decode curriculum resource \(name).json: \(error)")
    }
}

func makeCore1Challenges() -> [Challenge] {
    return requiredCurriculumResource("core1_challenges", as: [Challenge].self)
}

func makeCore2Challenges() -> [Challenge] {
    return requiredCurriculumResource("core2_challenges", as: [Challenge].self)
}

func makeCore3Challenges() -> [Challenge] {
    return requiredCurriculumResource("core3_challenges", as: [Challenge].self)
}

func makeMantle1Challenges() -> [Challenge] {
    return requiredCurriculumResource("mantle1_challenges", as: [Challenge].self)
}

func makeMantle2Challenges() -> [Challenge] {
    return requiredCurriculumResource("mantle2_challenges", as: [Challenge].self)
}

func makeMantle3Challenges() -> [Challenge] {
    return requiredCurriculumResource("mantle3_challenges", as: [Challenge].self)
}

func makeMantleChallenges() -> [Challenge] {
    return makeMantle1Challenges() + makeMantle2Challenges() + makeMantle3Challenges()
}

func makeCrust1Challenges() -> [Challenge] {
    return requiredCurriculumResource("crust1_challenges", as: [Challenge].self)
}

func makeCrust2Challenges() -> [Challenge] {
    return requiredCurriculumResource("crust2_challenges", as: [Challenge].self)
}

func makeCrust3Challenges() -> [Challenge] {
    return requiredCurriculumResource("crust3_challenges", as: [Challenge].self)
}

func makeCrustChallenges() -> [Challenge] {
    return makeCrust1Challenges() + makeCrust2Challenges() + makeCrust3Challenges()
}

func makeBridgeChallenges() -> (coreToMantle: [Challenge], mantleToCrust: [Challenge]) {
    let payload = requiredCurriculumResource("bridge_challenges", as: BridgeChallengeResource.self)
    return (payload.coreToMantle, payload.mantleToCrust)
}

func makeProjects() -> [Project] {
    return requiredCurriculumResource("projects", as: [Project].self)
}
