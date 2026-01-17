// Challenge 150: Constrained Extension
// Add shared behavior with constraints.

protocol Describable {
    var name: String { get }
}

extension Describable where Self: Equatable {
    func description() -> String {
        return "Forge: \(name)"
    }
}

struct Tool: Describable, Equatable {
    let name: String
}

let tool = Tool(name: "Anvil")
print(tool.description())
// TODO: Conform a struct and print its description