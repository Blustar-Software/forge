import Foundation

struct AIChallengeDraft: Codable {
    let id: String
    let title: String
    let description: String
    let starterCode: String
    let solution: String?
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
            solution: """
            if temp >= 1200 && temp <= 1800 {
                print("Ready")
            } else {
                print("Adjust")
            }
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

struct OllamaProvider: AIProvider {
    let key = "ollama"

    func scaffoldDraft(model: String?) -> AIChallengeDraft {
        return AIChallengeDraft(
            id: "ai-draft-ollama-temp-ready",
            title: "Forge Heat Band Check",
            description: "Print Stable when heat is between 1000 and 1600 inclusive, otherwise print Tune.",
            starterCode: """
            // AI Draft: Forge Heat Band Check
            let heat = 1400
            // TODO: Print "Stable" when heat is in 1000...1600, else print "Tune"
            """,
            solution: """
            if heat >= 1000 && heat <= 1600 {
                print("Stable")
            } else {
                print("Tune")
            }
            """,
            expectedOutput: "Stable",
            hints: [
                "Use an if/else condition.",
                "Check the inclusive range 1000...1600."
            ],
            topic: "conditionals",
            tier: "mainline",
            layer: "core"
        )
    }
}

func makeAIProvider(named name: String) -> (any AIProvider)? {
    switch name.lowercased() {
    case "ollama", "local", "phi-local", "phi4-local":
        return OllamaProvider()
    case "phi", "phi4", "phi-4", "phi-4-mini", "phi-4-mini-instruct":
        return PhiProvider()
    default:
        return nil
    }
}
