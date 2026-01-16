// Challenge 49: Nested Functions
// Validate before processing.

// TODO: Create a function 'process' that takes an Int parameter
// - defines a nested function isValid(_:) returning Bool
// - prints "OK" if valid, otherwise "Invalid"
// Valid = value >= 0
func process(value: Int) {
    func isValid(_ value: Int) -> Bool {
        value >= 0
    }
    
    isValid(value) ? print("OK") : print("Invalid")
}

// TODO: Call process with -1
process(value: -1)
