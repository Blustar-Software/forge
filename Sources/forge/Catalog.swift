import Foundation

func truncate(_ value: String, limit: Int) -> String {
    guard value.count > limit else { return value }
    let index = value.index(value.startIndex, offsetBy: max(0, limit - 1))
    return String(value[..<index]) + "..."
}

func challengeCatalogLines(_ challenges: [Challenge]) -> [String] {
    let sorted = challenges.sorted { lhs, rhs in
        let layerOrder: [ChallengeLayer: Int] = [.core: 0, .mantle: 1, .crust: 2]
        let lhsLayer = layerOrder[lhs.layer] ?? 99
        let rhsLayer = layerOrder[rhs.layer] ?? 99
        if lhsLayer != rhsLayer { return lhsLayer < rhsLayer }
        if lhs.tier != rhs.tier { return lhs.tier == .mainline }
        let lhsNumber = lhs.layerNumber ?? lhs.number
        let rhsNumber = rhs.layerNumber ?? rhs.number
        if lhsNumber != rhsNumber { return lhsNumber < rhsNumber }
        let lhsExtra = lhs.extraIndex ?? 0
        let rhsExtra = rhs.extraIndex ?? 0
        if lhsExtra != rhsExtra { return lhsExtra < rhsExtra }
        return lhs.displayId < rhs.displayId
    }

    let idWidth = min(28, max(6, challenges.map { $0.displayId.count }.max() ?? 6))
    let layerWidth = 6
    let tierWidth = 7
    let topicWidth = 12
    let numberWidth = 4
    let extraWidth = 5
    let titleWidth = 52

    func pad(_ value: String, to width: Int) -> String {
        if value.count >= width {
            return value
        }
        return value + String(repeating: " ", count: width - value.count)
    }

    let header = [
        pad("ID", to: idWidth),
        pad("Layer", to: layerWidth),
        pad("Tier", to: tierWidth),
        pad("Topic", to: topicWidth),
        pad("#", to: numberWidth),
        pad("Extra", to: extraWidth),
        pad("Title", to: titleWidth)
    ].joined(separator: "  ")
    var lines: [String] = []
    lines.append(header)
    lines.append(String(repeating: "-", count: header.count))
    for challenge in sorted {
        let title = truncate(challenge.title, limit: titleWidth)
        let number = challenge.layerNumber ?? challenge.number
        let extra = challenge.extraIndex.map(String.init) ?? ""
        let row = [
            pad(challenge.displayId, to: idWidth),
            pad(challenge.layer.rawValue, to: layerWidth),
            pad(challenge.tier.rawValue, to: tierWidth),
            pad(challenge.topic.rawValue, to: topicWidth),
            pad(String(number), to: numberWidth),
            pad(extra, to: extraWidth),
            pad(title, to: titleWidth)
        ].joined(separator: "  ")
        lines.append(row)
    }
    return lines
}

func printChallengeCatalogTable(_ challenges: [Challenge]) {
    let lines = challengeCatalogLines(challenges)
    for line in lines {
        print(line)
    }
}

func writeChallengeCatalogText(_ challenges: [Challenge], path: String) {
    let lines = challengeCatalogLines(challenges)
    let content = lines.joined(separator: "\n") + "\n"
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}

func projectCatalogLines(_ projects: [Project]) -> [String] {
    func projectSortKey(_ id: String) -> (layer: Int, number: Int, suffix: Int, raw: String) {
        let lower = id.lowercased()
        let layer: Int
        let prefix: String
        if lower.hasPrefix("core") {
            layer = 0
            prefix = "core"
        } else if lower.hasPrefix("mantle") {
            layer = 1
            prefix = "mantle"
        } else if lower.hasPrefix("crust") {
            layer = 2
            prefix = "crust"
        } else {
            return (99, 999, 99, lower)
        }

        let remainder = lower.dropFirst(prefix.count)
        var numberDigits = ""
        var suffixChar: Character? = nil
        for char in remainder {
            if char.isNumber, suffixChar == nil {
                numberDigits.append(char)
            } else {
                suffixChar = char
                break
            }
        }
        let number = Int(numberDigits) ?? 999
        let suffix: Int
        if let suffixChar = suffixChar, let ascii = suffixChar.asciiValue {
            let base = Character("a").asciiValue ?? ascii
            suffix = max(1, Int(ascii - base) + 1)
        } else {
            suffix = 99
        }
        return (layer, number, suffix, lower)
    }

    let sorted = projects.sorted { lhs, rhs in
        let lhsKey = projectSortKey(lhs.id)
        let rhsKey = projectSortKey(rhs.id)
        if lhsKey.layer != rhsKey.layer { return lhsKey.layer < rhsKey.layer }
        if lhsKey.number != rhsKey.number { return lhsKey.number < rhsKey.number }
        if lhsKey.suffix != rhsKey.suffix { return lhsKey.suffix < rhsKey.suffix }
        if lhs.tier != rhs.tier { return lhs.tier == .mainline }
        return lhsKey.raw < rhsKey.raw
    }

    let idWidth = min(18, max(2, projects.map { $0.id.count }.max() ?? 2))
    let layerWidth = 6
    let tierWidth = 7
    let titleWidth = 40

    func pad(_ value: String, to width: Int) -> String {
        if value.count >= width {
            return value
        }
        return value + String(repeating: " ", count: width - value.count)
    }

    let header = [
        pad("ID", to: idWidth),
        pad("Layer", to: layerWidth),
        pad("Tier", to: tierWidth),
        pad("Title", to: titleWidth)
    ].joined(separator: "  ")
    var lines: [String] = []
    lines.append(header)
    lines.append(String(repeating: "-", count: header.count))
    for project in sorted {
        let title = truncate(project.title, limit: titleWidth)
        let row = [
            pad(project.id, to: idWidth),
            pad(project.layer.rawValue, to: layerWidth),
            pad(project.tier.rawValue, to: tierWidth),
            pad(title, to: titleWidth)
        ].joined(separator: "  ")
        lines.append(row)
    }
    return lines
}

func printProjectCatalogTable(_ projects: [Project]) {
    let lines = projectCatalogLines(projects)
    for line in lines {
        print(line)
    }
}

func writeProjectCatalogText(_ projects: [Project], path: String) {
    let lines = projectCatalogLines(projects)
    let content = lines.joined(separator: "\n") + "\n"
    try? content.write(toFile: path, atomically: true, encoding: .utf8)
}
