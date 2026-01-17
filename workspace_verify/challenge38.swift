// Challenge 38: Optional Binding
// Unwrap multiple optionals

let smithName: String? = "Forge"
let metal: String? = "Iron"

if let smithName = smithName, let metal = metal {
    print("\(smithName) works \(metal)")
}
// Print "Forge works Iron"