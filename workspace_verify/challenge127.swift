// Challenge 127: Class Basics
// Define and instantiate a class.

class Anvil {
    var weight: Int
    init(weight: Int) {
        self.weight = weight
    }
}

let anvil = Anvil(weight: 10)
print(anvil.weight)
// TODO: Print the weight