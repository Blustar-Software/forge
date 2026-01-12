import Foundation

enum ChallengeTopic: String {
    case general
    case conditionals
    case loops
    case optionals
    case collections
    case functions
    case strings
    case structs
}

enum ChallengeTier: String {
    case core
    case extra
}

enum ProjectTier: String {
    case core
    case extra
}

// Centralized challenge definitions for the CLI flow.
struct Challenge {
    let number: Int
    let title: String
    let description: String
    let starterCode: String
    let expectedOutput: String
    let hints: [String]
    let solution: String
    let manualCheck: Bool
    let topic: ChallengeTopic
    let tier: ChallengeTier

    init(
        number: Int,
        title: String,
        description: String,
        starterCode: String,
        expectedOutput: String,
        hints: [String] = [],
        solution: String = "",
        manualCheck: Bool = false,
        topic: ChallengeTopic = .general,
        tier: ChallengeTier = .core
    ) {
        self.number = number
        self.title = title
        self.description = description
        self.starterCode = starterCode
        self.expectedOutput = expectedOutput
        self.hints = hints
        self.solution = solution
        self.manualCheck = manualCheck
        self.topic = topic
        self.tier = tier
    }

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
    let hints: [String]
    let solution: String
    let tier: ProjectTier

    init(
        id: String,
        pass: Int,
        title: String,
        description: String,
        starterCode: String,
        testCases: [(input: String, expectedOutput: String)],
        completionTitle: String,
        completionMessage: String,
        hints: [String] = [],
        solution: String = "",
        tier: ProjectTier = .core
    ) {
        self.id = id
        self.pass = pass
        self.title = title
        self.description = description
        self.starterCode = starterCode
        self.testCases = testCases
        self.completionTitle = completionTitle
        self.completionMessage = completionMessage
        self.hints = hints
        self.solution = solution
        self.tier = tier
    }

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

                // TODO: Create a function 'called' 'greet()'
                func greet() {
                    // Your code here
                }

                // TODO: Call the function
                """,
            expectedOutput: "Hello, Forge",
            hints: [
                "Write greet() to print \"Hello, Forge\", then call it.",
            ],
            solution: #"""
func greet() {
    print("Hello, Forge")
}

greet()
"""#,
            topic: .general,

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
            expectedOutput: "Hello, Forge\nComments complete",
            hints: [
                #"""
// This line prints a greeting to the console
print("Hello, Forge")
"""#,
                """
/* This is my second challenge.
I'm learning Swift with Forge. */
""",
            ],
            solution: #"""
// This line prints a greeting to the console
print("Hello, Forge")

/* This is my second challenge.
I'm learning Swift with Forge. */

print("Comments complete")
"""#,
            topic: .general,

        ),
        Challenge(
            number: 3,
            title: "Constants",
            description: "Create values that don't change",
            starterCode: """
                // Challenge 3: Constants
                // Create values that don't change

                // A forge operates at high temperatures
                // TODO: Create a constant 'called' 'forgeTemperature' with the value 1500

                // TODO: Print the constant
                """,
            expectedOutput: "1500",
            hints: [
                "let forgeTemperature = 1500",
            ],
            solution: """
let forgeTemperature = 1500
print(forgeTemperature)
""",
            topic: .general,

        ),
        Challenge(
            number: 4,
            title: "Variables",
            description: "Create values that can change",
            starterCode: """
                // Challenge 4: Variables
                // Variables can change; use var when a value will be updated

                // TODO: Create a variable 'called' 'hammerWeight' with the value 10

                // TODO: Print the variable

                // TODO: Change 'hammerWeight' to 12

                // TODO: Print the variable again
                """,
            expectedOutput: "10\n12",
            hints: [
                """
var hammerWeight = 10
print(hammerWeight)
""",
                """
hammerWeight = 12
print(hammerWeight)
""",
            ],
            solution: """
var hammerWeight = 10
print(hammerWeight)

hammerWeight = 12
print(hammerWeight)
""",
            topic: .general,

        ),
        Challenge(
            number: 5,
            title: "Type Annotations",
            description: "Use explicit types when helpful",
            starterCode: """
                // Challenge 5: Type Annotations
                // Explicit types can improve clarity

                // TODO: Create a constant 'metalCount' with an explicit Int type and value 5
                // TODO: Create a constant 'temperature' with an explicit Double type and value 1500.5

                // TODO: Print metalCount
                // TODO: Print temperature
                """,
            expectedOutput: "5\n1500.5",
            hints: [
                """
let metalCount: Int = 5
let temperature: Double = 1500.5
""",
            ],
            solution: """
let metalCount: Int = 5
let temperature: Double = 1500.5

print(metalCount)
print(temperature)
""",
            topic: .general,

        ),
        Challenge(
            number: 6,
            title: "Type Inference",
            description: "Let Swift infer types from values",
            starterCode: """
                // Challenge 6: Type Inference
                // You used inference already; now use it intentionally

                // TODO: Create a constant 'ingotCount' with the value 4 (no type annotation)
                // TODO: Create a constant 'forgeName' with the value 'Forge' (no type annotation)

                // TODO: Print ingotCount
                // TODO: Print forgeName
                """,
            expectedOutput: "4\nForge",
            hints: [
                #"""
let ingotCount = 4
let forgeName = "Forge"
"""#,
            ],
            solution: #"""
let ingotCount = 4
let forgeName = "Forge"

print(ingotCount)
print(forgeName)
"""#,
            topic: .general,

        ),
        Challenge(
            number: 7,
            title: "Basic Math",
            description: "Use arithmetic operators with integers",
            starterCode: """
                // Challenge 7: Basic Math
                // Use +, -, *, /, and % with integers

                let a = 20
                let b = 6

                // TODO: Print a + b
                // TODO: Print a - b
                // TODO: Print a * b
                // TODO: Print a / b (integer division)
                // TODO: Print a % b
                """,
            expectedOutput: "26\n14\n120\n3\n2",
            hints: [
                "Use print(a + b), then repeat with -, *, /, and %.",
            ],
            solution: """
print(a + b)
print(a - b)
print(a * b)
print(a / b)
print(a % b)
""",
            topic: .general,

        ),
        Challenge(
            number: 8,
            title: "Compound Assignment",
            description: "Update a value in place",
            starterCode: """
                // Challenge 8: Compound Assignment
                // Update a value using +=, -=, *=, and /=

                var heat = 10

                // TODO: Add 5 to heat using += and print heat
                // TODO: Subtract 3 from heat using -= and print heat
                // TODO: Multiply heat by 2 using *= and print heat
                // TODO: Divide heat by 3 using /= and print heat
                """,
            expectedOutput: "15\n12\n24\n8",
            hints: [
                """
heat += 5
print(heat)
""",
                """
heat -= 3
print(heat)
""",
                """
heat *= 2
print(heat)
""",
                """
heat /= 3
print(heat)
""",
            ],
            solution: """
heat += 5
print(heat)

heat -= 3
print(heat)

heat *= 2
print(heat)

heat /= 3
print(heat)
""",
            topic: .general,

        ),
        Challenge(
            number: 9,
            title: "Strings & Concatenation",
            description: "Join strings together with +",
            starterCode: """
                // Challenge 9: Strings & Concatenation
                // Combine strings to create a message

                // TODO: Create a constant 'forgeWord' with the value 'Forge'
                // TODO: Create a constant 'statusWord' with the value 'Ready'
                // TODO: Combine them with a space between using +

                // TODO: Print the combined message
                """,
            expectedOutput: "Forge Ready",
            hints: [
                #"let message = forgeWord + " " + statusWord"#,
            ],
            solution: #"""
let forgeWord = "Forge"
let statusWord = "Ready"
let message = forgeWord + " " + statusWord

print(message)
"""#,
            topic: .strings,

        ),
        Challenge(
            number: 10,
            title: "String Interpolation",
            description: "Insert values into strings with \\( )",
            starterCode: """
                // Challenge 10: String Interpolation
                // Use \\(variable) inside a string

                // TODO: Create a constant 'forgeLevel' with the value 3

                // TODO: Print "Forge level: 3" using string interpolation
                """,
            expectedOutput: "Forge level: 3",
            hints: [
                #"""
let forgeLevel = 3
// Interpolate like: "Forge level: \(forgeLevel)"
"""#,
            ],
            solution: #"""
let forgeLevel = 3
print("Forge level: \(forgeLevel)")
"""#,
            topic: .strings,

        ),
        Challenge(
            number: 11,
            title: "Booleans",
            description: "Work with true and false values",
            starterCode: """
                // Challenge 11: Booleans
                // Booleans represent true or false

                // TODO: Create a constant 'isHeated' of type Bool with the value true

                // TODO: Print the constant
                """,
            expectedOutput: "true",
            hints: [
                """
let isHeated: Bool = true
// Print the value
""",
            ],
            solution: """
let isHeated: Bool = true
print(isHeated)
""",
            topic: .conditionals,

        ),
        Challenge(
            number: 12,
            title: "Comparison Operators",
            description: "Compare values with ==, !=, <, >, <=, >=",
            starterCode: """
                // Challenge 12: Comparison Operators
                // Use all comparison operators

                let a = 5
                let b = 7

                // TODO: Print a == b
                // TODO: Print a != b
                // TODO: Print a < b
                // TODO: Print a > b
                // TODO: Print a <= b
                // TODO: Print b >= a
                """,
            expectedOutput: "false\ntrue\ntrue\nfalse\ntrue\ntrue",
            hints: [
                "Use print with ==, !=, <, >, <=, and >= comparisons.",
            ],
            solution: """
print(a == b)
print(a != b)
print(a < b)
print(a > b)
print(a <= b)
print(b >= a)
""",
            topic: .conditionals,

        ),
        Challenge(
            number: 13,
            title: "Logical Operators",
            description: "Combine conditions with && and ||",
            starterCode: """
                // Challenge 13: Logical Operators
                // Use &&, ||, and ! with a simple checklist

                let heatReady = true
                let toolsReady = false

                // TODO: Create a constant 'ready' that is true only if BOTH are ready (&&)
                // TODO: Create a constant 'partialReady' that is true if EITHER is ready (||)
                // TODO: Create a constant 'notReady' that is the opposite of ready (!)
                // TODO: Print ready, partialReady, and notReady (in that order)
                """,
            expectedOutput: "false\ntrue\ntrue",
            hints: [
                """
let ready = heatReady && toolsReady
let partialReady = heatReady || toolsReady
let notReady = !ready
""",
                """
print(ready)
print(partialReady)
print(notReady)
""",
            ],
            solution: """
let ready = heatReady && toolsReady
let partialReady = heatReady || toolsReady
let notReady = !ready

print(ready)
print(partialReady)
print(notReady)
""",
            topic: .conditionals,

        ),
        Challenge(
            number: 14,
            title: "Function Parameters",
            description: "Pass a value into a function",
            starterCode: """
                // Challenge 14: Function Parameters
                // Functions can accept input

                // TODO: Create a function 'called' 'announce' that takes a String parameter
                // and prints the parameter

                // TODO: Call the function with 'Forge'
                """,
            expectedOutput: "Forge",
            hints: [
                """
func announce(_ message: String) {
    print(message)
}
""",
                #"announce("Forge")"#,
            ],
            solution: #"""
func announce(_ message: String) {
    print(message)
}

announce("Forge")
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 15,
            title: "Multiple Parameters",
            description: "Functions can take more than one input",
            starterCode: """
                // Challenge 15: Multiple Parameters
                // Functions can accept multiple parameters

                // TODO: Create a function 'called' 'mix' that takes a metal (String)
                // and a weight (Int), then prints "Metal: <metal>, Weight: <weight>"

                // TODO: Call the function with 'Iron' and 3
                """,
            expectedOutput: "Metal: Iron, Weight: 3",
            hints: [
                #"""
func mix(metal: String, weight: Int) {
    print("Metal: \(metal), Weight: \(weight)")
}
"""#,
                #"mix(metal: "Iron", weight: 3)"#,
            ],
            solution: #"""
func mix(metal: String, weight: Int) {
    print("Metal: \(metal), Weight: \(weight)")
}

mix(metal: "Iron", weight: 3)
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 16,
            title: "Return Values",
            description: "Return a value from a function",
            starterCode: """
                // Challenge 16: Return Values
                // Functions can return a value

                // TODO: Create a function 'called' 'addHeat' that takes an Int
                // and returns that value plus 200

                // TODO: Call the function with 1300 and store the result
                // TODO: Print the result
                """,
            expectedOutput: "1500",
            hints: [
                """
func addHeat(_ value: Int) -> Int {
    return value + 200
}
""",
                """
let result = addHeat(1300)
print(result)
""",
            ],
            solution: """
func addHeat(_ value: Int) -> Int {
    return value + 200
}

let result = addHeat(1300)
print(result)
""",
            topic: .functions,

        ),
        Challenge(
            number: 17,
            title: "Integration Challenge 1",
            description: "Combine variables, functions, math, and strings",
            starterCode: """
                // Challenge 17: Integration Challenge 1
                // Use multiple concepts together

                // TODO: Create a variable 'hammerHits' with the value 2
                // TODO: Create a function 'totalHits' that multiplies hits by 3 and returns the result
                // TODO: Call totalHits and store the result
                // TODO: Print "Total hits: <result>" using string interpolation
                """,
            expectedOutput: "Total hits: 6",
            hints: [
                """
var hammerHits = 2

func totalHits(_ hits: Int) -> Int {
    return hits * 3
}
""",
                #"""
let result = totalHits(hammerHits)
print("Total hits: \(result)")
"""#,
            ],
            solution: #"""
var hammerHits = 2

func totalHits(_ hits: Int) -> Int {
    return hits * 3
}

let result = totalHits(hammerHits)
print("Total hits: \(result)")
"""#,
            topic: .general,

        ),
        Challenge(
            number: 18,
            title: "Integration Challenge 2",
            description: "Core 1 capstone: combine the essentials in one task",
            starterCode: """
                // Challenge 18: Integration Challenge 2
                // Core 1 capstone: combine constants, variables, math, functions, and comparisons

                // TODO: Create a constant 'metal' with the value 'Iron'
                // TODO: Create a variable 'temperature' with the value 1200
                // TODO: Increase temperature by 200 using a compound assignment
                // TODO: Create a function 'isReady' that takes a metal (String) and temperature (Int)
                // If metal is "Iron", return true when temperature >= 1400
                // Otherwise, return true when temperature >= 1200
                // TODO: Call isReady and store the result
                // TODO: Print "<metal> ready: <result>" using string interpolation
                """,
            expectedOutput: "Iron ready: true",
            hints: [
                #"""
let metal = "Iron"
var temperature = 1200
temperature += 200
"""#,
                #"""
func isReady(metal: String, temperature: Int) -> Bool {
    if metal == "Iron" {
        return temperature >= 1400
    }
    return temperature >= 1200
}
"""#,
                #"""
let ready = isReady(metal: metal, temperature: temperature)
print("\(metal) ready: \(ready)")
"""#,
            ],
            solution: #"""
let metal = "Iron"
var temperature = 1200

temperature += 200

func isReady(metal: String, temperature: Int) -> Bool {
    if metal == "Iron" {
        return temperature >= 1400
    }
    return temperature >= 1200
}

let ready = isReady(metal: metal, temperature: temperature)
print("\(metal) ready: \(ready)")
"""#,
            topic: .general,

        ),
    ]
}

func makeCore2Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 19,
            title: "If/Else If/Else",
            description: "Choose between multiple branches",
            starterCode: """
                // Challenge 19: If/Else If/Else
                // Choose the right message for the heat level

                let heatLevel = 2

                // TODO: If heatLevel >= 3, print 'Hot'
                // TODO: Else if heatLevel == 2, print 'Warm'
                // TODO: Else print 'Cold'
                """,
            expectedOutput: "Warm",
            hints: [
                "Use if / else if / else to cover >= 3, == 2, and the default.",
            ],
            solution: #"""
if heatLevel >= 3 {
    print("Hot")
} else if heatLevel == 2 {
    print("Warm")
} else {
    print("Cold")
}
"""#,
            topic: .conditionals,

        ),
        Challenge(
            number: 20,
            title: "Ternary Operator",
            description: "Use a ternary to choose a value",
            starterCode: """
                // Challenge 20: Ternary Operator
                // Use a ternary operator to choose a message

                let heatLevel = 3

                // TODO: If heatLevel is >= 3, set status to 'Hot', otherwise 'Warm'
                // TODO: Print status
                """,
            expectedOutput: "Hot",
            hints: [
                #"let status = heatLevel >= 3 ? "Hot" : "Warm""#,
                "print(status)",
            ],
            solution: #"""
let status = heatLevel >= 3 ? "Hot" : "Warm"
print(status)
"""#,
            topic: .conditionals,

        ),
        Challenge(
            number: 21,
            title: "Switch Statements",
            description: "Match multiple cases with switch",
            starterCode: """
                // Challenge 21: Switch Statements
                // Use switch to handle different metals

                let metal = "Iron"

                // TODO: Print 'Forgeable' for 'Iron', 'Soft' for 'Gold', and 'Unknown' otherwise
                """,
            expectedOutput: "Forgeable",
            hints: [
                "Use a switch on metal with cases for \"Iron\", \"Gold\", and default.",
            ],
            solution: #"""
switch metal {
case "Iron":
    print("Forgeable")
case "Gold":
    print("Soft")
default:
    print("Unknown")
}
"""#,
            topic: .conditionals,

        ),
        Challenge(
            number: 22,
            title: "Pattern Matching",
            description: "Match ranges and multiple values",
            starterCode: """
                // Challenge 22: Pattern Matching
                // Use switch to match ranges

                let temperature = 1450

                // TODO: Use switch on temperature
                // - 0...1199: print "Too cold"
                // - 1200...1499: print "Working"
                // - 1500...: print "Overheated"
                """,
            expectedOutput: "Working",
            hints: [
                "Use a switch with range patterns for 0...1199 and 1200...1499, then default.",
            ],
            solution: #"""
switch temperature {
case 0...1199:
    print("Too cold")
case 1200...1499:
    print("Working")
default:
    print("Overheated")
}
"""#,
            topic: .conditionals,

        ),
        Challenge(
            number: 23,
            title: "For-In Loops",
            description: "Repeat work over a range",
            starterCode: """
                // Challenge 23: For-In Loops
                // Sum the numbers 1 through 5

                var total = 0

                // TODO: Loop from 1 to 5 and add each number to total
                // TODO: Print total
                """,
            expectedOutput: "15",
            hints: [
                "Loop with for i in 1...5 and add each i to total, then print.",
            ],
            solution: """
for i in 1...5 {
    total += i
}
print(total)
""",
            topic: .loops,

        ),
        Challenge(
            number: 24,
            title: "While Loops",
            description: "Repeat work while a condition is true",
            starterCode: """
                // Challenge 24: While Loops
                // Count down from 3 to 1

                var count = 3

                // TODO: While count is greater than 0, print count and decrement it
                """,
            expectedOutput: "3\n2\n1",
            hints: [
                "Use while count > 0, print count, then decrement inside the loop.",
            ],
            solution: """
while count > 0 {
    print(count)
    count -= 1
}
""",
            topic: .loops,

        ),
        Challenge(
            number: 25,
            title: "Repeat-While",
            description: "Run code at least once",
            starterCode: """
                // Challenge 25: Repeat-While
                // Increase value until it reaches 1

                var value = 0

                // TODO: Use repeat-while to add 1 to value until it is at least 1
                // TODO: Print value
                """,
            expectedOutput: "1",
            hints: [
                "Use repeat { value += 1 } while value < 1, then print.",
            ],
            solution: """
repeat {
    value += 1
} while value < 1

print(value)
""",
            topic: .loops,

        ),
        Challenge(
            number: 26,
            title: "Break and Continue",
            description: "Skip or stop inside a loop",
            starterCode: """
                // Challenge 26: Break and Continue
                // Print numbers 1 to 4, skipping 3

                // TODO: Loop from 1 to 5
                // - Skip 3 using continue
                // - Stop when you hit 5 using break
                // - Print the other numbers
                """,
            expectedOutput: "1\n2\n4",
            hints: [
                """
for i in 1...5 {
    if i == 3 { continue }
    if i == 5 { break }
    print(i)
}
""",
            ],
            solution: """
for i in 1...5 {
    if i == 3 {
        continue
    }
    if i == 5 {
        break
    }
    print(i)
}
""",
            topic: .loops,

        ),
        Challenge(
            number: 27,
            title: "Ranges",
            description: "Use closed and half-open ranges",
            starterCode: """
                // Challenge 27: Ranges
                // Compare closed and half-open ranges

                // TODO: Loop through 1...3 and print each number
                // TODO: Loop through 1..<3 and print each number
                """,
            expectedOutput: "1\n2\n3\n1\n2",
            hints: [
                "Use for-in with 1...3 (closed) and 1..<3 (half-open).",
            ],
            solution: """
for i in 1...3 {
    print(i)
}
for i in 1..<3 {
    print(i)
}
""",
            topic: .loops,

        ),
        Challenge(
            number: 28,
            title: "Arrays",
            description: "Create an array of values",
            starterCode: """
                // Challenge 28: Arrays
                // Create an array before modifying it

                // TODO: Create an array named ingots with values 1, 2, 3
                // TODO: Print the array
                """,
            expectedOutput: "[1, 2, 3]",
            hints: [
                "Arrays use brackets: let ingots = [1, 2, 3]. Then print it.",
            ],
            solution: """
let ingots = [1, 2, 3]
print(ingots)
""",
            topic: .collections,

        ),
        Challenge(
            number: 29,
            title: "Array Append",
            description: "Add a value and check the count",
            starterCode: """
                // Challenge 29: Array Append
                // Append a value and check the count

                var ingots = [1, 2, 3]

                // TODO: Append 4 to the array
                // TODO: Print the count of the array
                """,
            expectedOutput: "4",
            hints: [
                "ingots.append(4)",
                "print(ingots.count)",
            ],
            solution: """
ingots.append(4)
print(ingots.count)
""",
            topic: .collections,

        ),
        Challenge(
            number: 30,
            title: "Array Iteration",
            description: "Loop through array elements",
            starterCode: """
                // Challenge 30: Array Iteration
                // Add up the weights

                let weights = [2, 4, 6]
                var total = 0

                // TODO: Loop through weights and add each to total
                // TODO: Print total
                """,
            expectedOutput: "12",
            hints: [
                """
for weight in weights {
    total += weight
}
""",
                "print(total)",
            ],
            solution: """
for weight in weights {
    total += weight
}
print(total)
""",
            topic: .loops,

        ),
        Challenge(
            number: 31,
            title: "Metrics Practice",
            description: "Practice loop-based stats on a small data set",
            starterCode: """
                // Challenge 31: Metrics Practice
                // Practice min/max/average counting in a loop.

                let weights = [3, 5, 7, 4]

                // TODO: Find the minimum value (start with weights[0] and update)
                // TODO: Find the maximum value (start with weights[0] and update)
                // TODO: Compute the average (sum then divide by weights.count)
                // TODO: Count values >= 5
                // TODO: Print results as:
                // "Min: 3"
                // "Max: 7"
                // "Average: 4"
                // "Heavy: 2"
                """,
            expectedOutput: "Min: 3\nMax: 7\nAverage: 4\nHeavy: 2",
            hints: [
                """
var minWeight = weights[0]
var maxWeight = weights[0]
var sum = 0
var heavyCount = 0
""",
                """
for weight in weights {
    if weight < minWeight { minWeight = weight }
    if weight > maxWeight { maxWeight = weight }
    sum += weight
    if weight >= 5 { heavyCount += 1 }
}
""",
                "let average = sum / weights.count",
                #"""
print("Min: \(minWeight)")
print("Max: \(maxWeight)")
print("Average: \(average)")
print("Heavy: \(heavyCount)")
"""#,
            ],
            solution: #"""
var minWeight = weights[0]
var maxWeight = weights[0]
var sum = 0
var heavyCount = 0

for weight in weights {
    if weight < minWeight { minWeight = weight }
    if weight > maxWeight { maxWeight = weight }
    sum += weight
    if weight >= 5 { heavyCount += 1 }
}

let average = sum / weights.count

print("Min: \(minWeight)")
print("Max: \(maxWeight)")
print("Average: \(average)")
print("Heavy: \(heavyCount)")
"""#,
            topic: .loops,

        ),
        Challenge(
            number: 32,
            title: "Collection Properties",
            description: "Use built-in collection properties",
            starterCode: """
                // Challenge 32: Collection Properties
                // Use properties to reduce manual work

                let ingots = [1, 2, 3, 4]
                let inventory = ["Iron": 2, "Gold": 1]

                // TODO: Print ingots.count
                // TODO: Print ingots.isEmpty
                // TODO: Print ingots.first (use ?? to default to 0)
                // TODO: Print inventory.count
                // TODO: Print inventory.keys.count
                """,
            expectedOutput: "4\nfalse\n1\n2\n2",
            hints: [
                "Use count, isEmpty, first ?? default, and keys.count on the collections.",
            ],
            solution: """
print(ingots.count)
print(ingots.isEmpty)
print(ingots.first ?? 0)
print(inventory.count)
print(inventory.keys.count)
""",
            topic: .collections,

        ),
        Challenge(
            number: 33,
            title: "Dictionaries",
            description: "Store key-value pairs",
            starterCode: """
                // Challenge 33: Dictionaries
                // Look up an item count

                let inventory = ["Iron": 3, "Gold": 1]

                // TODO: Read the count for 'Iron' (default to 0 if missing)
                // TODO: Print the count
                """,
            expectedOutput: "3",
            hints: [
                #"Use inventory["Iron", default: 0] to safely read a value."#,
            ],
            solution: #"""
let count = inventory["Iron", default: 0]
print(count)
"""#,
            topic: .collections,

        ),
        Challenge(
            number: 34,
            title: "Sets",
            description: "Keep only unique values",
            starterCode: """
                // Challenge 34: Sets
                // Count unique ingots

                let batch = [1, 2, 2, 3]

                // TODO: Create a Set from batch
                // TODO: Print the count of the set
                """,
            expectedOutput: "3",
            hints: [
                "Wrap the array in Set(...) and print the count.",
            ],
            solution: """
let unique = Set(batch)
print(unique.count)
""",
            topic: .collections,

        ),
        Challenge(
            number: 35,
            title: "Tuples",
            description: "Group related values together",
            starterCode: """
                // Challenge 35: Tuples
                // Use named tuple values

                let report = (min: 1200, max: 1600, average: 1425)
                let temps = (1200, 1600)

                // TODO: Print the first value using temps.0
                // TODO: Print the second value using temps.1

                // TODO: Print "Min: 1200" using report.min
                // TODO: Print "Max: 1600" using report.max
                // TODO: Print "Average: 1425" using report.average
                """,
            expectedOutput: "1200\n1600\nMin: 1200\nMax: 1600\nAverage: 1425",
            hints: [
                "Access tuples with temps.0/temps.1 and named values like report.min.",
            ],
            solution: #"""
print(temps.0)
print(temps.1)
print("Min: \(report.min)")
print("Max: \(report.max)")
print("Average: \(report.average)")
"""#,
            topic: .general,

        ),
        Challenge(
            number: 36,
            title: "Optionals",
            description: "Handle missing values safely",
            starterCode: """
                // Challenge 36: Optionals
                // Avoid force-unwrapping with !

                let heatLevel: Int? = 1200

                // TODO: Use if let to unwrap heatLevel
                // Print the value if it exists, otherwise print "No heat"
                """,
            expectedOutput: "1200",
            hints: [
                "Use if let to unwrap heatLevel and handle the else case.",
            ],
            solution: #"""
if let level = heatLevel {
    print(level)
} else {
    print("No heat")
}
"""#,
            topic: .optionals,

        ),
        Challenge(
            number: 37,
            title: "Optional Binding",
            description: "Unwrap optionals with if let",
            starterCode: """
                // Challenge 37: Optional Binding
                // Unwrap multiple optionals

                let smithName: String? = "Forge"
                let metal: String? = "Iron"

                // TODO: Use if let to unwrap both values
                // Print "Forge works Iron"
                """,
            expectedOutput: "Forge works Iron",
            hints: [
                "Use a single if let to unwrap both values before printing.",
            ],
            solution: #"""
if let smithName = smithName, let metal = metal {
    print("\(smithName) works \(metal)")
}
"""#,
            topic: .optionals,

        ),
        Challenge(
            number: 38,
            title: "Guard Let",
            description: "Exit early when data is missing",
            starterCode: """
                // Challenge 38: Guard Let
                // Print a heat value if it exists

                func printHeat(_ value: Int?) {
                    // TODO: Use guard let to unwrap value
                    // Print "No heat" if value is nil
                    // Otherwise print the unwrapped value
                }

                // TODO: Call printHeat with nil
                """,
            expectedOutput: "No heat",
            hints: [
                #"""
func printHeat(_ value: Int?) {
    guard let value = value else {
        print("No heat")
        return
    }
    print(value)
}
"""#,
                "printHeat(nil)",
            ],
            solution: #"""
func printHeat(_ value: Int?) {
    guard let value = value else {
        print("No heat")
        return
    }
    print(value)
}

printHeat(nil)
"""#,
            topic: .optionals,

        ),
        Challenge(
            number: 39,
            title: "Nil Coalescing",
            description: "Provide a fallback value",
            starterCode: """
                // Challenge 39: Nil Coalescing
                // Use ?? to provide a default

                let optionalLevel: Int? = nil

                // TODO: Use ?? to set level to 1 when optionalLevel is nil
                // TODO: Print "Level 1"
                """,
            expectedOutput: "Level 1",
            hints: [
                "Use ?? to default optionalLevel to 1, then print the level.",
            ],
            solution: #"""
let level = optionalLevel ?? 1
print("Level \(level)")
"""#,
            topic: .optionals,

        ),
    ]
}

func makeCore3Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 40,
            title: "String Methods",
            description: "Inspect and transform strings",
            starterCode: """
                // Challenge 40: String Methods
                // Use basic string properties and methods.

                let phrase = "Forge Ready"

                // TODO: Print phrase.count
                // TODO: Print phrase.lowercased()
                // TODO: Print phrase.contains("Ready")
                """,
            expectedOutput: "11\nforge ready\ntrue",
            hints: [
                "Use phrase.count, phrase.lowercased(), and phrase.contains(\"Ready\").",
            ],
            solution: """
print(phrase.count)
print(phrase.lowercased())
print(phrase.contains(\"Ready\"))
""",
            topic: .strings
        ),
        Challenge(
            number: 41,
            title: "Dictionary Iteration",
            description: "Loop through key-value pairs",
            starterCode: """
                // Challenge 41: Dictionary Iteration
                // Print inventory items in a stable order.

                let inventory = ["Iron": 3, "Gold": 1]

                // TODO: Loop over keys in sorted order
                // TODO: Print "<metal>: <count>" for each item
                """,
            expectedOutput: "Gold: 1\nIron: 3",
            hints: [
                "Use inventory.keys.sorted() and read inventory[key] inside the loop.",
            ],
            solution: """
for key in inventory.keys.sorted() {
    if let count = inventory[key] {
        print(\"\\(key): \\(count)\")
    }
}
""",
            topic: .collections
        ),
        Challenge(
            number: 42,
            title: "Tuple Returns",
            description: "Return multiple values from a function",
            starterCode: """
                // Challenge 42: Tuple Returns
                // Return min and max from a function.

                let temps = [3, 5, 2, 6]

                // TODO: Write a function minMax(_:) that returns (min: Int, max: Int)
                // TODO: Call it and print:
                // "Min: 2"
                // "Max: 6"
                """,
            expectedOutput: "Min: 2\nMax: 6",
            hints: [
                "Start min and max with temps[0], update in a loop, then return a named tuple.",
            ],
            solution: """
func minMax(_ values: [Int]) -> (min: Int, max: Int) {
    var minValue = values[0]
    var maxValue = values[0]

    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
    }

    return (min: minValue, max: maxValue)
}

let report = minMax(temps)
print(\"Min: \\(report.min)\")
print(\"Max: \\(report.max)\")
""",
            topic: .functions
        ),
        Challenge(
            number: 43,
            title: "Struct Basics",
            description: "Define and use a simple struct",
            starterCode: """
                // Challenge 43: Struct Basics
                // Create a tool and update its durability.

                struct Tool {
                    let name: String
                    var durability: Int
                }

                var tool = Tool(name: "Hammer", durability: 5)

                // TODO: Reduce durability by 1
                // TODO: Print "Hammer durability: 4"
                """,
            expectedOutput: "Hammer durability: 4",
            hints: [
                "Use tool.durability -= 1, then print the name and durability.",
            ],
            solution: """
tool.durability -= 1
print(\"\\(tool.name) durability: \\(tool.durability)\")
""",
            topic: .structs
        ),
        Challenge(
            number: 44,
            title: "External & Internal Labels",
            description: "Design clear APIs with distinct labels",
            starterCode: """
                // Challenge 44: External & Internal Labels
                // Create a function with different external and internal labels.

                // TODO: Create a function 'called' 'forgeHeat' that uses:
                // external label: at
                // internal label: temperature
                // It should print "Heat: <temperature>"

                // TODO: Call the function with 1500
                """,
            expectedOutput: "Heat: 1500",
            hints: [
                #"""
func forgeHeat(at temperature: Int) {
    print("Heat: \(temperature)")
}
"""#,
                "forgeHeat(at: 1500)",
            ],
            solution: #"""
func forgeHeat(at temperature: Int) {
    print("Heat: \(temperature)")
}

forgeHeat(at: 1500)
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 45,
            title: "Void Argument Labels",
            description: "Omit external labels when needed",
            starterCode: """
                // Challenge 45: Void Argument Labels
                // Use _ to omit the external label.

                // TODO: Create a function 'announce' that takes _ metal: String
                // and prints "Metal: <metal>"

                // TODO: Call announce with 'Iron' (no label)
                """,
            expectedOutput: "Metal: Iron",
            hints: [
                #"""
func announce(_ metal: String) {
    print("Metal: \(metal)")
}
"""#,
                #"announce("Iron")"#,
            ],
            solution: #"""
func announce(_ metal: String) {
    print("Metal: \(metal)")
}

announce("Iron")
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 46,
            title: "Default Parameters",
            description: "Use default values to simplify calls",
            starterCode: """
                // Challenge 46: Default Parameters
                // Add a default intensity parameter.

                // TODO: Create a function 'strike' that takes:
                // - a metal (String)
                // - an intensity (Int) defaulting to 1
                // Print "Striking <metal> with intensity <intensity>"

                // TODO: Call strike with 'Iron'
                // TODO: Call strike with 'Gold' and intensity 3
                """,
            expectedOutput: "Striking Iron with intensity 1\nStriking Gold with intensity 3",
            hints: [
                #"""
func strike(_ metal: String, intensity: Int = 1) {
    print("Striking \(metal) with intensity \(intensity)")
}
"""#,
                #"""
strike("Iron")
strike("Gold", intensity: 3)
"""#,
            ],
            solution: #"""
func strike(_ metal: String, intensity: Int = 1) {
    print("Striking \(metal) with intensity \(intensity)")
}

strike("Iron")
strike("Gold", intensity: 3)
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 47,
            title: "Variadics",
            description: "Accept any number of values",
            starterCode: """
                // Challenge 47: Variadics
                // Accept multiple temperatures.

                // TODO: Create a function 'averageTemp' that takes any number of Ints
                // TODO: Sum the values and divide by the count (integer division)
                // TODO: Print the average

                // TODO: Call averageTemp with 1000, 1200, 1400
                """,
            expectedOutput: "1200",
            hints: [
                """
func averageTemp(_ temps: Int...) {
    var total = 0
    for temp in temps {
        total += temp
    }
    let average = total / temps.count
    print(average)
}
""",
                "averageTemp(1000, 1200, 1400)",
            ],
            solution: """
func averageTemp(_ temps: Int...) {
    var total = 0
    for temp in temps {
        total += temp
    }
    let average = total / temps.count
    print(average)
}

averageTemp(1000, 1200, 1400)
""",
            topic: .functions,

        ),
        Challenge(
            number: 48,
            title: "inout Parameters",
            description: "Mutate a value passed into a function",
            starterCode: """
                // Challenge 48: inout Parameters
                // Simulate tool wear.

                // TODO: Create a function 'wear' that subtracts 1 from a passed-in Int

                // TODO: Create a variable 'durability' = 5
                // TODO: Call wear on durability
                // TODO: Print durability
                """,
            expectedOutput: "4",
            hints: [
                """
func wear(_ durability: inout Int) {
    durability -= 1
}
""",
                """
var durability = 5
wear(&durability)
print(durability)
""",
            ],
            solution: """
func wear(_ durability: inout Int) {
    durability -= 1
}

var durability = 5
wear(&durability)
print(durability)
""",
            topic: .functions,

        ),
        Challenge(
            number: 49,
            title: "Nested Functions",
            description: "Use helper functions inside functions",
            starterCode: """
                // Challenge 49: Nested Functions
                // Validate before processing.

                // TODO: Create a function 'process' that takes an Int parameter
                // - defines a nested function isValid(_:) returning Bool
                // - prints "OK" if valid, otherwise "Invalid"
                // Valid = value >= 0

                // TODO: Call process with -1
                """,
            expectedOutput: "Invalid",
            hints: [
                #"""
func process(_ value: Int) {
    func isValid(_ value: Int) -> Bool {
        return value >= 0
    }
    if isValid(value) {
        print("OK")
    } else {
        print("Invalid")
    }
}
"""#,
                "process(-1)",
            ],
            solution: #"""
func process(_ value: Int) {
    func isValid(_ value: Int) -> Bool {
        return value >= 0
    }
    if isValid(value) {
        print("OK")
    } else {
        print("Invalid")
    }
}

process(-1)
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 50,
            title: "Closure Basics",
            description: "Create and call a closure",
            starterCode: """
                // Challenge 50: Closure Basics
                // Store a closure in a constant.

                // TODO: Create a closure called strike that prints "Strike"
                // TODO: Call the closure
                """,
            expectedOutput: "Strike",
            hints: [
                #"""
let strike = { () -> Void in
    print("Strike")
}
"""#,
                "strike()",
            ],
            solution: #"""
let strike = { () -> Void in
    print("Strike")
}

strike()
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 51,
            title: "Closure Parameters",
            description: "Pass values into a closure",
            starterCode: """
                // Challenge 51: Closure Parameters
                // Create a closure that transforms a value.

                // TODO: Create a closure called doubleHeat that takes an Int
                // and returns the value multiplied by 2
                // TODO: Print doubleHeat(750)
                """,
            expectedOutput: "1500",
            hints: [
                """
let doubleHeat = { (value: Int) -> Int in
    return value * 2
}
""",
                "print(doubleHeat(750))",
            ],
            solution: """
let doubleHeat = { (value: Int) -> Int in
    return value * 2
}

print(doubleHeat(750))
""",
            topic: .functions,

        ),
        Challenge(
            number: 52,
            title: "Implicit Return in Closures",
            description: "Omit the return keyword in a single-expression closure",
            starterCode: """
                // Challenge 52: Implicit Return in Closures
                // Use an explicit signature, but omit return.

                // TODO: Create a closure called 'doubleHeat' that takes an Int
                // and returns the value multiplied by 2
                // TODO: Print doubleHeat(600)
                """,
            expectedOutput: "1200",
            hints: [
                """
let doubleHeat = { (value: Int) -> Int in
    value * 2
}
""",
                "print(doubleHeat(600))",
            ],
            solution: """
let doubleHeat = { (value: Int) -> Int in
    value * 2
}

print(doubleHeat(600))
""",
            topic: .functions,

        ),
        Challenge(
            number: 53,
            title: "Inferred Closure Types",
            description: "Let Swift infer parameter and return types",
            starterCode: """
                // Challenge 53: Inferred Closure Types
                // Remove explicit types when they can be inferred.

                // TODO: Create a closure called 'doubleHeat' using inferred types
                // It should multiply the input by 2
                // TODO: Print doubleHeat(750)
                """,
            expectedOutput: "1500",
            hints: [
                """
let doubleHeat = { value in
    value * 2
}
""",
                "print(doubleHeat(750))",
            ],
            solution: """
let doubleHeat = { value in
    value * 2
}

print(doubleHeat(750))
""",
            topic: .functions,

        ),
        Challenge(
            number: 54,
            title: "Shorthand Closure Syntax I",
            description: "Use $0 in an assigned closure",
            starterCode: """
                // Challenge 54: Shorthand Closure Syntax I
                // Use $0 in a closure stored in a constant.

                // TODO: Create a closure called 'doubleHeat' using $0
                // It should multiply the input by 2
                // TODO: Print doubleHeat(700)
                """,
            expectedOutput: "1400",
            hints: [
                "Use a closure with $0 to multiply by 2, then call it.",
            ],
            solution: """
let doubleHeat = { $0 * 2 }
print(doubleHeat(700))
""",
            topic: .functions,

        ),
        Challenge(
            number: 55,
            title: "Annotated Closure Assignment",
            description: "Bind a closure to a typed constant",
            starterCode: """
                // Challenge 55: Annotated Closure Assignment
                // Use a closure with an explicit type annotation.

                // TODO: Create a constant 'doubleHeat' with type (Int) -> Int
                // Use a shorthand closure to multiply the input by 2
                // TODO: Print doubleHeat(900)
                """,
            expectedOutput: "1800",
            hints: [
                "Add a type annotation: let doubleHeat: (Int) -> Int = { $0 * 2 }.",
            ],
            solution: """
let doubleHeat: (Int) -> Int = { $0 * 2 }
print(doubleHeat(900))
""",
            topic: .functions,

        ),
        Challenge(
            number: 56,
            title: "Closure Arguments",
            description: "Call a function with a closure argument",
            starterCode: """
                // Challenge 56: Closure Arguments
                // Call a function that takes a closure.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using the full closure argument
                // Multiply the value by 3
                """,
            expectedOutput: "15",
            hints: [
                "Call transform(5, using:) with a closure that multiplies by 3.",
            ],
            solution: """
transform(5, using: { (value: Int) -> Int in
    return value * 3
})
""",
            topic: .functions,

        ),
        Challenge(
            number: 57,
            title: "Trailing Closures",
            description: "Use trailing closure syntax",
            starterCode: """
                // Challenge 57: Trailing Closures
                // Use a closure to transform values.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using trailing closure syntax
                // Multiply the value by 3
                """,
            expectedOutput: "15",
            hints: [
                "Use trailing closure syntax with transform(5) { ... }.",
            ],
            solution: """
transform(5) { (value: Int) -> Int in
    return value * 3
}
""",
            topic: .functions,

        ),
        Challenge(
            number: 58,
            title: "Inferred Trailing Closures",
            description: "Drop types and return when they can be inferred",
            starterCode: """
                // Challenge 58: Inferred Trailing Closures
                // Let Swift infer types in a trailing closure.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 6 using trailing closure syntax
                // Multiply the value by 4
                // Note: You can omit return for a single-expression closure (Challenge 48)
                """,
            expectedOutput: "24",
            hints: [
                "Use transform(6) with a trailing closure that multiplies by 4.",
            ],
            solution: """
transform(6) { value in
    return value * 4
}
""",
            topic: .functions,

        ),
        Challenge(
            number: 59,
            title: "Shorthand Closure Syntax II",
            description: "Use $0 for compact closures",
            starterCode: """
                // Challenge 59: Shorthand Closure Syntax II
                // Use $0 to shorten a closure.

                func apply(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call apply with 4 and use $0 to add 6
                """,
            expectedOutput: "10",
            hints: [
                "apply(4) { $0 + 6 }",
            ],
            solution: "apply(4) { $0 + 6 }",
            topic: .functions,

        ),

        Challenge(
            number: 60,
            title: "Capturing Values",
            description: "Understand closure capture behavior",
            starterCode: """
                // Challenge 60: Capturing Values
                // Create a counter function.

                // TODO: Create a function 'makeCounter' that returns a closure
                // The closure should increment and print an internal count

                // TODO: Create a counter and call it three times
                """,
            expectedOutput: "1\n2\n3",
            hints: [
                """
func makeCounter() -> () -> Void {
    var count = 0
    return {
        count += 1
        print(count)
    }
}
""",
                """
let counter = makeCounter()
counter()
counter()
counter()
""",
            ],
            solution: """
func makeCounter() -> () -> Void {
    var count = 0
    return {
        count += 1
        print(count)
    }
}

let counter = makeCounter()
counter()
counter()
counter()
""",
            topic: .functions,

        ),
        Challenge(
            number: 61,
            title: "map",
            description: "Transform values with map",
            starterCode: """
                // Challenge 61: map
                // Transform forge temperatures into strings.

                let temps = [1200, 1500, 1600]

                // TODO: Use map to turn each temp into "T<temp>" (e.g "T1200"); In other words, prefix each temp with the letter 'T'.
                // TODO: Print the resulting array
                """,
            expectedOutput: #"["T1200", "T1500", "T1600"]"#,
            hints: [
                "Use map to turn each temp into a string prefixed with \"T\".",
            ],
            solution: #"""
let labels = temps.map { "T\($0)" }
print(labels)
"""#,
            topic: .collections,

        ),
        Challenge(
            number: 62,
            title: "filter",
            description: "Select values with filter",
            starterCode: """
                // Challenge 62: filter
                // Keep only hot temperatures.

                let temps = [1000, 1500, 1600, 1400]

                // TODO: Use filter to keep temps >= 1500
                // TODO: Print the filtered array
                """,
            expectedOutput: "[1500, 1600]",
            hints: [
                "Filter temps with a condition like $0 >= 1500, then print.",
            ],
            solution: """
let hot = temps.filter { $0 >= 1500 }
print(hot)
""",
            topic: .collections,

        ),
        Challenge(
            number: 63,
            title: "reduce",
            description: "Combine values with reduce",
            starterCode: """
                // Challenge 63: reduce
                // Sum forge temperatures.

                let temps = [1000, 1200, 1400]

                // TODO: Use reduce to compute the total
                // TODO: Print the total
                """,
            expectedOutput: "3600",
            hints: [
                "Use reduce starting at 0 to add all temps together.",
            ],
            solution: """
let total = temps.reduce(0) { partial, temp in
    partial + temp
}
print(total)
""",
            topic: .collections,

        ),
        Challenge(
            number: 64,
            title: "min/max",
            description: "Find smallest and largest values",
            starterCode: """
                // Challenge 64: min/max
                // Find the smallest and largest temperatures.

                let temps = [1200, 1500, 1600, 1400]

                // TODO: Use min() to find the smallest temp (default to 0 if nil)
                // TODO: Use max() to find the largest temp (default to 0 if nil)
                // TODO: Print min then max on separate lines
                """,
            expectedOutput: "1200\n1600",
            hints: [
                "Use temps.min() ?? 0 and temps.max() ?? 0, then print both.",
            ],
            solution: """
let minTemp = temps.min() ?? 0
let maxTemp = temps.max() ?? 0
print(minTemp)
print(maxTemp)
""",
            topic: .collections,

        ),

        Challenge(
            number: 65,
            title: "compactMap",
            description: "Remove nil values safely",
            starterCode: """
                // Challenge 65: compactMap
                // Clean up optional readings.

                let readings: [Int?] = [1200, nil, 1500, nil, 1600]

                // TODO: Use compactMap to remove nils
                // TODO: Print the cleaned array
                """,
            expectedOutput: "[1200, 1500, 1600]",
            hints: [
                "Use compactMap to drop nils, then print the result.",
            ],
            solution: """
let cleaned = readings.compactMap { $0 }
print(cleaned)
""",
            topic: .collections,

        ),
        Challenge(
            number: 66,
            title: "flatMap",
            description: "Flatten nested arrays",
            starterCode: """
                // Challenge 66: flatMap
                // Flatten batches.

                let batches = [[1, 2], [3], [4, 5]]

                // TODO: Flatten using flatMap
                // TODO: Print the result
                """,
            expectedOutput: "[1, 2, 3, 4, 5]",
            hints: [
                "Use flatMap to flatten the nested arrays, then print.",
            ],
            solution: """
let flat = batches.flatMap { $0 }
print(flat)
""",
            topic: .collections,

        ),


        Challenge(
            number: 67,
            title: "typealias",
            description: "Improve readability with type aliases",
            starterCode: """
                // Challenge 67: typealias
                // Create a readable alias.

                // TODO: Create a typealias ForgeReading = (temp: Int, time: Int)
                // TODO: Create a reading with temp 1200 and time 1
                // TODO: Print reading.temp
                """,
            expectedOutput: "1200",
            hints: [
                "Create typealias ForgeReading = (temp: Int, time: Int), then read reading.temp.",
            ],
            solution: """
typealias ForgeReading = (temp: Int, time: Int)
let reading: ForgeReading = (temp: 1200, time: 1)
print(reading.temp)
""",
            topic: .general,

        ),

        Challenge(
            number: 68,
            title: "Enums",
            description: "Represent a set of cases",
            starterCode: """
                // Challenge 68: Enums
                // Represent forge metals.

                // TODO: Create an enum Metal with cases iron and gold
                // TODO: Create a value and print 'iron' or 'gold' using a switch
                """,
            expectedOutput: "iron",
            hints: [
                """
enum Metal {
    case iron
    case gold
}
""",
                "let metal = Metal.iron",
                #"""
switch metal {
case .iron:
    print("iron")
case .gold:
    print("gold")
}
"""#,
            ],
            solution: #"""
enum Metal {
    case iron
    case gold
}

let metal = Metal.iron

switch metal {
case .iron:
    print("iron")
case .gold:
    print("gold")
}
"""#,
            topic: .general,

        ),
        Challenge(
            number: 69,
            title: "Enums with Raw Values",
            description: "Represent simple categories",
            starterCode: """
                // Challenge 69: Enums with Raw Values
                // Represent metals.

                // TODO: Create an enum Metal: String with cases iron, gold
                // TODO: Print Metal.iron.rawValue
                """,
            expectedOutput: "iron",
            hints: [
                """
enum Metal: String {
    case iron
    case gold
}
""",
                "print(Metal.iron.rawValue)",
            ],
            solution: """
enum Metal: String {
    case iron
    case gold
}

print(Metal.iron.rawValue)
""",
            topic: .general,

        ),
        Challenge(
            number: 70,
            title: "Enums with Associated Values",
            description: "Represent structured events",
            starterCode: """
                // Challenge 70: Enums with Associated Values
                // Represent forge events.

                // TODO: Create an enum 'Event' with:
                // - temperature(Int)
                // - error(String)

                // TODO: Create one of each and print something based on the case
                // Use a switch to print:
                // - "Temp: 1500" for temperature(1500)
                // - "Error: Overheat" for error("Overheat")
                """,
            expectedOutput: "Temp: 1500\nError: Overheat",
            hints: [
                """
enum Event {
    case temperature(Int)
    case error(String)
}
""",
                #"""
let tempEvent = Event.temperature(1500)
let errorEvent = Event.error("Overheat")
"""#,
                #"""
switch tempEvent {
case .temperature(let value):
    print("Temp: \(value)")
case .error(let message):
    print("Error: \(message)")
}
"""#,
                #"""
switch errorEvent {
case .temperature(let value):
    print("Temp: \(value)")
case .error(let message):
    print("Error: \(message)")
}
"""#,
            ],
            solution: #"""
enum Event {
    case temperature(Int)
    case error(String)
}

let tempEvent = Event.temperature(1500)
let errorEvent = Event.error("Overheat")

switch tempEvent {
case .temperature(let value):
    print("Temp: \(value)")
case .error(let message):
    print("Error: \(message)")
}

switch errorEvent {
case .temperature(let value):
    print("Temp: \(value)")
case .error(let message):
    print("Error: \(message)")
}
"""#,
            topic: .general,

        ),
        Challenge(
            number: 71,
            title: "Enum Pattern Matching",
            description: "Match and extract associated values",
            starterCode: """
                // Challenge 71: Enum Pattern Matching
                // Use a switch with a where clause.

                enum Event {
                    case temperature(Int)
                    case error(String)
                }

                let event = Event.temperature(1600)

                // TODO: Use switch to print 'Overheated' when temp >= 1500
                // Print "Normal" for other temperature events
                // Print "Error" for error events
                """,
            expectedOutput: "Overheated",
            hints: [
                "Use a switch with a where clause on .temperature(let temp).",
            ],
            solution: #"""
switch event {
case .temperature(let temp) where temp >= 1500:
    print("Overheated")
case .temperature:
    print("Normal")
case .error:
    print("Error")
}
"""#,
            topic: .conditionals,

        ),
        Challenge(
            number: 72,
            title: "Throwing Functions",
            description: "Introduce error throwing",
            starterCode: """
                // Challenge 72: Throwing Functions
                // Validate temperature.

                // TODO: Create an enum TempError: Error with case outOfRange
                // TODO: Create a function 'checkTemp' that throws if temp < 0
                // TODO: Call it with -1 using do/try/catch
                // Print "Error" in the catch block
                """,
            expectedOutput: "Error",
            hints: [
                """
enum TempError: Error {
    case outOfRange
}
""",
                """
func checkTemp(_ temp: Int) throws {
    if temp < 0 {
        throw TempError.outOfRange
    }
}
""",
                #"""
 do {
    try checkTemp(-1)
} catch {
    print("Error")
}
"""#,
            ],
            solution: #"""
enum TempError: Error {
    case outOfRange
}

func checkTemp(_ temp: Int) throws {
    if temp < 0 {
        throw TempError.outOfRange
    }
}

 do {
    try checkTemp(-1)
} catch {
    print("Error")
}
"""#,
            topic: .functions,

        ),
        Challenge(
            number: 73,
            title: "try?",
            description: "Convert errors into optionals",
            starterCode: """
                // Challenge 73: try?
                // Use try? to simplify error handling.

                // TODO: Reuse checkTemp from the previous challenge
                // TODO: Make checkTemp return the temperature if valid
                // TODO: Call it with -1 using try?
                // TODO: Print the result (should be nil)
                """,
            expectedOutput: "nil",
            hints: [
                """
enum TempError: Error {
    case outOfRange
}
""",
                """
func checkTemp(_ temp: Int) throws -> Int {
    if temp < 0 {
        throw TempError.outOfRange
    }

    return temp
}
""",
                """
let result = try? checkTemp(-1)
print(result as Any)
""",
            ],
            solution: """
enum TempError: Error {
    case outOfRange
}

func checkTemp(_ temp: Int) throws -> Int {
    if temp < 0 {
        throw TempError.outOfRange
    }

    return temp
}

let result = try? checkTemp(-1)
print(result as Any)
""",
            topic: .functions,

        ),
        Challenge(
            number: 74,
            title: "ReadLine Input",
            description: "Read from standard input",
            starterCode: """
                // Challenge 74: readLine
                // Read a value from standard input.
                //
                // Run from repo root: swift workspace/challenge74.swift
                // Then type a metal and press Enter.

                // TODO: Prompt the user to type something
                // TODO: Read a line from input
                // TODO: If input exists, print "You entered <input>"
                // TODO: Otherwise print "No input"
                """,
            expectedOutput: "Manual check",
            hints: [
                #"""
print("Enter a metal: ", terminator: "")
if let input = readLine() {
    let message = "You entered \(input)"
    print(message)
} else {
    print("No input")
}
"""#,
            ],
            solution: #"""
print("Enter a metal: ", terminator: "")
if let input = readLine() {
    let message = "You entered \(input)"
    print(message)
} else {
    print("No input")
}
"""#,
            manualCheck: true,
            topic: .general,

        ),
        Challenge(
            number: 75,
            title: "Command-Line Arguments",
            description: "Read from CommandLine.arguments",
            starterCode: """
                // Challenge 75: Command-Line Arguments
                // Read arguments.
                //
                // Run from repo root: swift workspace/challenge75.swift Iron

                let args = CommandLine.arguments

                // TODO: If args has at least 2 items, print args[1]
                // Otherwise print "No args"
                //
                // Note: This prints only the first argument after the script name.
                """,
            expectedOutput: "Manual check",
            hints: [
                #"""
if args.count >= 2 {
    print(args[1])
} else {
    print("No args")
}
"""#,
            ],
            solution: #"""
if args.count >= 2 {
    print(args[1])
} else {
    print("No args")
}
"""#,
            manualCheck: true,
            topic: .general,

        ),
        Challenge(
            number: 76,
            title: "File Read",
            description: "Read from a file on disk",
            starterCode: """
                // Challenge 76: File Read
                // Read a file of temperatures.
                //
                // Create workspace/temperatures.txt:
                // 1) From repo root, run: printf "1200\\n1500\\n1600\\n" > workspace/temperatures.txt
                // 2) Or create the file manually with these lines:
                //    1200
                //    1500
                //    1600
                //
                // Run from repo root: swift workspace/challenge76.swift
                //
                // Note: This requires Foundation for String(contentsOfFile:).

                import Foundation

                let path = "workspace/temperatures.txt"

                // TODO: Read the file contents from path
                // TODO: Split the contents into lines
                // TODO: Print the number of lines
                //
                // Expected output: 3
                """,
            expectedOutput: "Manual check",
            hints: [
                #"""
if let fileContents = try? String(contentsOfFile: path, encoding: .utf8) {
    let lines = fileContents.split(separator: "\n")
    print(lines.count)
} else {
    print("Missing file")
}
"""#,
            ],
            solution: #"""
import Foundation

if let fileContents = try? String(contentsOfFile: path, encoding: .utf8) {
    let lines = fileContents.split(separator: "\n")
    print(lines.count)
} else {
    print("Missing file")
}
"""#,
            manualCheck: true,
            topic: .general,

        ),
        Challenge(
            number: 77,
            title: "Basic Test",
            description: "Check a condition and report result",
            starterCode: """
                // Challenge 77: Basic Test
                // Write a basic test case.
                //
                // Run from repo root: swift workspace/challenge77.swift

                // TODO: If 2 + 2 == 4, print "Test passed"
                """,
            expectedOutput: "Manual check",
            hints: [
                #"""
if 2 + 2 == 4 {
    print("Test passed")
}
"""#,
            ],
            solution: #"""
if 2 + 2 == 4 {
    print("Test passed")
}
"""#,
            manualCheck: true,
            topic: .general,

        ),
        Challenge(
            number: 78,
            title: "Integration Challenge",
            description: "Combine Core 3 concepts",
            starterCode: """
                // Challenge 78: Integration Challenge
                // Process forge logs with advanced tools.

                let lines = ["1200", "x", "1500", "1600", "bad", "1400"]

                // TODO: Convert each line to an Int? using Int()
                // TODO: Use compactMap to remove nils
                // TODO: Use filter to keep temps >= 1500
                // TODO: Use reduce to compute total
                // TODO: Print the total
                """,
            expectedOutput: "3100",
            hints: [
                "Use map → compactMap → filter → reduce in that order, then print the total.",
            ],
            solution: """
let values = lines.map { Int($0) }
let temps = values.compactMap { $0 }
let hotTemps = temps.filter { $0 >= 1500 }
let total = hotTemps.reduce(0) { $0 + $1 }
print(total)
""",
            topic: .general,

        ),
        Challenge(
            number: 79,
            title: "Safety Check",
            description: "Combine conditions with &&",
            starterCode: """
                // Challenge 79: Safety Check
                // Use && to require two conditions.

                let heatLevel = 3
                let hasVentilation = true

                // TODO: If heatLevel >= 3 AND hasVentilation, print "Safe"
                // Otherwise print "Unsafe"
                """,
            expectedOutput: "Safe",
            hints: [
                "Use if heatLevel >= 3 && hasVentilation { ... } else { ... }.",
            ],
            solution: """
if heatLevel >= 3 && hasVentilation {
    print("Safe")
} else {
    print("Unsafe")
}
""",
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 80,
            title: "Heat Levels",
            description: "Use if/else if/else with ranges",
            starterCode: """
                // Challenge 80: Heat Levels
                // Categorize a value using if/else if/else.

                let heatLevel = 1

                // TODO: If heatLevel == 0, print "Off"
                // TODO: Else if heatLevel <= 2, print "Warm"
                // TODO: Else print "Hot"
                """,
            expectedOutput: "Warm",
            hints: [
                "Use if heatLevel == 0, then else if heatLevel <= 2, else.",
            ],
            solution: """
if heatLevel == 0 {
    print("Off")
} else if heatLevel <= 2 {
    print("Warm")
} else {
    print("Hot")
}
""",
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 81,
            title: "Count Multiples",
            description: "Count matches in a loop",
            starterCode: """
                // Challenge 81: Count Multiples
                // Count numbers divisible by 3.

                let numbers = [1, 2, 3, 4, 5, 6]
                var count = 0

                // TODO: Loop through numbers
                // TODO: If a number is divisible by 3, increment count
                // TODO: Print count
                """,
            expectedOutput: "2",
            hints: [
                "Use number % 3 == 0 to test divisibility.",
            ],
            solution: """
for number in numbers {
    if number % 3 == 0 {
        count += 1
    }
}

print(count)
""",
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 82,
            title: "Running Total",
            description: "Break when a total reaches a limit",
            starterCode: """
                // Challenge 82: Running Total
                // Add values until the total reaches a limit.

                let temps = [900, 1000, 1200, 1500]
                var total = 0

                // TODO: Loop through temps and add to total
                // TODO: If total >= 2500, break
                // TODO: Print total
                """,
            expectedOutput: "3100",
            hints: [
                "Update total inside the loop, then check if total >= 2500 to break.",
            ],
            solution: """
for temp in temps {
    total += temp
    if total >= 2500 {
        break
    }
}

print(total)
""",
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 83,
            title: "Optional Conversion",
            description: "Convert a string to an Int safely",
            starterCode: """
                // Challenge 83: Optional Conversion
                // Use if let with Int().

                let input = "1500"

                // TODO: Convert input to an Int using if let
                // TODO: Print "Temp: <value>"
                // TODO: Otherwise print "Invalid"
                """,
            expectedOutput: "Temp: 1500",
            hints: [
                "Use if let temp = Int(input) { ... } else { ... }.",
            ],
            solution: """
if let temp = Int(input) {
    print("Temp: \\(temp)")
} else {
    print("Invalid")
}
""",
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 84,
            title: "Guard Conversion",
            description: "Use guard let for early exit",
            starterCode: """
                // Challenge 84: Guard Conversion
                // Use guard let to unwrap and convert.

                func readTemp(_ value: String?) {
                    // TODO: Use guard let to unwrap value and convert to Int
                    // Print "Invalid" if conversion fails
                    // Otherwise print "Temp: <value>"
                }

                // TODO: Call readTemp with "abc"
                """,
            expectedOutput: "Invalid",
            hints: [
                "Use guard let value = value, let temp = Int(value) else { print(\"Invalid\"); return }.",
            ],
            solution: """
func readTemp(_ value: String?) {
    guard let value = value, let temp = Int(value) else {
        print("Invalid")
        return
    }
    print("Temp: \\(temp)")
}

readTemp("abc")
""",
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 85,
            title: "Inventory Update",
            description: "Update a dictionary value",
            starterCode: """
                // Challenge 85: Inventory Update
                // Increment a dictionary value.

                var inventory = ["Iron": 1]

                // TODO: Increase the count for "Iron" by 1
                // TODO: Print the new count
                """,
            expectedOutput: "2",
            hints: [
                "Use inventory[\"Iron\", default: 0] += 1, then print the value.",
            ],
            solution: """
inventory["Iron", default: 0] += 1
print(inventory["Iron", default: 0])
""",
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 86,
            title: "Remove from Array",
            description: "Remove an element by index",
            starterCode: """
                // Challenge 86: Remove from Array
                // Remove one item and print the result.

                var metals = ["Iron", "Gold", "Copper"]

                // TODO: Remove "Gold"
                // TODO: Print metals
                """,
            expectedOutput: #"["Iron", "Copper"]"#,
            hints: [
                "Use metals.remove(at: 1), then print metals.",
            ],
            solution: """
metals.remove(at: 1)
print(metals)
""",
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 87,
            title: "Boolean Return",
            description: "Return true or false from a function",
            starterCode: """
                // Challenge 87: Boolean Return
                // Return a Bool from a function.

                // TODO: Create a function isOverheated(temp:) -> Bool
                // Return true when temp >= 1500
                // TODO: Call it with 1600 and print the result
                """,
            expectedOutput: "true",
            hints: [
                "Return temp >= 1500, then print isOverheated(temp: 1600).",
            ],
            solution: """
func isOverheated(temp: Int) -> Bool {
    return temp >= 1500
}

print(isOverheated(temp: 1600))
""",
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 88,
            title: "Helper Function",
            description: "Call one function from another",
            starterCode: """
                // Challenge 88: Helper Function
                // Use a helper to build a message.

                // TODO: Create a function label(temp:) -> String returning "T<temp>"
                // TODO: Create a function printLabel(for:) that prints label(temp:)
                // TODO: Call printLabel with 1200
                """,
            expectedOutput: "T1200",
            hints: [
                "Have printLabel(for:) call label(temp:) and print the result.",
            ],
            solution: """
func label(temp: Int) -> String {
    return "T\\(temp)"
}

func printLabel(for temp: Int) {
    print(label(temp: temp))
}

printLabel(for: 1200)
""",
            topic: .functions,
            tier: .extra
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
            starterCode: #"""
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

                // Test code (don't modify):
                print(celsiusToFahrenheit(celsius: 0))
                print(celsiusToFahrenheit(celsius: 100))
                print(celsiusToFahrenheit(celsius: 37))
                """#,
            testCases: [
                (input: "0", expectedOutput: "32"),
                (input: "100", expectedOutput: "212"),
                (input: "37", expectedOutput: "98"),  // Accepting Int version
            ],
            completionTitle: "🎆 Core 1 Complete!",
            completionMessage: "You've mastered the fundamentals. Well done.",
            hints: [
                """
func celsiusToFahrenheit(celsius: Int) -> Int {
    return (celsius * 9) / 5 + 32
}
""",
            ],
            solution: """
func celsiusToFahrenheit(celsius: Int) -> Int {
    return (celsius * 9) / 5 + 32
}
""",
            tier: .core
        ),
        Project(
            id: "core1b",
            pass: 1,
            title: "Forge Checklist",
            description: "Combine variables, functions, and comparisons",
            starterCode: #"""
                // Core 1 Project B: Forge Checklist
                // Build a basic readiness check.
                //
                // Requirements:
                // - Create constants for metal and target temperature
                // - Write a function isReady(metal:temperature:) -> Bool
                // - Print three lines:
                //   "Metal: <metal>"
                //   "Target: <temperature>"
                //   "Ready: <true/false>"
                //
                // TODO: Write your readiness logic

                // Test code (don't modify):
                let metal = "Iron"
                let target = 1500
                let ready = isReady(metal: metal, temperature: target)
                print("Metal: \(metal)")
                print("Target: \(target)")
                print("Ready: \(ready)")
                """#,
            testCases: [
                (input: "metal", expectedOutput: "Metal: Iron"),
                (input: "target", expectedOutput: "Target: 1500"),
                (input: "ready", expectedOutput: "Ready: true"),
            ],
            completionTitle: "✨ Core 1 Extra Project Complete!",
            completionMessage: "Nice work reinforcing the basics.",
            hints: [
                """
func isReady(metal: String, temperature: Int) -> Bool {
    if metal == "Iron" {
        return temperature >= 1400
    }
    return temperature >= 1200
}
""",
            ],
            solution: """
func isReady(metal: String, temperature: Int) -> Bool {
    if metal == "Iron" {
        return temperature >= 1400
    }
    return temperature >= 1200
}
""",
            tier: .extra
        ),
        Project(
            id: "core1c",
            pass: 1,
            title: "Ingot Calculator",
            description: "Use arithmetic and a helper function",
            starterCode: #"""
                // Core 1 Project C: Ingot Calculator
                // Calculate a total from simple inputs.
                //
                // Requirements:
                // - Create a function totalIngots(base:batches:) -> Int
                // - Return base + (batches * 2)
                // - Print:
                //   "Base: 4"
                //   "Batches: 3"
                //   "Total: 10"
                //
                // TODO: Write totalIngots

                // Test code (don't modify):
                let base = 4
                let batches = 3
                let total = totalIngots(base: base, batches: batches)
                print("Base: \(base)")
                print("Batches: \(batches)")
                print("Total: \(total)")
                """#,
            testCases: [
                (input: "base", expectedOutput: "Base: 4"),
                (input: "batches", expectedOutput: "Batches: 3"),
                (input: "total", expectedOutput: "Total: 10"),
            ],
            completionTitle: "✨ Core 1 Extra Project Complete!",
            completionMessage: "You’re getting fast with core syntax.",
            hints: [
                """
func totalIngots(base: Int, batches: Int) -> Int {
    return base + (batches * 2)
}
""",
            ],
            solution: """
func totalIngots(base: Int, batches: Int) -> Int {
    return base + (batches * 2)
}
""",
            tier: .extra
        ),
        Project(
            id: "core2a",
            pass: 2,
            title: "Forge Log Analyzer",
            description: "Analyze a list of forge temperatures",
            starterCode: #"""
                // Core 2 Project A: Forge Log Analyzer
                // Analyze a list of forge temperatures
                //
                // Requirements:
                // - Function name: analyzeTemperatures
                // - Takes one [Int] parameter labeled temperatures
                // - Returns a tuple: (min: Int, max: Int, average: Int, overheatCount: Int)
                // - average should use integer division
                // - overheatCount should count values >= 1500
                // - Use named tuple fields (min, max, average, overheatCount)
                //
                // Your function will be tested with:
                // - [1200, 1500, 1600, 1400]
                //
                // Expected outputs:
                // Min: 1200
                // Max: 1600
                // Average: 1425
                // Overheat: 2

                // TODO: Write your 'analyzeTemperatures' function here

                // Test code (don't modify):
                let report = analyzeTemperatures(temperatures: [1200, 1500, 1600, 1400])
                print("Min: \(report.min)")
                print("Max: \(report.max)")
                print("Average: \(report.average)")
                print("Overheat: \(report.overheatCount)")
                """#,
            testCases: [
                (input: "min", expectedOutput: "Min: 1200"),
                (input: "max", expectedOutput: "Max: 1600"),
                (input: "average", expectedOutput: "Average: 1425"),
                (input: "overheat", expectedOutput: "Overheat: 2"),
            ],
            completionTitle: "🏗️ Core 2 Complete!",
            completionMessage: "Control flow and collections are now in your toolkit.",
            hints: [
                """
func analyzeTemperatures(temperatures: [Int]) -> (min: Int, max: Int, average: Int, overheatCount: Int) {
    var minTemp = temperatures[0]
    var maxTemp = temperatures[0]
    var sum = 0
    var overheat = 0
""",
                """
    for temp in temperatures {
        if temp < minTemp { minTemp = temp }
        if temp > maxTemp { maxTemp = temp }
        sum += temp
        if temp >= 1500 { overheat += 1 }
    }
""",
                """
    let average = sum / temperatures.count
    return (min: minTemp, max: maxTemp, average: average, overheatCount: overheat)
}
""",
            ],
            solution: """
func analyzeTemperatures(temperatures: [Int]) -> (min: Int, max: Int, average: Int, overheatCount: Int) {
    var minTemp = temperatures[0]
    var maxTemp = temperatures[0]
    var sum = 0
    var overheat = 0

    for temp in temperatures {
        if temp < minTemp { minTemp = temp }
        if temp > maxTemp { maxTemp = temp }
        sum += temp
        if temp >= 1500 { overheat += 1 }
    }

    let average = sum / temperatures.count
    return (min: minTemp, max: maxTemp, average: average, overheatCount: overheat)
}
""",
            tier: .core
        ),
        Project(
            id: "core2b",
            pass: 2,
            title: "Inventory Audit",
            description: "Loop through a dictionary and summarize counts",
            starterCode: #"""
                // Core 2 Project B: Inventory Audit
                // Summarize inventory levels.
                //
                // Requirements:
                // - Function name: auditInventory
                // - Takes [String: Int] inventory
                // - Returns (total: Int, empty: Int)
                // - Loop through items to compute total count
                // - Count how many items are empty (count == 0)
                // - Print:
                //   "Total: 3"
                //   "Empty: 1"
                //
                // TODO: Write auditInventory

                // Test code (don't modify):
                let inventory = ["Iron": 2, "Gold": 1, "Copper": 0]
                let report = auditInventory(inventory)
                print("Total: \(report.total)")
                print("Empty: \(report.empty)")
                """#,
            testCases: [
                (input: "total", expectedOutput: "Total: 3"),
                (input: "empty", expectedOutput: "Empty: 1"),
            ],
            completionTitle: "✨ Core 2 Extra Project Complete!",
            completionMessage: "Solid work with loops and dictionaries.",
            hints: [
                """
func auditInventory(_ inventory: [String: Int]) -> (total: Int, empty: Int) {
    var total = 0
    var empty = 0
    for (_, count) in inventory {
        total += count
        if count == 0 { empty += 1 }
    }
    return (total: total, empty: empty)
}
""",
            ],
            solution: """
func auditInventory(_ inventory: [String: Int]) -> (total: Int, empty: Int) {
    var total = 0
    var empty = 0
    for (_, count) in inventory {
        total += count
        if count == 0 { empty += 1 }
    }
    return (total: total, empty: empty)
}
""",
            tier: .extra
        ),
        Project(
            id: "core2c",
            pass: 2,
            title: "Optional Readings",
            description: "Unwrap optionals and compute an average",
            starterCode: #"""
                // Core 2 Project C: Optional Readings
                // Compute metrics from optional values.
                //
                // Requirements:
                // - Function name: summarizeReadings
                // - Takes [Int?] readings
                // - Returns (count: Int, average: Int)
                // - Use if let to unwrap readings
                // - Count valid readings and compute average
                // - Print:
                //   "Valid: 3"
                //   "Average: 1433"
                //
                // TODO: Write summarizeReadings

                // Test code (don't modify):
                let readings: [Int?] = [1200, nil, 1500, 1600]
                let report = summarizeReadings(readings)
                print("Valid: \(report.count)")
                print("Average: \(report.average)")
                """#,
            testCases: [
                (input: "valid", expectedOutput: "Valid: 3"),
                (input: "average", expectedOutput: "Average: 1433"),
            ],
            completionTitle: "✨ Core 2 Extra Project Complete!",
            completionMessage: "Nice job handling optionals.",
            hints: [
                """
func summarizeReadings(_ readings: [Int?]) -> (count: Int, average: Int) {
    var count = 0
    var total = 0
    for reading in readings {
        if let value = reading {
            count += 1
            total += value
        }
    }
    let average = count == 0 ? 0 : total / count
    return (count: count, average: average)
}
""",
            ],
            solution: """
func summarizeReadings(_ readings: [Int?]) -> (count: Int, average: Int) {
    var count = 0
    var total = 0
    for reading in readings {
        if let value = reading {
            count += 1
            total += value
        }
    }
    let average = count == 0 ? 0 : total / count
    return (count: count, average: average)
}
""",
            tier: .extra
        ),
        Project(
            id: "core3a",
            pass: 3,
            title: "Forge Log Interpreter",
            description: "Build a full data-processing pipeline for forge logs",
            starterCode: #"""
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
                // TODO: Define the ForgeEvent enum with cases:
                // - temperature(Int)
                // - error(String)
                //
                // TODO: Write a throwing 'parseLine(_:)' function that:
                // - splits the line into parts
                // - returns .temperature for valid temps
                // - returns .error for error lines
                // - throws for malformed lines
                //
                // TODO: In interpretForgeLogs(lines:):
                // - use compactMap to parse lines safely
                // - separate temps from errors with filter/map
                // - compute average with reduce (integer division)
                // - count overheat temps (>= 1500)
                // - return the summary tuple
                //
                // Test code (don't modify):
                let logs = ["TEMP 1400", "TEMP 1600", "ERROR Overheated", "TEMP abc", "TEMP 1500"]
                let report = interpretForgeLogs(lines: logs)
                print("Valid: \(report.validCount)")
                print("Average: \(report.averageTemp)")
                print("Overheats: \(report.overheatEvents)")
                print("Errors: \(report.errors)")
                """#,
            testCases: [
                (input: "valid", expectedOutput: "Valid: 3"),
                (input: "average", expectedOutput: "Average: 1500"),
                (input: "overheat", expectedOutput: "Overheats: 2"),
                (input: "errors", expectedOutput: "Errors: [\"Overheated\"]"),
            ],
            completionTitle: "🧠 Core 3 Complete!",
            completionMessage: "Advanced Swift tools are now in your hands.",
            hints: [
                """
enum ForgeEvent {
    case temperature(Int)
    case error(String)
}
""",
                """
enum ParseError: Error {
    case malformed
}
""",
                #"""
func parseLine(_ line: String) throws -> ForgeEvent {
    let parts = line.split(separator: " ")
    guard parts.count >= 2 else {
        throw ParseError.malformed
    }
    let tag = parts[0]
    let rest = parts.dropFirst().joined(separator: " ")
    if tag == "TEMP", let value = Int(rest) {
        return .temperature(value)
    }
    if tag == "ERROR" {
        return .error(rest)
    }
    throw ParseError.malformed
}
"""#,
                """
func interpretForgeLogs(lines: [String]) -> (validCount: Int, averageTemp: Int, overheatEvents: Int, errors: [String]) {
    let events = lines.compactMap { try? parseLine($0) }
    let temps = events.compactMap { event -> Int? in
        if case .temperature(let value) = event {
            return value
        }
        return nil
    }
    let errors = events.compactMap { event -> String? in
        if case .error(let message) = event {
            return message
        }
        return nil
    }
    let total = temps.reduce(0, +)
    let average = temps.isEmpty ? 0 : total / temps.count
    let overheat = temps.filter { $0 >= 1500 }.count
    return (validCount: temps.count, averageTemp: average, overheatEvents: overheat, errors: errors)
}
""",
            ],
            solution: #"""
enum ForgeEvent {
    case temperature(Int)
    case error(String)
}

enum ParseError: Error {
    case malformed
}

func parseLine(_ line: String) throws -> ForgeEvent {
    let parts = line.split(separator: " ")
    guard parts.count >= 2 else {
        throw ParseError.malformed
    }
    let tag = parts[0]
    let rest = parts.dropFirst().joined(separator: " ")
    if tag == "TEMP", let value = Int(rest) {
        return .temperature(value)
    }
    if tag == "ERROR" {
        return .error(rest)
    }
    throw ParseError.malformed
}

func interpretForgeLogs(lines: [String]) -> (validCount: Int, averageTemp: Int, overheatEvents: Int, errors: [String]) {
    let events = lines.compactMap { try? parseLine($0) }
    let temps = events.compactMap { event -> Int? in
        if case .temperature(let value) = event {
            return value
        }
        return nil
    }
    let errors = events.compactMap { event -> String? in
        if case .error(let message) = event {
            return message
        }
        return nil
    }
    let total = temps.reduce(0, +)
    let average = temps.isEmpty ? 0 : total / temps.count
    let overheat = temps.filter { $0 >= 1500 }.count
    return (validCount: temps.count, averageTemp: average, overheatEvents: overheat, errors: errors)
}
"""#,
            tier: .core
        ),
        Project(
            id: "core3b",
            pass: 3,
            title: "Temperature Pipeline",
            description: "Use higher-order functions to compute a summary",
            starterCode: #"""
                // Core 3 Project B: Temperature Pipeline
                // Transform and summarize temperature data.
                //
                // Requirements:
                // - Function name: summarizeTemps
                // - Takes [Int] temps
                // - Map: add 100 to each temp
                // - Filter: keep temps >= 1500
                // - Reduce: total the filtered temps
                // - Return (count: Int, total: Int)
                //
                // TODO: Write summarizeTemps

                // Test code (don't modify):
                let temps = [1200, 1500, 1600, 1400]
                let report = summarizeTemps(temps)
                print("Count: \(report.count)")
                print("Total: \(report.total)")
                """#,
            testCases: [
                (input: "count", expectedOutput: "Count: 3"),
                (input: "total", expectedOutput: "Total: 4800"),
            ],
            completionTitle: "✨ Core 3 Extra Project Complete!",
            completionMessage: "Great work with functional tools.",
            hints: [
                "Use map, filter, and reduce; return (count: filtered.count, total: total).",
            ],
            solution: """
func summarizeTemps(_ temps: [Int]) -> (count: Int, total: Int) {
    let adjusted = temps.map { $0 + 100 }
    let hot = adjusted.filter { $0 >= 1500 }
    let total = hot.reduce(0, +)
    return (count: hot.count, total: total)
}
""",
            tier: .extra
        ),
        Project(
            id: "core3c",
            pass: 3,
            title: "Event Router",
            description: "Parse lines into events with errors",
            starterCode: #"""
                // Core 3 Project C: Event Router
                // Parse events and summarize results.
                //
                // Requirements:
                // - Define Event enum with .temperature(Int) and .error(String)
                // - Write parseLine(_:) that throws on malformed lines
                // - Use compactMap with try? to skip malformed lines
                // - Count valid temps (>= 0), find max temp, collect errors
                // - If no temps, max temp should be 0
                //
                // TODO: Implement interpretEvents(lines:)

                // Test code (don't modify):
                let lines = ["TEMP 1400", "ERROR Jam", "TEMP -1", "BAD"]
                let report = interpretEvents(lines: lines)
                print("Temps: \(report.tempCount)")
                print("Max: \(report.maxTemp)")
                print("Errors: \(report.errorCount)")
                """#,
            testCases: [
                (input: "temps", expectedOutput: "Temps: 1"),
                (input: "max", expectedOutput: "Max: 1400"),
                (input: "errors", expectedOutput: "Errors: 1"),
            ],
            completionTitle: "✨ Core 3 Extra Project Complete!",
            completionMessage: "Enums and errors are clicking.",
            hints: [
                "Use try? parseLine in compactMap, then switch to separate temps and errors.",
            ],
            solution: """
enum Event {
    case temperature(Int)
    case error(String)
}

enum ParseError: Error {
    case malformed
}

func parseLine(_ line: String) throws -> Event {
    let parts = line.split(separator: " ")
    guard parts.count >= 2 else {
        throw ParseError.malformed
    }
    let tag = parts[0]
    let rest = parts.dropFirst().joined(separator: " ")
    if tag == "TEMP", let value = Int(rest) {
        return .temperature(value)
    }
    if tag == "ERROR" {
        return .error(rest)
    }
    throw ParseError.malformed
}

func interpretEvents(lines: [String]) -> (tempCount: Int, maxTemp: Int, errorCount: Int) {
    let events = lines.compactMap { try? parseLine($0) }
    var temps: [Int] = []
    var errorCount = 0

    for event in events {
        switch event {
        case .temperature(let value):
            if value >= 0 {
                temps.append(value)
            }
        case .error:
            errorCount += 1
        }
    }

    let maxTemp = temps.max() ?? 0
    return (tempCount: temps.count, maxTemp: maxTemp, errorCount: errorCount)
}
""",
            tier: .extra
        ),
    ]
}
