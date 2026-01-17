// Challenge 160: Default Label
// Add a shared method with a protocol extension.

protocol Named {
    var name: String { get }
}

extension Named {
    func label() -> String {
        return "Tool: \(name)"
    }
}

struct Tool: Named {
    let name: String
}

print(Tool(name: "Hammer").label())
// TODO: Conform a struct and print its label