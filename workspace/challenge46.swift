// Challenge 46: Default Parameters
// Add a default intensity parameter.

// TODO: Create a function 'strike' that takes:
// - a metal (String)
// - an intensity (Int) defaulting to 1
// Print "Striking <metal> with intensity <intensity>"
func strike(metal: String, intensity: Int = 1) {
    print("Striking \(metal) with intensity \(intensity)")
}

// TODO: Call strike with 'Iron'
// TODO: Call strike with 'Gold' and intensity 3
strike(metal: "Iron")
strike(metal: "Gold", intensity: 3)
