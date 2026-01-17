class Operator {
    var name: String
    weak var forge: Forge?

    init(name: String) {
        self.name = name
    }
}

class Forge {
    var operatorRef: Operator?
}

let forge = Forge()
let operatorRef = Operator(name: "Ada")
forge.operatorRef = operatorRef
operatorRef.forge = forge
print("Cycle avoided")