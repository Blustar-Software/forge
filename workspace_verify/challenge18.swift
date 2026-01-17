let metal = "Iron"
var temperature = 1200

temperature += 200

func isReady(metal: String, temperature: Int) -> Bool {
    let ironReady = metal == "Iron" && temperature >= 1400
    let otherReady = metal != "Iron" && temperature >= 1200
    return ironReady || otherReady
}

let ready = isReady(metal: metal, temperature: temperature)
print("\(metal) ready: \(ready)")