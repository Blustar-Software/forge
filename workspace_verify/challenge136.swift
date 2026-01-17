// Challenge 136: Conformance
// Make a struct conform to a protocol.

protocol Inspectable {
    var status: String { get }
}

struct Furnace: Inspectable {
    let status: String
}

let furnace = Furnace(status: "Ready")
print(furnace.status)
// TODO: Print its status