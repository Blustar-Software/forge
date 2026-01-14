// Challenge 37: Optional Binding
// Unwrap multiple optionals

let smithName: String? = "Forge"
let metal: String? = "Iron"

// TODO: Use if let to unwrap both values
// Print "Forge works Iron"
if let smithName = smithName, let metal = metal {
    print("\(smithName) works \(metal)")
}
