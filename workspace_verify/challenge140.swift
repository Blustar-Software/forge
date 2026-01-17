// Challenge 140: Extensions
// Add behavior using an extension.

struct Ingot {
    let weight: Int
}

extension Ingot {
    func label() -> String {
        return "Ingot \(weight)"
    }
}

let ingot = Ingot(weight: 5)
print(ingot.label())
// TODO: Create an Ingot and print its label