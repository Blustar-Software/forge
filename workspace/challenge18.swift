// Challenge 18: Integration Challenge 2
// Core 1 capstone: combine constants, variables, math, functions, and comparisons

// TODO: Create a constant 'metal' with the value "Iron"
// TODO: Create a variable 'temperature' with the value 1200
// TODO: Increase temperature by 200 using a compound assignment
// TODO: Create a function 'isReady' that takes a metal (String) and temperature (Int)
// Use boolean logic only:
// - For "Iron": ready when temperature >= 1400
// - For other metals: ready when temperature >= 1200
// TODO: Call isReady and store the result
// TODO: Print "<metal> ready: <result>" using string interpolation
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
