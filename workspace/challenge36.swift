// Challenge 36: Optionals
// Avoid force-unwrapping with !

let heatLevel: Int? = 1200

// TODO: Use if let to unwrap heatLevel
// Print the value if it exists, otherwise print "No heat"
if let heatLevel = heatLevel {
    print(heatLevel)
} else {
    print("No heat")
}
