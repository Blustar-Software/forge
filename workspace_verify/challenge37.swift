// Challenge 37: Optionals
// Avoid force-unwrapping with !

let heatLevel: Int? = 1200

if let level = heatLevel {
    print(level)
} else {
    print("No heat")
}
// Print the value if it exists, otherwise print "No heat"