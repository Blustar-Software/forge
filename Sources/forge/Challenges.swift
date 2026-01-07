import Foundation

// Centralized challenge definitions for the CLI flow.
struct Challenge {
    let number: Int
    let title: String
    let description: String
    let starterCode: String
    let expectedOutput: String

    var filename: String {
        return "challenge\(number).swift"
    }
}

struct Project {
    let id: String
    let pass: Int
    let title: String
    let description: String
    let starterCode: String
    let testCases: [(input: String, expectedOutput: String)]
    let completionTitle: String
    let completionMessage: String

    var filename: String {
        return "project_\(id).swift"
    }
}

func makeCore1Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 1,
            title: "Hello, Forge",
            description: "Print \"Hello, Forge\" to the console",
            starterCode: """
                // Challenge 1: Hello, Forge
                // Print "Hello, Forge" to the console

                // TODO: Create a function called greet()
                func greet() {
                    // Your code here
                }

                // TODO: Call the function
                """,
            expectedOutput: "Hello, Forge"
        ),
        Challenge(
            number: 2,
            title: "Comments",
            description: "Add comments to make code clear and document your work",
            starterCode: """
                // Challenge 2: Comments
                // Add comments to make code clear and document your work

                // TODO: Write a comment explaining what the next line does
                print("Hello, Forge")

                // TODO: Create a multi-line comment (use /* */) that says:
                // "This is my second challenge.
                // I'm learning Swift with Forge."

                // TODO: Print "Comments complete"
                """,
            expectedOutput: "Hello, Forge\nComments complete"
        ),
        Challenge(
            number: 3,
            title: "Constants",
            description: "Create values that don't change",
            starterCode: """
                // Challenge 3: Constants
                // Create values that don't change

                // A forge operates at high temperatures
                // TODO: Create a constant called 'forgeTemperature' with the value 1500

                // TODO: Print the constant
                """,
            expectedOutput: "1500"
        ),
        Challenge(
            number: 4,
            title: "Variables",
            description: "Create values that can change",
            starterCode: """
                // Challenge 4: Variables
                // Variables can change; use var when a value will be updated

                // TODO: Create a variable called 'hammerWeight' with the value 10

                // TODO: Print the variable

                // TODO: Change 'hammerWeight' to 12

                // TODO: Print the variable again
                """,
            expectedOutput: "10\n12"
        ),
        Challenge(
            number: 5,
            title: "Type Annotations",
            description: "Use explicit types when helpful",
            starterCode: """
                // Challenge 5: Type Annotations
                // Explicit types can improve clarity

                // TODO: Create a constant 'metalCount' of type Int with the value 5
                // TODO: Create a constant 'temperature' of type Double with the value 1500.5

                // TODO: Print metalCount
                // TODO: Print temperature
                """,
            expectedOutput: "5\n1500.5"
        ),
        Challenge(
            number: 6,
            title: "Basic Math",
            description: "Use arithmetic operators with integers",
            starterCode: """
                // Challenge 6: Basic Math
                // Use arithmetic operators to calculate results

                // TODO: Create a constant 'ingots' with the value 20
                // TODO: Create a constant 'used' with the value 6
                // TODO: Create a constant 'remaining' that subtracts used from ingots

                // TODO: Print remaining
                """,
            expectedOutput: "14"
        ),
        Challenge(
            number: 7,
            title: "Compound Assignment",
            description: "Update a value in place",
            starterCode: """
                // Challenge 7: Compound Assignment
                // Update a value using += and -=

                var hammerHits = 10

                // TODO: Add 5 to hammerHits using +=
                // TODO: Subtract 3 from hammerHits using -=
                // TODO: Print hammerHits
                """,
            expectedOutput: "12"
        ),
        Challenge(
            number: 8,
            title: "Strings & Concatenation",
            description: "Join strings together with +",
            starterCode: """
                // Challenge 8: Strings & Concatenation
                // Combine strings to create a message

                // TODO: Create a constant 'forgeWord' with the value "Forge"
                // TODO: Create a constant 'statusWord' with the value "Ready"
                // TODO: Combine them with a space between using +

                // TODO: Print the combined message
                """,
            expectedOutput: "Forge Ready"
        ),
        Challenge(
            number: 9,
            title: "String Interpolation",
            description: "Insert values into strings with \\( )",
            starterCode: """
                // Challenge 9: String Interpolation
                // Use \\(variable) inside a string

                // TODO: Create a constant 'forgeLevel' with the value 3

                // TODO: Print "Forge level: 3" using string interpolation
                """,
            expectedOutput: "Forge level: 3"
        ),
        Challenge(
            number: 10,
            title: "Booleans",
            description: "Work with true and false values",
            starterCode: """
                // Challenge 10: Booleans
                // Booleans represent true or false

                // TODO: Create a constant 'isHeated' of type Bool with the value true

                // TODO: Print the constant
                """,
            expectedOutput: "true"
        ),
        Challenge(
            number: 11,
            title: "Comparison Operators",
            description: "Compare values with ==, !=, <, >, <=, >=",
            starterCode: """
                // Challenge 11: Comparison Operators
                // Comparisons return a Bool

                // TODO: Create a constant 'temperature' with the value 1500
                // TODO: Create a constant 'ready' that checks if temperature is >= 1200

                // TODO: Print ready
                """,
            expectedOutput: "true"
        ),
        Challenge(
            number: 12,
            title: "Logical Operators",
            description: "Combine conditions with && and ||",
            starterCode: """
                // Challenge 12: Logical Operators
                // Combine conditions to produce a Bool

                let temperature = 1300
                let metalCount = 2

                // TODO: Create a constant 'ready' that is true when
                // temperature >= 1200 AND metalCount > 0
                // TODO: Print ready
                """,
            expectedOutput: "true"
        ),
        Challenge(
            number: 13,
            title: "Function Parameters",
            description: "Pass a value into a function",
            starterCode: """
                // Challenge 13: Function Parameters
                // Functions can accept input

                // TODO: Create a function called 'announce' that takes a String parameter
                // and prints the parameter

                // TODO: Call the function with "Forge"
                """,
            expectedOutput: "Forge"
        ),
        Challenge(
            number: 14,
            title: "Multiple Parameters",
            description: "Functions can take more than one input",
            starterCode: """
                // Challenge 14: Multiple Parameters
                // Functions can accept multiple parameters

                // TODO: Create a function called 'mix' that takes a metal (String)
                // and a weight (Int), then prints "Metal: <metal>, Weight: <weight>"

                // TODO: Call the function with "Iron" and 3
                """,
            expectedOutput: "Metal: Iron, Weight: 3"
        ),
        Challenge(
            number: 15,
            title: "Return Values",
            description: "Return a value from a function",
            starterCode: """
                // Challenge 15: Return Values
                // Functions can return a value

                // TODO: Create a function called 'addHeat' that takes an Int
                // and returns that value plus 200

                // TODO: Call the function with 1300 and store the result
                // TODO: Print the result
                """,
            expectedOutput: "1500"
        ),
        Challenge(
            number: 16,
            title: "Integration Challenge 1",
            description: "Combine variables, functions, math, and strings",
            starterCode: """
                // Challenge 16: Integration Challenge 1
                // Use multiple concepts together

                // TODO: Create a variable 'hammerHits' with the value 2
                // TODO: Create a function 'totalHits' that multiplies hits by 3 and returns the result
                // TODO: Call totalHits and store the result
                // TODO: Print "Total hits: <result>" using string interpolation
                """,
            expectedOutput: "Total hits: 6"
        ),
        Challenge(
            number: 17,
            title: "Integration Challenge 2",
            description: "Use everything from Pass 1 in a slightly larger task",
            starterCode: """
                // Challenge 17: Integration Challenge 2
                // Combine constants, variables, math, functions, and comparisons

                // TODO: Create a constant 'metal' with the value "Iron"
                // TODO: Create a variable 'temperature' with the value 1200
                // TODO: Increase temperature by 200 using a compound assignment
                // TODO: Create a function 'isReady' that takes a metal (String) and temperature (Int)
                // and returns true if temperature is >= 1400
                // TODO: Call isReady and store the result
                // TODO: Print "<metal> ready: <result>" using string interpolation
                """,
            expectedOutput: "Iron ready: true"
        ),
    ]
}

func makeCore2Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 18,
            title: "If/Else If/Else",
            description: "Choose between multiple branches",
            starterCode: """
                // Challenge 18: If/Else If/Else
                // Choose the right message for the heat level

                let heatLevel = 2

                // TODO: If heatLevel >= 3, print "Hot"
                // TODO: Else if heatLevel == 2, print "Warm"
                // TODO: Else print "Cold"
                """,
            expectedOutput: "Warm"
        ),
        Challenge(
            number: 19,
            title: "Ternary Operator",
            description: "Use a ternary to choose a value",
            starterCode: """
                // Challenge 19: Ternary Operator
                // Use a ternary operator to choose a message

                let heatLevel = 3

                // TODO: If heatLevel is >= 3, set status to "Hot", otherwise "Warm"
                // TODO: Print status
                """,
            expectedOutput: "Hot"
        ),
        Challenge(
            number: 20,
            title: "Switch Statements",
            description: "Match multiple cases with switch",
            starterCode: """
                // Challenge 20: Switch Statements
                // Use switch to handle different metals

                let metal = "Iron"

                // TODO: Print "Forgeable" for "Iron", "Soft" for "Gold", and "Unknown" otherwise
                """,
            expectedOutput: "Forgeable"
        ),
        Challenge(
            number: 21,
            title: "Pattern Matching",
            description: "Match ranges and multiple values",
            starterCode: """
                // Challenge 21: Pattern Matching
                // Use switch to match ranges

                let temperature = 1450

                // TODO: Use switch on temperature
                // - 0...1199: print "Too cold"
                // - 1200...1499: print "Working"
                // - 1500...: print "Overheated"
                """,
            expectedOutput: "Working"
        ),
        Challenge(
            number: 22,
            title: "For-In Loops",
            description: "Repeat work over a range",
            starterCode: """
                // Challenge 22: For-In Loops
                // Sum the numbers 1 through 5

                var total = 0

                // TODO: Loop from 1 to 5 and add each number to total
                // TODO: Print total
                """,
            expectedOutput: "15"
        ),
        Challenge(
            number: 23,
            title: "While Loops",
            description: "Repeat work while a condition is true",
            starterCode: """
                // Challenge 23: While Loops
                // Count down from 3 to 1

                var count = 3

                // TODO: While count is greater than 0, print count and decrement it
                """,
            expectedOutput: "3\n2\n1"
        ),
        Challenge(
            number: 24,
            title: "Repeat-While",
            description: "Run code at least once",
            starterCode: """
                // Challenge 24: Repeat-While
                // Increase value until it reaches 1

                var value = 0

                // TODO: Use repeat-while to add 1 to value until it is at least 1
                // TODO: Print value
                """,
            expectedOutput: "1"
        ),
        Challenge(
            number: 25,
            title: "Break and Continue",
            description: "Skip or stop inside a loop",
            starterCode: """
                // Challenge 25: Break and Continue
                // Print numbers 1 to 4, skipping 3

                // TODO: Loop from 1 to 5
                // - Skip 3 using continue
                // - Stop when you hit 5 using break
                // - Print the other numbers
                """,
            expectedOutput: "1\n2\n4"
        ),
        Challenge(
            number: 26,
            title: "Ranges",
            description: "Use closed and half-open ranges",
            starterCode: """
                // Challenge 26: Ranges
                // Compare closed and half-open ranges

                // TODO: Create a constant 'closed' as 1...3
                // TODO: Create a constant 'halfOpen' as 1..<3
                // TODO: Print closed.count
                // TODO: Print halfOpen.count
                """,
            expectedOutput: "3\n2"
        ),
        Challenge(
            number: 27,
            title: "Arrays",
            description: "Store multiple values in order",
            starterCode: """
                // Challenge 27: Arrays
                // Create an array and add a value

                var ingots = [1, 2, 3]

                // TODO: Append 4 to the array
                // TODO: Print the count of the array
                """,
            expectedOutput: "4"
        ),
        Challenge(
            number: 28,
            title: "Array Iteration",
            description: "Loop through array elements",
            starterCode: """
                // Challenge 28: Array Iteration
                // Add up the weights

                let weights = [2, 4, 6]
                var total = 0

                // TODO: Loop through weights and add each to total
                // TODO: Print total
                """,
            expectedOutput: "12"
        ),
        Challenge(
            number: 29,
            title: "Dictionaries",
            description: "Store key-value pairs",
            starterCode: """
                // Challenge 29: Dictionaries
                // Look up an item count

                let inventory = ["Iron": 3, "Gold": 1]

                // TODO: Read the count for "Iron" (default to 0 if missing)
                // TODO: Print the count
                """,
            expectedOutput: "3"
        ),
        Challenge(
            number: 30,
            title: "Sets",
            description: "Keep only unique values",
            starterCode: """
                // Challenge 30: Sets
                // Count unique ingots

                let batch = [1, 2, 2, 3]

                // TODO: Create a Set from batch
                // TODO: Print the count of the set
                """,
            expectedOutput: "3"
        ),
        Challenge(
            number: 31,
            title: "Optionals",
            description: "Handle missing values safely",
            starterCode: """
                // Challenge 31: Optionals
                // Use a default value when optional is nil

                let heatLevel: Int? = 1200

                // TODO: Print heatLevel, using 0 if it is nil
                """,
            expectedOutput: "1200"
        ),
        Challenge(
            number: 32,
            title: "Optional Binding",
            description: "Unwrap optionals with if let",
            starterCode: """
                // Challenge 32: Optional Binding
                // Greet the smith if the name exists

                let smithName: String? = "Forge"

                // TODO: Use if let to unwrap smithName and print "Hello, <name>"
                """,
            expectedOutput: "Hello, Forge"
        ),
        Challenge(
            number: 33,
            title: "Guard Let",
            description: "Exit early when data is missing",
            starterCode: """
                // Challenge 33: Guard Let
                // Print a heat value if it exists

                func printHeat(_ value: Int?) {
                    // TODO: Use guard let to unwrap value
                    // Print "No heat" if value is nil
                    // Otherwise print the unwrapped value
                }

                // TODO: Call printHeat with nil
                """,
            expectedOutput: "No heat"
        ),
        Challenge(
            number: 34,
            title: "Nil Coalescing",
            description: "Provide a fallback value",
            starterCode: """
                // Challenge 34: Nil Coalescing
                // Use ?? to provide a default

                let optionalLevel: Int? = nil

                // TODO: Use ?? to set level to 1 when optionalLevel is nil
                // TODO: Print "Level 1"
                """,
            expectedOutput: "Level 1"
        ),
        Challenge(
            number: 35,
            title: "Tuples",
            description: "Group related values together",
            starterCode: """
                // Challenge 35: Tuples
                // Use named tuple values

                let report = (min: 1200, max: 1600, average: 1425)

                // TODO: Print "Min: 1200" using report.min
                // TODO: Print "Max: 1600" using report.max
                // TODO: Print "Average: 1425" using report.average
                """,
            expectedOutput: "Min: 1200\nMax: 1600\nAverage: 1425"
        ),
    ]
}

func makeCore3Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 36,
            title: "External & Internal Labels",
            description: "Design clear APIs with distinct labels",
            starterCode: """
                // Challenge 36: External & Internal Labels
                // Create a function with different external and internal labels.

                // TODO: Create a function called forgeHeat that uses:
                // external label: at
                // internal label: temperature
                // It should print "Heat: <temperature>"

                // TODO: Call the function with 1500
                """,
            expectedOutput: "Heat: 1500"
        ),
        Challenge(
            number: 37,
            title: "Default Parameters",
            description: "Use default values to simplify calls",
            starterCode: """
                // Challenge 37: Default Parameters
                // Add a default intensity parameter.

                // TODO: Create a function strike that takes:
                // - a metal (String)
                // - an intensity (Int) defaulting to 1
                // Print "Striking <metal> with intensity <intensity>"

                // TODO: Call strike with "Iron"
                // TODO: Call strike with "Gold" and intensity 3
                """,
            expectedOutput: "Striking Iron with intensity 1\nStriking Gold with intensity 3"
        ),
        Challenge(
            number: 38,
            title: "Variadics",
            description: "Accept any number of values",
            starterCode: """
                // Challenge 38: Variadics
                // Accept multiple temperatures.

                // TODO: Create a function averageTemp that takes any number of Ints
                // and prints the average (integer division)

                // TODO: Call averageTemp with 1000, 1200, 1400
                """,
            expectedOutput: "1200"
        ),
        Challenge(
            number: 39,
            title: "inout Parameters",
            description: "Mutate a value passed into a function",
            starterCode: """
                // Challenge 39: inout Parameters
                // Simulate tool wear.

                // TODO: Create a function wear that subtracts 1 from a passed-in Int
                // Use inout

                // TODO: Create a variable durability = 5
                // TODO: Call wear on durability
                // TODO: Print durability
                """,
            expectedOutput: "4"
        ),
        Challenge(
            number: 40,
            title: "Nested Functions",
            description: "Use helper functions inside functions",
            starterCode: """
                // Challenge 40: Nested Functions
                // Validate before processing.

                // TODO: Create a function process that:
                // - defines a nested function isValid(_:) returning Bool
                // - prints "OK" if valid, otherwise "Invalid"

                // Valid = value >= 0

                // TODO: Call process with -1
                """,
            expectedOutput: "Invalid"
        ),
        Challenge(
            number: 41,
            title: "Closure Syntax",
            description: "Convert to shorthand closure syntax",
            starterCode: """
                // Challenge 41: Closure Syntax
                // Convert to shorthand closure syntax.

                let temps = [1200, 1500, 1600]

                // TODO: Use map to convert each temp to a string like "<temp> deg"
                // Use the shortest closure syntax possible

                // TODO: Print the resulting array
                """,
            expectedOutput: "[\"1200 deg\", \"1500 deg\", \"1600 deg\"]"
        ),
        Challenge(
            number: 42,
            title: "Capturing Values",
            description: "Understand closure capture behavior",
            starterCode: """
                // Challenge 42: Capturing Values
                // Create a counter function.

                // TODO: Create a function makeCounter that returns a closure
                // The closure should increment and print an internal count

                // TODO: Create a counter and call it three times
                """,
            expectedOutput: "1\n2\n3"
        ),
        Challenge(
            number: 43,
            title: "Trailing Closures",
            description: "Use trailing closure syntax",
            starterCode: """
                // Challenge 43: Trailing Closures
                // Use a closure to transform values.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using trailing closure syntax
                // Multiply the value by 3
                """,
            expectedOutput: "15"
        ),
        Challenge(
            number: 44,
            title: "map/filter/reduce",
            description: "Combine higher-order functions",
            starterCode: """
                // Challenge 44: map/filter/reduce
                // Process forge temperatures.

                let temps = [1000, 1500, 1600, 1400]

                // TODO: Filter temps >= 1500
                // TODO: Map them to Fahrenheit (C × 9/5 + 32)
                // TODO: Reduce to a total
                // TODO: Print the total
                """,
            expectedOutput: "5644"
        ),
        Challenge(
            number: 45,
            title: "compactMap",
            description: "Remove nil values safely",
            starterCode: """
                // Challenge 45: compactMap
                // Clean up optional readings.

                let readings: [Int?] = [1200, nil, 1500, nil, 1600]

                // TODO: Use compactMap to remove nils
                // TODO: Print the cleaned array
                """,
            expectedOutput: "[1200, 1500, 1600]"
        ),
        Challenge(
            number: 46,
            title: "flatMap",
            description: "Flatten nested arrays",
            starterCode: """
                // Challenge 46: flatMap
                // Flatten batches.

                let batches = [[1, 2], [3], [4, 5]]

                // TODO: Flatten using flatMap
                // TODO: Print the result
                """,
            expectedOutput: "[1, 2, 3, 4, 5]"
        ),
        Challenge(
            number: 47,
            title: "typealias",
            description: "Improve readability with type aliases",
            starterCode: """
                // Challenge 47: typealias
                // Create a readable alias.

                // TODO: Create a typealias ForgeReading = (temp: Int, time: Int)
                // TODO: Create a reading and print its temp
                """,
            expectedOutput: "1200"
        ),
        Challenge(
            number: 48,
            title: "Enums with Raw Values",
            description: "Represent simple categories",
            starterCode: """
                // Challenge 48: Enums with Raw Values
                // Represent metals.

                // TODO: Create an enum Metal: String with cases iron, gold
                // TODO: Print Metal.iron.rawValue
                """,
            expectedOutput: "iron"
        ),
        Challenge(
            number: 49,
            title: "Enums with Associated Values",
            description: "Represent structured events",
            starterCode: """
                // Challenge 49: Enums with Associated Values
                // Represent forge events.

                // TODO: Create an enum Event with:
                // - temperature(Int)
                // - error(String)

                // TODO: Create one of each and print something based on the case
                // Use a switch to print:
                // - "Temp: 1500" for temperature(1500)
                // - "Error: Overheat" for error("Overheat")
                """,
            expectedOutput: "Temp: 1500\nError: Overheat"
        ),
        Challenge(
            number: 50,
            title: "Throwing Functions",
            description: "Introduce error throwing",
            starterCode: """
                // Challenge 50: Throwing Functions
                // Validate temperature.

                // TODO: Create an enum TempError: Error with case outOfRange
                // TODO: Create a function checkTemp that throws if temp < 0
                // TODO: Call it with -1 using do/try/catch
                """,
            expectedOutput: "Error"
        ),
        Challenge(
            number: 51,
            title: "try?",
            description: "Convert errors into optionals",
            starterCode: """
                // Challenge 51: try?
                // Use try? to simplify error handling.

                // TODO: Reuse checkTemp from previous challenge
                // TODO: Call it with -1 using try?
                // TODO: Print the result (should be nil)
                """,
            expectedOutput: "nil"
        ),
        Challenge(
            number: 52,
            title: "Simulated Input",
            description: "Use a provided input value",
            starterCode: """
                // Challenge 52: readLine
                // Simulate a value from the user.

                let input = "Iron"

                // TODO: Print "You entered <metal>" using input
                """,
            expectedOutput: "You entered Iron"
        ),
        Challenge(
            number: 53,
            title: "Simulated Arguments",
            description: "Read from a provided args array",
            starterCode: """
                // Challenge 53: Command-Line Arguments
                // Read arguments.

                let args = ["forge", "Iron"]

                // TODO: Print the first argument after the program name, or "No args"
                """,
            expectedOutput: "Iron"
        ),
        Challenge(
            number: 54,
            title: "Simulated File Read",
            description: "Process provided file contents",
            starterCode: """
                // Challenge 54: File Read
                // Read a file of temperatures.

                let fileContents = """
                1200
                1500
                1600
                """

                // TODO: Print the number of characters in fileContents
                """,
            expectedOutput: "15"
        ),
        Challenge(
            number: 55,
            title: "Simulated Test",
            description: "Check a condition and report result",
            starterCode: """
                // Challenge 55: XCTest
                // Write a basic test case.

                // TODO: If 2 + 2 == 4, print "Test passed"
                """,
            expectedOutput: "Test passed"
        ),
        Challenge(
            number: 56,
            title: "Integration Challenge",
            description: "Combine Core 3 concepts",
            starterCode: """
                // Challenge 56: Integration Challenge
                // Process forge logs with advanced tools.

                let lines = ["1200", "x", "1500", "1600", "bad", "1400"]

                // TODO: Convert each line to an Int? using Int()
                // TODO: Use compactMap to remove nils
                // TODO: Use filter to keep temps >= 1500
                // TODO: Use reduce to compute total
                // TODO: Print the total
                """,
            expectedOutput: "3100"
        ),
    ]
}

func makeProjects() -> [Project] {
    return [
        Project(
            id: "core1a",
            pass: 1,
            title: "Temperature Converter",
            description: "Build a function that converts Celsius to Fahrenheit",
            starterCode: """
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

                // TODO: Write your celsiusToFahrenheit function here

                // Test code (don't modify):
                print(celsiusToFahrenheit(celsius: 0))
                print(celsiusToFahrenheit(celsius: 100))
                print(celsiusToFahrenheit(celsius: 37))
                """,
            testCases: [
                (input: "0", expectedOutput: "32"),
                (input: "100", expectedOutput: "212"),
                (input: "37", expectedOutput: "98"),  // Accepting Int version
            ],
            completionTitle: "🎆 Core 1, Pass 1 Complete!",
            completionMessage: "You've mastered the fundamentals. Well done."
        ),
        Project(
            id: "core2a",
            pass: 2,
            title: "Forge Log Analyzer",
            description: "Analyze a list of forge temperatures",
            starterCode: """
                // Core 2 Project A: Forge Log Analyzer
                // Analyze a list of forge temperatures
                //
                // Requirements:
                // - Function name: analyzeTemperatures
                // - Takes one [Int] parameter labeled temperatures
                // - Returns a tuple: (min: Int, max: Int, average: Int, overheatCount: Int)
                // - average should use integer division
                // - overheatCount should count values >= 1500
                //
                // Your function will be tested with:
                // - [1200, 1500, 1600, 1400]
                //
                // Expected outputs:
                // Min: 1200
                // Max: 1600
                // Average: 1425
                // Overheat: 2

                // TODO: Write your analyzeTemperatures function here

                // Test code (don't modify):
                let report = analyzeTemperatures(temperatures: [1200, 1500, 1600, 1400])
                print("Min: \\(report.min)")
                print("Max: \\(report.max)")
                print("Average: \\(report.average)")
                print("Overheat: \\(report.overheatCount)")
                """,
            testCases: [
                (input: "min", expectedOutput: "Min: 1200"),
                (input: "max", expectedOutput: "Max: 1600"),
                (input: "average", expectedOutput: "Average: 1425"),
                (input: "overheat", expectedOutput: "Overheat: 2"),
            ],
            completionTitle: "🏗️ Core 2, Pass 2 Complete!",
            completionMessage: "Control flow and collections are now in your toolkit."
        ),
        Project(
            id: "core3a",
            pass: 3,
            title: "Forge Log Interpreter",
            description: "Build a full data-processing pipeline for forge logs",
            starterCode: """
                // Core 3 Project A: Forge Log Interpreter
                // Build a full data-processing pipeline for forge logs.
                //
                // Requirements:
                // - Function name: interpretForgeLogs
                // - Takes [String] log lines
                // - Uses an enum with associated values to represent events
                // - Uses a throwing parser function
                // - Uses higher-order functions to transform data
                // - Returns a tuple:
                //   (validCount: Int, averageTemp: Int, overheatEvents: Int, errors: [String])
                //
                // Parsing rules:
                // - Valid lines are either "TEMP <int>" or "ERROR <message>"
                // - TEMP lines with non-integer values should be ignored
                // - Malformed lines should be handled safely (no crash)
                // - If there are no valid temps, averageTemp should be 0
                //
                // Example input:
                // ["TEMP 1400", "TEMP 1600", "ERROR Overheated", "TEMP abc", "TEMP 1500"]
                //
                // Expected behavior:
                // - Valid temps: 1400, 1600, 1500
                // - Invalid temp ("abc") should be ignored
                // - Errors: ["Overheated"]
                // - validCount = 3
                // - averageTemp = 1500
                // - overheatEvents = 2
                //
                // TODO: Define the ForgeEvent enum
                // TODO: Write a throwing parseLine(_:) function
                // TODO: Write interpretForgeLogs(lines:) using map/filter/reduce
                // TODO: Return the summary tuple
                //
                // Test code (don't modify):
                let logs = ["TEMP 1400", "TEMP 1600", "ERROR Overheated", "TEMP abc", "TEMP 1500"]
                let report = interpretForgeLogs(lines: logs)
                print("Valid: \\(report.validCount)")
                print("Average: \\(report.averageTemp)")
                print("Overheats: \\(report.overheatEvents)")
                print("Errors: \\(report.errors)")
                """,
            testCases: [
                (input: "valid", expectedOutput: "Valid: 3"),
                (input: "average", expectedOutput: "Average: 1500"),
                (input: "overheat", expectedOutput: "Overheats: 2"),
                (input: "errors", expectedOutput: "Errors: [\"Overheated\"]"),
            ],
            completionTitle: "🧠 Core 3, Pass 3 Complete!",
            completionMessage: "Advanced Swift tools are now in your hands."
        ),
    ]
}
