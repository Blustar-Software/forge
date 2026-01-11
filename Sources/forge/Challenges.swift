import Foundation

// Centralized challenge definitions for the CLI flow.
struct Challenge {
    let number: Int
    let title: String
    let description: String
    let starterCode: String
    let expectedOutput: String
    let hints: [String]
    let solution: String

    init(
        number: Int,
        title: String,
        description: String,
        starterCode: String,
        expectedOutput: String,
        hints: [String] = [],
        solution: String = ""
    ) {
        self.number = number
        self.title = title
        self.description = description
        self.starterCode = starterCode
        self.expectedOutput = expectedOutput
        self.hints = hints
        self.solution = solution
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
        solution: String = ""
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
                #"""
func greet() {
    print("Hello, Forge")
}
"""#,
            ],
            solution: #"""
func greet() {
    print("Hello, Forge")
}

greet()
"""#
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
"""#
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
"""
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
"""
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
"""
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
"""#
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
                """
print(a + b)
print(a - b)
print(a * b)
print(a / b)
print(a % b)
""",
            ],
            solution: """
print(a + b)
print(a - b)
print(a * b)
print(a / b)
print(a % b)
"""
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
"""
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
"""#
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
print("Forge level: \(forgeLevel)")
"""#,
            ],
            solution: #"""
let forgeLevel = 3
print("Forge level: \(forgeLevel)")
"""#
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
print(isHeated)
""",
            ],
            solution: """
let isHeated: Bool = true
print(isHeated)
"""
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
                """
print(a == b)
print(a != b)
print(a < b)
print(a > b)
print(a <= b)
print(b >= a)
""",
            ],
            solution: """
print(a == b)
print(a != b)
print(a < b)
print(a > b)
print(a <= b)
print(b >= a)
"""
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
"""
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
"""#
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
"""#
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
"""
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
"""#
        ),
        Challenge(
            number: 18,
            title: "Integration Challenge 2",
            description: "Use everything from Pass 1 in a slightly larger task",
            starterCode: """
                // Challenge 18: Integration Challenge 2
                // Combine constants, variables, math, functions, and comparisons

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
"""#
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
                #"""
if heatLevel >= 3 {
    print("Hot")
} else if heatLevel == 2 {
    print("Warm")
} else {
    print("Cold")
}
"""#,
            ],
            solution: #"""
if heatLevel >= 3 {
    print("Hot")
} else if heatLevel == 2 {
    print("Warm")
} else {
    print("Cold")
}
"""#
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
"""#
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
                #"""
switch metal {
case "Iron":
    print("Forgeable")
case "Gold":
    print("Soft")
default:
    print("Unknown")
}
"""#,
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
"""#
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
                #"""
switch temperature {
case 0...1199:
    print("Too cold")
case 1200...1499:
    print("Working")
default:
    print("Overheated")
}
"""#,
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
"""#
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
                """
for i in 1...5 {
    total += i
}
print(total)
""",
            ],
            solution: """
for i in 1...5 {
    total += i
}
print(total)
"""
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
                """
while count > 0 {
    print(count)
    count -= 1
}
""",
            ],
            solution: """
while count > 0 {
    print(count)
    count -= 1
}
"""
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
                """
repeat {
    value += 1
} while value < 1

print(value)
""",
            ],
            solution: """
repeat {
    value += 1
} while value < 1

print(value)
"""
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
"""
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
                """
for i in 1...3 {
    print(i)
}
for i in 1..<3 {
    print(i)
}
""",
            ],
            solution: """
for i in 1...3 {
    print(i)
}
for i in 1..<3 {
    print(i)
}
"""
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
                """
let ingots = [1, 2, 3]
print(ingots)
""",
            ],
            solution: """
let ingots = [1, 2, 3]
print(ingots)
"""
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
"""
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
"""
        ),
        Challenge(
            number: 31,
            title: "Array Metrics",
            description: "Practice the logic for the Core 2 project",
            starterCode: """
                // Challenge 31: Array Metrics
                // Practice the logic you will need for the project

                let temps = [1200, 1500, 1600, 1400]

                // TODO: Find the minimum value (start with temps[0] and update)
                // TODO: Find the maximum value (start with temps[0] and update)
                // TODO: Compute the average (sum then divide by temps.count)
                // TODO: Count values >= 1500
                // TODO: Print results as:
                // "Min: 1200"
                // "Max: 1600"
                // "Average: 1425"
                // "Overheat: 2"
                """,
            expectedOutput: "Min: 1200\nMax: 1600\nAverage: 1425\nOverheat: 2",
            hints: [
                """
var minTemp = temps[0]
var maxTemp = temps[0]
var sum = 0
var overheat = 0
""",
                """
for temp in temps {
    if temp < minTemp { minTemp = temp }
    if temp > maxTemp { maxTemp = temp }
    sum += temp
    if temp >= 1500 { overheat += 1 }
}
""",
                "let average = sum / temps.count",
                #"""
print("Min: \(minTemp)")
print("Max: \(maxTemp)")
print("Average: \(average)")
print("Overheat: \(overheat)")
"""#,
            ],
            solution: #"""
var minTemp = temps[0]
var maxTemp = temps[0]
var sum = 0
var overheat = 0

for temp in temps {
    if temp < minTemp { minTemp = temp }
    if temp > maxTemp { maxTemp = temp }
    sum += temp
    if temp >= 1500 { overheat += 1 }
}

let average = sum / temps.count

print("Min: \(minTemp)")
print("Max: \(maxTemp)")
print("Average: \(average)")
print("Overheat: \(overheat)")
"""#
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
                """
print(ingots.count)
print(ingots.isEmpty)
print(ingots.first ?? 0)
print(inventory.count)
print(inventory.keys.count)
""",
            ],
            solution: """
print(ingots.count)
print(ingots.isEmpty)
print(ingots.first ?? 0)
print(inventory.count)
print(inventory.keys.count)
"""
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
                #"""
let count = inventory["Iron", default: 0]
print(count)
"""#,
            ],
            solution: #"""
let count = inventory["Iron", default: 0]
print(count)
"""#
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
                """
let unique = Set(batch)
print(unique.count)
""",
            ],
            solution: """
let unique = Set(batch)
print(unique.count)
"""
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
                #"""
print(temps.0)
print(temps.1)
print("Min: \(report.min)")
print("Max: \(report.max)")
print("Average: \(report.average)")
"""#,
            ],
            solution: #"""
print(temps.0)
print(temps.1)
print("Min: \(report.min)")
print("Max: \(report.max)")
print("Average: \(report.average)")
"""#
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
                #"""
if let level = heatLevel {
    print(level)
} else {
    print("No heat")
}
"""#,
            ],
            solution: #"""
if let level = heatLevel {
    print(level)
} else {
    print("No heat")
}
"""#
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
                #"""
if let smithName = smithName, let metal = metal {
    print("\(smithName) works \(metal)")
}
"""#,
            ],
            solution: #"""
if let smithName = smithName, let metal = metal {
    print("\(smithName) works \(metal)")
}
"""#
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
"""#
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
                #"""
let level = optionalLevel ?? 1
print("Level \(level)")
"""#,
            ],
            solution: #"""
let level = optionalLevel ?? 1
print("Level \(level)")
"""#
        ),
    ]
}

func makeCore3Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 40,
            title: "External & Internal Labels",
            description: "Design clear APIs with distinct labels",
            starterCode: """
                // Challenge 40: External & Internal Labels
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
"""#
        ),
        Challenge(
            number: 41,
            title: "Void Argument Labels",
            description: "Omit external labels when needed",
            starterCode: """
                // Challenge 41: Void Argument Labels
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
"""#
        ),
        Challenge(
            number: 42,
            title: "Default Parameters",
            description: "Use default values to simplify calls",
            starterCode: """
                // Challenge 42: Default Parameters
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
"""#
        ),
        Challenge(
            number: 43,
            title: "Variadics",
            description: "Accept any number of values",
            starterCode: """
                // Challenge 43: Variadics
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
"""
        ),
        Challenge(
            number: 44,
            title: "inout Parameters",
            description: "Mutate a value passed into a function",
            starterCode: """
                // Challenge 44: inout Parameters
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
"""
        ),
        Challenge(
            number: 45,
            title: "Nested Functions",
            description: "Use helper functions inside functions",
            starterCode: """
                // Challenge 45: Nested Functions
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
"""#
        ),
        Challenge(
            number: 46,
            title: "Closure Basics",
            description: "Create and call a closure",
            starterCode: """
                // Challenge 46: Closure Basics
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
"""#
        ),
        Challenge(
            number: 47,
            title: "Closure Parameters",
            description: "Pass values into a closure",
            starterCode: """
                // Challenge 47: Closure Parameters
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
"""
        ),
        Challenge(
            number: 48,
            title: "Implicit Return in Closures",
            description: "Omit the return keyword in a single-expression closure",
            starterCode: """
                // Challenge 48: Implicit Return in Closures
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
"""
        ),
        Challenge(
            number: 49,
            title: "Inferred Closure Types",
            description: "Let Swift infer parameter and return types",
            starterCode: """
                // Challenge 49: Inferred Closure Types
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
"""
        ),
        Challenge(
            number: 50,
            title: "Shorthand Closure Syntax I",
            description: "Use $0 in an assigned closure",
            starterCode: """
                // Challenge 50: Shorthand Closure Syntax I
                // Use $0 in a closure stored in a constant.

                // TODO: Create a closure called 'doubleHeat' using $0
                // It should multiply the input by 2
                // TODO: Print doubleHeat(700)
                """,
            expectedOutput: "1400",
            hints: [
                """
let doubleHeat = { $0 * 2 }
print(doubleHeat(700))
""",
            ],
            solution: """
let doubleHeat = { $0 * 2 }
print(doubleHeat(700))
"""
        ),
        Challenge(
            number: 51,
            title: "Annotated Closure Assignment",
            description: "Bind a closure to a typed constant",
            starterCode: """
                // Challenge 51: Annotated Closure Assignment
                // Use a closure with an explicit type annotation.

                // TODO: Create a constant 'doubleHeat' with type (Int) -> Int
                // Use a shorthand closure to multiply the input by 2
                // TODO: Print doubleHeat(900)
                """,
            expectedOutput: "1800",
            hints: [
                """
let doubleHeat: (Int) -> Int = { $0 * 2 }
print(doubleHeat(900))
""",
            ],
            solution: """
let doubleHeat: (Int) -> Int = { $0 * 2 }
print(doubleHeat(900))
"""
        ),
        Challenge(
            number: 52,
            title: "Closure Arguments",
            description: "Call a function with a closure argument",
            starterCode: """
                // Challenge 52: Closure Arguments
                // Call a function that takes a closure.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using the full closure argument
                // Multiply the value by 3
                """,
            expectedOutput: "15",
            hints: [
                """
transform(5, using: { (value: Int) -> Int in
    return value * 3
})
""",
            ],
            solution: """
transform(5, using: { (value: Int) -> Int in
    return value * 3
})
"""
        ),
        Challenge(
            number: 53,
            title: "Trailing Closures",
            description: "Use trailing closure syntax",
            starterCode: """
                // Challenge 53: Trailing Closures
                // Use a closure to transform values.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using trailing closure syntax
                // Multiply the value by 3
                """,
            expectedOutput: "15",
            hints: [
                """
transform(5) { (value: Int) -> Int in
    return value * 3
}
""",
            ],
            solution: """
transform(5) { (value: Int) -> Int in
    return value * 3
}
"""
        ),
        Challenge(
            number: 54,
            title: "Inferred Trailing Closures",
            description: "Drop types and return when they can be inferred",
            starterCode: """
                // Challenge 54: Inferred Trailing Closures
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
                """
transform(6) { value in
    return value * 4
}
""",
            ],
            solution: """
transform(6) { value in
    return value * 4
}
"""
        ),
        Challenge(
            number: 55,
            title: "Shorthand Closure Syntax II",
            description: "Use $0 for compact closures",
            starterCode: """
                // Challenge 55: Shorthand Closure Syntax II
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
            solution: "apply(4) { $0 + 6 }"
        ),

        Challenge(
            number: 56,
            title: "Capturing Values",
            description: "Understand closure capture behavior",
            starterCode: """
                // Challenge 56: Capturing Values
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
"""
        ),
        Challenge(
            number: 57,
            title: "map",
            description: "Transform values with map",
            starterCode: """
                // Challenge 57: map
                // Transform forge temperatures into strings.

                let temps = [1200, 1500, 1600]

                // TODO: Use map to turn each temp into "T<temp>" (e.g "T1200"); In other words, prefix each temp with the letter 'T'.
                // TODO: Print the resulting array
                """,
            expectedOutput: #"["T1200", "T1500", "T1600"]"#,
            hints: [
                #"""
let labels = temps.map { "T\($0)" }
print(labels)
"""#,
            ],
            solution: #"""
let labels = temps.map { "T\($0)" }
print(labels)
"""#
        ),
        Challenge(
            number: 58,
            title: "filter",
            description: "Select values with filter",
            starterCode: """
                // Challenge 58: filter
                // Keep only hot temperatures.

                let temps = [1000, 1500, 1600, 1400]

                // TODO: Use filter to keep temps >= 1500
                // TODO: Print the filtered array
                """,
            expectedOutput: "[1500, 1600]",
            hints: [
                """
let hot = temps.filter { $0 >= 1500 }
print(hot)
""",
            ],
            solution: """
let hot = temps.filter { $0 >= 1500 }
print(hot)
"""
        ),
        Challenge(
            number: 59,
            title: "reduce",
            description: "Combine values with reduce",
            starterCode: """
                // Challenge 59: reduce
                // Sum forge temperatures.

                let temps = [1000, 1200, 1400]

                // TODO: Use reduce to compute the total
                // TODO: Print the total
                """,
            expectedOutput: "3600",
            hints: [
                """
let total = temps.reduce(0) { partial, temp in
    partial + temp
}
print(total)
""",
            ],
            solution: """
let total = temps.reduce(0) { partial, temp in
    partial + temp
}
print(total)
"""
        ),
        Challenge(
            number: 60,
            title: "min/max",
            description: "Find smallest and largest values",
            starterCode: """
                // Challenge 60: min/max
                // Find the smallest and largest temperatures.

                let temps = [1200, 1500, 1600, 1400]

                // TODO: Use min() to find the smallest temp (default to 0 if nil)
                // TODO: Use max() to find the largest temp (default to 0 if nil)
                // TODO: Print min then max on separate lines
                """,
            expectedOutput: "1200\n1600",
            hints: [
                """
let minTemp = temps.min() ?? 0
let maxTemp = temps.max() ?? 0
print(minTemp)
print(maxTemp)
""",
            ],
            solution: """
let minTemp = temps.min() ?? 0
let maxTemp = temps.max() ?? 0
print(minTemp)
print(maxTemp)
"""
        ),

        Challenge(
            number: 61,
            title: "compactMap",
            description: "Remove nil values safely",
            starterCode: """
                // Challenge 61: compactMap
                // Clean up optional readings.

                let readings: [Int?] = [1200, nil, 1500, nil, 1600]

                // TODO: Use compactMap to remove nils
                // TODO: Print the cleaned array
                """,
            expectedOutput: "[1200, 1500, 1600]",
            hints: [
                """
let cleaned = readings.compactMap { $0 }
print(cleaned)
""",
            ],
            solution: """
let cleaned = readings.compactMap { $0 }
print(cleaned)
"""
        ),
        Challenge(
            number: 62,
            title: "flatMap",
            description: "Flatten nested arrays",
            starterCode: """
                // Challenge 62: flatMap
                // Flatten batches.

                let batches = [[1, 2], [3], [4, 5]]

                // TODO: Flatten using flatMap
                // TODO: Print the result
                """,
            expectedOutput: "[1, 2, 3, 4, 5]",
            hints: [
                """
let flat = batches.flatMap { $0 }
print(flat)
""",
            ],
            solution: """
let flat = batches.flatMap { $0 }
print(flat)
"""
        ),


        Challenge(
            number: 63,
            title: "typealias",
            description: "Improve readability with type aliases",
            starterCode: """
                // Challenge 63: typealias
                // Create a readable alias.

                // TODO: Create a typealias ForgeReading = (temp: Int, time: Int)
                // TODO: Create a reading with temp 1200 and time 1
                // TODO: Print reading.temp
                """,
            expectedOutput: "1200",
            hints: [
                """
typealias ForgeReading = (temp: Int, time: Int)
let reading: ForgeReading = (temp: 1200, time: 1)
print(reading.temp)
""",
            ],
            solution: """
typealias ForgeReading = (temp: Int, time: Int)
let reading: ForgeReading = (temp: 1200, time: 1)
print(reading.temp)
"""
        ),

        Challenge(
            number: 64,
            title: "Enums",
            description: "Represent a set of cases",
            starterCode: """
                // Challenge 64: Enums
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
"""#
        ),
        Challenge(
            number: 65,
            title: "Enums with Raw Values",
            description: "Represent simple categories",
            starterCode: """
                // Challenge 65: Enums with Raw Values
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
"""
        ),
        Challenge(
            number: 66,
            title: "Enums with Associated Values",
            description: "Represent structured events",
            starterCode: """
                // Challenge 66: Enums with Associated Values
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
"""#
        ),
        Challenge(
            number: 67,
            title: "Enum Pattern Matching",
            description: "Match and extract associated values",
            starterCode: """
                // Challenge 67: Enum Pattern Matching
                // Use a switch with a where clause.

                enum Event {
                    case temperature(Int)
                    case error(String)
                }

                let event = Event.temperature(1600)

                // TODO: Use switch to print 'Overheated' when temp >= 1500
                // Otherwise print "Normal"
                """,
            expectedOutput: "Overheated",
            hints: [
                #"""
switch event {
case .temperature(let temp) where temp >= 1500:
    print("Overheated")
case .temperature:
    print("Normal")
case .error:
    print("Normal")
}
"""#,
            ],
            solution: #"""
switch event {
case .temperature(let temp) where temp >= 1500:
    print("Overheated")
case .temperature:
    print("Normal")
case .error:
    print("Normal")
}
"""#
        ),
        Challenge(
            number: 68,
            title: "Throwing Functions",
            description: "Introduce error throwing",
            starterCode: """
                // Challenge 68: Throwing Functions
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
"""#
        ),
        Challenge(
            number: 69,
            title: "try?",
            description: "Convert errors into optionals",
            starterCode: """
                // Challenge 69: try?
                // Use try? to simplify error handling.

                // TODO: Reuse checkTemp from the previous challenge
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
func checkTemp(_ temp: Int) throws {
    if temp < 0 {
        throw TempError.outOfRange
    }
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

func checkTemp(_ temp: Int) throws {
    if temp < 0 {
        throw TempError.outOfRange
    }
}

let result = try? checkTemp(-1)
print(result as Any)
"""
        ),
        Challenge(
            number: 70,
            title: "Simulated Input",
            description: "Use a provided input value",
            starterCode: """
                // Challenge 70: readLine
                // Simulate a value from the user.

                let input = "Iron"

                // TODO: Create a message "You entered <metal>"
                // TODO: Print the message
                """,
            expectedOutput: "You entered Iron",
            hints: [
                #"""
let message = "You entered \(input)"
print(message)
"""#,
            ],
            solution: #"""
let message = "You entered \(input)"
print(message)
"""#
        ),
        Challenge(
            number: 71,
            title: "Simulated Arguments",
            description: "Read from a provided args array",
            starterCode: """
                // Challenge 71: Command-Line Arguments
                // Read arguments.

                let args = ["forge", "Iron"]

                // TODO: If args has at least 2 items, print args[1]
                // Otherwise print "No args"
                """,
            expectedOutput: "Iron",
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
"""#
        ),
        Challenge(
            number: 72,
            title: "Simulated File Read",
            description: "Process provided file contents",
            starterCode: """
                // Challenge 72: File Read
                // Read a file of temperatures.

                let fileContents = "1200\n1500\n1600\n"

                // TODO: Split fileContents into lines
                // TODO: Print the number of lines
                """,
            expectedOutput: "3",
            hints: [
                #"""
let lines = fileContents.split(separator: "
")
print(lines.count)
"""#,
            ],
            solution: #"""
let lines = fileContents.split(separator: "
")
print(lines.count)
"""#
        ),
        Challenge(
            number: 73,
            title: "Simulated Test",
            description: "Check a condition and report result",
            starterCode: """
                // Challenge 73: XCTest
                // Write a basic test case.

                // TODO: If 2 + 2 == 4, print "Test passed"
                """,
            expectedOutput: "Test passed",
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
"""#
        ),
        Challenge(
            number: 74,
            title: "Integration Challenge",
            description: "Combine Core 3 concepts",
            starterCode: """
                // Challenge 74: Integration Challenge
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
                """
let values = lines.map { Int($0) }
let temps = values.compactMap { $0 }
let hotTemps = temps.filter { $0 >= 1500 }
let total = hotTemps.reduce(0) { $0 + $1 }
print(total)
""",
            ],
            solution: """
let values = lines.map { Int($0) }
let temps = values.compactMap { $0 }
let hotTemps = temps.filter { $0 >= 1500 }
let total = hotTemps.reduce(0) { $0 + $1 }
print(total)
"""
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
            completionTitle: "🎆 Core 1, Pass 1 Complete!",
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
"""
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
            completionTitle: "🏗️ Core 2, Pass 2 Complete!",
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
"""
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
                (input: "errors", expectedOutput: "Errors: [\\\"Overheated\\\"]"),
            ],
            completionTitle: "🧠 Core 3, Pass 3 Complete!",
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
"""#
        ),
    ]
}