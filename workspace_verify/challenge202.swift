@resultBuilder
struct MessageBuilder {
    static func buildBlock(_ components: String...) -> [String] {
        return components
    }
}

func makeMessages(@MessageBuilder _ content: () -> [String]) -> [String] {
    return content()
}

let messages = makeMessages {
    "Forge"
    "Ready"
}

print(messages.joined(separator: " "))