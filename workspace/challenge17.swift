// Challenge 17: Integration Challenge 2
// Combine constants, variables, math, functions, and comparisons

// TODO: Create a constant 'metal' with the value "Iron"
let metal = "Iron"
// TODO: Create a variable 'temperature' with the value 1200
var temperature = 1200
// TODO: Increase temperature by 200 using a compound assignment
temperature += 200
// TODO: Create a function 'isReady' that takes a metal (String) and temperature (Int)
// and returns true if temperature is >= 1400
func isReady(metal: String, temperature: Int) -> Bool {
    temperature >= 1400
}
// TODO: Call isReady and store the result
let metalState = isReady(metal: metal, temperature: temperature)
// TODO: Print "<metal> ready: <result>" using string interpolation
print("\(metal) ready: \(metalState)")
