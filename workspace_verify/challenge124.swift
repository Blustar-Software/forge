struct Ingot {
    var metal: String
    var weight: Int

    init(metal: String) {
        self.metal = metal
        self.weight = 1
    }
}

let ingot = Ingot(metal: "Copper")
print(ingot.metal)
print(ingot.weight)