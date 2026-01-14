// Core 1 Project A: Temperature Converter
// Build a function that converts Celsius to Fahrenheit
//
// Requirements:
// - Function name: celsiusToFahrenheit
// - Takes one Int parameter (Celsius temperature) labeled celsius
// - Returns the Fahrenheit temperature (Int or Double)
// - Formula: F = C × 9/5 + 32
//
// Your function will be tested with:
// - 0°C (should return 32)
// - 100°C (should return 212)
// - 37°C (should return 98.6 or 98)

// TODO: Write your 'celsiusToFahrenheit' function here
func celsiusToFahrenheit(celsius: Int) -> Int {
    celsius * 9/5 + 32
}

// Test code (don't modify):
print(celsiusToFahrenheit(celsius: 0))
print(celsiusToFahrenheit(celsius: 100))
print(celsiusToFahrenheit(celsius: 37))
