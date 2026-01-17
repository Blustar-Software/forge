// Challenge 83: Optional Conversion
// Use if let with Int().

let input = "1500"

if let temp = Int(input) {
    print("Temp: \(temp)")
} else {
    print("Invalid")
}
// TODO: Print "Temp: <value>"
// TODO: Otherwise print "Invalid"