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

func makeChallenges() -> [Challenge] {
    return [
        Challenge(
            number: 1,
            title: "Hello, Forge",
            description: "Print \"Hello, Forge\" to the console",
            starterCode: """
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
            title: "Variables",
            description: "Create a variable and print it",
            starterCode: """
                // TODO: Create a variable called 'message' with the text "Learning Swift"

                // TODO: Print that variable
                """,
            expectedOutput: "Learning Swift"
        ),
        Challenge(
            number: 3,
            title: "Basic Math",
            description: "Perform arithmetic and print the result",
            starterCode: """
                // TODO: Create a variable 'result' that holds the sum of 25 and 17

                // TODO: Print the result
                """,
            expectedOutput: "42"
        ),
        Challenge(
            number: 4,
            title: "String Interpolation",
            description: "Combine text and variables in a print statement",
            starterCode: """
                // Create a variable with a number
                let score = 100

                // TODO: Print "Your score is 100" using string interpolation
                // Hint: Use \\(variableName) inside a string
                """,
            expectedOutput: "Your score is 100"
        ),
        Challenge(
            number: 5,
            title: "Function Parameters",
            description: "Create a function that takes a parameter",
            starterCode: """
                // TODO: Create a function called 'greet' that takes a 'name' parameter
                // and prints "Hello, " followed by that name

                // TODO: Call the function with "Forge"
                """,
            expectedOutput: "Hello, Forge"
        ),
        Challenge(
            number: 6,
            title: "Return Values",
            description: "Create a function that returns a value",
            starterCode: """
                // TODO: Create a function called 'double' that takes an Int parameter
                // and returns that number multiplied by 2

                // TODO: Call the function with 21 and print the result
                """,
            expectedOutput: "42"
        ),
    ]
}
