// Challenge 38: Guard Let
// Print a heat value if it exists

func printHeat(_ value: Int?) {
    // TODO: Use guard let to unwrap value
    // Print "No heat" if value is nil
    // Otherwise print the unwrapped value
    guard let value = value else {
        print("No heat")
        return
    }
    
    print(value)
}

// TODO: Call printHeat with nil
printHeat(nil)
