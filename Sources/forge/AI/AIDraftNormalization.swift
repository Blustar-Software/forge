import Foundation

struct AIDraftNormalizationResult {
    let draft: AIChallengeDraft
    let warnings: [String]
}

func normalizeAIDraft(_ draft: AIChallengeDraft) -> AIDraftNormalizationResult {
    var warnings: [String] = []

    let normalizedTopic = normalizeDraftTopic(draft.topic, warnings: &warnings)
    let normalizedTier = normalizeDraftTier(draft.tier, warnings: &warnings)
    let normalizedLayer = normalizeDraftLayer(draft.layer, warnings: &warnings)

    let normalizedExpectedOutput = normalizeExpectedOutput(draft.expectedOutput, warnings: &warnings)
    let normalizedStarterCode = normalizeDraftCode(draft.starterCode, field: "starterCode", warnings: &warnings)
    let normalizedSolution = draft.solution.map { normalizeDraftCode($0, field: "solution", warnings: &warnings) }
    let normalizedHints = normalizeHints(draft.hints, warnings: &warnings)

    return AIDraftNormalizationResult(
        draft: AIChallengeDraft(
            id: draft.id.trimmingCharacters(in: .whitespacesAndNewlines),
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: draft.description.trimmingCharacters(in: .whitespacesAndNewlines),
            starterCode: normalizedStarterCode,
            solution: normalizedSolution,
            expectedOutput: normalizedExpectedOutput,
            hints: normalizedHints,
            topic: normalizedTopic,
            tier: normalizedTier,
            layer: normalizedLayer
        ),
        warnings: warnings
    )
}

func normalizeDraftTopic(_ raw: String, warnings: inout [String]) -> String {
    let lowered = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if ChallengeTopic(rawValue: lowered) != nil {
        return lowered
    }

    let aliases: [String: String] = [
        "conditional": "conditionals",
        "loop": "loops",
        "optional": "optionals",
        "collection": "collections",
        "function": "functions",
        "string": "strings",
        "struct": "structs",
        "class": "classes",
        "property": "properties",
        "protocol": "protocols",
        "extension": "extensions",
        "error": "errors",
        "generic": "generics",
        "actor": "actors",
    ]
    if let mapped = aliases[lowered], ChallengeTopic(rawValue: mapped) != nil {
        warnings.append("Normalized topic '\(raw)' to '\(mapped)'.")
        return mapped
    }

    if ["core", "mantle", "crust"].contains(lowered) {
        warnings.append("Topic '\(raw)' looked like a layer; defaulted topic to 'general'.")
        return ChallengeTopic.general.rawValue
    }

    warnings.append("Unknown topic '\(raw)'; defaulted topic to 'general'.")
    return ChallengeTopic.general.rawValue
}

func normalizeDraftTier(_ raw: String, warnings: inout [String]) -> String {
    let lowered = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if ChallengeTier(rawValue: lowered) != nil {
        return lowered
    }
    warnings.append("Unknown tier '\(raw)'; defaulted tier to 'mainline'.")
    return ChallengeTier.mainline.rawValue
}

func normalizeDraftLayer(_ raw: String, warnings: inout [String]) -> String {
    let lowered = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if ChallengeLayer(rawValue: lowered) != nil {
        return lowered
    }
    warnings.append("Unknown layer '\(raw)'; defaulted layer to 'core'.")
    return ChallengeLayer.core.rawValue
}

func normalizeExpectedOutput(_ raw: String, warnings: inout [String]) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.count >= 2,
       ((trimmed.hasPrefix("\"") && trimmed.hasSuffix("\""))
            || (trimmed.hasPrefix("'") && trimmed.hasSuffix("'"))) {
        warnings.append("Removed surrounding quotes from expectedOutput.")
        return String(trimmed.dropFirst().dropLast())
    }
    return raw
}

func normalizeDraftCode(_ raw: String, field: String, warnings: inout [String]) -> String {
    var value = raw.replacingOccurrences(of: "\r\n", with: "\n")

    if value.contains("```") {
        value = stripCodeFencesFromDraft(value)
        warnings.append("Removed markdown code fences from \(field).")
    }

    let lines = value.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    var normalizedLines: [String] = []
    var convertedHashComment = false

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("#") {
            if let hashIndex = line.firstIndex(of: "#") {
                let prefix = String(line[..<hashIndex])
                let rest = String(line[line.index(after: hashIndex)...])
                normalizedLines.append("\(prefix)//\(rest)")
                convertedHashComment = true
                continue
            }
        }
        normalizedLines.append(line)
    }

    if convertedHashComment {
        warnings.append("Converted '#' comments to '//' in \(field).")
    }

    if !codeRequiresFoundation(normalizedLines) {
        let withoutFoundation = normalizedLines.filter { line in
            line.trimmingCharacters(in: .whitespacesAndNewlines) != "import Foundation"
        }
        if withoutFoundation.count != normalizedLines.count {
            warnings.append("Removed unnecessary 'import Foundation' from \(field).")
        }
        return withoutFoundation.joined(separator: "\n")
    }

    return normalizedLines.joined(separator: "\n")
}

func normalizeHints(_ rawHints: [String], warnings: inout [String]) -> [String] {
    var hints = rawHints.map { hint in
        hint.replacingOccurrences(of: "import Foundation", with: "use standard Swift syntax")
    }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    if hints.count < 2 {
        warnings.append("Added default hints to reach minimum hint count.")
        let defaults = [
            "Use print(...) for console output.",
            "Match expected output exactly, including punctuation."
        ]
        for fallback in defaults where hints.count < 2 {
            hints.append(fallback)
        }
    }
    return hints
}

func codeRequiresFoundation(_ lines: [String]) -> Bool {
    let source = lines.joined(separator: "\n")
    let markers = [
        "Dispatch",
        "RunLoop",
        "Date(",
        "URL(",
        "URLSession",
        "FileManager",
        "JSONSerialization",
        "ISO8601",
        "Data(",
    ]
    return markers.contains { source.contains($0) }
}

func stripCodeFencesFromDraft(_ text: String) -> String {
    var value = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if value.hasPrefix("```") {
        if let firstNewline = value.firstIndex(of: "\n") {
            value = String(value[value.index(after: firstNewline)...])
        }
        if value.hasSuffix("```") {
            value = String(value.dropLast(3))
        }
    }
    return value.trimmingCharacters(in: .whitespacesAndNewlines)
}
