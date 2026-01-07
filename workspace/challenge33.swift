// Challenge 33: Guard Let
// Print a heat value if it exists

func printHeat(_ value: Int?) {
    // TODO: Use guard let to unwrap value
    // Print "No heat" if value is nil
    // Otherwise print the unwrapped value
    guard let heat = value else {
        print("No heat")
        return
    }
    
    print(heat)
}

// TODO: Call printHeat with nil
printHeat(nil)
