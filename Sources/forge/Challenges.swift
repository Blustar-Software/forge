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
    ]
}
