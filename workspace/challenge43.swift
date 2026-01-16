// Challenge 43: Struct Basics
// Create a tool and update its durability.

struct Tool {
    let name: String
    var durability: Int
}

var tool = Tool(name: "Hammer", durability: 5)

// TODO: Reduce durability by 1
// TODO: Print "Hammer durability: 4"
tool.durability -= 1
print("\(tool.name) durability: \(tool.durability)")
