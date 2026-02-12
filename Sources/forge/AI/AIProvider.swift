import Foundation

struct AIChallengeDraft: Codable {
    let id: String
    let title: String
    let description: String
    let starterCode: String
    let expectedOutput: String
    let hints: [String]
    let topic: String
    let tier: String
    let layer: String
}

protocol AIProvider {
    var key: String { get }
    func scaffoldDraft(model: String?) -> AIChallengeDraft
}

struct PhiProvider: AIProvider {
    let key = "phi"

    func scaffoldDraft(model: String?) -> AIChallengeDraft {
        return AIChallengeDraft(
            id: "ai-draft-phi-temp-ready",
            title: "Forge Temperature Ready Check",
            description: "Print Ready when temp is in 1200...1800, otherwise print Adjust.",
            starterCode: """
            // AI Draft: Forge Temperature Ready Check
            let temp = 1500
            // TODO: Print "Ready" when temp is in 1200...1800, else print "Adjust"
            """,
            expectedOutput: "Ready",
            hints: [
                "Use an if/else condition.",
                "Check the inclusive range 1200...1800."
            ],
            topic: "conditionals",
            tier: "mainline",
            layer: "core"
        )
    }
}

func makeAIProvider(named name: String) -> (any AIProvider)? {
    switch name.lowercased() {
    case "phi", "phi4", "phi-4", "phi-4-mini", "phi-4-mini-instruct":
        return PhiProvider()
    default:
        return nil
    }
}
