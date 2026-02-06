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

func makeMantleChallenges() -> [Challenge] {
    return requiredCurriculumResource("mantle_challenges", as: [Challenge].self)
}

func makeCrustChallenges() -> [Challenge] {
    return requiredCurriculumResource("crust_challenges", as: [Challenge].self)
}

func makeBridgeChallenges() -> (coreToMantle: [Challenge], mantleToCrust: [Challenge]) {
    let payload = requiredCurriculumResource("bridge_challenges", as: BridgeChallengeResource.self)
    return (payload.coreToMantle, payload.mantleToCrust)
}

func makeProjects() -> [Project] {
    return requiredCurriculumResource("projects", as: [Project].self)
}
