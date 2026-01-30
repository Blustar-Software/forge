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
    case classes
    case properties
    case protocols
    case extensions
    case accessControl
    case errors
    case generics
    case memory
    case concurrency
    case actors
    case keyPaths
    case sequences
    case propertyWrappers
    case macros
    case swiftpm
    case testing
    case interop
    case performance
    case advancedFeatures
}

enum ChallengeTier: String {
    case mainline
    case extra
}

enum ChallengeLayer: String {
    case core
    case mantle
    case crust
}

enum ProjectTier: String {
    case mainline
    case extra
}

enum ProjectLayer: String {
    case core
    case mantle
    case crust
}

enum ConstraintConcept: String {
    case ifElse
    case switchStatement
    case forInLoop
    case whileLoop
    case repeatWhileLoop
    case breakContinue
    case ranges
    case functionsBasics
    case optionals
    case nilLiteral
    case optionalBinding
    case guardStatement
    case nilCoalescing
    case collections
    case closures
    case shorthandClosureArgs
    case map
    case filter
    case reduce
    case compactMap
    case flatMap
    case typeAlias
    case enums
    case doCatch
    case throwKeyword
    case tryKeyword
    case tryOptional
    case readLine
    case commandLineArguments
    case fileIO
    case tuples
    case asyncAwait
    case actors
    case propertyWrappers
    case protocols
    case structs
    case classes
    case properties
    case initializers
    case mutatingMethods
    case selfKeyword
    case extensions
    case whereClauses
    case associatedTypes
    case generics
    case task
    case mainActor
    case sendable
    case protocolConformance
    case protocolExtensions
    case defaultImplementations
    case taskSleep
    case taskGroup
    case accessControl
    case accessControlOpen
    case accessControlFileprivate
    case accessControlInternal
    case accessControlSetter
    case errorTypes
    case throwingFunctions
    case doTryCatch
    case tryForce
    case resultBuilders
    case macros
    case projectedValues
    case swiftpmBasics
    case swiftpmDependencies
    case buildConfigs
    case dependencyInjection
    case protocolMocking
    case comparisons
    case booleanLogic
    case compoundAssignment
    case stringInterpolation
}


struct ConstraintProfile {
    let allowedImports: [String]
    let disallowedTokens: [String]
    let requiredTokens: [String]
    let allowFileIO: Bool
    let allowNetwork: Bool
    let allowConcurrency: Bool
    let maxRuntimeMs: Int?
    let requireOptionalUsage: Bool?
    let requireCollectionUsage: Bool?
    let requireClosureUsage: Bool?

    init(
        allowedImports: [String] = [],
        disallowedTokens: [String] = [],
        requiredTokens: [String] = [],
        allowFileIO: Bool = true,
        allowNetwork: Bool = false,
        allowConcurrency: Bool = true,
        maxRuntimeMs: Int? = nil,
        requireOptionalUsage: Bool? = nil,
        requireCollectionUsage: Bool? = nil,
        requireClosureUsage: Bool? = nil
    ) {
        self.allowedImports = allowedImports
        self.disallowedTokens = disallowedTokens
        self.requiredTokens = requiredTokens
        self.allowFileIO = allowFileIO
        self.allowNetwork = allowNetwork
        self.allowConcurrency = allowConcurrency
        self.maxRuntimeMs = maxRuntimeMs
        self.requireOptionalUsage = requireOptionalUsage
        self.requireCollectionUsage = requireCollectionUsage
        self.requireClosureUsage = requireClosureUsage
    }
}

// Centralized challenge definitions for the CLI flow.
struct Challenge {
    let number: Int
    let id: String
    let title: String
    let description: String
    let starterCode: String
    let expectedOutput: String
    let hints: [String]
    let cheatsheet: String
    let lesson: String
    let solution: String
    let manualCheck: Bool
    let stdinFixture: String?
    let argsFixture: String?
    let fixtureFiles: [String]
    let constraintProfile: ConstraintProfile?
    let introduces: [ConstraintConcept]
    let requires: [ConstraintConcept]
    let topic: ChallengeTopic
    let tier: ChallengeTier
    let layer: ChallengeLayer
    let layerNumber: Int?
    let extraParent: Int?
    let extraIndex: Int?
    let canonicalId: String

    init(
        number: Int,
        id: String = "",
        title: String,
        description: String,
        starterCode: String,
        expectedOutput: String,
        hints: [String] = [],
        cheatsheet: String = "",
        lesson: String = "",
        solution: String = "",
        manualCheck: Bool = false,
        stdinFixture: String? = nil,
        argsFixture: String? = nil,
        fixtureFiles: [String] = [],
        constraintProfile: ConstraintProfile? = nil,
        introduces: [ConstraintConcept] = [],
        requires: [ConstraintConcept] = [],
        topic: ChallengeTopic = .general,
        tier: ChallengeTier = .mainline,
        layer: ChallengeLayer = .core,
        layerNumber: Int? = nil,
        extraParent: Int? = nil,
        extraIndex: Int? = nil,
        canonicalId: String = ""
    ) {
        self.number = number
        self.id = id
        self.title = title
        self.description = description
        self.starterCode = starterCode
        self.expectedOutput = expectedOutput
        self.hints = hints
        self.cheatsheet = cheatsheet
        self.lesson = lesson
        self.solution = solution
        self.manualCheck = manualCheck
        self.stdinFixture = stdinFixture
        self.argsFixture = argsFixture
        self.fixtureFiles = fixtureFiles
        self.constraintProfile = constraintProfile
        self.introduces = introduces
        self.requires = requires
        self.topic = topic
        self.tier = tier
        self.layer = layer
        self.layerNumber = layerNumber
        self.extraParent = extraParent
        self.extraIndex = extraIndex
        self.canonicalId = canonicalId
    }

    var filename: String {
        if !canonicalId.isEmpty {
            let safeId = canonicalId.replacingOccurrences(of: ":", with: "-")
            return "challenge-\(safeId).swift"
        }
        return "challenge\(number).swift"
    }

    var progressId: String {
        if !canonicalId.isEmpty {
            return canonicalId
        }
        if !id.isEmpty {
            return id
        }
        if tier == .extra {
            return "\(number)a"
        }
        return String(number)
    }

    var displayId: String {
        return progressId
    }

    func withCanonicalId(
        _ canonicalId: String,
        layerNumber: Int?,
        extraParent: Int?,
        extraIndex: Int?
    ) -> Challenge {
        return Challenge(
            number: number,
            id: id,
            title: title,
            description: description,
            starterCode: starterCode,
            expectedOutput: expectedOutput,
            hints: hints,
            cheatsheet: cheatsheet,
            lesson: lesson,
            solution: solution,
            manualCheck: manualCheck,
            stdinFixture: stdinFixture,
            argsFixture: argsFixture,
            fixtureFiles: fixtureFiles,
            constraintProfile: constraintProfile,
            introduces: introduces,
            requires: requires,
            topic: topic,
            tier: tier,
            layer: layer,
            layerNumber: layerNumber,
            extraParent: extraParent,
            extraIndex: extraIndex,
            canonicalId: canonicalId
        )
    }

    func withLayer(_ layer: ChallengeLayer) -> Challenge {
        return Challenge(
            number: number,
            id: id,
            title: title,
            description: description,
            starterCode: starterCode,
            expectedOutput: expectedOutput,
            hints: hints,
            cheatsheet: cheatsheet,
            solution: solution,
            manualCheck: manualCheck,
            stdinFixture: stdinFixture,
            argsFixture: argsFixture,
            fixtureFiles: fixtureFiles,
            constraintProfile: constraintProfile,
            introduces: introduces,
            requires: requires,
            topic: topic,
            tier: tier,
            layer: layer,
            layerNumber: layerNumber,
            extraParent: extraParent,
            extraIndex: extraIndex,
            canonicalId: canonicalId
        )
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
    let cheatsheet: String
    let lesson: String
    let solution: String
    let tier: ProjectTier
    let layer: ProjectLayer

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
        cheatsheet: String = "",
        lesson: String = "",
        solution: String = "",
        tier: ProjectTier = .mainline,
        layer: ProjectLayer = .core
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
        self.cheatsheet = cheatsheet
        self.lesson = lesson
        self.solution = solution
        self.tier = tier
        self.layer = layer
    }

    var filename: String {
        return "project_\(id).swift"
    }
}

let cheatsheetStrings = """
Strings
- count returns an Int of characters
- lowercased()/uppercased() return new strings
- contains(_:) returns Bool
- hasPrefix()/hasSuffix() check prefixes/suffixes
- split(separator:) returns [Substring]
"""

let cheatsheetComments = """
Comments
- Single-line: // comment
- Multi-line: /* comment */
- Comments are ignored by the compiler
"""

let cheatsheetBasics = """
Basics
- print(...) outputs text to the console
- Code runs top to bottom
"""

let cheatsheetVariables = """
Variables
- let creates a constant
- var creates a variable
- Type annotation: let x: Int = 5
- Swift infers types from values
"""

let cheatsheetMathOperators = """
Math Operators
- +, -, *, / for arithmetic
- % for remainder
- Compound assignment: +=, -=, *=, /=
"""

let cheatsheetStringBasics = """
Strings
- String literals use double quotes
- Concatenate with +
- Interpolate with \\(value)
"""

let cheatsheetBooleans = """
Booleans
- Bool values are true or false
- Comparisons return Bool
- Logical operators: &&, ||, !
"""

let cheatsheetCore1Integration = """
Core 1 Integration
- Use let for constants; var for values that change
- Compound assignment: +=, -=, *=, /=
- Comparisons produce Bool: ==, !=, <, >, <=, >=
- Logic: && (and), || (or), ! (not)
- Functions: func name(param: Type) -> ReturnType { ... }
- Interpolation: "Value: \\(value)"
"""

let lessonComments = """
Lesson: Comments
Comments are ignored by the compiler and help humans read code.

Types:
- Single-line: // comment
- Multi-line: /* comment */

Use comments to explain intent, not obvious syntax.
"""

let lessonVariablesAndTypes = """
Lesson: Constants, Variables, and Types
Use let for values that never change and var for values you will update.

Types:
- Swift is type-safe: once a type is set, it does not change.
- You can annotate: let count: Int = 3
- Or infer: let count = 3

Common types:
Int (whole numbers), Double (decimals), String (text), Bool (true/false).
"""

let lessonMathAndAssignment = """
Lesson: Math & Assignment
Arithmetic operators:
- +, -, *, /, % (remainder)

Integer division:
- Int / Int produces an Int (truncates decimals).

Compound assignment:
- +=, -=, *=, /= update a variable in place.
"""

let lessonStrings = """
Lesson: Strings
Strings store text.

Concatenation:
- "Forge" + " Ready" → "Forge Ready"

Interpolation:
- "Level: \\(value)" inserts a value into text.
"""

let lessonBooleans = """
Lesson: Booleans & Logic
A Bool stores true or false. Comparisons (==, !=, <, >, <=, >=) produce Bool values.

Logical operators:
- && (and): true only when both sides are true
- || (or): true when either side is true
- ! (not): flips a Bool

Grouping:
- Use parentheses to group conditions.
- && runs before || if you skip parentheses.

Pattern:
let ready = (metal == "Iron" && temp >= 1400) || temp >= 1200
"""

let lessonFunctionsBasics = """
Lesson: Functions
Define a reusable action with func.

Syntax:
- func name(param: Type) -> ReturnType { ... }
- If there is no return value, omit the return type.

Calling:
- Use argument labels by default: greet(name: "Forge")

Return values:
- Use return to send a value back to the caller.
"""

let lessonCore1Integration = """
Lesson: Core 1 Integration
Combine the basics into a single flow:
- Setup: constants/variables
- Compute: math and functions
- Decide: comparisons and boolean logic
- Report: string interpolation

Keep steps clear and store intermediate results when helpful.
"""

let lessonConditionalsFlow = """
Lesson: Conditionals
Use if/else if/else to pick between multiple paths.

Tips:
- Check the most specific cases first.
- The final else is your fallback.

Ternary:
- condition ? valueIfTrue : valueIfFalse
"""

let lessonSwitchAndRanges = """
Lesson: Switch & Ranges
Switch matches one value against multiple cases.

Ranges:
- Closed: 1...3 includes both ends
- Half-open: 1..<3 excludes the upper bound

Use ranges inside switch cases to match numeric bands.
"""

let lessonLoopsBasics = """
Lesson: Loops
Use loops to repeat work.

Types:
- for-in over ranges or collections
- while when the condition is checked first
- repeat-while when the body must run at least once

Control:
- continue skips the current iteration
- break exits the loop
"""

let lessonCollectionsBasics = """
Lesson: Collections
Arrays and dictionaries store multiple values.

Arrays:
- [Int], [String], etc.
- count and isEmpty
- append to add

Dictionaries:
- ["Key": Value]
- access with subscript and a default
"""

let lessonSetsBasics = """
Lesson: Sets
Sets keep unique values only and have no fixed order.
Use Set(array) to remove duplicates.
"""

let lessonTuplesBasics = """
Lesson: Tuples
Tuples group related values without a new type.

Access:
- By index: value.0, value.1
- By name: (min: Int, max: Int) then value.min

Functions can return tuples to send multiple values back.
"""

let lessonOptionalsBasics = """
Lesson: Optionals
An Optional may be nil (missing).

Unwrap safely:
- if let value = optional { ... }
- guard let value = optional else { return }

Fallback:
- optional ?? defaultValue

Conversion:
- Int("123") returns Int? and must be unwrapped
"""

let lessonStringsAdvanced = """
Lesson: String Inspection
Strings have helpful properties and methods.

Common tools:
- count for length
- lowercased() for lowercase
- contains("text") to search
- hasPrefix("pre") and hasSuffix("suf")
"""

let lessonCollectionsAdvanced = """
Lesson: Collection Iteration
Iterate arrays and dictionaries to summarize data.

Dictionary loops:
- for (key, value) in dict { ... }
- Use dict.keys.sorted() for stable order
"""

let lessonFunctionsAdvanced = """
Lesson: Functions (Advanced)
Customize function signatures for clarity and flexibility.

Topics:
- External/internal labels: func label(at value: Int)
- Omit labels with _: func announce(_ value: String)
- Default params: intensity: Int = 1
- Variadics: func average(_ values: Int...)
- inout: mutate caller values with &
- Nested helper functions for validation
"""

let lessonClosuresBasics = """
Lesson: Closures
Closures are inline functions you can store or pass around.

Progression:
- Full syntax: { (value: Int) -> Int in ... }
- Implicit return for single expressions
- Type inference to drop types
- Shorthand args: $0
- Trailing closure syntax with function calls
"""

let lessonCollectionTransforms = """
Lesson: Collection Transforms
Use higher-order functions to transform data.

Tools:
- map: transform each element
- filter: keep matching values
- reduce: combine into one value
- compactMap: unwrap + drop nils
- flatMap: flatten nested collections
- min/max return Optionals
"""

let lessonTypealiases = """
Lesson: Typealias
Typealiases give long types a readable name.
Example: typealias Reading = (temp: Int, time: Int)
"""

let lessonEnumsBasics = """
Lesson: Enums
Enums define a fixed set of cases.

Variants:
- Raw values: enum Metal: String { case iron }
- Associated values: case temperature(Int)
- Pattern matching in switch, including where clauses
"""

let lessonErrorsBasics = """
Lesson: Errors
Throwing functions signal failure.

Flow:
- Define Error types
- throw in invalid cases
- do/try/catch to handle
- try? converts errors to nil
"""

let lessonInputOutputBasics = """
Lesson: Input & Files
Read input from different sources.

Sources:
- readLine() for stdin
- CommandLine.arguments for CLI args
- String(contentsOfFile:) for files (Foundation)
"""

let lessonCore3Integration = """
Lesson: Core 3 Integration
Combine strings, collections, and transforms into a pipeline.
Break the task into stages and verify each stage’s output.
"""

let lessonStructsBasics = """
Lesson: Structs
Structs are value types. Copies are independent.

Focus:
- Stored properties
- Methods (use self when needed)
- Custom init and mutating methods
"""

let lessonClassesBasics = """
Lesson: Classes
Classes are reference types. Copies share the same instance.

Focus:
- Initializers
- Shared state
- deinit for cleanup
"""

let lessonPropertiesAdvanced = """
Lesson: Properties
Swift supports computed, observed, lazy, and static properties.

Patterns:
- Computed get/set
- willSet/didSet observers
- lazy for deferred creation
- static for type-wide values
"""

let lessonProtocolsBasics = """
Lesson: Protocols
Protocols define required properties or methods.

Patterns:
- Conformance in structs/classes
- Protocols as parameter types
- Composition with A & B
- Inheritance to refine requirements
"""

let lessonExtensionsBasics = """
Lesson: Extensions
Extensions add behavior to existing types.

Patterns:
- Add methods or computed properties
- Provide protocol default implementations
- Constrained extensions for specific cases
"""

let lessonAccessControlBasics = """
Lesson: Access Control
Access levels control visibility of APIs.

Levels:
- private, internal (default), public, open
- private(set) for controlled mutation
"""

let lessonGenericsBasics = """
Lesson: Generics
Generics let code work across many types.

Patterns:
- Generic functions and types
- Constraints with : Comparable
- Associated types in protocols
- Where clauses and conditional conformance
"""

let lessonMemoryBasics = """
Lesson: Memory & ARC
ARC manages class lifetime with reference counting.

Tip:
- Use weak to avoid reference cycles.
"""

let lessonConcurrencyBasics = """
Lesson: Concurrency Basics
Swift concurrency uses async/await and Tasks.

Tools:
- async functions + await calls
- Task for async work
- Task groups for parallel work
- AsyncStream for async sequences
- Task cancellation via Task.isCancelled
"""

let lessonActorsBasics = """
Lesson: Actors
Actors protect mutable state from data races.

Notes:
- Access actor state with await
- @MainActor isolates work to the main actor
"""

let lessonPropertyWrappersBasics = """
Lesson: Property Wrappers
Wrappers encapsulate storage behavior.

Patterns:
- @Wrapper on a property
- wrappedValue controls get/set
- projectedValue exposed with $name
"""

let lessonKeyPathsBasics = """
Lesson: Key Paths
Key paths refer to properties as values.

Usage:
- let path = \\Type.property
- value[keyPath: path]
- map(\\.property) for arrays
"""

let lessonSequencesBasics = """
Lesson: Sequences
Sequences provide one-pass iteration.

Patterns:
- Sequence + IteratorProtocol
- lazy for deferred work
- Array(sequence) to materialize
"""

let lessonAdvancedGenericsBasics = """
Lesson: Advanced Generics
Use protocols and generics to hide concrete types.

Concepts:
- Opaque types: some Protocol
- Existentials: any Protocol
- Type erasure wrappers
- Primary associated types
- where clauses for constraints
"""

let lessonPerformanceBasics = """
Lesson: Performance & Layout
Measure before optimizing and understand value semantics.

Concepts:
- Copy-on-write collections
- MemoryLayout size/stride/alignment
- Profiling with elapsed time
"""

let lessonAdvancedFeaturesBasics = """
Lesson: Advanced Features
Swift includes power features for expressive APIs.

Examples:
- Custom operators and subscripts
- @dynamicMemberLookup and @dynamicCallable
- Result builders
- Reflection and runtime concepts
"""

let lessonMacrosBasics = """
Lesson: Macros
Macros expand code at compile time.

Notes:
- Usage is at call sites
- Authoring provides expansion logic
"""

let lessonSwiftPMBasics = """
Lesson: SwiftPM
Swift Package Manager defines targets and dependencies.

Notes:
- Package.swift declares products and targets
- Build configs affect #if DEBUG
"""

let lessonArchitecturePatterns = """
Lesson: Architecture Patterns
Organize code for testability and clarity.

Patterns:
- MVVM for view logic
- Dependency injection
- Coordinator and repository patterns
- Protocol-based mocking
"""

let lessonTestingBasics = """
Lesson: Testing Concepts
Tests validate behavior and prevent regressions.

Notes:
- TDD: Red → Green → Refactor
- Async tests can await
- UI tests verify user flows
"""

let lessonInteropBasics = """
Lesson: Interop Concepts
Swift can interoperate with C and Objective-C.

Notes:
- C via module maps
- Objective-C via @objc and bridging headers
"""

let lessonDebuggingBasics = """
Lesson: Debugging Concepts
Debuggers help inspect state and control execution.

Notes:
- LLDB common commands: po, bt
"""

let lessonGitBasics = """
Lesson: Git Workflow
Git tracks changes and coordinates collaboration.

Typical flow:
- branch → commit → push → PR
"""

let lessonCrustIntegration = """
Lesson: Crust Integration
Combine concurrency, actors, and wrappers in one flow.
Focus on safe state updates and clear async boundaries.
"""

let cheatsheetFunctionsBasics = """
Functions
- func name(param: Type) { ... }
- Return with -> Type
- Call by name with arguments
"""

let cheatsheetArrays = """
Arrays
- Type syntax: [Element]
- Literal: [1, 2, 3]
- Count: array.count
- Append: array.append(value)
- Access by index: array[0]
"""

let cheatsheetDictionaries = """
Dictionaries
- Type syntax: [Key: Value]
- Subscript returns Optional: dict[key]
- Iterate: for (key, value) in dict { ... }
- keys and values are collections
- keys.sorted() produces a stable order
"""

let cheatsheetSets = """
Sets
- Type syntax: Set<Element>
- Literal: Set([1, 2, 3])
- Unordered and unique
- Count: set.count
"""

let cheatsheetTuples = """
Tuples
- (value1, value2) groups values
- Named elements: (min: Int, max: Int)
- Access by .0/.1 or by name
"""

let cheatsheetStructs = """
Structs
- struct Name { var property: Type }
- Instances: let/var value = Name(...)
- Properties use dot syntax
- var instance required to mutate properties
"""

let cheatsheetClasses = """
Classes
- class Name { var property: Type }
- Classes are reference types
- deinit runs when an instance is released
"""

let cheatsheetProperties = """
Properties
- Stored properties hold values
- Computed properties use get/set
- willSet/didSet observe changes
- lazy defers initialization
- static creates type-level members
"""

let cheatsheetProtocols = """
Protocols
- Define required properties and methods
- Types conform by implementing requirements
- Protocols can be used as types
"""

let cheatsheetExtensions = """
Extensions
- Add methods or computed properties to existing types
- Protocol extensions can provide defaults
"""

let cheatsheetAccessControl = """
Access Control
- private limits access to the enclosing scope
- internal is the default (module-wide)
- public/open expose APIs outside the module
"""

let cheatsheetGenerics = """
Generics
- Use <T> to make functions and types reusable
- Constraints limit T to specific protocols
- where adds extra requirements
"""

let cheatsheetMemory = """
Memory
- strong references keep instances alive
- weak breaks reference cycles
- Use [weak self] in closures to avoid leaks
"""

let cheatsheetFunctions = """
Functions
- func name(label param: Type) -> ReturnType { ... }
- External vs internal labels: func f(external internal: Type)
- Omit labels with _: func f(_ value: Type)
- Default values: param: Type = value
- Variadics: param: Type...
- inout params mutate caller; call with &value
- Nested functions are allowed inside functions
- Tuple return types: -> (min: Int, max: Int)
"""

let cheatsheetLoops = """
Loops
- for value in collection { ... }
- for i in 1...5 (closed) or 1..<5 (half-open)
- while condition { ... }
- repeat { ... } while condition
- break stops a loop; continue skips ahead
"""

let cheatsheetRanges = """
Ranges
- Closed: 1...3 includes the end
- Half-open: 1..<3 excludes the end
- Used in for-in loops and switch cases
"""

let cheatsheetClosures = """
Closures
- Syntax: { (params) -> ReturnType in statements }
- Types can be inferred from context
- Single-expression closures can omit return
- Shorthand args: $0, $1, ...
- Trailing closure: f(x) { ... }
- Closures capture values from outer scope
"""

let cheatsheetCollectionsBasics = """
Collection Basics
- count returns the number of elements
- isEmpty returns Bool
- first returns Optional
- keys.count returns number of keys
"""

let cheatsheetCollectionTransforms = """
Collection Transforms
- map transforms each element into a new array
- filter keeps elements matching a condition
- reduce combines elements into one value
- compactMap removes nils and unwraps values
- flatMap flattens nested arrays
- min()/max() return Optional values
"""

let cheatsheetTypealiases = """
Typealias
- typealias Name = ExistingType
- Useful for readable tuple types
"""

let cheatsheetEnums = """
Enums
- enum Name { case a, b }
- Raw values: enum Name: String { case a }
- Associated values: case event(Int)
- Switch extracts values with let bindings
- where adds an extra condition in a case
"""

let cheatsheetConditionals = """
Conditionals
- if/else if/else chooses branches
- Ternary: condition ? valueIfTrue : valueIfFalse
- switch matches cases; default for non-exhaustive
- switch cases can match ranges and multiple values
- where adds an extra check in switch
"""

let cheatsheetOptionals = """
Optionals
- Type? can be a value or nil
- if let unwraps optionals safely
- guard let unwraps with early exit
- ?? provides a default value
- Int("123") returns Int? (optional)
"""

let cheatsheetErrors = """
Errors
- Define: enum MyError: Error { case ... }
- Throwing functions use throws
- Call with try
- Handle with do { try ... } catch { ... }
- try? returns Optional, nil on error
"""

let cheatsheetInputOutput = """
I/O Basics
- readLine() returns String?
- CommandLine.arguments is [String], index 0 is the script
- File read: String(contentsOfFile: path, encoding: .utf8)
"""

let cheatsheetConcurrency = """
Concurrency
- async functions can suspend and resume
- await calls async work and returns the value
- Task runs async work concurrently
- withTaskGroup manages child tasks
"""

let cheatsheetActors = """
Actors
- actor isolates mutable state
- actor methods are accessed with await
- @MainActor marks main-thread-bound work
"""

let cheatsheetPropertyWrappers = """
Property Wrappers
- @propertyWrapper wraps get/set logic
- wrappedValue is the stored interface
- projectedValue is accessed via $name
"""

let cheatsheetKeyPaths = """
Key Paths
- Syntax: \\Type.property
- Access with value[keyPath: path]
- Map with \\Type.property
"""

let cheatsheetSequences = """
Sequences
- Sequence can be iterated once with for-in
- Collection adds indices and count
- lazy creates deferred transformations
"""

let cheatsheetAdvancedGenerics = """
Advanced Generics
- some returns an opaque type
- any uses an existential type
- Type erasure hides concrete types
- where clauses add constraints
"""

let cheatsheetPerformance = """
Performance
- Arrays use copy-on-write behavior
- MemoryLayout reports size/stride/alignment
- Measure before optimizing
"""

let cheatsheetAdvancedFeatures = """
Advanced Features
- Custom operators declare precedence
- Subscripts can accept multiple parameters
- dynamicMemberLookup forwards unknown members
- dynamicCallable forwards calls
"""

let cheatsheetSwiftPM = """
SwiftPM
- Package.swift defines targets and dependencies
- Executable targets produce CLI tools
- Library targets expose modules
"""

let cheatsheetMacros = """
Macros (Usage)
- Macros are expanded at compile time
- Macro packages are added via SwiftPM
- Use #macroName(...) per macro definition
"""

let cheatsheetProjectCore1a = """
Project Cheatsheet: Temperature Converter
- Functions can return computed values
- Integer division truncates; use Double for precision
- Labels appear at call sites when defined
"""

let cheatsheetProjectCore1b = """
Project Cheatsheet: Forge Checklist
- Comparisons produce Bool values
- Combine conditions with && and ||
- String interpolation inserts values into text
"""

let cheatsheetProjectCore1c = """
Project Cheatsheet: Ingot Calculator
- Arithmetic follows standard precedence
- Use parentheses to clarify intent
- Functions can return a computed Int
"""

let cheatsheetProjectCore2a = """
Project Cheatsheet: Ironclad Commands
- Arrays are ordered; dictionaries are key-value pairs
- for-in loops traverse collections
- Track min/max/sums with running variables
- Tuples can return multiple values
"""

let cheatsheetProjectCore2b = """
Project Cheatsheet: Inventory Audit
- Dictionary iteration yields key/value pairs
- Use running totals while looping
- Conditionals split counts into categories
"""

let cheatsheetProjectCore2c = """
Project Cheatsheet: Optional Readings
- Optionals are values that may be nil
- if let unwraps values safely
- Avoid divide-by-zero when averaging
"""

let cheatsheetProjectCore3a = """
Project Cheatsheet: Forge Log Interpreter
- Enums can carry associated values
- Throwing functions surface invalid data
- compactMap removes nils while transforming
- Tuples group multiple return values
"""

let cheatsheetProjectCore3b = """
Project Cheatsheet: Temperature Pipeline
- map/filter/reduce chain into a pipeline
- Derived metrics come from transformed data
- Helper functions reduce repetition
"""

let cheatsheetProjectCore3c = """
Project Cheatsheet: Event Router
- switch handles enum cases
- Associated values can be extracted with let
- Aggregates update inside loops
"""

let cheatsheetProjectMantle1a = """
Project Cheatsheet: Forge Inventory Model
- Structs model data with stored properties
- Computed properties derive values
- Methods bundle behavior
"""

let cheatsheetProjectMantle2a = """
Project Cheatsheet: Component Inspector
- Protocols define shared requirements
- Extensions add default behavior
- Access control scopes API surface
"""

let cheatsheetProjectMantle3a = """
Project Cheatsheet: Task Manager
- Generics make reusable containers
- Protocol extensions add shared behavior
- weak references prevent cycles
"""

let cheatsheetProjectMantle1b = """
Project Cheatsheet: Shift Tracker
- Mutating methods update struct state
- Computed properties derive totals
"""

let cheatsheetProjectMantle1c = """
Project Cheatsheet: Shared Controller
- Classes are reference types
- Updates are shared across references
"""

let cheatsheetProjectMantle2b = """
Project Cheatsheet: Inspection Line
- Protocol composition combines requirements
- Extensions can add shared formatting
"""

let cheatsheetProjectMantle2c = """
Project Cheatsheet: Safe Heater
- Throwing functions signal failures
- do/try/catch handles errors
"""

let cheatsheetProjectMantle3b = """
Project Cheatsheet: Generic Stack
- Generics allow reusable containers
- Mutating methods update stored arrays
"""

let cheatsheetProjectMantle3c = """
Project Cheatsheet: Constraint Report
- where clauses add constraints
- Protocol extensions add shared behavior
"""

let cheatsheetProjectCrust1a = """
Project Cheatsheet: Async Client
- async functions return values with await
- Tasks run async work concurrently
- Actors isolate mutable state
"""

let cheatsheetProjectCrust1b = """
Project Cheatsheet: KeyPath Transformer
- Key paths access stored properties
- map can use \\Type.property
- Reduce combines values into one
"""

let cheatsheetProjectCrust1c = """
Project Cheatsheet: Task Orchestrator
- withTaskGroup manages child tasks
- Sum results as they arrive
- Keep output deterministic
"""

let cheatsheetProjectCrust2a = """
Project Cheatsheet: Config DSL
- Result builders collect values
- Custom types keep settings structured
- Print in a stable order
"""

let cheatsheetProjectCrust2b = """
Project Cheatsheet: Lazy Metrics
- lazy defers work until needed
- map transforms, reduce aggregates
- Arrays preserve order
"""

let cheatsheetProjectCrust2c = """
Project Cheatsheet: Feature Flags
- Enums model known flags
- Sets provide fast membership checks
- Print booleans for enabled state
"""

let cheatsheetProjectCrust3a = """
Project Cheatsheet: Mini Framework
- Protocols define boundaries
- Inject dependencies for testability
- Store events in a simple sink
"""

let cheatsheetProjectCrust3b = """
Project Cheatsheet: Modular CLI Tool
- Commands expose a shared interface
- Use a lookup table for dispatch
- Print a single selected result
"""

let cheatsheetProjectCrust3c = """
Project Cheatsheet: DSL Builder
- Result builders collect steps
- Join with separators for output
- Keep the DSL minimal and clear
"""

let core1BaselineProfile = ConstraintProfile(
    disallowedTokens: ["import"],
    allowFileIO: false,
    allowNetwork: false,
    allowConcurrency: false
)


let core2BaselineProfile = ConstraintProfile(
    disallowedTokens: ["import"],
    allowFileIO: false,
    allowNetwork: false,
    allowConcurrency: false
)


let core3BaselineProfile = ConstraintProfile(
    disallowedTokens: ["import"],
    allowFileIO: false,
    allowNetwork: false,
    allowConcurrency: false
)

let core3ClosureProfile = ConstraintProfile(
    disallowedTokens: ["import"],
    allowFileIO: false,
    allowNetwork: false,
    allowConcurrency: false,
    requireClosureUsage: true
)


let mantleBaselineProfile = ConstraintProfile(
    disallowedTokens: ["import"],
    allowFileIO: false,
    allowNetwork: false,
    allowConcurrency: false
)


let crustBaselineProfile = ConstraintProfile(
    disallowedTokens: ["import"],
    allowFileIO: false,
    allowNetwork: false,
    allowConcurrency: false
)

let topicConstraintProfiles: [ChallengeTopic: ConstraintProfile] = [
    .strings: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true
    ),
    .conditionals: ConstraintProfile(
        disallowedTokens: ["for", "while", "repeat"],
        allowNetwork: true
    ),
    .loops: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true
    ),
    .functions: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true
    ),
    .collections: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true,
        requireCollectionUsage: true
    ),
    .optionals: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true,
        requireOptionalUsage: true
    ),
    .structs: ConstraintProfile(
        requiredTokens: ["struct"],
        allowNetwork: true
    ),
]

func makeCore1Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 1,
            title: "Hello, Forge",
            description: "Print \"Hello, Forge\" to the console",
            starterCode: """
                // Challenge 1: Hello, Forge
                // Print "Hello, Forge" to the console

                // TODO: Print "Hello, Forge"
                """,
            expectedOutput: "Hello, Forge",
            hints: [
                "Use print(...) to show text in the console.",
                "Pay attention to capitalization and punctuation.",
            ],
            cheatsheet: cheatsheetBasics,
            solution: #"""
print("Hello, Forge")
"""#,
            constraintProfile: core1BaselineProfile,
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

                // TODO: Create a multi-line comment that says:
                // "This is my second challenge.
                // I'm learning Swift with Forge."

                // TODO: Print "Comments complete"
                """,
            expectedOutput: "Hello, Forge\nComments complete",
            hints: [
                "Single-line comments start with //.",
                "Multi-line comments use /* */ and can span lines.",
                "Make sure the program prints two lines total.",
            ],
            cheatsheet: cheatsheetComments,
            lesson: lessonComments,
            solution: #"""
// This line prints a greeting to the console
print("Hello, Forge")

/* This is my second challenge.
I'm learning Swift with Forge. */

print("Comments complete")
"""#,
            constraintProfile: core1BaselineProfile,
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
                // TODO: Create a constant called 'forgeTemperature' with the value 1500

                // TODO: Print the constant
                """,
            expectedOutput: "1500",
            hints: [
                "Constants are declared with let.",
                "print(...) outputs a value to the console.",
            ],
            cheatsheet: cheatsheetVariables,
            lesson: lessonVariablesAndTypes,
            solution: """
let forgeTemperature = 1500
print(forgeTemperature)
""",
            constraintProfile: core1BaselineProfile,
            topic: .general,

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
            expectedOutput: "10\n12",
            hints: [
                "var is for values that can change.",
                "Reassignment updates the stored value.",
            ],
            cheatsheet: cheatsheetVariables,
            lesson: lessonVariablesAndTypes,
            solution: """
var hammerWeight = 10
print(hammerWeight)

hammerWeight = 12
print(hammerWeight)
""",
            constraintProfile: core1BaselineProfile,
            topic: .general,

        ),
        Challenge(
            number: 5,
            title: "Type Annotations",
            description: "Use explicit types when helpful",
            starterCode: """
                // Challenge 5: Type Annotations
                // Explicit types can improve clarity

                // TODO: Create a constant 'metalCount' with an explicit type and value 5
                // TODO: Create a constant 'temperature' with an explicit type and value 1500.5

                // TODO: Print metalCount
                // TODO: Print temperature
                """,
            expectedOutput: "5\n1500.5",
            hints: [
                "Type annotations use a colon, like name: Type.",
                "Use Int for whole numbers and Double for decimals.",
            ],
            cheatsheet: cheatsheetVariables,
            lesson: lessonVariablesAndTypes,
            solution: """
let metalCount: Int = 5
let temperature: Double = 1500.5

print(metalCount)
print(temperature)
""",
            constraintProfile: core1BaselineProfile,
            topic: .general,

        ),
        Challenge(
            number: 6,
            title: "Type Inference",
            description: "Let Swift infer types from values",
            starterCode: """
                // Challenge 6: Type Inference
                // You used inference already; now use it intentionally

                // TODO: Create a constant 'ingotCount' with the value 4 using type inference
                // TODO: Create a constant 'forgeName' with the value "Forge" using type inference

                // TODO: Print ingotCount
                // TODO: Print forgeName
                """,
            expectedOutput: "4\nForge",
            hints: [
                "Swift infers types from literal values; omit type annotations.",
                "print(...) outputs a value to the console.",
            ],
            cheatsheet: cheatsheetVariables,
            lesson: lessonVariablesAndTypes,
            solution: #"""
let ingotCount = 4
let forgeName = "Forge"

print(ingotCount)
print(forgeName)
"""#,
            constraintProfile: core1BaselineProfile,
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
                // TODO: Print the integer division result of a by b
                // TODO: Print a % b
                """,
            expectedOutput: "26\n14\n120\n3\n2",
            hints: [
                "Arithmetic operators include +, -, *, /, and %.",
                "Integer division uses / on Int values.",
            ],
            cheatsheet: cheatsheetMathOperators,
            lesson: lessonMathAndAssignment,
            solution: """
print(a + b)
print(a - b)
print(a * b)
print(a / b)
print(a % b)
""",
            constraintProfile: core1BaselineProfile,
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
                "Compound assignment updates a value in place (+=, -=, *=, /=).",
                "print(...) outputs a value to the console.",
            ],
            cheatsheet: cheatsheetMathOperators,
            lesson: lessonMathAndAssignment,
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
            constraintProfile: core1BaselineProfile,
            introduces: [.compoundAssignment],
            topic: .general,

        ),
        Challenge(
            number: 9,
            title: "Strings & Concatenation",
            description: "Join strings together with +",
            starterCode: """
                // Challenge 9: Strings & Concatenation
                // Combine strings to create a message

                // TODO: Create a constant 'forgeWord' with the value "Forge"
                // TODO: Create a constant 'statusWord' with the value "Ready"
                // TODO: Combine them with a space between using +

                // TODO: Print the combined message
                """,
            expectedOutput: "Forge Ready",
            hints: [
                "String concatenation uses the + operator.",
                "Include a space so the two words don't run together.",
            ],
            cheatsheet: cheatsheetStringBasics,
            lesson: lessonStrings,
            solution: #"""
let forgeWord = "Forge"
let statusWord = "Ready"
let message = forgeWord + " " + statusWord

print(message)
"""#,
            constraintProfile: core1BaselineProfile,
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
                "String interpolation uses \\(value) inside a string.",
            ],
            cheatsheet: cheatsheetStringBasics,
            lesson: lessonStrings,
            solution: #"""
let forgeLevel = 3
print("Forge level: \(forgeLevel)")
"""#,
            constraintProfile: core1BaselineProfile,
            introduces: [.stringInterpolation],
            topic: .strings,

        ),
        Challenge(
            number: 11,
            title: "Booleans",
            description: "Work with true and false values",
            starterCode: """
                // Challenge 11: Booleans
                // Booleans represent true or false

                // TODO: Create a constant 'isHeated' with the value true

                // TODO: Print the constant
                """,
            expectedOutput: "true",
            hints: [
                "Bool represents true/false values.",
                "print(...) outputs a value to the console.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
let isHeated: Bool = true
print(isHeated)
""",
            constraintProfile: core1BaselineProfile,
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
                "Comparisons return Bool values.",
                "print(...) outputs a value to the console.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
print(a == b)
print(a != b)
print(a < b)
print(a > b)
print(a <= b)
print(b >= a)
""",
            constraintProfile: core1BaselineProfile,
            introduces: [.comparisons],
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

                // TODO: Create a constant 'ready' that is true only if BOTH are ready
                // TODO: Create a constant 'partialReady' that is true if EITHER is ready
                // TODO: Create a constant 'notReady' that is the opposite of ready
                // TODO: Print the three readiness results in order
                """,
            expectedOutput: "false\ntrue\ntrue",
            hints: [
                "&& requires both conditions to be true; || requires either.",
                "! flips a Bool to its opposite.",
                "Print ready, then partialReady, then notReady.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
let ready = heatReady && toolsReady
let partialReady = heatReady || toolsReady
let notReady = !ready

print(ready)
print(partialReady)
print(notReady)
""",
            constraintProfile: core1BaselineProfile,
            introduces: [.booleanLogic],
            topic: .conditionals,

        ),
        Challenge(
            number: 14,
            title: "Comparison Flags",
            description: "Store comparison results in Bool constants",
            starterCode: """
                // Challenge 14: Comparison Flags
                // Store comparison results in a Bool.

                let temperature = 1500
                let minTemp = 1400

                // TODO: Create a constant 'hotEnough' that is true when temperature >= minTemp
                // TODO: Print hotEnough
                """,
            expectedOutput: "true",
            hints: [
                "Comparisons evaluate to Bool values.",
                "Assign the result to a named constant before printing.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
let hotEnough = temperature >= minTemp
print(hotEnough)
""",
            constraintProfile: core1BaselineProfile,
            topic: .conditionals,
        ),
        Challenge(
            number: 15,
            title: "Metal Readiness",
            description: "Use comparisons with && and ||",
            starterCode: """
                // Challenge 15: Metal Readiness
                // Use comparisons with boolean logic (no if/else).

                let metal = "Iron"
                let temperature = 1400

                // TODO: Create a constant 'ready' using boolean logic only:
                // - For "Iron": ready when temperature >= 1400
                // - For other metals: ready when temperature >= 1200
                // TODO: Print ready
                """,
            expectedOutput: "true",
            hints: [
                "Model it as two separate conditions, then combine them.",
                "Use parentheses to group each condition before you join them.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
let ready = (metal == "Iron" && temperature >= 1400)
    || (metal != "Iron" && temperature >= 1200)
print(ready)
""",
            constraintProfile: core1BaselineProfile,
            topic: .conditionals,
        ),
        Challenge(
            number: 16,
            title: "Function Basics",
            description: "Define and call a function",
            starterCode: """
                // Challenge 16: Function Basics
                // Define and call a function.

                // TODO: Create a function called 'greet' that prints "Forge"
                // TODO: Call the function
                """,
            expectedOutput: "Forge",
            hints: [
                "Define a function with func, then call it by name.",
                "The function body should print the word.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            lesson: lessonFunctionsBasics,
            solution: #"""
func greet() {
    print("Forge")
}

greet()
"""#,
            constraintProfile: core1BaselineProfile,
            introduces: [.functionsBasics],
            topic: .functions,

        ),
        Challenge(
            number: 17,
            title: "Function Parameters",
            description: "Pass values into functions",
            starterCode: """
                // Challenge 17: Function Parameters
                // Pass values into functions.

                // TODO: Create a function called 'announce' that takes a String parameter
                // and prints the parameter

                // TODO: Call the function with "Forge"

                // TODO: Create a function called 'mix' that takes a metal and weight
                // and prints "Metal: <metal>, Weight: <weight>"

                // TODO: Call the function with "Iron" and 3
                """,
        expectedOutput: "Forge\nMetal: Iron, Weight: 3",
        hints: [
            "Single-parameter functions use a name and a type.",
            "Function signatures look like announce(message: String).",
            "Multiple parameters look like mix(metal: String, weight: Int).",
            "Call both functions in order.",
        ],
        cheatsheet: cheatsheetFunctionsBasics,
        lesson: lessonFunctionsBasics,
        solution: #"""
func announce(message: String) {
    print(message)
}

announce(message: "Forge")

func mix(metal: String, weight: Int) {
    print("Metal: \(metal), Weight: \(weight)")
}

mix(metal: "Iron", weight: 3)
"""#,
            constraintProfile: core1BaselineProfile,
            topic: .functions,

    ),
        Challenge(
            number: 18,
            title: "Return Values",
            description: "Return a value from a function",
            starterCode: """
                // Challenge 18: Return Values
                // Functions can return a value

                // TODO: Create a function called 'addHeat' that takes an Int
                // and returns that value plus 200

                // TODO: Call the function with 1300 and store the result
                // TODO: Print the result
                """,
            expectedOutput: "1500",
            hints: [
                "Functions that return a value use -> ReturnType.",
                "Returned values can be stored for later use.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            lesson: lessonFunctionsBasics,
            solution: """
func addHeat(value: Int) -> Int {
    return value + 200
}

let result = addHeat(value: 1300)
print(result)
""",
            constraintProfile: core1BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 19,
            title: "Integration Challenge 1",
            description: "Combine variables, functions, math, and strings",
            starterCode: """
                // Challenge 19: Integration Challenge 1
                // Use multiple concepts together
                // Prereqs: variables, functions, math, string interpolation.

                // TODO: Create a variable 'hammerHits' with the value 2
                // TODO: Create a function 'totalHits' that multiplies hits by 3 and returns the result
                // TODO: Call totalHits and store the result
                // TODO: Print "Total hits: <result>" using string interpolation
                """,
            expectedOutput: "Total hits: 6",
            hints: [
                "This task blends state, computation, and presentation in one flow.",
                "You can store intermediate results before producing final output.",
                "Formatted output can include values inside the text.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            lesson: lessonCore1Integration,
            solution: #"""
var hammerHits = 2

func totalHits(hits: Int) -> Int {
    return hits * 3
}

let result = totalHits(hits: hammerHits)
print("Total hits: \(result)")
"""#,
            constraintProfile: core1BaselineProfile,
            requires: [.functionsBasics, .stringInterpolation],
            topic: .general,

        ),
        Challenge(
            number: 20,
            title: "Integration Challenge 2",
            description: "Core 1 capstone: combine the essentials in one task",
            starterCode: """
                // Challenge 20: Integration Challenge 2
                // Core 1 capstone: combine constants, variables, math, functions, and comparisons
                // Prereqs: comparisons, boolean logic, compound assignment.

                // TODO: Create a constant 'metal' with the value "Iron"
                // TODO: Create a variable 'temperature' with the value 1200
                // TODO: Increase temperature by 200 using a compound assignment
                // TODO: Create a function 'isReady' that takes a metal and temperature
                // Use boolean logic only:
                // - For "Iron": ready when temperature >= 1400
                // - For other metals: ready when temperature >= 1200
                // TODO: Call isReady and store the result
                // TODO: Print "<metal> ready: <result>" using string interpolation
                """,
            expectedOutput: "Iron ready: true",
            hints: [
                "Separate setup, rule selection, and reporting into distinct steps.",
                "Signature: isReady(metal: String, temperature: Int) -> Bool.",
                "Combine comparisons with && and || to express the rule.",
                "The final output should summarize the chosen rule’s result.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            lesson: lessonCore1Integration,
            solution: #"""
let metal = "Iron"
var temperature = 1200

temperature += 200

func isReady(metal: String, temperature: Int) -> Bool {
    let ironReady = metal == "Iron" && temperature >= 1400
    let otherReady = metal != "Iron" && temperature >= 1200
    return ironReady || otherReady
}

let ready = isReady(metal: metal, temperature: temperature)
print("\(metal) ready: \(ready)")
"""#,
            constraintProfile: core1BaselineProfile,
            requires: [.functionsBasics, .comparisons, .booleanLogic, .compoundAssignment, .stringInterpolation],
            topic: .general,

        ),
    ]
}

func makeCore2Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 21,
            title: "If/Else If/Else",
            description: "Choose between multiple branches",
            starterCode: """
                // Challenge 21: If/Else If/Else
                // Choose the right message for the heat level

                let heatLevel = 2

                // TODO: If heatLevel >= 3, print "Hot"
                // TODO: Else if heatLevel == 2, print "Warm"
                // TODO: Else print "Cold"
                """,
            expectedOutput: "Warm",
            hints: [
                "if/else if/else chains cover three cases.",
                "Put the fallback in the final else branch.",
            ],
            cheatsheet: cheatsheetConditionals,
            lesson: lessonConditionalsFlow,
            solution: #"""
if heatLevel >= 3 {
    print("Hot")
} else if heatLevel == 2 {
    print("Warm")
} else {
    print("Cold")
}
"""#,
            constraintProfile: core2BaselineProfile,
            introduces: [.ifElse],
            topic: .conditionals,

        ),
        Challenge(
            number: 22,
            title: "Ternary Operator",
            description: "Use a ternary to choose a value",
            starterCode: """
                // Challenge 22: Ternary Operator
                // Use a ternary operator to choose a message

                let heatLevel = 3

                // TODO: If heatLevel is >= 3, set status to "Hot", otherwise "Warm"
                // TODO: Print status
                """,
            expectedOutput: "Hot",
            hints: [
                "A ternary picks one of two values based on a condition.",
                "A ternary result can be stored in a variable before output.",
            ],
            cheatsheet: cheatsheetConditionals,
            lesson: lessonConditionalsFlow,
            solution: #"""
let status = heatLevel >= 3 ? "Hot" : "Warm"
print(status)
"""#,
            constraintProfile: core2BaselineProfile,
            topic: .conditionals,

        ),
        Challenge(
            number: 23,
            title: "Switch Statements",
            description: "Match multiple cases with switch",
            starterCode: """
                // Challenge 23: Switch Statements
                // Use switch to handle different metals

                let metal = "Iron"

                // TODO: Print "Forgeable" for 'Iron', "Soft" for 'Gold', and "Unknown" otherwise
                """,
            expectedOutput: "Forgeable",
            hints: [
                "switch compares one value against multiple cases.",
                "Include a default case for anything not matched.",
            ],
            cheatsheet: cheatsheetConditionals,
            lesson: lessonSwitchAndRanges,
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
            constraintProfile: core2BaselineProfile,
            introduces: [.switchStatement],
            topic: .conditionals,

        ),
        Challenge(
            number: 24,
            title: "Pattern Matching",
            description: "Match ranges and multiple values",
            starterCode: """
                // Challenge 24: Pattern Matching
                // Use switch to match ranges

                let temperature = 1450

                // TODO: Use switch on temperature
                // - 0...1199: print "Too cold"
                // - 1200...1499: print "Working"
                // - 1500...: print "Overheated"
                """,
            expectedOutput: "Working",
            hints: [
                "Switch cases can match ranges like 0...1199.",
                "A final case can cover values outside earlier ranges.",
            ],
            cheatsheet: cheatsheetRanges,
            lesson: lessonSwitchAndRanges,
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
            constraintProfile: core2BaselineProfile,
            introduces: [.ranges],
            topic: .conditionals,

        ),
        Challenge(
            number: 25,
            title: "For-In Loops",
            description: "Repeat work over a range",
            starterCode: """
                // Challenge 25: For-In Loops
                // Sum the numbers 1 through 5

                var total = 0

                // TODO: Loop from 1 to 5 and add each number to total
                // TODO: Print total
                """,
            expectedOutput: "15",
            hints: [
                "Closed ranges work with for-in loops.",
                "Accumulate into total before printing.",
            ],
            cheatsheet: cheatsheetLoops,
            lesson: lessonLoopsBasics,
            solution: """
for i in 1...5 {
    total += i
}
print(total)
""",
            constraintProfile: core2BaselineProfile,
            introduces: [.forInLoop],
            topic: .loops,

        ),
        Challenge(
            number: 26,
            title: "While Loops",
            description: "Repeat work while a condition is true",
            starterCode: """
                // Challenge 26: While Loops
                // Count down from 3 to 1

                var count = 3

                // TODO: While count is greater than 0, print count and decrement it
                """,
            expectedOutput: "3\n2\n1",
            hints: [
                "A while loop repeats while the condition stays true.",
                "Update the counter each pass so it eventually stops.",
            ],
            cheatsheet: cheatsheetLoops,
            lesson: lessonLoopsBasics,
            solution: """
while count > 0 {
    print(count)
    count -= 1
}
""",
            constraintProfile: core2BaselineProfile,
            introduces: [.whileLoop],
            topic: .loops,

        ),
        Challenge(
            number: 27,
            title: "Repeat-While",
            description: "Run code at least once",
            starterCode: """
                // Challenge 27: Repeat-While
                // Increase value until it reaches 1

                var value = 0

                // TODO: Use repeat-while to add 1 to value until it is at least 1
                // TODO: Print value
                """,
            expectedOutput: "1",
            hints: [
                "repeat-while always runs at least once.",
                "Update the value, then check the condition.",
            ],
            cheatsheet: cheatsheetLoops,
            lesson: lessonLoopsBasics,
            solution: """
repeat {
    value += 1
} while value < 1

print(value)
""",
            constraintProfile: core2BaselineProfile,
            introduces: [.repeatWhileLoop],
            topic: .loops,

        ),
        Challenge(
            number: 28,
            title: "Break and Continue",
            description: "Skip or stop inside a loop",
            starterCode: """
                // Challenge 28: Break and Continue
                // Print numbers 1 to 4, skipping 3

                // TODO: Loop from 1 to 5
                // - Skip 3 using continue
                // - Stop when you hit 5 using break
                // - Print the other numbers
                """,
            expectedOutput: "1\n2\n4",
            hints: [
                "continue skips the current loop iteration.",
                "break exits the loop entirely.",
            ],
            cheatsheet: cheatsheetLoops,
            lesson: lessonLoopsBasics,
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
            constraintProfile: core2BaselineProfile,
            introduces: [.breakContinue],
            topic: .loops,

        ),
        Challenge(
            number: 29,
            title: "Ranges",
            description: "Use closed and half-open ranges",
            starterCode: """
                // Challenge 29: Ranges
                // Compare closed and half-open ranges

                // TODO: Loop from 1 through 3 (inclusive) and print each number
                // TODO: Loop from 1 up to 3 (exclusive) and print each number
                """,
            expectedOutput: "1\n2\n3\n1\n2",
            hints: [
                "Closed ranges use 1...3 and include the end value.",
                "Half-open ranges use 1..<3 and stop before the end value.",
            ],
            cheatsheet: cheatsheetRanges,
            lesson: lessonSwitchAndRanges,
            solution: """
for i in 1...3 {
    print(i)
}
for i in 1..<3 {
    print(i)
}
""",
            constraintProfile: core2BaselineProfile,
            topic: .loops,

        ),
        Challenge(
            number: 30,
            title: "Arrays",
            description: "Create an array with a type annotation",
            starterCode: """
                // Challenge 30: Arrays
                // Create an array before modifying it

                // TODO: Create an array named 'ingots' with values 1, 2, 3
                // TODO: Use an explicit type annotation for the array
                // TODO: Print the array
                """,
            expectedOutput: "[1, 2, 3]",
            hints: [
                "Array literals use brackets with comma-separated values.",
                "Annotate the type: let ingots: [Int] = ...",
                "Printing shows array contents.",
            ],
            cheatsheet: cheatsheetArrays,
            lesson: lessonCollectionsBasics,
            solution: """
let ingots: [Int] = [1, 2, 3]
print(ingots)
""",
            constraintProfile: core2BaselineProfile,
            introduces: [.collections],
            topic: .collections,

        ),
        Challenge(
            number: 31,
            title: "Array Append",
            description: "Add a value and check the count",
            starterCode: """
                // Challenge 31: Array Append
                // Append a value and check the count

                var ingots = [1, 2, 3]

                // TODO: Append 4 to the array
                // TODO: Print how many values are in the array
                """,
            expectedOutput: "4",
            hints: [
                "append adds an element to the end.",
                "Use the count property to get the number of elements.",
            ],
            cheatsheet: cheatsheetArrays,
            lesson: lessonCollectionsBasics,
            solution: """
ingots.append(4)
print(ingots.count)
""",
            constraintProfile: core2BaselineProfile,
            topic: .collections,

        ),
        Challenge(
            number: 32,
            title: "Array Iteration",
            description: "Loop through array elements",
            starterCode: """
                // Challenge 32: Array Iteration
                // Add up the weights

                let weights = [2, 4, 6]
                var total = 0

                // TODO: Loop through weights and add each to total
                // TODO: Print total
                """,
            expectedOutput: "12",
            hints: [
                "for-in iterates over each element.",
                "Accumulate a running total, then print it.",
            ],
            cheatsheet: cheatsheetLoops,
            lesson: lessonLoopsBasics,
            solution: """
for weight in weights {
    total += weight
}
print(total)
""",
            constraintProfile: core2BaselineProfile,
            topic: .loops,

        ),
        Challenge(
            number: 33,
            title: "Metrics Practice",
            description: "Practice loop-based stats on a small data set (mini Core 2 Project A)",
            starterCode: """
                // Challenge 33: Metrics Practice
                // Practice min/max/average counting in a loop.

                let weights = [3, 5, 7, 4]

                // TODO: Find the minimum value (start with weights[0] and update)
                // TODO: Find the maximum value (start with weights[0] and update)
                // TODO: Compute the average (sum then divide by the number of weights)
                // TODO: Count values >= 5
                // TODO: Print results as:
                // "Min: 3"
                // "Max: 7"
                // "Average: 4"
                // "Heavy: 2"
                """,
            expectedOutput: "Min: 3\nMax: 7\nAverage: 4\nHeavy: 2",
            hints: [
                "Initialize min and max with the first value.",
                "A loop can update min, max, sum, and counts.",
                "Average uses integer division by the count (weights.count).",
            ],
            cheatsheet: cheatsheetLoops,
            lesson: lessonLoopsBasics,
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
            constraintProfile: core2BaselineProfile,
            topic: .loops,

        ),
        Challenge(
            number: 34,
            title: "Dictionaries",
            description: "Store key-value pairs",
            starterCode: """
                // Challenge 34: Dictionaries
                // Look up an item count

                let inventory = ["Iron": 3, "Gold": 1]

                // TODO: Read the value for 'Iron' (use a default if missing)
                // TODO: Print the value
                """,
            expectedOutput: "3",
            hints: [
                "Use a dictionary subscript with a default value.",
                "Example: inventory[\"Iron\", default: 0].",
            ],
            cheatsheet: cheatsheetDictionaries,
            lesson: lessonCollectionsBasics,
            solution: #"""
let count = inventory["Iron", default: 0]
print(count)
"""#,
            constraintProfile: core2BaselineProfile,
            topic: .collections,

        ),
        Challenge(
            number: 35,
            title: "Collection Properties",
            description: "Use built-in collection properties",
            starterCode: """
                // Challenge 35: Collection Properties
                // Use properties to reduce manual work

                let ingots = [1, 2, 3, 4]
                let inventory = ["Iron": 2, "Gold": 1]

                // TODO: Print how many ingots are in the array
                // TODO: Print whether the ingots array is empty
                // TODO: Print how many inventory entries exist
                // TODO: Print how many inventory keys exist
                // TODO: Print how many inventory values exist
                """,
            expectedOutput: "4\nfalse\n2\n2\n2",
            hints: [
                "You've seen count; now apply it to arrays and dictionaries.",
                "Use collection properties like `.count` and `.isEmpty`.",
                "Dictionary keys are a collection too (`.keys`).",
                "Dictionary values are also a collection (`.values`).",
            ],
            cheatsheet: cheatsheetCollectionsBasics,
            lesson: lessonCollectionsBasics,
            solution: """
print(ingots.count)
print(ingots.isEmpty)
print(inventory.count)
print(inventory.keys.count)
print(inventory.values.count)
""",
            constraintProfile: core2BaselineProfile,
            topic: .collections,

        ),
        Challenge(
            number: 36,
            title: "Sets",
            description: "Keep only unique values",
            starterCode: """
                // Challenge 36: Sets
                // Count unique ingots

                let batch = [1, 2, 2, 3]

                // TODO: Create a Set from batch
                // TODO: Print the number of unique values
                """,
            expectedOutput: "3",
            hints: [
                "A Set removes duplicate values.",
                "Use the count property to measure unique values.",
            ],
            cheatsheet: cheatsheetSets,
            lesson: lessonSetsBasics,
            solution: """
let unique = Set(batch)
print(unique.count)
""",
            constraintProfile: core2BaselineProfile,
            topic: .collections,

        ),
        Challenge(
            number: 37,
            title: "Tuples",
            description: "Group related values together",
            starterCode: """
                // Challenge 37: Tuples
                // Use named tuple values

                let report = (min: 1200, max: 1600, average: 1425)
                let temps = (1200, 1600)

                // TODO: Print the first value of 'temps'
                // TODO: Print the second value

                // TODO: Print "Min: 1200" using the tuple labels
                // TODO: Print "Max: 1600" using the tuple labels
                // TODO: Print "Average: 1425" using the tuple labels
                """,
            expectedOutput: "1200\n1600\nMin: 1200\nMax: 1600\nAverage: 1425",
            hints: [
                "Tuples can be accessed by index or by name.",
                "Use temps.0 and temps.1 for the positional tuple.",
                "Use report.min, report.max, and report.average for the labeled tuple.",
                "String interpolation formats labeled values.",
            ],
            cheatsheet: cheatsheetTuples,
            lesson: lessonTuplesBasics,
            solution: #"""
print(temps.0)
print(temps.1)
print("Min: \(report.min)")
print("Max: \(report.max)")
print("Average: \(report.average)")
"""#,
            constraintProfile: core2BaselineProfile,
            introduces: [.tuples],
            topic: .general,

        ),
        Challenge(
            number: 38,
            title: "Tuple Returns",
            description: "Return multiple values from a function (Core 2 Project A pattern)",
            starterCode: """
                // Challenge 38: Tuple Returns
                // Return min and max from a function.

                let temps = [3, 5, 2, 6]

                // TODO: Write a function minMax(values:) that returns a (min, max) tuple
                // TODO: Call it and print:
                // "Min: 2"
                // "Max: 6"
                """,
            expectedOutput: "Min: 2\nMax: 6",
            hints: [
                "Initialize min/max from the first element.",
                "Update them while iterating the array.",
                "Return a named tuple like (min: Int, max: Int).",
            ],
            cheatsheet: cheatsheetTuples,
            lesson: lessonTuplesBasics,
            solution: """
func minMax(values: [Int]) -> (min: Int, max: Int) {
    var minValue = values[0]
    var maxValue = values[0]

    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
    }

    return (min: minValue, max: maxValue)
}

let report = minMax(values: temps)
print(\"Min: \\(report.min)\")
print(\"Max: \\(report.max)\")
""",
            constraintProfile: core2BaselineProfile,
            topic: .functions
        ),
        Challenge(
            number: 39,
            title: "Optionals",
            description: "Handle missing values safely",
            starterCode: """
                // Challenge 39: Optionals
                // Avoid force-unwrapping with !

                let heatLevel: Int? = 1200

                // TODO: Use if let to unwrap heatLevel
                // Print the value if it exists, otherwise print "No heat"
                """,
            expectedOutput: "1200",
            hints: [
                "if let unwraps an optional safely.",
                "Provide a fallback when the value is nil.",
            ],
            cheatsheet: cheatsheetOptionals,
            lesson: lessonOptionalsBasics,
            solution: #"""
if let level = heatLevel {
    print(level)
} else {
    print("No heat")
}
"""#,
            constraintProfile: core2BaselineProfile,
            introduces: [.optionals, .optionalBinding, .nilLiteral],
            topic: .optionals,

        ),
        Challenge(
            number: 40,
            title: "Optional Binding",
            description: "Unwrap optionals with if let",
            starterCode: """
                // Challenge 40: Optional Binding
                // Unwrap multiple optionals

                let smithName: String? = "Forge"
                let metal: String? = "Iron"

                // TODO: Use if let to unwrap both values
                // Print "Forge works Iron"
                """,
            expectedOutput: "Forge works Iron",
            hints: [
                "Multiple optionals can be unwrapped in one if let.",
                "Only print when both values are available.",
            ],
            cheatsheet: cheatsheetOptionals,
            lesson: lessonOptionalsBasics,
            solution: #"""
if let smithName = smithName, let metal = metal {
    print("\(smithName) works \(metal)")
}
"""#,
            constraintProfile: core2BaselineProfile,
            topic: .optionals,

        ),
        Challenge(
            number: 41,
            title: "Guard Let",
            description: "Exit early when data is missing",
            starterCode: """
                // Challenge 41: Guard Let
                // Print a heat value if it exists

                func printHeat(value: Int?) {
                    // TODO: Use guard let to unwrap value
                    // Print "No heat" if value is nil
                    // Otherwise print the unwrapped value
                }

                // TODO: Call printHeat with nil
                """,
            expectedOutput: "No heat",
            hints: [
                "guard let unwraps and exits early on nil.",
                "Place the fallback print inside the guard's else block.",
            ],
            cheatsheet: cheatsheetOptionals,
            lesson: lessonOptionalsBasics,
            solution: #"""
func printHeat(value: Int?) {
    guard let value = value else {
        print("No heat")
        return
    }
    print(value)
}

printHeat(value: nil)
"""#,
            constraintProfile: core2BaselineProfile,
            introduces: [.guardStatement],
            topic: .optionals,

        ),
        Challenge(
            number: 42,
            title: "Nil Coalescing",
            description: "Provide a fallback value",
            starterCode: """
                // Challenge 42: Nil Coalescing
                // Use ?? to provide a default

                let optionalLevel: Int? = nil

                // TODO: Use ?? to set level to 1 when optionalLevel is nil
                // TODO: Print "Level 1"
                """,
            expectedOutput: "Level 1",
            hints: [
                "?? supplies a fallback when an optional is nil.",
                "A fallback value can be used when the optional is nil.",
            ],
            cheatsheet: cheatsheetOptionals,
            lesson: lessonOptionalsBasics,
            solution: #"""
let level = optionalLevel ?? 1
print("Level \(level)")
"""#,
            constraintProfile: core2BaselineProfile,
            introduces: [.nilCoalescing],
            topic: .optionals,

        ),
    ]
}

func makeCore3Challenges() -> [Challenge] {
    return [
        Challenge(
            number: 43,
            title: "String Methods",
            description: "Inspect and transform strings",
            starterCode: """
                // Challenge 43: String Methods
                // Use basic string properties and methods.

                let phrase = "Forge Ready"

                // TODO: Print the length of the phrase
                // TODO: Print the lowercase version of the phrase
                // TODO: Print whether the phrase contains "Ready"
                """,
            expectedOutput: "11\nforge ready\ntrue",
            hints: [
                "Strings have properties and methods for basic inspection.",
                "Use phrase.count and phrase.lowercased().",
                "Use phrase.contains(\"Ready\") to check for a substring.",
            ],
            cheatsheet: cheatsheetStrings,
            lesson: lessonStringsAdvanced,
            solution: """
print(phrase.count)
print(phrase.lowercased())
print(phrase.contains(\"Ready\"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings
        ),
        Challenge(
            number: 44,
            title: "Dictionary Iteration",
            description: "Loop through key-value pairs",
            starterCode: """
                // Challenge 44: Dictionary Iteration
                // Summarize the inventory totals.

                let inventory = ["Iron": 3, "Gold": 1]

                // TODO: Loop over each (metal, count) pair
                // TODO: Sum the total ingot count
                // TODO: Count how many metals are in the inventory
                // TODO: Print the metal count, then the total ingots
                """,
            expectedOutput: "2\n4",
            hints: [
                "Loop through the dictionary with for (metal, count) in inventory.",
                "Use Int variables to track totals as you iterate.",
            ],
            cheatsheet: cheatsheetDictionaries,
            lesson: lessonCollectionsAdvanced,
            solution: """
var total = 0
var metalCount = 0

for (_, count) in inventory {
    total += count
    metalCount += 1
}

print(metalCount)
print(total)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections
        ),
        Challenge(
            number: 45,
            title: "Dictionary Ordering",
            description: "Print dictionary items in a stable order",
            starterCode: """
                // Challenge 45: Dictionary Ordering
                // Print inventory items in a stable order.

                let inventory = ["Iron": 3, "Gold": 1]

                // TODO: Loop over keys in alphabetical order
                // TODO: Print "<metal>: <count>" for each item
                """,
            expectedOutput: "Gold: 1\nIron: 3",
            hints: [
                "Dictionaries can provide their keys as a collection.",
                "Use inventory.keys.sorted() for a stable order.",
                "Read values through the subscript (inventory[key]).",
            ],
            cheatsheet: cheatsheetDictionaries,
            lesson: lessonCollectionsAdvanced,
            solution: """
for key in inventory.keys.sorted() {
    if let count = inventory[key] {
        print(\"\\(key): \\(count)\")
    }
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections
        ),
        Challenge(
            number: 46,
            title: "String Prefix & Suffix",
            description: "Check string prefixes and suffixes",
            starterCode: """
                // Challenge 46: String Prefix & Suffix
                // Check the start and end of a string.

                let code = "Forge-01"

                // TODO: Print whether 'code' has prefix "Forge"
                // TODO: Print whether 'code' has suffix "01"
                """,
            expectedOutput: "true\ntrue",
            hints: [
                "hasPrefix and hasSuffix return Bool values.",
            ],
            cheatsheet: cheatsheetStrings,
            lesson: lessonStringsAdvanced,
            solution: """
print(code.hasPrefix("Forge"))
print(code.hasSuffix("01"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings
        ),
        Challenge(
            number: 47,
            title: "External & Internal Labels",
            description: "Design clear APIs with distinct labels",
            starterCode: """
                // Challenge 47: External & Internal Labels
                // Create a function with different external and internal labels.

                // TODO: Create a function called 'forgeHeat' that uses:
                // external label: at
                // internal label: temperature
                // It should print "Heat: <temperature>"

                // TODO: Call the function with 1500
                """,
            expectedOutput: "Heat: 1500",
            hints: [
                "External and internal labels can differ in a function signature.",
                "External labels appear at call sites.",
            ],
            cheatsheet: cheatsheetFunctions,
            lesson: lessonFunctionsAdvanced,
            solution: #"""
func forgeHeat(at temperature: Int) {
    print("Heat: \(temperature)")
}

forgeHeat(at: 1500)
"""#,
            constraintProfile: core3BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 48,
            title: "Void Argument Labels",
            description: "Omit external labels when needed",
            starterCode: """
                // Challenge 48: Void Argument Labels
                // Use _ to omit the external label.

                // TODO: Create a function 'announce' that omits the external label
                // and prints "Metal: <metal>"

                // TODO: Call announce with "Iron" (no label)
                """,
            expectedOutput: "Metal: Iron",
            hints: [
                "Use an underscore in the signature: announce(_ metal: String).",
                "When underscore is used, call it like announce(\"Iron\").",
            ],
            cheatsheet: cheatsheetFunctions,
            lesson: lessonFunctionsAdvanced,
            solution: #"""
func announce(_ metal: String) {
    print("Metal: \(metal)")
}

announce("Iron")
"""#,
            constraintProfile: core3BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 49,
            title: "Default Parameters",
            description: "Use default values to simplify calls",
            starterCode: """
                // Challenge 49: Default Parameters
                // Add a default intensity parameter.

                // TODO: Create a function 'strike' that takes:
                // - a metal
                // - an intensity with a default value of 1
                // Print "Striking <metal> with intensity <intensity>"

                // TODO: Call strike with "Iron"
                // TODO: Call strike with "Gold" and intensity 3
                """,
            expectedOutput: "Striking Iron with intensity 1\nStriking Gold with intensity 3",
            hints: [
                "Default parameter values make arguments optional.",
                "Signature example: strike(_ metal: String, intensity: Int = 1).",
                "Default parameters can be omitted at the call site.",
            ],
            cheatsheet: cheatsheetFunctions,
            lesson: lessonFunctionsAdvanced,
            solution: #"""
func strike(_ metal: String, intensity: Int = 1) {
    print("Striking \(metal) with intensity \(intensity)")
}

strike("Iron")
strike("Gold", intensity: 3)
"""#,
            constraintProfile: core3BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 50,
            title: "Variadics",
            description: "Accept any number of values",
            starterCode: """
                // Challenge 50: Variadics
                // Accept multiple temperatures.

                // TODO: Create a function 'averageTemp' that takes any number of Ints
                // TODO: Sum the values and divide by how many values there are (integer division)
                // TODO: Print the average

                // TODO: Call averageTemp with 1000, 1200, 1400
                """,
            expectedOutput: "1200",
            hints: [
                "Variadic parameters accept multiple values of the same type.",
                "The average uses the total divided by temps.count.",
            ],
            cheatsheet: cheatsheetFunctions,
            lesson: lessonFunctionsAdvanced,
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
            constraintProfile: core3BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 51,
            title: "inout Parameters",
            description: "Mutate a value passed into a function",
            starterCode: """
                // Challenge 51: inout Parameters
                // Simulate tool wear.

                // TODO: Create a function 'wear' that subtracts 1 from a passed-in Int

                // TODO: Create a variable 'durability' = 5
                // TODO: Call wear on durability
                // TODO: Print durability
                """,
            expectedOutput: "4",
            hints: [
                "inout lets a function modify the caller’s variable.",
                "inout arguments are passed with &.",
            ],
            cheatsheet: cheatsheetFunctions,
            lesson: lessonFunctionsAdvanced,
            solution: """
func wear(_ durability: inout Int) {
    durability -= 1
}

var durability = 5
wear(&durability)
print(durability)
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 52,
            title: "Nested Functions",
            description: "Use helper functions inside functions",
            starterCode: """
                // Challenge 52: Nested Functions
                // Validate before processing.

                // TODO: Create a function 'process' that takes an Int parameter
                // - defines a nested function isValid(_:) returning Bool
                // - prints "OK" if valid, otherwise "Invalid"
                // Valid = value >= 0

                // TODO: Call process with -1
                """,
            expectedOutput: "Invalid",
            hints: [
                "Nested functions can encapsulate helper logic.",
                "A helper Bool can drive the output choice.",
            ],
            cheatsheet: cheatsheetFunctions,
            lesson: lessonFunctionsAdvanced,
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
            constraintProfile: core3BaselineProfile,
            topic: .functions,

        ),
        Challenge(
            number: 53,
            title: "Closure Basics",
            description: "Create and call a closure",
            starterCode: """
                // Challenge 53: Closure Basics
                // Store a closure in a constant.

                // TODO: Create a closure called strike that prints "Strike"
                // TODO: Call the closure
                """,
            expectedOutput: "Strike",
            hints: [
                "Closures can be assigned to constants.",
                "Invoke the closure like a function.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: #"""
let strike = { () -> Void in
    print("Strike")
}

strike()
"""#,
            constraintProfile: core3ClosureProfile,
            introduces: [.closures],
            topic: .functions,

        ),
        Challenge(
            number: 54,
            title: "Closure Parameters",
            description: "Pass values into a closure",
            starterCode: """
                // Challenge 54: Closure Parameters
                // Create a closure that transforms a value.

                // TODO: Create a closure called doubleHeat that takes an Int
                // and returns the value multiplied by 2
                // TODO: Print doubleHeat(750)
                """,
            expectedOutput: "1500",
            hints: [
                "Closures can take parameters and return values.",
                "Closures are invoked like functions to produce a result.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
let doubleHeat = { (value: Int) -> Int in
    return value * 2
}

print(doubleHeat(750))
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 55,
            title: "Implicit Return in Closures",
            description: "Omit the return keyword in a single-expression closure",
            starterCode: """
                // Challenge 55: Implicit Return in Closures
                // Use an explicit signature, but omit return.

                // TODO: Create a closure called 'doubleHeat' that takes an Int
                // and returns the value multiplied by 2
                // TODO: Print doubleHeat(600)
                """,
            expectedOutput: "1200",
            hints: [
                "Single-expression closures can omit return.",
                "Keep the same parameter and return types.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
let doubleHeat = { (value: Int) -> Int in
    value * 2
}

print(doubleHeat(600))
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 56,
            title: "Inferred Closure Types",
            description: "Let Swift infer parameter and return types",
            starterCode: """
                // Challenge 56: Inferred Closure Types
                // Remove explicit types when they can be inferred.

                // TODO: Create a closure called 'doubleHeat' using inferred types
                // It should multiply the input by 2
                // TODO: Print doubleHeat(750)
                """,
            expectedOutput: "1500",
            hints: [
                "Type inference can remove explicit parameter types.",
                "Let Swift infer the return type from the expression.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
let doubleHeat = { value in
    value * 2
}

print(doubleHeat(750))
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 57,
            title: "Shorthand Closure Syntax I",
            description: "Use $0 in an assigned closure",
            starterCode: """
                // Challenge 57: Shorthand Closure Syntax I
                // Use $0 in a closure stored in a constant.

                // TODO: Create a closure called 'doubleHeat' using $0
                // It should multiply the input by 2
                // TODO: Print doubleHeat(700)
                """,
            expectedOutput: "1400",
            hints: [
                "Shorthand arguments like $0 can replace named parameters.",
                "After defining it, call the closure like a function to produce a value.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
let doubleHeat = { $0 * 2 }
print(doubleHeat(700))
""",
            constraintProfile: core3ClosureProfile,
            introduces: [.shorthandClosureArgs],
            topic: .functions,

        ),
        Challenge(
            number: 58,
            title: "Annotated Closure Assignment",
            description: "Bind a closure to a typed constant",
            starterCode: """
                // Challenge 58: Annotated Closure Assignment
                // Use a closure with an explicit type annotation.

                // TODO: Create a constant 'doubleHeat' with an explicit function type
                // Use a shorthand closure to multiply the input by 2
                // TODO: Print doubleHeat(900)
                """,
            expectedOutput: "1800",
            hints: [
                "You can annotate a closure variable with its function type (Int) -> Int.",
                "Shorthand closure syntax can compute the result.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
let doubleHeat: (Int) -> Int = { $0 * 2 }
print(doubleHeat(900))
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 59,
            title: "Closure Arguments",
            description: "Call a function with a closure argument",
            starterCode: """
                // Challenge 59: Closure Arguments
                // Call a function that takes a closure.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using the full closure argument
                // Multiply the value by 3
                """,
            expectedOutput: "15",
            hints: [
                "Functions can accept closures as parameters.",
                "Provide a closure that multiplies the input.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
transform(5, using: { (value: Int) -> Int in
    return value * 3
})
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 60,
            title: "Trailing Closures",
            description: "Use trailing closure syntax",
            starterCode: """
                // Challenge 60: Trailing Closures
                // Use a closure to transform values.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 5 using trailing closure syntax
                // Multiply the value by 3
                """,
            expectedOutput: "15",
            hints: [
                "Trailing closure syntax moves the closure outside the parentheses.",
                "Keep the same multiplication logic as before.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
transform(5) { (value: Int) -> Int in
    return value * 3
}
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 61,
            title: "Inferred Trailing Closures",
            description: "Drop types and return when they can be inferred",
            starterCode: """
                // Challenge 61: Inferred Trailing Closures
                // Let Swift infer types in a trailing closure.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 6 using trailing closure syntax
                // Multiply the value by 4
                // Note: You can omit return for a single-expression closure (Challenge 50)
                """,
            expectedOutput: "24",
            hints: [
                "Let Swift infer parameter and return types in the closure.",
                "Keep the expression to a single line.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: """
transform(6) { value in
    return value * 4
}
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 62,
            title: "Shorthand Closure Syntax II",
            description: "Use $0 for compact closures",
            starterCode: """
                // Challenge 62: Shorthand Closure Syntax II
                // Use $0 to shorten a closure.

                func apply(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call apply with 4 and use $0 to add 6
                """,
            expectedOutput: "10",
            hints: [
                "Shorthand arguments can keep the closure concise.",
                "The result adds a constant to the input.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
            solution: "apply(4) { $0 + 6 }",
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 63,
            title: "Capturing Values",
            description: "Understand closure capture behavior",
            starterCode: """
                // Challenge 63: Capturing Values
                // Create a counter function.

                // TODO: Create a function 'makeCounter' that returns a closure
                // The closure should increment and print an internal count

                // TODO: Create a counter and call it three times
                """,
            expectedOutput: "1\n2\n3",
            hints: [
                "Closures can capture and mutate values from their outer scope.",
                "Each call should update the stored count.",
            ],
            cheatsheet: cheatsheetClosures,
            lesson: lessonClosuresBasics,
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
            constraintProfile: core3ClosureProfile,
            topic: .functions,

        ),
        Challenge(
            number: 64,
            title: "map",
            description: "Transform values with map",
            starterCode: """
                // Challenge 64: map
                // Transform forge temperatures into strings.

                let temps = [1200, 1500, 1600]

                // TODO: Transform each temp into a label like "T1200"
                // TODO: Print the resulting array
                """,
            expectedOutput: #"["T1200", "T1500", "T1600"]"#,
            hints: [
                "Use map to transform each element.",
                "Build a string that combines a prefix with the value.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCollectionTransforms,
            solution: #"""
let labels = temps.map { "T\($0)" }
print(labels)
"""#,
            constraintProfile: core3BaselineProfile,
            introduces: [.map],
            topic: .collections,

        ),
        Challenge(
            number: 65,
            title: "filter",
            description: "Select values with filter",
            starterCode: """
                // Challenge 65: filter
                // Keep only hot temperatures.

                let temps = [1000, 1500, 1600, 1400]

                // TODO: Keep temps >= 1500
                // TODO: Print the filtered array
                """,
            expectedOutput: "[1500, 1600]",
            hints: [
                "Use filter to keep values that match a condition.",
                "A comparison can filter for hot temperatures.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCollectionTransforms,
            solution: """
let hot = temps.filter { $0 >= 1500 }
print(hot)
""",
            constraintProfile: core3BaselineProfile,
            introduces: [.filter],
            topic: .collections,

        ),
        Challenge(
            number: 66,
            title: "reduce",
            description: "Combine values with reduce",
            starterCode: """
                // Challenge 66: reduce
                // Sum forge temperatures.

                let temps = [1000, 1200, 1400]

                // TODO: Compute the total of all temps
                // TODO: Print the total
                """,
            expectedOutput: "3600",
            hints: [
                "Use reduce to combine all elements into a single value.",
                "Start from 0 and add each element.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCollectionTransforms,
            solution: """
let total = temps.reduce(0) { partial, temp in
    partial + temp
}
print(total)
""",
            constraintProfile: core3BaselineProfile,
            introduces: [.reduce],
            topic: .collections,

        ),
        Challenge(
            number: 67,
            title: "min/max",
            description: "Find smallest and largest values",
            starterCode: """
                // Challenge 67: min/max
                // Find the smallest and largest temperatures.

                let temps = [1200, 1500, 1600, 1400]

                // TODO: Find the smallest temp (default to 0 if nil)
                // TODO: Find the largest temp (default to 0 if nil)
                // TODO: Print min then max on separate lines
                """,
            expectedOutput: "1200\n1600",
            hints: [
                "Use min() and max(); they return Optionals.",
                "Provide a fallback with ?? before printing.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCollectionTransforms,
            solution: """
let minTemp = temps.min() ?? 0
let maxTemp = temps.max() ?? 0
print(minTemp)
print(maxTemp)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,

        ),
        Challenge(
            number: 68,
            title: "compactMap",
            description: "Remove nil values safely",
            starterCode: """
                // Challenge 68: compactMap
                // Clean up optional readings.

                let readings: [Int?] = [1200, nil, 1500, nil, 1600]

                // TODO: Remove nils and keep only Int values
                // TODO: Print the cleaned array
                """,
            expectedOutput: "[1200, 1500, 1600]",
            hints: [
                "Use compactMap to remove nils while unwrapping values.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCollectionTransforms,
            solution: """
let cleaned = readings.compactMap { $0 }
print(cleaned)
""",
            constraintProfile: core3BaselineProfile,
            introduces: [.compactMap],
            topic: .collections,

        ),
        Challenge(
            number: 69,
            title: "flatMap",
            description: "Flatten nested arrays",
            starterCode: """
                // Challenge 69: flatMap
                // Flatten batches.

                let batches = [[1, 2], [3], [4, 5]]

                // TODO: Flatten the nested arrays into one list
                // TODO: Print the result
                """,
            expectedOutput: "[1, 2, 3, 4, 5]",
            hints: [
                "Use flatMap to flatten arrays of arrays into one array.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCollectionTransforms,
            solution: """
let flat = batches.flatMap { $0 }
print(flat)
""",
            constraintProfile: core3BaselineProfile,
            introduces: [.flatMap],
            topic: .collections,

        ),
        Challenge(
            number: 70,
            title: "typealias",
            description: "Improve readability with type aliases",
            starterCode: """
                // Challenge 70: typealias
                // Create a readable alias.

                // TODO: Create a typealias for a reading with temp and time
                // TODO: Create a reading with temp 1200 and time 1
                // TODO: Print the temperature from reading
                """,
            expectedOutput: "1200",
            hints: [
                "typealias can make tuple types more readable (e.g., ForgeReading = (temp: Int, time: Int)).",
                "Named tuple fields are accessed with dot syntax (reading.temp).",
            ],
            cheatsheet: cheatsheetTypealiases,
            lesson: lessonTypealiases,
            solution: """
typealias ForgeReading = (temp: Int, time: Int)
let reading: ForgeReading = (temp: 1200, time: 1)
print(reading.temp)
""",
            constraintProfile: core3BaselineProfile,
            introduces: [.typeAlias],
            topic: .general,

        ),
        Challenge(
            number: 71,
            title: "Enums",
            description: "Represent a set of cases",
            starterCode: """
                // Challenge 71: Enums
                // Represent forge metals.

                // TODO: Create an enum Metal with cases iron and gold
                // TODO: Create a value and print "iron" or "gold" using a switch
                """,
            expectedOutput: "iron",
            hints: [
                "Enums define a closed set of cases.",
                "switch handles each enum case.",
            ],
            cheatsheet: cheatsheetEnums,
            lesson: lessonEnumsBasics,
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
            constraintProfile: core3BaselineProfile,
            introduces: [.enums],
            topic: .general,

        ),
        Challenge(
            number: 72,
            title: "Enums with Raw Values",
            description: "Represent simple categories",
            starterCode: """
                // Challenge 72: Enums with Raw Values
                // Represent metals.

                // TODO: Create an enum Metal with String raw values (iron, gold)
                // TODO: Print the raw value for the iron case
                """,
            expectedOutput: "iron",
            hints: [
                "Declare the enum as Metal: String and use .rawValue to print.",
            ],
            cheatsheet: cheatsheetEnums,
            lesson: lessonEnumsBasics,
            solution: """
enum Metal: String {
    case iron
    case gold
}

print(Metal.iron.rawValue)
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,

        ),
        Challenge(
            number: 73,
            title: "Enums with Associated Values",
            description: "Represent structured events",
            starterCode: """
                // Challenge 73: Enums with Associated Values
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
                "Associated values let enum cases carry data.",
                "Value bindings in switch extract associated data.",
            ],
            cheatsheet: cheatsheetEnums,
            lesson: lessonEnumsBasics,
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
            constraintProfile: core3BaselineProfile,
            topic: .general,

        ),
        Challenge(
            number: 74,
            title: "Enum Pattern Matching",
            description: "Match and extract associated values",
            starterCode: """
                // Challenge 74: Enum Pattern Matching
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
                "switch with where can add extra conditions to a case.",
                "Handle temperature and error cases separately.",
            ],
            cheatsheet: cheatsheetEnums,
            lesson: lessonEnumsBasics,
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
            constraintProfile: core3BaselineProfile,
            introduces: [.whereClauses],
            topic: .conditionals,

        ),
        Challenge(
            number: 75,
            title: "Throwing Functions",
            description: "Introduce error throwing",
            starterCode: """
                // Challenge 75: Throwing Functions
                // Validate temperature.

                // TODO: Create an enum TempError: Error with case outOfRange
                // TODO: Create a function 'checkTemp' that throws if temp < 0
                // TODO: Call it with -1 using do/try/catch
                // Print "Error" in the catch block
                """,
            expectedOutput: "Error",
            hints: [
                "Define an Error type for invalid input.",
                "Throw when the temperature is out of range.",
                "do/try/catch handles thrown errors.",
            ],
            cheatsheet: cheatsheetErrors,
            lesson: lessonErrorsBasics,
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
            constraintProfile: core3BaselineProfile,
            introduces: [.doCatch, .throwKeyword, .tryKeyword, .errorTypes, .throwingFunctions, .doTryCatch],
            topic: .functions,

        ),
        Challenge(
            number: 76,
            title: "try?",
            description: "Convert errors into optionals",
            starterCode: """
                // Challenge 76: try?
                // Use try? to simplify error handling.

                // TODO: Reuse checkTemp from the previous challenge
                // TODO: Make checkTemp return the temperature if valid
                // TODO: Call it with -1 using optional try
                // TODO: Print the result (should be nil)
                """,
            expectedOutput: "nil",
            hints: [
                "Use try? to convert a thrown error into nil.",
                "Printing the optional should show nil when the call fails.",
            ],
            cheatsheet: cheatsheetErrors,
            lesson: lessonErrorsBasics,
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
print(String(describing: result))
""",
            constraintProfile: core3BaselineProfile,
            introduces: [.tryOptional],
            topic: .functions,

        ),
        Challenge(
            number: 77,
            title: "ReadLine Input",
            description: "Read from standard input",
            starterCode: """
                // Challenge 77: readLine
                // Read a value from standard input.
                //
                // Forge pipes fixtures/input.txt into stdin, so readLine() reads its first line.
                //
                // Expected output: You entered Iron

                // TODO: Read a line from input
                // TODO: If input exists, print "You entered <input>"
                // TODO: Otherwise print "No input"
                """,
            expectedOutput: "You entered Iron",
            hints: [
                "readLine() returns an optional string.",
                "Handle nil with an else branch.",
            ],
            cheatsheet: cheatsheetInputOutput,
            lesson: lessonInputOutputBasics,
            solution: #"""
if let input = readLine() {
    let message = "You entered \(input)"
    print(message)
} else {
    print("No input")
}
"""#,
            stdinFixture: "input.txt",
            constraintProfile: core3BaselineProfile,
            introduces: [.readLine],
            topic: .general,

        ),
        Challenge(
            number: 78,
            title: "Command-Line Arguments",
            description: "Read from CommandLine.arguments",
            starterCode: """
                // Challenge 78: Command-Line Arguments
                // Read arguments.
                //
                // Forge injects args from fixtures/args.txt into CommandLine.arguments.
                //
                // Expected output: Iron

                let args = CommandLine.arguments

                // TODO: If args has at least 2 items, print args[1]
                // Otherwise print "No args"
                //
                // Note: This prints only the first argument after the script name.
                """,
            expectedOutput: "Iron",
            hints: [
                "CommandLine.arguments includes the script name at index 0.",
                "Check the count before accessing args[1].",
            ],
            cheatsheet: cheatsheetInputOutput,
            lesson: lessonInputOutputBasics,
            solution: #"""
if args.count >= 2 {
    print(args[1])
} else {
    print("No args")
}
"""#,
            argsFixture: "args.txt",
            constraintProfile: core3BaselineProfile,
            introduces: [.commandLineArguments],
            topic: .general,

        ),
        Challenge(
            number: 79,
            title: "File Read",
            description: "Read from a file on disk",
            starterCode: """
                // Challenge 79: File Read
                // Read a file of temperatures.
                //
                // Forge copies fixtures/temperatures.txt into the workspace folder.
                // Your code reads it by path from the current working directory.
                // Note: This requires Foundation for String(contentsOfFile:).
                //
                // Expected output: 3

                import Foundation

                let path = "temperatures.txt"

                // TODO: Read the file contents from path
                // TODO: Split the contents into lines
                // TODO: Print the number of lines
                //
                // Expected output: 3
                """,
            expectedOutput: "3",
            hints: [
                "Read the file into a String with Foundation.",
                "Split the contents on newline characters.",
            ],
            cheatsheet: cheatsheetInputOutput,
            lesson: lessonInputOutputBasics,
            solution: #"""
if let fileContents = try? String(contentsOfFile: path, encoding: .utf8) {
    let lines = fileContents.split(separator: "\n")
    print(lines.count)
} else {
    print("Missing file")
}
"""#,
            fixtureFiles: ["temperatures.txt"],
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowFileIO: true
            ),
            introduces: [.fileIO],
            topic: .general,

        ),
        Challenge(
            number: 80,
            title: "Basic Test",
            description: "Check a condition and report result",
            starterCode: """
                // Challenge 80: Basic Test
                // Write a basic test case.
                //
                // Steps:
                // 1) From repo root: swift workspace/challenge77.swift
                //
                // Expected output: Test passed

                // TODO: If 2 + 2 == 4, print "Test passed"
                """,
            expectedOutput: "Test passed",
            hints: [
                "A basic condition can gate a success message.",
            ],
            cheatsheet: cheatsheetConditionals,
            lesson: lessonConditionalsFlow,
            solution: #"""
if 2 + 2 == 4 {
    print("Test passed")
}
"""#,
            constraintProfile: core3BaselineProfile,
            topic: .general,

        ),
        Challenge(
            number: 81,
            title: "Integration Challenge",
            description: "Combine Core 3 concepts",
            starterCode: """
                // Challenge 81: Integration Challenge
                // Process forge logs with advanced tools.
                // Prereqs: map, compactMap, filter, reduce.

                let lines = ["1200", "x", "1500", "1600", "bad", "1400"]

                // TODO: Convert each line to an optional Int
                // TODO: Remove invalid values
                // TODO: Keep only temps >= 1500
                // TODO: Compute the total
                // TODO: Print the total
                """,
            expectedOutput: "3100",
            hints: [
                "Combine higher-order functions into a pipeline.",
                "Use Int($0), compactMap, filter, and reduce in stages.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            lesson: lessonCore3Integration,
            solution: """
let values = lines.map { Int($0) }
let temps = values.compactMap { $0 }
let hotTemps = temps.filter { $0 >= 1500 }
let total = hotTemps.reduce(0) { $0 + $1 }
print(total)
""",
            constraintProfile: core3BaselineProfile,
            requires: [.map, .compactMap, .filter, .reduce],
            topic: .general,

        ),
        Challenge(
            number: 82,
            id: "core-extra-safety-check",
            title: "Safety Check",
            description: "Combine conditions with &&",
            starterCode: """
                // Challenge 82: Safety Check
                // Use && to require two conditions.

                let heatLevel = 3
                let hasVentilation = true

                // TODO: If 'heatLevel' >= 3 AND 'hasVentilation', print "Safe"
                // Otherwise print "Unsafe"
                """,
            expectedOutput: "Safe",
            hints: [
                "Require both checks to pass before reporting success.",
                "Add a fallback message for the failing case.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
if heatLevel >= 3 && hasVentilation {
    print("Safe")
} else {
    print("Unsafe")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 83,
            id: "core-extra-heat-levels",
            title: "Heat Levels",
            description: "Use if/else if/else with ranges",
            starterCode: """
                // Challenge 83: Heat Levels
                // Categorize a value using if/else if/else.

                let heatLevel = 1

                // TODO: If 'heatLevel' == 0, print "Off"
                // TODO: Else if 'heatLevel' <= 2, print "Warm"
                // TODO: Else print "Hot"
                """,
            expectedOutput: "Warm",
            hints: [
                "Order checks from most specific to most general.",
                "Handle the exact-zero case before broader ranges.",
                "Use a final fallback for anything not matched.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
if heatLevel == 0 {
    print("Off")
} else if heatLevel <= 2 {
    print("Warm")
} else {
    print("Hot")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 84,
            id: "core-extra-count-multiples",
            title: "Count Multiples",
            description: "Count matches in a loop",
            starterCode: """
                // Challenge 84: Count Multiples
                // Count numbers divisible by 3.

                let numbers = [1, 2, 3, 4, 5, 6]
                var count = 0

                // TODO: Loop through 'numbers'
                // TODO: If a number is divisible by 3, increment 'count'
                // TODO: Print 'count'
                """,
            expectedOutput: "2",
            hints: [
                "Use the remainder to detect multiples of 3.",
                "Track how many values match the rule.",
                "Print the count after the loop.",
            ],
            cheatsheet: cheatsheetLoops,
            solution: """
for number in numbers {
    if number % 3 == 0 {
        count += 1
    }
}

print(count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 85,
            id: "core-extra-running-total",
            title: "Running Total",
            description: "Break when a total reaches a limit",
            starterCode: """
                // Challenge 85: Running Total
                // Add values until the total reaches a limit.

                let temps = [900, 1000, 1200, 1500]
                var total = 0

                // TODO: Loop through 'temps' and add to 'total'
                // TODO: If 'total' >= 2500, break
                // TODO: Print 'total'
                """,
            expectedOutput: "3100",
            hints: [
                "Maintain a running total as you iterate.",
                "Stop once the total reaches or exceeds the limit.",
                "Print the total after the loop ends.",
            ],
            cheatsheet: cheatsheetLoops,
            solution: """
for temp in temps {
    total += temp
    if total >= 2500 {
        break
    }
}

print(total)
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 86,
            id: "core-extra-optional-conversion",
            title: "Optional Conversion",
            description: "Convert a string to an Int safely",
            starterCode: """
                // Challenge 86: Optional Conversion
                // Use if let with Int().

                let input = "1500"

                // TODO: Convert 'input' to an Int using if let
                // TODO: Print "Temp: <value>"
                // TODO: Otherwise print "Invalid"
                """,
            expectedOutput: "Temp: 1500",
            hints: [
                "Converting from String to Int yields an optional.",
                "Unwrap the value before building the success message.",
                "Include a fallback message for the failure path.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
if let temp = Int(input) {
    print("Temp: \\(temp)")
} else {
    print("Invalid")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 87,
            id: "core-extra-guard-conversion",
            title: "Guard Conversion",
            description: "Use guard let for early exit",
            starterCode: """
                // Challenge 87: Guard Conversion
                // Use guard let to unwrap and convert.

                func readTemp(_ value: String?) {
                    // TODO: Use guard let to unwrap 'value' and convert to Int
                    // Print "Invalid" if conversion fails
                    // Otherwise print "Temp: <value>"
                }

                // TODO: Call 'readTemp' with "abc"
                """,
            expectedOutput: "Invalid",
            hints: [
                "guard let can unwrap and convert in one step.",
                "Exit early before reaching the success print.",
            ],
            cheatsheet: cheatsheetOptionals,
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
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 88,
            id: "core-extra-inventory-update",
            title: "Inventory Update",
            description: "Update a dictionary value",
            starterCode: """
                // Challenge 88: Inventory Update
                // Increment a dictionary value.

                var inventory = ["Iron": 1]

                // TODO: Increment the count for "Iron" by 1
                // TODO: Print the new count
                """,
            expectedOutput: "2",
            hints: [
                "Use a defaulted subscript like inventory[\"Iron\", default: 0] += 1.",
                "Print the value after updating it.",
            ],
            cheatsheet: cheatsheetDictionaries,
            solution: """
inventory["Iron", default: 0] += 1
print(inventory["Iron", default: 0])
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 89,
            id: "core-extra-remove-from-array",
            title: "Remove from Array",
            description: "Remove an element by index",
            starterCode: """
                // Challenge 89: Remove from Array
                // Remove one item and print the result.

                var metals = ["Iron", "Gold", "Copper"]

                // TODO: Remove "Gold"
                // TODO: Print 'metals'
                """,
            expectedOutput: #"["Iron", "Copper"]"#,
            hints: [
                "Remove by index rather than by value.",
                "Print the updated array afterward.",
            ],
            cheatsheet: cheatsheetArrays,
            solution: """
metals.remove(at: 1)
print(metals)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 90,
            id: "core-extra-boolean-return",
            title: "Boolean Return",
            description: "Return true or false from a function",
            starterCode: """
                // Challenge 90: Boolean Return
                // Return a Bool from a function.

                // TODO: Create a function that returns true when temp >= 1500
                // TODO: Call 'isOverheated' with 1600, then print
                """,
            expectedOutput: "true",
            hints: [
                "Signature example: isOverheated(temp: Int) -> Bool.",
                "Return the result of a comparison and print it.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func isOverheated(temp: Int) -> Bool {
    return temp >= 1500
}

print(isOverheated(temp: 1600))
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 91,
            id: "core-extra-helper-function",
            title: "Helper Function",
            description: "Call one function from another",
            starterCode: """
                // Challenge 91: Helper Function
                // Use a helper to build a message.

                // TODO: Create a helper that returns a label like "T<temp>"
                // TODO: Create a function that prints the helper’s label
                // TODO: Call 'printLabel' with 1200
                """,
            expectedOutput: "T1200",
            hints: [
                "Signature example: label(temp: Int) -> String.",
                "Signature example: printLabel(for temp: Int).",
                "Call the wrapper to trigger printing.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func label(temp: Int) -> String {
    return "T\\(temp)"
}

func printLabel(for temp: Int) {
    print(label(temp: temp))
}

printLabel(for: 1200)
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 92,
            id: "core-extra-fuel-warning",
            title: "Fuel Warning",
            description: "Branch on a Bool with if/else",
            starterCode: """
                // Challenge 92: Fuel Warning
                // Use if/else with a Bool.

                let hasFuel = false

                // TODO: If 'hasFuel' is true, print "Fuel ready"
                // TODO: Otherwise print "Refuel needed"
                """,
            expectedOutput: "Refuel needed",
            hints: [
                "Use a simple true/false branch to pick a message.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
if hasFuel {
    print("Fuel ready")
} else {
    print("Refuel needed")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 93,
            id: "core-extra-override-switch",
            title: "Override Switch",
            description: "Combine conditions with ||",
            starterCode: """
                // Challenge 93: Override Switch
                // Use || to allow either condition.

                let hasFuel = false
                let emergencyOverride = true

                // TODO: If 'hasFuel' OR 'emergencyOverride', print "Ignite"
                // TODO: Otherwise print "Hold"
                """,
            expectedOutput: "Ignite",
            hints: [
                "Allow either condition to trigger the success path.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
if hasFuel || emergencyOverride {
    print("Ignite")
} else {
    print("Hold")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 94,
            id: "core-extra-negation-drill",
            title: "Negation Drill",
            description: "Use ! to invert a Bool",
            starterCode: """
                // Challenge 94: Negation Drill
                // Use ! to flip a Bool condition.

                let isCooling = false

                // TODO: If NOT 'isCooling', print "Heating"
                // TODO: Otherwise print "Cooling"
                """,
            expectedOutput: "Heating",
            hints: [
                "Invert the Bool to test the opposite case.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
if !isCooling {
    print("Heating")
} else {
    print("Cooling")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 95,
            id: "core-extra-ternary-warm-up",
            title: "Ternary Warm-up",
            description: "Use the ternary operator",
            starterCode: """
                // Challenge 95: Ternary Warm-up
                // Use ?: to choose a value.

                let heatLevel = 2

                // TODO: Use a ternary to set 'status' to "Hot" when 'heatLevel' >= 3, else "Warm"
                // TODO: Print 'status'
                """,
            expectedOutput: "Warm",
            hints: [
                "A ternary chooses between two values based on a condition.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
let status = heatLevel >= 3 ? "Hot" : "Warm"
print(status)
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 96,
            id: "core-extra-heat-steps",
            title: "Heat Steps",
            description: "Loop over a range with for-in",
            starterCode: """
                // Challenge 96: Heat Steps
                // Use a for-in loop over a range.

                let steps = 3

                // TODO: Loop from 1 to 'steps' inclusive
                // TODO: Print "Step <n>" each time
                """,
            expectedOutput: "Step 1\nStep 2\nStep 3",
            hints: [
                "Use a closed range to include the final step.",
                "Insert the loop value into the output text.",
            ],
            cheatsheet: cheatsheetLoops,
            solution: """
for step in 1...steps {
    print("Step \\(step)")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 97,
            id: "core-extra-cooldown-countdown",
            title: "Cooldown Countdown",
            description: "Use a while loop to count down",
            starterCode: """
                // Challenge 97: Cooldown Countdown
                // Use a while loop to count down.

                var level = 3

                // TODO: While 'level' is greater than 0, print 'level' and subtract 1
                """,
            expectedOutput: "3\n2\n1",
            hints: [
                "Update the loop variable so the loop can end.",
            ],
            cheatsheet: cheatsheetLoops,
            solution: """
while level > 0 {
    print(level)
    level -= 1
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 98,
            id: "core-extra-repeat-ignite",
            title: "Repeat Ignite",
            description: "Use repeat-while for at least one run",
            starterCode: """
                // Challenge 98: Repeat Ignite
                // Use repeat-while to run at least once.

                var attempts = 0

                // TODO: Use repeat-while to print "Attempt <n>" twice
                """,
            expectedOutput: "Attempt 1\nAttempt 2",
            hints: [
                "repeat-while runs before checking the condition.",
                "Stop after two prints by checking the counter.",
            ],
            cheatsheet: cheatsheetLoops,
            solution: """
repeat {
    attempts += 1
    print("Attempt \\(attempts)")
} while attempts < 2
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 99,
            id: "core-extra-skip-weak-ore",
            title: "Skip Weak Ore",
            description: "Use continue and break",
            starterCode: """
                // Challenge 99: Skip Weak Ore
                // Use continue and break.

                let strengths = [1, 2, 0, 3]
                var processed = 0

                // TODO: Loop through 'strengths'
                // TODO: Skip values that are 0
                // TODO: Count 'processed' values
                // TODO: Stop after processing 2 values
                // TODO: Print 'processed'
                """,
            expectedOutput: "2",
            hints: [
                "Skip unwanted values before incrementing the count.",
                "Stop once you have processed the required number.",
            ],
            cheatsheet: cheatsheetLoops,
            solution: """
for strength in strengths {
    if strength == 0 {
        continue
    }
    processed += 1
    if processed == 2 {
        break
    }
}

print(processed)
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 100,
            id: "core-extra-stock-count",
            title: "Stock Count",
            description: "Append to an array and count it",
            starterCode: """
                // Challenge 100: Stock Count
                // Use append and count.

                var metals = ["Iron"]

                // TODO: Append "Gold" to 'metals'
                // TODO: Print how many metals are in the list
                """,
            expectedOutput: "2",
            hints: [
                "Add one element to the array before printing.",
                "Use metals.count to get the number of elements.",
            ],
            cheatsheet: cheatsheetArrays,
            solution: """
metals.append("Gold")
print(metals.count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 101,
            id: "core-extra-first-ore",
            title: "First Ore",
            description: "Use first with a default value",
            starterCode: """
                // Challenge 101: First Ore
                // Access the first element safely.

                let metals = ["Iron", "Gold"]

                // TODO: Set 'firstMetal' to the first metal, using "None" as a default
                // TODO: Print 'firstMetal'
                """,
            expectedOutput: "Iron",
            hints: [
                "first yields an optional; use metals.first ?? \"None\".",
            ],
            cheatsheet: cheatsheetArrays,
            solution: """
let firstMetal = metals.first ?? "None"
print(firstMetal)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 102,
            id: "core-extra-unique-ingots",
            title: "Unique Ingots",
            description: "Insert and check a set",
            starterCode: """
                // Challenge 102: Unique Ingots
                // Use a set to track unique values.

                var ingots: Set<String> = ["Iron"]

                // TODO: Insert "Iron" and "Gold" into 'ingots'
                // TODO: Print whether the set contains "Gold"
                """,
            expectedOutput: "true",
            hints: [
                "Inserting a duplicate does not change a set.",
                "Check membership with contains before printing.",
            ],
            cheatsheet: cheatsheetSets,
            solution: """
ingots.insert("Iron")
ingots.insert("Gold")
print(ingots.contains("Gold"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 103,
            id: "core-extra-fuel-ledger",
            title: "Fuel Ledger",
            description: "Update dictionary values and count keys",
            starterCode: """
                // Challenge 103: Fuel Ledger
                // Update values in a dictionary.

                var fuel = ["Coal": 2]

                // TODO: Increase 'Coal' by 1 using a default value
                // TODO: Add "Charcoal" with a value of 0
                // TODO: Print the number of keys in fuel
                """,
            expectedOutput: "2",
            hints: [
                "Use a defaulted subscript to increment safely.",
                "Add a new key with its starting value.",
                "Use fuel.keys.count to count keys after updates.",
            ],
            cheatsheet: cheatsheetDictionaries,
            solution: """
fuel["Coal", default: 0] += 1
fuel["Charcoal"] = 0
print(fuel.keys.count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 104,
            id: "core-extra-iterate-ores",
            title: "Iterate Ores",
            description: "Build labels while iterating an array",
            starterCode: """
                // Challenge 104: Iterate Ores
                // Build a new array while iterating.

                let ores = ["Iron", "Gold"]
                var labels: [String] = []

                // TODO: Loop through 'ores' and append "Ore: <name>" to 'labels'
                // TODO: Print 'labels'
                """,
            expectedOutput: #"["Ore: Iron", "Ore: Gold"]"#,
            hints: [
                "Build each label while iterating the array.",
                "Use interpolation to format each label.",
            ],
            cheatsheet: cheatsheetArrays,
            solution: """
for ore in ores {
    labels.append("Ore: \\(ore)")
}

print(labels)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 105,
            id: "core-extra-iterate-ledger",
            title: "Iterate Ledger",
            description: "Sum dictionary values",
            starterCode: """
                // Challenge 105: Iterate Ledger
                // Sum values in a dictionary.

                let ledger = ["Iron": 2, "Gold": 1]
                var total = 0

                // TODO: Loop through 'ledger' and add each count to 'total'
                // TODO: Print 'total'
                """,
            expectedOutput: "3",
            hints: [
                "Dictionary iteration gives key/value pairs.",
                "Add the values into a running total before printing.",
            ],
            cheatsheet: cheatsheetDictionaries,
            solution: """
for (_, count) in ledger {
    total += count
}

print(total)
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 106,
            id: "core-extra-announce-heat",
            title: "Announce Heat",
            description: "Define a function with one parameter",
            starterCode: """
                // Challenge 106: Announce Heat
                // Define a function with one parameter.

                // TODO: Create a function 'announceHeat' that takes an Int 'level'
                // TODO: Inside, print "Heat: <level>"
                // TODO: Call 'announceHeat' with 1500
                """,
            expectedOutput: "Heat: 1500",
            hints: [
                "Define a function that accepts one Int parameter.",
                "Print the value inside the function using interpolation.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func announceHeat(level: Int) {
    print("Heat: \\(level)")
}

announceHeat(level: 1500)
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 107,
            id: "core-extra-combine-alloy",
            title: "Combine Alloy",
            description: "Define a function with two parameters",
            starterCode: """
                // Challenge 107: Combine Alloy
                // Define a function with two parameters.

                // TODO: Create a function 'combine' that takes metal and additive
                // TODO: Print "<metal> + <additive>"
                // TODO: Call 'combine' with "Iron" and "Carbon"
                """,
            expectedOutput: "Iron + Carbon",
            hints: [
                "Use two String parameters in a single print line.",
                "Signature example: combine(metal: String, additive: String).",
                "Call the function with two arguments.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func combine(metal: String, additive: String) {
    print("\\(metal) + \\(additive)")
}

combine(metal: "Iron", additive: "Carbon")
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 108,
            id: "core-extra-return-weight",
            title: "Return Weight",
            description: "Return a value from a function",
            starterCode: """
                // Challenge 108: Return Weight
                // Return an Int from a function.

                // TODO: Create a function 'totalWeight' that returns 'ingots' * 'weightPerIngot'
                // TODO: Call 'totalWeight' with 3 and 5, then print
                """,
            expectedOutput: "15",
            hints: [
                "Return the computed value from the function.",
                "Print the result of calling the function.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func totalWeight(ingots: Int, weightPerIngot: Int) -> Int {
    return ingots * weightPerIngot
}

print(totalWeight(ingots: 3, weightPerIngot: 5))
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 109,
            id: "core-extra-label-maker",
            title: "Label Maker",
            description: "Use a function that returns a String",
            starterCode: """
                // Challenge 109: Label Maker
                // Return a String from a function.

                // TODO: Create a function 'makeLabel' that returns "Batch-<id>"
                // TODO: Print the label for id 7
                """,
            expectedOutput: "Batch-7",
            hints: [
                "Return a string built with interpolation.",
                "Call makeLabel(id: 7) and print the result.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func makeLabel(id: Int) -> String {
    return "Batch-\\(id)"
}

print(makeLabel(id: 7))
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 110,
            id: "core-extra-coalesce-default",
            title: "Coalesce Default",
            description: "Use ?? with an optional",
            starterCode: """
                // Challenge 110: Coalesce Default
                // Provide a default with ??.

                let reading: Int? = nil

                // TODO: Use ?? to set 'value' to 1200 if 'reading' is nil
                // TODO: Print 'value'
                """,
            expectedOutput: "1200",
            hints: [
                "Nil coalescing uses a fallback when the optional is nil.",
                "Print the resulting value.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
let value = reading ?? 1200
print(value)
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 111,
            id: "core-extra-optional-bool-check",
            title: "Optional Bool Check",
            description: "Unwrap an optional Bool",
            starterCode: """
                // Challenge 111: Optional Bool Check
                // Use if let with an optional Bool.

                let isReady: Bool? = nil

                // TODO: If 'isReady' has a value, print "Ready: <value>"
                // TODO: Otherwise print "Unknown"
                """,
            expectedOutput: "Unknown",
            hints: [
                "Use if let to unwrap the optional Bool.",
                "Provide an else path for the nil case.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
if let ready = isReady {
    print("Ready: \\(ready)")
} else {
    print("Unknown")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 112,
            id: "core-extra-string-count",
            title: "String Count",
            description: "Use count on a String",
            starterCode: """
                // Challenge 112: String Count
                // Use count on a String.

                let alloyName = "Iron"

                // TODO: Print the length of alloyName
                """,
            expectedOutput: "4",
            hints: [
                "Use alloyName.count to get the length.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
print(alloyName.count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 113,
            id: "core-extra-string-contains",
            title: "String Contains",
            description: "Check if a String contains text",
            starterCode: """
                // Challenge 113: String Contains
                // Use contains to search.

                let label = "Gold Ingot"

                // TODO: Print whether 'label' contains "Gold"
                """,
            expectedOutput: "true",
            hints: [
                "contains returns true or false based on a match.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
print(label.contains("Gold"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 114,
            id: "core-extra-case-shift",
            title: "Case Shift",
            description: "Uppercase a String",
            starterCode: """
                // Challenge 114: Case Shift
                // Use uppercased().

                let code = "Forge"

                // TODO: Print the uppercase version of code
                """,
            expectedOutput: "FORGE",
            hints: [
                "Use code.uppercased() to get the uppercase string.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
print(code.uppercased())
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 115,
            id: "core-extra-prefix-check",
            title: "Prefix Check",
            description: "Check a String prefix",
            starterCode: """
                // Challenge 115: Prefix Check
                // Use hasPrefix.

                let line = "TEMP 1500"

                // TODO: Print whether 'line' has prefix "TEMP"
                """,
            expectedOutput: "true",
            hints: [
                "hasPrefix returns true when the text starts with a prefix.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
print(line.hasPrefix("TEMP"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 116,
            id: "core-extra-suffix-check",
            title: "Suffix Check",
            description: "Check a String suffix",
            starterCode: """
                // Challenge 116: Suffix Check
                // Use hasSuffix.

                let line = "ALLOY-IRON"

                // TODO: Print whether 'line' has suffix "IRON"
                """,
            expectedOutput: "true",
            hints: [
                "hasSuffix returns true when the text ends with a suffix.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
print(line.hasSuffix("IRON"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 117,
            id: "core-extra-split-words",
            title: "Split Words",
            description: "Split a String and count parts",
            starterCode: """
                // Challenge 117: Split Words
                // Split a String into parts.

                let report = "TEMP 1500"

                // TODO: Print the number of words in report
                """,
            expectedOutput: "2",
            hints: [
                "Use report.split(separator: \" \") to break the string.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
let parts = report.split(separator: " ")
print(parts.count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 118,
            id: "core-extra-heat-comparison",
            title: "Heat Comparison",
            description: "Use a comparison operator",
            starterCode: """
                // Challenge 118: Heat Comparison
                // Compare numeric values.

                let heatLevel = 1600

                // TODO: Print whether 'heatLevel' >= 1500
                """,
            expectedOutput: "true",
            hints: [
                "Comparisons evaluate to true or false.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
print(heatLevel >= 1500)
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 119,
            id: "core-extra-not-equal-check",
            title: "Not Equal Check",
            description: "Compare two Strings",
            starterCode: """
                // Challenge 119: Not Equal Check
                // Use != with Strings.

                let a = "Iron"
                let b = "Gold"

                // TODO: Print whether 'a' != 'b'
                """,
            expectedOutput: "true",
            hints: [
                "Strings can be compared for equality or inequality.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
print(a != b)
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 120,
            id: "core-extra-lower-than",
            title: "Lower Than",
            description: "Use < with Ints",
            starterCode: """
                // Challenge 120: Lower Than
                // Use < with Ints.

                let temp = 1400

                // TODO: Print whether 'temp' < 1500
                """,
            expectedOutput: "true",
            hints: [
                "The < operator checks whether one value is lower than another.",
            ],
            cheatsheet: cheatsheetConditionals,
            solution: """
print(temp < 1500)
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 121,
            id: "core-extra-open-range-loop",
            title: "Open Range Loop",
            description: "Loop with 1..<n",
            starterCode: """
                // Challenge 121: Open Range Loop
                // Use an open range with for-in.

                let end = 3

                // TODO: Loop from 1 up to (but not including) 'end'
                // TODO: Print each number
                """,
            expectedOutput: "1\n2",
            hints: [
                "Use 1..<end for an open range.",
            ],
            cheatsheet: cheatsheetRanges,
            solution: """
for value in 1..<end {
    print(value)
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 122,
            id: "core-extra-closed-range-sum",
            title: "Closed Range Sum",
            description: "Sum values in 1...n",
            starterCode: """
                // Challenge 122: Closed Range Sum
                // Sum a closed range.

                let end = 3
                var total = 0

                // TODO: Loop from 1 through 'end' and add to 'total'
                // TODO: Print 'total'
                """,
            expectedOutput: "6",
            hints: [
                "A closed range includes the upper bound.",
            ],
            cheatsheet: cheatsheetRanges,
            solution: """
for value in 1...end {
    total += value
}

print(total)
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 123,
            id: "core-extra-index-range",
            title: "Index Range",
            description: "Use 0..<count with an array",
            starterCode: """
                // Challenge 123: Index Range
                // Loop with array indices.

                let metals = ["Iron", "Gold", "Copper"]

                // TODO: Loop over indices of the metals array
                // TODO: Print each metal
                """,
            expectedOutput: "Iron\nGold\nCopper",
            hints: [
                "Use 0..<metals.count to cover valid indices.",
                "Access elements by index inside the loop.",
            ],
            cheatsheet: cheatsheetRanges,
            solution: """
for index in 0..<metals.count {
print(metals[index])
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .loops,
            tier: .extra
        ),
        Challenge(
            number: 245,
            id: "core-extra-number-conversion",
            title: "Number Conversion",
            description: "Compare integer and floating division",
            starterCode: """
                // Challenge 245: Number Conversion
                // Compare integer and floating division.

                let a = 7
                let b = 2

                // TODO: Print a / b
                // TODO: Convert to Double and print the fractional result
                """,
            expectedOutput: "3\n3.5",
            hints: [
                "Int division truncates the remainder.",
                "Convert to Double before dividing to keep the fraction.",
            ],
            cheatsheet: cheatsheetMathOperators,
            solution: """
print(a / b)
print(Double(a) / Double(b))
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 246,
            id: "core-extra-string-to-int",
            title: "String to Int",
            description: "Convert a numeric string safely",
            starterCode: """
                // Challenge 246: String to Int
                // Convert a numeric string safely.

                let text = "1500"

                // TODO: Convert text to an Int with if let
                // TODO: Print "Temp: 1500"
                """,
            expectedOutput: "Temp: 1500",
            hints: [
                "Int(text) returns an optional.",
                "Unwrap before printing the success message.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
if let value = Int(text) {
    print("Temp: \\(value)")
}
""",
            constraintProfile: core3BaselineProfile,
            requires: [.optionalBinding],
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 247,
            id: "core-extra-dictionary-default-update",
            title: "Dictionary Default Update",
            description: "Update counts with default values",
            starterCode: """
                // Challenge 247: Dictionary Default Update
                // Update counts with default values.

                var inventory = ["Iron": 2]

                // TODO: Add 1 to "Iron" using default:
                // TODO: Add 1 to "Gold" using default:
                // TODO: Print "Iron: 3" then "Gold: 1"
                """,
            expectedOutput: "Iron: 3\nGold: 1",
            hints: [
                "Use a defaulted subscript to update both counts.",
                "Print each count on its own line.",
            ],
            cheatsheet: cheatsheetDictionaries,
            solution: """
inventory["Iron", default: 0] += 1
inventory["Gold", default: 0] += 1
print("Iron: \\(inventory["Iron", default: 0])")
print("Gold: \\(inventory["Gold", default: 0])")
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 248,
            id: "core-extra-set-operations",
            title: "Set Operations",
            description: "Combine and intersect sets",
            starterCode: """
                // Challenge 248: Set Operations
                // Combine and intersect sets.

                let a: Set<Int> = [1, 2, 3]
                let b: Set<Int> = [3, 4]

                // TODO: Print the union of a and b (sorted)
                // TODO: Print the intersection of a and b (sorted)
                """,
            expectedOutput: "[1, 2, 3, 4]\n[3]",
            hints: [
                "Use union and intersection, then call sorted().",
                "union combines unique values; intersection keeps shared values.",
            ],
            cheatsheet: cheatsheetSets,
            solution: """
print(a.union(b).sorted())
print(a.intersection(b).sorted())
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 249,
            id: "core-extra-sorting-basics",
            title: "Sorting Basics",
            description: "Sort values ascending and descending",
            starterCode: """
                // Challenge 249: Sorting Basics
                // Sort values ascending and descending.

                let temps = [1500, 1200, 1600]

                // TODO: Print temps in ascending order
                // TODO: Print temps in descending order
                """,
            expectedOutput: "[1200, 1500, 1600]\n[1600, 1500, 1200]",
            hints: [
                "Use sorted() for ascending order.",
                "Use reversed() and wrap in Array for descending order.",
            ],
            cheatsheet: cheatsheetCollectionsBasics,
            solution: """
print(temps.sorted())
print(Array(temps.sorted().reversed()))
""",
            constraintProfile: core3BaselineProfile,
            topic: .collections,
            tier: .extra
        ),
        Challenge(
            number: 254,
            id: "core-extra-boolean-flags",
            title: "Boolean Flags",
            description: "Combine comparisons with &&",
            starterCode: """
                // Challenge 254: Boolean Flags
                // Combine a Bool with a comparison.

                let temperature = 1500
                let minTemp = 1400
                let isIron = true

                // TODO: Create a constant 'ready' that is true only when
                // isIron is true AND temperature >= minTemp
                // TODO: Print ready
                """,
            expectedOutput: "true",
            hints: [
                "Put the readiness rule in a single expression.",
                "Assign the expression to a constant, then print it.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
let ready = isIron && temperature >= minTemp
print(ready)
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 255,
            id: "core-extra-grouped-logic",
            title: "Grouped Logic",
            description: "Use parentheses to group conditions",
            starterCode: """
                // Challenge 255: Grouped Logic
                // Group conditions with parentheses.

                let isIron = true
                let isHot = false
                let overrideOn = true

                // TODO: Create a constant 'canForge' that is true when
                // (isIron AND isHot) OR overrideOn is true
                // TODO: Print canForge
                """,
            expectedOutput: "true",
            hints: [
                "Group the strongest condition first, then add the fallback.",
                "Parentheses can clarify how the pieces should combine.",
            ],
            cheatsheet: cheatsheetBooleans,
            lesson: lessonBooleans,
            solution: """
let canForge = (isIron && isHot) || overrideOn
print(canForge)
""",
            constraintProfile: core3BaselineProfile,
            topic: .conditionals,
            tier: .extra
        ),
        Challenge(
            number: 256,
            id: "core-extra-optional-label",
            title: "Optional Label",
            description: "Provide a default label for a missing value",
            starterCode: """
                // Challenge 256: Optional Label
                // Provide a default when the optional is nil.

                let batchLabel: String? = nil

                // TODO: Use ?? to set 'label' to "Unknown" when batchLabel is nil
                // TODO: Print label
                """,
            expectedOutput: "Unknown",
            hints: [
                "Nil coalescing provides a fallback value.",
                "Store the result in a constant before printing.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
let label = batchLabel ?? "Unknown"
print(label)
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 257,
            id: "core-extra-optional-count",
            title: "Optional Count",
            description: "Use optional chaining with a default",
            starterCode: """
                // Challenge 257: Optional Count
                // Use optional chaining with a default.

                let temps: [Int]? = [1200, 1400]

                // TODO: Use optional chaining to read temps?.count
                // TODO: Use ?? to default to 0
                // TODO: Print the count
                """,
            expectedOutput: "2",
            hints: [
                "temps?.count returns an optional Int.",
                "Use ?? to provide a fallback value.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
let count = temps?.count ?? 0
print(count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 258,
            id: "core-extra-optional-dictionary-read",
            title: "Optional Dictionary Read",
            description: "Unwrap a dictionary lookup",
            starterCode: """
                // Challenge 258: Optional Dictionary Read
                // Unwrap a dictionary lookup with if let.

                let scores = ["Iron": 3, "Gold": 1]

                // TODO: Use if let to read the score for "Iron"
                // TODO: Print "Score: <value>" or "Missing"
                """,
            expectedOutput: "Score: 3",
            hints: [
                "Dictionary lookups return optionals.",
                "Use if let to unwrap the value before printing.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
if let score = scores["Iron"] {
    print("Score: \\(score)")
} else {
    print("Missing")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 259,
            id: "core-extra-optional-two-step",
            title: "Optional Two-Step",
            description: "Unwrap an optional and convert it",
            starterCode: """
                // Challenge 259: Optional Two-Step
                // Unwrap an optional string, then convert.

                let text: String? = "1500"

                // TODO: Use if let to unwrap text and convert to Int
                // TODO: Print the Int value or "Invalid"
                """,
            expectedOutput: "1500",
            hints: [
                "You can unwrap and convert in the same if let.",
                "Provide a fallback path for invalid values.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
if let text = text, let value = Int(text) {
    print(value)
} else {
    print("Invalid")
}
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 260,
            id: "core-extra-optional-bool-default",
            title: "Optional Bool Default",
            description: "Default a missing Bool to false",
            starterCode: """
                // Challenge 260: Optional Bool Default
                // Default an optional Bool to false.

                let isReady: Bool? = nil

                // TODO: Use ?? to set 'ready' to false when isReady is nil
                // TODO: Print ready
                """,
            expectedOutput: "false",
            hints: [
                "Use nil coalescing with a Bool.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
let ready = isReady ?? false
print(ready)
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 261,
            id: "core-extra-optional-guard-name",
            title: "Optional Guard Name",
            description: "Use guard let with a parameter",
            starterCode: """
                // Challenge 261: Optional Guard Name
                // Use guard let for an early exit.

                func announce(name: String?) {
                    // TODO: Use guard let to unwrap name
                    // Print "Missing" and return if nil
                    // Otherwise print "Name: <value>"
                }

                // TODO: Call announce with nil
                """,
            expectedOutput: "Missing",
            hints: [
                "guard let unwraps and exits early when nil.",
                "Return before the success print.",
            ],
            cheatsheet: cheatsheetOptionals,
            solution: """
func announce(name: String?) {
    guard let name = name else {
        print("Missing")
        return
    }
    print("Name: \\(name)")
}

announce(name: nil)
""",
            constraintProfile: core3BaselineProfile,
            topic: .optionals,
            tier: .extra
        ),
        Challenge(
            number: 262,
            id: "core-extra-heat-summary",
            title: "Heat Summary",
            description: "Combine variables, math, and strings",
            starterCode: """
                // Challenge 262: Heat Summary
                // Combine variables, math, and string interpolation.

                let baseHeat = 1200
                let boost = 200

                // TODO: Create totalHeat by adding baseHeat and boost
                // TODO: Print "Heat: <totalHeat>"
                """,
            expectedOutput: "Heat: 1400",
            hints: [
                "Store the computed total in a constant before printing.",
                "Use interpolation to include the value in the output.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            solution: """
let totalHeat = baseHeat + boost
print("Heat: \\(totalHeat)")
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 263,
            id: "core-extra-average-temp",
            title: "Average Temp",
            description: "Compute a Double average",
            starterCode: """
                // Challenge 263: Average Temp
                // Compute a Double average.

                let low = 1200
                let high = 1600

                // TODO: Compute the average as a Double
                // TODO: Print the average
                """,
            expectedOutput: "1400.0",
            hints: [
                "Convert to Double before dividing to keep the fraction.",
                "Average is (low + high) / 2.",
            ],
            cheatsheet: cheatsheetMathOperators,
            solution: """
let average = (Double(low) + Double(high)) / 2
print(average)
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 264,
            id: "core-extra-batch-tag",
            title: "Batch Tag",
            description: "Build a string from a number",
            starterCode: """
                // Challenge 264: Batch Tag
                // Build a string from a number.

                let batchId = 7

                // TODO: Create tag as "Batch-<id>"
                // TODO: Print tag
                """,
            expectedOutput: "Batch-7",
            hints: [
                "Use interpolation to build the tag string.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
let tag = "Batch-\\(batchId)"
print(tag)
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 265,
            id: "core-extra-heat-step-report",
            title: "Heat Step Report",
            description: "Combine math with a simple label",
            starterCode: """
                // Challenge 265: Heat Step Report
                // Combine math and a simple label.

                let step = 3

                // TODO: Compute totalHeat as step * 200
                // TODO: Print "Step <step>: <totalHeat>"
                """,
            expectedOutput: "Step 3: 600",
            hints: [
                "Compute the value before formatting the string.",
                "Use interpolation for both values.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            solution: """
let totalHeat = step * 200
print("Step \\(step): \\(totalHeat)")
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 266,
            id: "core-extra-double-heat",
            title: "Double Heat",
            description: "Return a computed value from a function",
            starterCode: """
                // Challenge 266: Double Heat
                // Return a computed value from a function.

                // TODO: Create a function 'doubleHeat' that returns value * 2
                // TODO: Call doubleHeat with 700 and print the result
                """,
            expectedOutput: "1400",
            hints: [
                "Define a function with a return type.",
                "Call the function and print the returned value.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func doubleHeat(value: Int) -> Int {
    return value * 2
}

print(doubleHeat(value: 700))
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 267,
            id: "core-extra-parameter-labels",
            title: "Parameter Labels",
            description: "Use an external label in a function",
            starterCode: """
                // Challenge 267: Parameter Labels
                // Use an external label for readability.

                // TODO: Create a function 'heat' that takes an Int with external label 'to'
                // TODO: Inside, print "Heating to <value>"
                // TODO: Call heat(to: 1500)
                """,
            expectedOutput: "Heating to 1500",
            hints: [
                "Function example: heat(to value: Int).",
                "Use interpolation inside the print.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func heat(to value: Int) {
    print("Heating to \\(value)")
}

heat(to: 1500)
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 268,
            id: "core-extra-return-string",
            title: "Return String",
            description: "Build and return a String",
            starterCode: """
                // Challenge 268: Return String
                // Return a formatted String from a function.

                // TODO: Create a function 'status' that returns "Heat: <value>"
                // TODO: Print status(1200)
                """,
            expectedOutput: "Heat: 1200",
            hints: [
                "Return a String built with interpolation.",
                "Call the function inside print.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func status(_ value: Int) -> String {
    return "Heat: \\(value)"
}

print(status(1200))
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 269,
            id: "core-extra-parameter-default",
            title: "Parameter Default",
            description: "Use a default parameter value",
            starterCode: """
                // Challenge 269: Parameter Default
                // Use a default parameter value.

                // TODO: Create a function 'forge' with a default material of "Iron"
                // TODO: Print "Forge <material>"
                // TODO: Call forge() with no arguments
                """,
            expectedOutput: "Forge Iron",
            hints: [
                "Provide a default value in the parameter list.",
                "Call the function without passing a value.",
            ],
            cheatsheet: cheatsheetFunctionsBasics,
            solution: """
func forge(material: String = "Iron") {
    print("Forge \\(material)")
}

forge()
""",
            constraintProfile: core3BaselineProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 270,
            id: "core-extra-string-join",
            title: "String Join",
            description: "Join words with a separator",
            starterCode: """
                // Challenge 270: String Join
                // Join words with a separator.

                let parts = ["Forge", "Ready"]

                // TODO: Join parts with "-" and print the result
                """,
            expectedOutput: "Forge-Ready",
            hints: [
                "Use joined(separator:).",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
print(parts.joined(separator: "-"))
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 271,
            id: "core-extra-string-trim",
            title: "Trim Spaces",
            description: "Trim leading and trailing spaces",
            starterCode: """
                // Challenge 271: Trim Spaces
                // Trim whitespace from a String.

                import Foundation

                let raw = "  Iron  "

                // TODO: Trim whitespace and print the result
                """,
            expectedOutput: "Iron",
            hints: [
                "Use trimmingCharacters(in: .whitespacesAndNewlines).",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
print(trimmed)
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 272,
            id: "core-extra-string-replace",
            title: "Replace Text",
            description: "Replace part of a String",
            starterCode: """
                // Challenge 272: Replace Text
                // Replace a substring with another.

                let label = "Heat: 1500"

                // TODO: Replace "1500" with "1600" and print
                """,
            expectedOutput: "Heat: 1600",
            hints: [
                "Use replacingOccurrences(of:with:).",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
let updated = label.replacingOccurrences(of: "1500", with: "1600")
print(updated)
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 273,
            id: "core-extra-string-lines",
            title: "String Lines",
            description: "Split a string into lines",
            starterCode: """
                // Challenge 273: String Lines
                // Split a string into lines.

                let report = "Iron\\nGold\\nCopper"

                // TODO: Split report into lines and print the count
                """,
            expectedOutput: "3",
            hints: [
                "Split on the newline character.",
            ],
            cheatsheet: cheatsheetStrings,
            solution: """
let lines = report.split(separator: \"\\n\")
print(lines.count)
""",
            constraintProfile: core3BaselineProfile,
            topic: .strings,
            tier: .extra
        ),
        Challenge(
            number: 274,
            id: "core-extra-closure-label",
            title: "Closure Label",
            description: "Store and call a simple closure",
            starterCode: """
                // Challenge 274: Closure Label
                // Store and call a simple closure.

                // TODO: Create a closure called 'label' that prints "Forge"
                // TODO: Call the closure
                """,
            expectedOutput: "Forge",
            hints: [
                "Closures can be assigned to constants.",
                "Call the closure like a function.",
            ],
            cheatsheet: cheatsheetClosures,
            solution: """
let label = {
    print("Forge")
}

label()
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 275,
            id: "core-extra-closure-multiply",
            title: "Closure Multiply",
            description: "Use a closure that takes a parameter",
            starterCode: """
                // Challenge 275: Closure Multiply
                // Use a closure with a parameter.

                // TODO: Create a closure called 'tripleHeat' that takes an Int
                // and returns the value multiplied by 3
                // TODO: Print tripleHeat(500)
                """,
            expectedOutput: "1500",
            hints: [
                "Closures can take parameters and return values.",
                "Call the closure like a function to get the result.",
            ],
            cheatsheet: cheatsheetClosures,
            solution: """
let tripleHeat = { (value: Int) -> Int in
    return value * 3
}

print(tripleHeat(500))
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 276,
            id: "core-extra-closure-trailing",
            title: "Closure Trailing",
            description: "Use trailing closure syntax",
            starterCode: """
                // Challenge 276: Closure Trailing
                // Use trailing closure syntax.

                func transform(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call transform with 4 using trailing closure syntax
                // Multiply the value by 5
                """,
            expectedOutput: "20",
            hints: [
                "Move the closure outside the parentheses.",
                "Keep the multiplication inside the closure.",
            ],
            cheatsheet: cheatsheetClosures,
            solution: """
transform(4) { value in
    return value * 5
}
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 277,
            id: "core-extra-closure-shorthand",
            title: "Closure Shorthand",
            description: "Use $0 in a trailing closure",
            starterCode: """
                // Challenge 277: Closure Shorthand
                // Use $0 in a trailing closure.

                func apply(_ value: Int, using closure: (Int) -> Int) {
                    print(closure(value))
                }

                // TODO: Call apply with 8 and use $0 to add 2
                """,
            expectedOutput: "10",
            hints: [
                "Use $0 to represent the input value.",
            ],
            cheatsheet: cheatsheetClosures,
            solution: """
apply(8) { $0 + 2 }
""",
            constraintProfile: core3ClosureProfile,
            introduces: [.shorthandClosureArgs],
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 278,
            id: "core-extra-closure-capture",
            title: "Closure Capture",
            description: "Capture and update a value",
            starterCode: """
                // Challenge 278: Closure Capture
                // Capture and update a value.

                func makeCounter() -> () -> Void {
                    var count = 0
                    return {
                        // TODO: Increment count and print it
                    }
                }

                // TODO: Create a counter and call it twice
                """,
            expectedOutput: "1\n2",
            hints: [
                "Closures can capture and mutate variables from the outer scope.",
                "Each call should increase the stored count.",
            ],
            cheatsheet: cheatsheetClosures,
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
""",
            constraintProfile: core3ClosureProfile,
            topic: .functions,
            tier: .extra
        ),
        Challenge(
            number: 303,
            id: "core-extra-shift-status",
            title: "Shift Status",
            description: "Combine math with a labeled report",
            starterCode: """
                // Challenge 303: Shift Status
                // Combine math with a labeled report.

                let shift = 2
                let baseHeat = 1200
                let boost = 150

                // TODO: Compute totalHeat as baseHeat + boost
                // TODO: Print "Shift 2: 1350"
                """,
            expectedOutput: "Shift 2: 1350",
            hints: [
                "Compute the total before formatting the string.",
                "Use interpolation to include both values.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            solution: """
let totalHeat = baseHeat + boost
print("Shift \\(shift): \\(totalHeat)")
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 304,
            id: "core-extra-calibration-report",
            title: "Calibration Report",
            description: "Return a calculated value from a function",
            starterCode: """
                // Challenge 304: Calibration Report
                // Return a calculated value from a function.

                // TODO: Create a function 'calibrate' that returns base + offset
                // TODO: Call calibrate with 1200 and 80
                // TODO: Print "Calibrated: 1280"
                """,
            expectedOutput: "Calibrated: 1280",
            hints: [
                "Functions that return values use -> Int.",
                "Store the returned value before printing.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            solution: """
func calibrate(base: Int, offset: Int) -> Int {
    return base + offset
}

let result = calibrate(base: 1200, offset: 80)
print("Calibrated: \\(result)")
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
        Challenge(
            number: 305,
            id: "core-extra-heat-adjustment",
            title: "Heat Adjustment",
            description: "Update a value in place and report it",
            starterCode: """
                // Challenge 305: Heat Adjustment
                // Update a value in place and report it.

                var heat = 1000

                // TODO: Increase heat by 250 using +=
                // TODO: Print "Heat now: 1250"
                """,
            expectedOutput: "Heat now: 1250",
            hints: [
                "Compound assignment updates the variable directly.",
                "Use interpolation in the output.",
            ],
            cheatsheet: cheatsheetCore1Integration,
            solution: """
heat += 250
print("Heat now: \\(heat)")
""",
            constraintProfile: core3BaselineProfile,
            topic: .general,
            tier: .extra
        ),
    ]
}

func makeMantleChallenges() -> [Challenge] {
    let challenges = [
        Challenge(
            number: 124,
            title: "Struct Basics",
            description: "Define a struct and create an instance",
            starterCode: """
                // Challenge 124: Struct Basics
                // Define a struct and create an instance.

                // TODO: Create a struct named 'ForgeItem' with a 'name' property
                // TODO: Create an instance named 'item' with name "Iron"
                // TODO: Print 'item.name'
                """,
            expectedOutput: "Iron",
            hints: [
                "Model the item as a value type with a single stored property.",
                "Use dot syntax to read the property for output.",
            ],
            cheatsheet: cheatsheetStructs,
            lesson: lessonStructsBasics,
            solution: """
struct ForgeItem {
    var name: String
}

let item = ForgeItem(name: "Iron")
print(item.name)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.structs, .properties],
            topic: .structs,
        ),
        Challenge(
            number: 125,
            title: "Stored Properties",
            description: "Read and update stored properties",
            starterCode: """
                // Challenge 125: Stored Properties
                // Read and update stored properties.

                struct Furnace {
                    var heat: Int
                }

                var furnace = Furnace(heat: 1200)

                // TODO: Update 'furnace.heat' to 1500
                // TODO: Print 'furnace.heat'
                """,
            expectedOutput: "1500",
            hints: [
                "Stored properties can be updated on a var instance.",
            ],
            cheatsheet: cheatsheetStructs,
            lesson: lessonStructsBasics,
            solution: """
furnace.heat = 1500
print(furnace.heat)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.properties],
            topic: .structs,
        ),
        Challenge(
            number: 126,
            title: "Methods + self",
            description: "Add a method that uses self",
            starterCode: """
                // Challenge 126: Methods + self
                // Add a method that reads state.

                struct Hammer {
                    var strikes: Int
                    // TODO: Add a method 'summary()' that returns "Strikes: <value>"
                }

                var hammer = Hammer(strikes: 0)
                // TODO: Print 'hammer.summary()'
                """,
            expectedOutput: "Strikes: 0",
            hints: [
                "Use self to build the return string from the property.",
            ],
            cheatsheet: cheatsheetStructs,
            lesson: lessonStructsBasics,
            solution: """
struct Hammer {
    var strikes: Int

    func summary() -> String {
        return "Strikes: \\(strikes)"
    }
}

var hammer = Hammer(strikes: 0)
print(hammer.summary())
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.selfKeyword],
            topic: .structs,
        ),
        Challenge(
            number: 127,
            title: "Custom Init",
            description: "Write a custom initializer",
            starterCode: """
                // Challenge 127: Custom Init
                // Create a custom initializer.

                struct Ingot {
                    var metal: String
                    var weight: Int
                    // TODO: Add init(metal:) that sets 'weight' to 1
                }

                // TODO: Create an Ingot with metal "Copper"
                // TODO: Print the metal and weight on separate lines
                """,
            expectedOutput: "Copper\n1",
            hints: [
                "Custom initializers can set default values.",
            ],
            cheatsheet: cheatsheetStructs,
            lesson: lessonStructsBasics,
            solution: """
struct Ingot {
    var metal: String
    var weight: Int

    init(metal: String) {
        self.metal = metal
        self.weight = 1
    }
}

let ingot = Ingot(metal: "Copper")
print(ingot.metal)
print(ingot.weight)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.initializers],
            topic: .structs,
        ),
        Challenge(
            number: 128,
            title: "Mutating Method",
            description: "Use mutating to update struct state",
            starterCode: """
                // Challenge 128: Mutating Method
                // Use mutating for state changes.

                struct Crucible {
                    var level: Int
                    // TODO: Add mutating func 'raise' that increments 'level'
                }

                var crucible = Crucible(level: 1)
                // TODO: Call 'raise()' twice
                // TODO: Print 'crucible.level'
                """,
            expectedOutput: "3",
            hints: [
                "Use mutating when a struct method changes properties.",
            ],
            cheatsheet: cheatsheetStructs,
            lesson: lessonStructsBasics,
            solution: """
struct Crucible {
    var level: Int

    mutating func raise() {
        level += 1
    }
}

var crucible = Crucible(level: 1)
crucible.raise()
crucible.raise()
print(crucible.level)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.mutatingMethods],
            topic: .structs,
        ),
        Challenge(
            number: 129,
            title: "Value Semantics",
            description: "Show independent copies of a struct",
            starterCode: """
                // Challenge 129: Value Semantics
                // Show that structs are copied on assignment.

                struct Mold {
                    var size: Int
                }

                let original = Mold(size: 1)
                var copy = original

                // TODO: Change 'copy.size' to 2
                // TODO: Print 'original.size' and 'copy.size' on separate lines
                """,
            expectedOutput: "1\n2",
            hints: [
                "Changing a copy does not affect the original.",
            ],
            cheatsheet: cheatsheetStructs,
            lesson: lessonStructsBasics,
            solution: """
struct Mold {
    var size: Int
}

let original = Mold(size: 1)
var copy = original
copy.size = 2

print(original.size)
print(copy.size)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .structs,
        ),
        Challenge(
            number: 130,
            title: "Class Basics",
            description: "Define and instantiate a class",
            starterCode: """
                // Challenge 130: Class Basics
                // Define and instantiate a class.

                class Anvil {
                    var weight: Int
                    init(weight: Int) {
                        self.weight = weight
                    }
                }

                // TODO: Create an Anvil with weight 10
                // TODO: Print the weight
                """,
            expectedOutput: "10",
            hints: [
                "Classes need an initializer if they have stored properties.",
            ],
            cheatsheet: cheatsheetClasses,
            lesson: lessonClassesBasics,
            solution: """
let anvil = Anvil(weight: 10)
print(anvil.weight)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.classes],
            topic: .classes,
        ),
        Challenge(
            number: 131,
            title: "Reference Semantics",
            description: "Show shared state in classes",
            starterCode: """
                // Challenge 131: Reference Semantics
                // Show that classes share references.

                class Bellows {
                    var power: Int
                    init(power: Int) {
                        self.power = power
                    }
                }

                let primary = Bellows(power: 1)
                let secondary = primary

                // TODO: Set 'secondary.power' to 3
                // TODO: Print 'primary.power'
                """,
            expectedOutput: "3",
            hints: [
                "Changing a reference affects all references to the same instance.",
            ],
            cheatsheet: cheatsheetClasses,
            lesson: lessonClassesBasics,
            solution: """
secondary.power = 3
print(primary.power)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .classes,
        ),
        Challenge(
            number: 132,
            title: "Deinit",
            description: "Observe deinitialization",
            starterCode: """
                // Challenge 132: Deinit
                // Add a deinit message.

                class Torch {
                    let id: Int
                    init(id: Int) {
                        self.id = id
                    }
                    // TODO: Add deinit that prints "Torch <id> released"
                }

                // TODO: Create an optional Torch, then set it to nil
                """,
            expectedOutput: "Torch 1 released",
            hints: [
                "deinit runs when the last strong reference is released.",
            ],
            cheatsheet: cheatsheetClasses,
            lesson: lessonClassesBasics,
            solution: """
class Torch {
    let id: Int
    init(id: Int) {
        self.id = id
    }

    deinit {
        print("Torch \\(id) released")
    }
}

var torch: Torch? = Torch(id: 1)
torch = nil
""",
            constraintProfile: mantleBaselineProfile,
            topic: .classes,
        ),
        Challenge(
            number: 133,
            title: "Struct vs Class",
            description: "Choose the right type",
            starterCode: """
                // Challenge 133: Struct vs Class
                // Decide which type fits the scenario.

                // TODO: Create a struct for a simple 'Tag' (value type)
                // TODO: Create a class for a shared 'ForgeController' (reference type)
                // TODO: Print one property from each
                """,
            expectedOutput: "Batch-A\nOnline",
            hints: [
                "Use a struct for independent values and a class for shared state.",
            ],
            cheatsheet: cheatsheetClasses,
            lesson: lessonClassesBasics,
            solution: """
struct Tag {
    var label: String
}

class ForgeController {
    var status: String
    init(status: String) {
        self.status = status
    }
}

let tag = Tag(label: "Batch-A")
let controller = ForgeController(status: "Online")
print(tag.label)
print(controller.status)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .classes,
        ),
        Challenge(
            number: 134,
            title: "Computed Property",
            description: "Add a computed property",
            starterCode: """
                // Challenge 134: Computed Property
                // Use get/set on a computed property.

                struct Press {
                    var force: Int
                    // TODO: Add computed property 'doubleForce' with get/set
                }

                var press = Press(force: 2)
                // TODO: Set 'press.doubleForce' to 10
                // TODO: Print 'press.force'
                """,
            expectedOutput: "5",
            hints: [
                "Computed properties can translate values in get/set.",
            ],
            cheatsheet: cheatsheetProperties,
            lesson: lessonPropertiesAdvanced,
            solution: """
struct Press {
    var force: Int

    var doubleForce: Int {
        get { force * 2 }
        set { force = newValue / 2 }
    }
}

var press = Press(force: 2)
press.doubleForce = 10
print(press.force)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
        ),
        Challenge(
            number: 135,
            title: "Property Observers",
            description: "Use willSet and didSet",
            starterCode: """
                // Challenge 135: Property Observers
                // Observe changes with willSet/didSet.

                struct Gauge {
                    var pressure: Int {
                        // TODO: Add willSet/didSet prints
                    }
                }

                var gauge = Gauge(pressure: 1)
                // TODO: Change 'gauge.pressure' to 2
                """,
            expectedOutput: "Will set to 2\nDid set from 1",
            hints: [
                "Observers can print before and after changes.",
            ],
            cheatsheet: cheatsheetProperties,
            lesson: lessonPropertiesAdvanced,
            solution: """
struct Gauge {
    var pressure: Int {
        willSet {
            print("Will set to \\(newValue)")
        }
        didSet {
            print("Did set from \\(oldValue)")
        }
    }
}

var gauge = Gauge(pressure: 1)
gauge.pressure = 2
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
        ),
        Challenge(
            number: 136,
            title: "Lazy Property",
            description: "Initialize a property lazily",
            starterCode: """
                // Challenge 136: Lazy Property
                // Use lazy to defer creation.

                struct ForgeReport {
                    var id: Int
                    // TODO: Add lazy var 'summary' that returns "Report <id>"
                }

                var report = ForgeReport(id: 1)
                // TODO: Print 'report.summary'
                """,
            expectedOutput: "Report 1",
            hints: [
                "Lazy properties are created the first time they are accessed.",
            ],
            cheatsheet: cheatsheetProperties,
            lesson: lessonPropertiesAdvanced,
            solution: """
struct ForgeReport {
    var id: Int
    lazy var summary: String = "Report \\(id)"
}

var report = ForgeReport(id: 1)
print(report.summary)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
        ),
        Challenge(
            number: 137,
            title: "Static vs Instance",
            description: "Use static properties",
            starterCode: """
                // Challenge 137: Static vs Instance
                // Use a static property.

                struct Shift {
                    static let maxHours = 8
                    var hours: Int
                }

                let shift = Shift(hours: 6)
                // TODO: Print 'Shift.maxHours'
                // TODO: Print 'shift.hours'
                """,
            expectedOutput: "8\n6",
            hints: [
                "Static properties live on the type, not the instance.",
            ],
            cheatsheet: cheatsheetProperties,
            lesson: lessonPropertiesAdvanced,
            solution: """
print(Shift.maxHours)
print(shift.hours)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
        ),
        Challenge(
            number: 138,
            title: "Protocol Definition",
            description: "Define a protocol",
            starterCode: """
                // Challenge 138: Protocol Definition
                // Define a protocol with requirements.

                // TODO: Create a protocol 'Inspectable' with a read-only 'status' String
                // TODO: Print "Inspectable ready"
                """,
            expectedOutput: "Inspectable ready",
            hints: [
                "Protocols define required properties or methods.",
            ],
            cheatsheet: cheatsheetProtocols,
            lesson: lessonProtocolsBasics,
            solution: """
protocol Inspectable {
    var status: String { get }
}

print("Inspectable ready")
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.protocols],
            topic: .protocols,
        ),
        Challenge(
            number: 139,
            title: "Conformance",
            description: "Adopt a protocol in a struct",
            starterCode: """
                // Challenge 139: Conformance
                // Make a struct conform to a protocol.

                protocol Inspectable {
                    var status: String { get }
                }

                // TODO: Create a struct 'Furnace' that conforms to Inspectable
                // TODO: Print its status
                """,
            expectedOutput: "Ready",
            hints: [
                "Provide the required property to conform.",
            ],
            cheatsheet: cheatsheetProtocols,
            lesson: lessonProtocolsBasics,
            solution: """
struct Furnace: Inspectable {
    let status: String
}

let furnace = Furnace(status: "Ready")
print(furnace.status)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.protocolConformance],
            topic: .protocols,
        ),
        Challenge(
            number: 140,
            title: "Protocol as Type",
            description: "Use a protocol as a parameter type",
            starterCode: """
                // Challenge 140: Protocol as Type
                // Use a protocol in a function signature.

                protocol HeatSource {
                    var heat: Int { get }
                }

                struct Burner: HeatSource {
                    let heat: Int
                }

                // TODO: Write a function 'reportHeat(source:)' that prints 'source.heat'
                // TODO: Call it with a Burner
                """,
            expectedOutput: "1200",
            hints: [
                "Protocol types let you accept a conforming type.",
            ],
            cheatsheet: cheatsheetProtocols,
            lesson: lessonProtocolsBasics,
            solution: """
func reportHeat(source: HeatSource) {
    print(source.heat)
}

let burner = Burner(heat: 1200)
reportHeat(source: burner)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
        ),
        Challenge(
            number: 141,
            title: "Protocol Composition",
            description: "Use A & B in a parameter",
            starterCode: """
                // Challenge 141: Protocol Composition
                // Use multiple protocol requirements.

                protocol Fueling {
                    var fuel: Int { get }
                }

                protocol Venting {
                    var airflow: Int { get }
                }

                struct Vent: Fueling, Venting {
                    let fuel: Int
                    let airflow: Int
                }

                // TODO: Write a function 'report(_:)' that accepts Fueling & Venting
                // TODO: Print fuel and airflow on separate lines
                """,
            expectedOutput: "2\n3",
            hints: [
                "Use protocol composition to require both capabilities.",
            ],
            cheatsheet: cheatsheetProtocols,
            lesson: lessonProtocolsBasics,
            solution: """
func report(_ source: Fueling & Venting) {
    print(source.fuel)
    print(source.airflow)
}

let vent = Vent(fuel: 2, airflow: 3)
report(vent)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
        ),
        Challenge(
            number: 142,
            title: "Protocol Inheritance",
            description: "Refine a protocol",
            starterCode: """
                // Challenge 142: Protocol Inheritance
                // Inherit requirements from another protocol.

                protocol Component {
                    var id: String { get }
                }

                // TODO: Create protocol 'InspectableComponent' inheriting Component with 'status'
                // TODO: Create a type that conforms and print its status
                """,
            expectedOutput: "OK",
            hints: [
                "Protocol inheritance adds requirements on top of another protocol.",
            ],
            cheatsheet: cheatsheetProtocols,
            lesson: lessonProtocolsBasics,
            solution: """
protocol InspectableComponent: Component {
    var status: String { get }
}

struct Sensor: InspectableComponent {
    let id: String
    let status: String
}

let sensor = Sensor(id: "S1", status: "OK")
print(sensor.status)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
        ),
        Challenge(
            number: 143,
            title: "Extensions",
            description: "Add methods with an extension",
            starterCode: """
                // Challenge 143: Extensions
                // Add behavior using an extension.

                struct Ingot {
                    let weight: Int
                }

                // TODO: Add an extension that adds a method 'label()' -> String
                // TODO: Create an Ingot and print its label
                """,
            expectedOutput: "Ingot 5",
            hints: [
                "Extensions can add computed properties and methods.",
            ],
            cheatsheet: cheatsheetExtensions,
            lesson: lessonExtensionsBasics,
            solution: """
extension Ingot {
    func label() -> String {
        return "Ingot \\(weight)"
    }
}

let ingot = Ingot(weight: 5)
print(ingot.label())
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.extensions],
            topic: .extensions,
        ),
        Challenge(
            number: 144,
            title: "Default Implementations",
            description: "Add default behavior with a protocol extension",
            starterCode: """
                // Challenge 144: Default Implementations
                // Provide default behavior with a protocol extension.

                protocol Reportable {
                    var message: String { get }
                }

                // TODO: Add a default method 'printReport()' in a protocol extension
                // TODO: Conform a struct and call 'printReport()'
                """,
            expectedOutput: "Report ready",
            hints: [
                "Use a protocol extension to add a default method.",
            ],
            cheatsheet: cheatsheetExtensions,
            lesson: lessonExtensionsBasics,
            solution: """
extension Reportable {
    func printReport() {
        print(message)
    }
}

struct Report: Reportable {
    let message: String
}

let report = Report(message: "Report ready")
report.printReport()
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.protocolExtensions, .defaultImplementations],
            topic: .extensions,
        ),
        Challenge(
            number: 145,
            title: "Access Control 1",
            description: "Use private and internal",
            starterCode: """
                // Challenge 145: Access Control 1
                // Add private and internal members.

                struct Vault {
                    private var code: Int
                    private(set) var state: String = "Locked"
                    // TODO: Add an internal init(code:)
                }
                
                // TODO: Create a Vault and print "Vault ready"
                """,
            expectedOutput: "Vault ready",
            hints: [
                "private limits access to the type; internal is the default.",
            ],
            cheatsheet: cheatsheetAccessControl,
            lesson: lessonAccessControlBasics,
            solution: """
struct Vault {
    private var code: Int
    private(set) var state: String = "Locked"

    init(code: Int) {
        self.code = code
    }
}

let _ = Vault(code: 1234)
print("Vault ready")
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.accessControl, .accessControlInternal, .accessControlSetter],
            topic: .accessControl,
        ),
        Challenge(
            number: 146,
            title: "Access Control 2",
            description: "Use public and open",
            starterCode: """
                // Challenge 146: Access Control 2
                // Mark APIs public/open in a library.

                // TODO: Add a public struct 'Ledger'
                // TODO: Add an open class 'Controller'
                // TODO: Create instances and print "Ledger" then "Controller"
                """,
            expectedOutput: "Ledger\nController",
            hints: [
                "public exposes types outside the module; open allows subclassing.",
            ],
            cheatsheet: cheatsheetAccessControl,
            lesson: lessonAccessControlBasics,
            solution: """
public struct Ledger {}

open class Controller {}

let _ = Ledger()
let _ = Controller()
print("Ledger")
print("Controller")
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.accessControlOpen],
            topic: .accessControl,
        ),
        Challenge(
            number: 147,
            title: "Error Integration",
            description: "Use errors in a protocol-based API",
            starterCode: """
                // Challenge 147: Error Integration
                // Use errors in an API surface.

                enum FurnaceError: Error {
                    case tooCold
                }

                protocol Heatable {
                    func heat(to level: Int) throws
                }

                // TODO: Create a type that conforms and throws on low values
                // TODO: Call it with a low value and print "Too cold" in catch
                """,
            expectedOutput: "Too cold",
            hints: [
                "Throw errors when constraints are not met.",
            ],
            cheatsheet: cheatsheetErrors,
            lesson: lessonErrorsBasics,
            solution: """
struct Furnace: Heatable {
    func heat(to level: Int) throws {
        if level < 1000 {
            throw FurnaceError.tooCold
        }
    }
}

do {
    try Furnace().heat(to: 900)
} catch {
    print("Too cold")
}
""",
            constraintProfile: mantleBaselineProfile,
            requires: [.doCatch, .throwKeyword, .tryKeyword, .errorTypes, .throwingFunctions, .doTryCatch],
            topic: .errors,
        ),
        Challenge(
            number: 148,
            title: "Generic Function",
            description: "Write a generic function",
            starterCode: """
                // Challenge 148: Generic Function
                // Create a generic helper.

                // TODO: Write a generic function 'swapPair' that returns a tuple (B, A)
                // TODO: Call it with "Iron" and 3, then print the tuple
                """,
            expectedOutput: "(3, \"Iron\")",
            hints: [
                "Generics let you reuse logic across types.",
            ],
            cheatsheet: cheatsheetGenerics,
            lesson: lessonGenericsBasics,
            solution: """
func swapPair<A, B>(_ first: A, _ second: B) -> (B, A) {
    return (second, first)
}

print(swapPair("Iron", 3))
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.generics],
            topic: .generics,
        ),
        Challenge(
            number: 149,
            title: "Generic Type",
            description: "Define a generic container",
            starterCode: """
                // Challenge 149: Generic Type
                // Build a simple generic container.

                // TODO: Create a generic struct 'Box<T>' with a value: T
                // TODO: Create a Box of Int with value 7 and print the value
                """,
            expectedOutput: "7",
            hints: [
                "Generic types store values of a type parameter.",
            ],
            cheatsheet: cheatsheetGenerics,
            lesson: lessonGenericsBasics,
            solution: """
struct Box<T> {
    let value: T
}

let box = Box(value: 7)
print(box.value)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 150,
            title: "Type Constraints",
            description: "Add a constraint to a generic",
            starterCode: """
                // Challenge 150: Type Constraints
                // Constrain a generic to Comparable.

                // TODO: Write a generic function 'maxValue' that takes two T: Comparable
                // TODO: Call it with 3 and 5, then print the result
                """,
            expectedOutput: "5",
            hints: [
                "Constraints allow you to use protocol requirements on T.",
            ],
            cheatsheet: cheatsheetGenerics,
            lesson: lessonGenericsBasics,
            solution: """
func maxValue<T: Comparable>(_ first: T, _ second: T) -> T {
    return first >= second ? first : second
}

print(maxValue(3, 5))
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 151,
            title: "Associated Types",
            description: "Use associatedtype in a protocol",
            starterCode: """
                // Challenge 151: Associated Types
                // Define a protocol with an associated type.

                // TODO: Create a protocol 'Storage' with associatedtype 'Item' and var items: [Item]
                // TODO: Create a struct that conforms with String items and print its count
                """,
            expectedOutput: "2",
            hints: [
                "associatedtype lets protocols describe generic placeholders.",
            ],
            cheatsheet: cheatsheetGenerics,
            lesson: lessonGenericsBasics,
            solution: """
protocol Storage {
    associatedtype Item
    var items: [Item] { get }
}

struct StringStorage: Storage {
    let items: [String]
}

let storage = StringStorage(items: ["Iron", "Gold"])
print(storage.items.count)
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.associatedTypes],
            topic: .generics,
        ),
        Challenge(
            number: 152,
            title: "Where Clauses",
            description: "Add a where clause to constrain generics",
            starterCode: """
                // Challenge 152: Where Clauses
                // Constrain an extension with where.

                // TODO: Extend Array where Element: Equatable and add a method 'allEqual()'
                // TODO: Call it with [2, 2, 2] and print the result
                """,
            expectedOutput: "true",
            hints: [
                "where adds extra constraints for a generic extension.",
            ],
            cheatsheet: cheatsheetGenerics,
            lesson: lessonGenericsBasics,
            solution: """
extension Array where Element: Equatable {
    func allEqual() -> Bool {
        guard let first = first else { return true }
        return allSatisfy { $0 == first }
    }
}

print([2, 2, 2].allEqual())
""",
            constraintProfile: mantleBaselineProfile,
            introduces: [.whereClauses],
            topic: .generics,
        ),
        Challenge(
            number: 153,
            title: "Constrained Extension",
            description: "Add shared behavior with constraints",
            starterCode: """
                // Challenge 153: Constrained Extension
                // Add shared behavior with constraints.

                protocol Describable {
                    var name: String { get }
                }

                // TODO: Add a constrained extension for Describable where Self: Equatable
                // TODO: Conform a struct and print its description
                """,
            expectedOutput: "Forge: Anvil",
            hints: [
                "Constrain the shared behavior so it applies only to types that support equality checks.",
            ],
            cheatsheet: cheatsheetExtensions,
            lesson: lessonGenericsBasics,
            solution: """
extension Describable where Self: Equatable {
    func description() -> String {
        return "Forge: \\(name)"
    }
}

struct Tool: Describable, Equatable {
    let name: String
}

let tool = Tool(name: "Anvil")
print(tool.description())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 154,
            title: "Conditional Conformance",
            description: "Conform generics conditionally",
            starterCode: """
                // Challenge 154: Conditional Conformance
                // Add conditional conformance to a generic type.

                struct Crate<T> {
                    let items: [T]
                }

                // TODO: Make Crate conform to Equatable when T is Equatable
                // TODO: Compare two crates of Ints and print the result
                """,
            expectedOutput: "true",
            hints: [
                "Conditional conformance lives in an extension with a type constraint.",
            ],
            cheatsheet: cheatsheetGenerics,
            lesson: lessonGenericsBasics,
            solution: """
extension Crate: Equatable where T: Equatable {}

let first = Crate(items: [1, 2])
let second = Crate(items: [1, 2])
print(first == second)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 155,
            title: "Model Layer Exercise",
            description: "Apply protocol-oriented design",
            starterCode: """
                // Challenge 155: Model Layer Exercise
                // Compose a small model layer with protocols and defaults.

                // TODO: Define a protocol and a default implementation
                // TODO: Create a conforming struct and use the default method
                """,
            expectedOutput: "Alloy ready",
            hints: [
                "Use protocols to define behavior and extensions for defaults.",
            ],
            cheatsheet: cheatsheetProtocols,
            lesson: lessonProtocolsBasics,
            solution: """
protocol StatusProviding {
    var status: String { get }
}

extension StatusProviding {
    func report() {
        print(status)
    }
}

struct Alloy: StatusProviding {
    let status: String
}

let alloy = Alloy(status: "Alloy ready")
alloy.report()
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
        ),
        Challenge(
            number: 156,
            title: "ARC Safety",
            description: "Avoid reference cycles with weak",
            starterCode: """
                // Challenge 156: ARC Safety
                // Use weak references to avoid cycles.

                class Operator {
                    var name: String
                    init(name: String) {
                        self.name = name
                    }
                    // TODO: Add a weak reference back to a Forge
                }

                class Forge {
                    var operatorRef: Operator?
                }
                
                // TODO: Create instances and print "Cycle avoided"
                """,
            expectedOutput: "Cycle avoided",
            hints: [
                "Weak references prevent strong reference cycles.",
            ],
            cheatsheet: cheatsheetMemory,
            lesson: lessonMemoryBasics,
            solution: """
class Operator {
    var name: String
    weak var forge: Forge?

    init(name: String) {
        self.name = name
    }
}

class Forge {
    var operatorRef: Operator?
}

let forge = Forge()
let operatorRef = Operator(name: "Ada")
forge.operatorRef = operatorRef
operatorRef.forge = forge
print("Cycle avoided")
""",
            constraintProfile: mantleBaselineProfile,
            topic: .memory,
        ),
        Challenge(
            number: 157,
            id: "mantle-extra-struct-copy-drill",
            title: "Struct Copy Drill",
            description: "Show independent struct copies",
            starterCode: """
                // Challenge 157: Struct Copy Drill
                // Show independent struct copies.

                struct Plate {
                    var thickness: Int
                }

                let original = Plate(thickness: 2)
                var copy = original

                // TODO: Set 'copy.thickness' to 5
                // TODO: Print 'original.thickness' and 'copy.thickness' on separate lines
                """,
            expectedOutput: "2\n5",
            hints: [
                "Structs are copied on assignment.",
            ],
            cheatsheet: cheatsheetStructs,
            solution: """
copy.thickness = 5
print(original.thickness)
print(copy.thickness)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .structs,
            tier: .extra
        ),
        Challenge(
            number: 158,
            id: "mantle-extra-mutating-counter",
            title: "Mutating Counter",
            description: "Use a mutating method",
            starterCode: """
                // Challenge 158: Mutating Counter
                // Update state with a mutating method.

                struct Counter {
                    var value: Int
                    // TODO: Add mutating func 'increment' to add 1
                }

                var counter = Counter(value: 1)
                // TODO: Call 'increment' twice
                // TODO: Print 'counter.value'
                """,
            expectedOutput: "3",
            hints: [
                "Mutating methods can change stored properties.",
            ],
            cheatsheet: cheatsheetStructs,
            solution: """
struct Counter {
    var value: Int

    mutating func increment() {
        value += 1
    }
}

var counter = Counter(value: 1)
counter.increment()
counter.increment()
print(counter.value)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .structs,
            tier: .extra
        ),
        Challenge(
            number: 159,
            id: "mantle-extra-computed-conversion",
            title: "Computed Conversion",
            description: "Use a computed get/set",
            starterCode: """
                // Challenge 159: Computed Conversion
                // Convert between units with get/set.

                struct Weight {
                    var kg: Int
                    // TODO: Add computed property 'pounds' using 1 kg = 2 lb
                }

                var weight = Weight(kg: 1)
                // TODO: Set 'weight.pounds' to 10
                // TODO: Print 'weight.kg'
                """,
            expectedOutput: "5",
            hints: [
                "Set should convert pounds back to kg.",
            ],
            cheatsheet: cheatsheetProperties,
            solution: """
struct Weight {
    var kg: Int

    var pounds: Int {
        get { kg * 2 }
        set { kg = newValue / 2 }
    }
}

var weight = Weight(kg: 1)
weight.pounds = 10
print(weight.kg)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
            tier: .extra
        ),
        Challenge(
            number: 160,
            id: "mantle-extra-observer-echo",
            title: "Observer Echo",
            description: "Use property observers",
            starterCode: """
                // Challenge 160: Observer Echo
                // Print before and after changes.

                struct Gauge {
                    var pressure: Int {
                        // TODO: Add willSet/didSet to print changes
                    }
                }

                var gauge = Gauge(pressure: 1)
                // TODO: Set 'gauge.pressure' to 3
                """,
            expectedOutput: "Will set to 3\nDid set from 1",
            hints: [
                "Use newValue and oldValue in observers.",
            ],
            cheatsheet: cheatsheetProperties,
            solution: """
struct Gauge {
    var pressure: Int {
        willSet {
            print("Will set to \\(newValue)")
        }
        didSet {
            print("Did set from \\(oldValue)")
        }
    }
}

var gauge = Gauge(pressure: 1)
gauge.pressure = 3
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
            tier: .extra
        ),
        Challenge(
            number: 161,
            id: "mantle-extra-class-shared-state",
            title: "Class Shared State",
            description: "Share state across references",
            starterCode: """
                // Challenge 161: Class Shared State
                // Show reference semantics.

                class Controller {
                    var mode: String
                    init(mode: String) {
                        self.mode = mode
                    }
                }

                let primary = Controller(mode: "Idle")
                let secondary = primary

                // TODO: Set 'secondary.mode' to "Active"
                // TODO: Print 'primary.mode'
                """,
            expectedOutput: "Active",
            hints: [
                "Classes share a single instance across references.",
            ],
            cheatsheet: cheatsheetClasses,
            solution: """
secondary.mode = "Active"
print(primary.mode)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .classes,
            tier: .extra
        ),
        Challenge(
            number: 162,
            id: "mantle-extra-lazy-builder",
            title: "Lazy Builder",
            description: "Use a lazy property",
            starterCode: """
                // Challenge 162: Lazy Builder
                // Build a lazy property.

                struct Report {
                    var id: Int
                    // TODO: Add lazy var 'title' returning "Report <id>"
                }

                var report = Report(id: 2)
                // TODO: Print 'report.title'
                """,
            expectedOutput: "Report 2",
            hints: [
                "Lazy properties are initialized on first access.",
            ],
            cheatsheet: cheatsheetProperties,
            solution: """
struct Report {
    var id: Int
    lazy var title: String = "Report \\(id)"
}

var report = Report(id: 2)
print(report.title)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
            tier: .extra
        ),
        Challenge(
            number: 163,
            id: "mantle-extra-default-label",
            title: "Default Label",
            description: "Add a protocol default method",
            starterCode: """
                // Challenge 163: Default Label
                // Add a shared method with a protocol extension.

                protocol Named {
                    var name: String { get }
                }

                // TODO: Add default method label() -> String returning "Tool: <name>"
                // TODO: Conform a struct and print its label
                """,
            expectedOutput: "Tool: Hammer",
            hints: [
                "Protocol extensions can provide default methods.",
            ],
            cheatsheet: cheatsheetExtensions,
            solution: """
extension Named {
    func label() -> String {
        return "Tool: \\(name)"
    }
}

struct Tool: Named {
    let name: String
}

print(Tool(name: "Hammer").label())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 164,
            id: "mantle-extra-protocol-parameter",
            title: "Protocol Parameter",
            description: "Use a protocol as a parameter",
            starterCode: """
                // Challenge 164: Protocol Parameter
                // Accept a protocol type.

                protocol HeatSource {
                    var heat: Int { get }
                }

                struct Furnace: HeatSource {
                    let heat: Int
                }

                // TODO: Write function 'reportHeat(source:)' that prints "Heat: <value>"
                // TODO: Call it with a Furnace(heat: 1500)
                """,
            expectedOutput: "Heat: 1500",
            hints: [
                "Accept any type that conforms to the protocol, not a concrete type.",
            ],
            cheatsheet: cheatsheetProtocols,
            solution: """
func reportHeat(source: HeatSource) {
    print("Heat: \\(source.heat)")
}

reportHeat(source: Furnace(heat: 1500))
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 165,
            id: "mantle-extra-composition-drill",
            title: "Composition Drill",
            description: "Require two protocols",
            starterCode: """
                // Challenge 165: Composition Drill
                // Require two protocols in one parameter.

                protocol Fueling {
                    var fuel: Int { get }
                }

                protocol Venting {
                    var airflow: Int { get }
                }

                struct Vent: Fueling, Venting {
                    let fuel: Int
                    let airflow: Int
                }

                // TODO: Write function report(_:) that accepts Fueling & Venting
                // TODO: Print "Fuel <fuel>" and "Air <airflow>" on separate lines
                """,
            expectedOutput: "Fuel 2\nAir 3",
            hints: [
                "Require both capabilities in the parameter type.",
            ],
            cheatsheet: cheatsheetProtocols,
            solution: """
func report(_ vent: Fueling & Venting) {
    print("Fuel \\(vent.fuel)")
    print("Air \\(vent.airflow)")
}

report(Vent(fuel: 2, airflow: 3))
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 166,
            id: "mantle-extra-extension-helper",
            title: "Extension Helper",
            description: "Add a method with an extension",
            starterCode: """
                // Challenge 166: Extension Helper
                // Add a helper method to Int.

                // TODO: Extend Int with a method squared() -> Int
                // TODO: Print 5.squared()
                """,
            expectedOutput: "25",
            hints: [
                "Extensions can add methods to existing types.",
            ],
            cheatsheet: cheatsheetExtensions,
            solution: """
extension Int {
    func squared() -> Int {
        return self * self
    }
}

print(5.squared())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .extensions,
            tier: .extra
        ),
        Challenge(
            number: 167,
            id: "mantle-extra-access-wrapper",
            title: "Access Wrapper",
            description: "Hide data with access control",
            starterCode: """
                // Challenge 167: Access Wrapper
                // Use private storage with a public view.

                struct Vault {
                    private var code: Int
                    // TODO: Add computed property 'masked' returning "****"
                    // TODO: Add init(code:) to set code
                }

                // TODO: Create a Vault and print 'masked'
                """,
            expectedOutput: "****",
            hints: [
                "Expose a safe value while keeping the code private.",
            ],
            cheatsheet: cheatsheetAccessControl,
            solution: """
struct Vault {
    private var code: Int

    var masked: String {
        return "****"
    }

    init(code: Int) {
        self.code = code
    }
}

let vault = Vault(code: 1234)
print(vault.masked)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .accessControl,
            tier: .extra
        ),
        Challenge(
            number: 168,
            id: "mantle-extra-error-route",
            title: "Error Route",
            description: "Throw and catch an error",
            starterCode: """
                // Challenge 168: Error Route
                // Throw and catch a custom error.

                enum ForgeError: Error {
                    case jam
                }

                // TODO: Write a function 'start(fuel:)' that throws when fuel == 0
                // TODO: Call it with fuel 0 and print "Jam" in catch
                """,
            expectedOutput: "Jam",
            hints: [
                "Throw the error when the condition is met.",
            ],
            cheatsheet: cheatsheetErrors,
            solution: """
func start(fuel: Int) throws {
    if fuel == 0 {
        throw ForgeError.jam
    }
}

do {
    try start(fuel: 0)
} catch {
    print("Jam")
}
""",
            constraintProfile: mantleBaselineProfile,
            topic: .errors,
            tier: .extra
        ),
        Challenge(
            number: 169,
            id: "mantle-extra-generic-box",
            title: "Generic Box",
            description: "Store a type in a box",
            starterCode: """
                // Challenge 169: Generic Box
                // Create a generic container.

                // TODO: Define struct Box<T> with value: T
                // TODO: Create Box(value: "Iron") and print the value
                """,
            expectedOutput: "Iron",
            hints: [
                "Use a generic type parameter T for the stored value.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
struct Box<T> {
    let value: T
}

let box = Box(value: "Iron")
print(box.value)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 170,
            id: "mantle-extra-comparable-min",
            title: "Comparable Min",
            description: "Use a generic constraint",
            starterCode: """
                // Challenge 170: Comparable Min
                // Use Comparable constraints.

                // TODO: Write minValue(_:_:) for T: Comparable
                // TODO: Call it with 3 and 5, then print the result
                """,
            expectedOutput: "3",
            hints: [
                "Compare the two values and return the smaller.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
func minValue<T: Comparable>(_ first: T, _ second: T) -> T {
    return first <= second ? first : second
}

print(minValue(3, 5))
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 171,
            id: "mantle-extra-associated-storage",
            title: "Associated Storage",
            description: "Use associated types",
            starterCode: """
                // Challenge 171: Associated Storage
                // Define a protocol with an associated type.

                protocol Stackable {
                    associatedtype Item
                    var items: [Item] { get set }
                    // TODO: Add mutating func push(_:)
                }

                struct Stack<T>: Stackable {
                    var items: [T]
                    // TODO: Implement push(_:)
                }

                var stack = Stack(items: [])
                // TODO: Push 2 and print stack.items.count
                """,
            expectedOutput: "1",
            hints: [
                "Mutating methods can append to the items array.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
protocol Stackable {
    associatedtype Item
    var items: [Item] { get set }
    mutating func push(_ item: Item)
}

struct Stack<T>: Stackable {
    var items: [T]

    mutating func push(_ item: T) {
        items.append(item)
    }
}

var stack = Stack(items: [])
stack.push(2)
print(stack.items.count)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 172,
            id: "mantle-extra-where-clause",
            title: "Where Clause",
            description: "Constrain an extension",
            starterCode: """
                // Challenge 172: Where Clause
                // Add a constrained extension.

                // TODO: Extend Array where Element: Equatable with allSame() -> Bool
                // TODO: Call it on [1, 1, 2] and print the result
                """,
            expectedOutput: "false",
            hints: [
                "Compare each element to the first.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
extension Array where Element: Equatable {
    func allSame() -> Bool {
        guard let first = first else { return true }
        return allSatisfy { $0 == first }
    }
}

print([1, 1, 2].allSame())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 173,
            id: "mantle-extra-conditional-conformance",
            title: "Conditional Conformance",
            description: "Add Equatable conformance conditionally",
            starterCode: """
                // Challenge 173: Conditional Conformance
                // Conform a generic type when T is Equatable.

                struct Wrapper<T> {
                    let value: T
                }

                // TODO: Make Wrapper conform to Equatable when T: Equatable
                // TODO: Compare two Wrapper(value: "A") and print the result
                """,
            expectedOutput: "true",
            hints: [
                "Add the constraint in an extension so conformance is conditional.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
extension Wrapper: Equatable where T: Equatable {}

let first = Wrapper(value: "A")
let second = Wrapper(value: "A")
print(first == second)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 174,
            id: "mantle-extra-weak-capture",
            title: "Weak Capture",
            description: "Use weak in a closure capture list",
            starterCode: """
                // Challenge 174: Weak Capture
                // Avoid strong capture cycles.

                class Logger {
                    let prefix: String
                    init(prefix: String) {
                        self.prefix = prefix
                    }

                    func makePrinter() -> () -> Void {
                        // TODO: Return a closure that prints prefix using [weak self]
                    }
                }

                let logger = Logger(prefix: "Log")
                let printer = logger.makePrinter()
                printer()
                """,
            expectedOutput: "Log",
            hints: [
                "Use a weak capture to avoid a cycle, then safely access the instance.",
            ],
            cheatsheet: cheatsheetMemory,
            solution: """
class Logger {
    let prefix: String
    init(prefix: String) {
        self.prefix = prefix
    }

    func makePrinter() -> () -> Void {
        return { [weak self] in
            if let self = self {
                print(self.prefix)
            }
        }
    }
}

let logger = Logger(prefix: "Log")
let printer = logger.makePrinter()
printer()
""",
            constraintProfile: mantleBaselineProfile,
            topic: .memory,
            tier: .extra
        ),
        Challenge(
            number: 250,
            id: "mantle-extra-access-control-nuance",
            title: "Access Control Nuance",
            description: "Use fileprivate, internal, and private(set)",
            starterCode: """
                // Challenge 250: Access Control Nuance
                // Use fileprivate, internal, and private(set).

                struct Vault {
                    fileprivate var code = "X"
                    internal var owner = "Forge"
                    private(set) var count = 1
                }

                let vault = Vault()
                // TODO: Print vault.owner
                // TODO: Print vault.count
                """,
            expectedOutput: "Forge\n1",
            hints: [
                "internal is the default access level.",
                "private(set) allows reads but prevents external mutation.",
            ],
            cheatsheet: cheatsheetAccessControl,
            solution: """
struct Vault {
    fileprivate var code = "X"
    internal var owner = "Forge"
    private(set) var count = 1
}

let vault = Vault()
print(vault.owner)
print(vault.count)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .accessControl,
            tier: .extra
        ),
        Challenge(
            number: 251,
            id: "mantle-extra-protocol-extension-constraint",
            title: "Protocol Extension Constraint",
            description: "Add a constrained default method",
            starterCode: """
                // Challenge 251: Protocol Extension Constraint
                // Add a constrained default method.

                protocol Taggable {
                    var tag: String { get }
                }

                // TODO: Add a protocol extension where Self: CustomStringConvertible
                // TODO: Add describeTag() -> String returning "Tag: <tag>"
                // TODO: Create a conforming type and print describeTag()
                """,
            expectedOutput: "Tag: Forge",
            hints: [
                "Add a where clause to limit the default method.",
                "Return a formatted string using tag.",
            ],
            cheatsheet: cheatsheetExtensions,
            solution: """
protocol Taggable {
    var tag: String { get }
}

extension Taggable where Self: CustomStringConvertible {
    func describeTag() -> String {
        return "Tag: \\(tag)"
    }
}

struct Tool: Taggable, CustomStringConvertible {
    let tag: String
    var description: String { tag }
}

let tool = Tool(tag: "Forge")
print(tool.describeTag())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 279,
            id: "mantle-extra-memberwise-init",
            title: "Memberwise Init",
            description: "Use a struct's memberwise initializer",
            starterCode: """
                // Challenge 279: Memberwise Init
                // Use the memberwise initializer.

                struct Ingot {
                    let metal: String
                    let weight: Int
                }

                // TODO: Create an Ingot for Iron with weight 3
                // TODO: Print "<metal> <weight>"
                """,
            expectedOutput: "Iron 3",
            hints: [
                "Memberwise init uses property names as labels.",
                "Print the stored properties in order.",
            ],
            cheatsheet: cheatsheetStructs,
            solution: """
let ingot = Ingot(metal: "Iron", weight: 3)
print("\\(ingot.metal) \\(ingot.weight)")
""",
            constraintProfile: mantleBaselineProfile,
            topic: .structs,
            tier: .extra
        ),
        Challenge(
            number: 280,
            id: "mantle-extra-class-identity",
            title: "Class Identity",
            description: "Compare class references",
            starterCode: """
                // Challenge 280: Class Identity
                // Compare two references to the same instance.

                class Forge {
                    var heat: Int
                    init(heat: Int) {
                        self.heat = heat
                    }
                }

                let primary = Forge(heat: 1)
                let secondary = primary

                // TODO: Print whether primary and secondary refer to the same instance
                """,
            expectedOutput: "true",
            hints: [
                "Use the identity operator (===) for classes.",
            ],
            cheatsheet: cheatsheetClasses,
            solution: """
print(primary === secondary)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .classes,
            tier: .extra
        ),
        Challenge(
            number: 281,
            id: "mantle-extra-readonly-property",
            title: "Readonly Property",
            description: "Use a computed read-only property",
            starterCode: """
                // Challenge 281: Readonly Property
                // Add a computed property without a setter.

                struct Gauge {
                    var psi: Int
                    // TODO: Add computed property bar using 1 bar = 14 psi (integer math)
                }

                let gauge = Gauge(psi: 28)
                // TODO: Print gauge.bar
                """,
            expectedOutput: "2",
            hints: [
                "Only provide a get block.",
                "Use integer division for 28 / 14.",
            ],
            cheatsheet: cheatsheetProperties,
            solution: """
struct Gauge {
    var psi: Int
    var bar: Int {
        return psi / 14
    }
}

let gauge = Gauge(psi: 28)
print(gauge.bar)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .properties,
            tier: .extra
        ),
        Challenge(
            number: 282,
            id: "mantle-extra-protocol-default",
            title: "Protocol Default",
            description: "Provide a default implementation",
            starterCode: """
                // Challenge 282: Protocol Default
                // Provide a default method in an extension.

                protocol Describable {
                    var name: String { get }
                }

                // TODO: Add describe() -> String that returns "Name: <name>"
                // TODO: Create a struct conforming to Describable and print describe()
                """,
            expectedOutput: "Name: Anvil",
            hints: [
                "Default methods live in protocol extensions.",
            ],
            cheatsheet: cheatsheetExtensions,
            solution: """
extension Describable {
    func describe() -> String {
        return "Name: \\(name)"
    }
}

struct Tool: Describable {
    let name: String
}

print(Tool(name: "Anvil").describe())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 283,
            id: "mantle-extra-extension-static",
            title: "Extension Static",
            description: "Add a static helper",
            starterCode: """
                // Challenge 283: Extension Static
                // Add a static helper with an extension.

                struct Alloy {
                    let name: String
                }

                // TODO: Add static func standard() -> Alloy returning name "Steel"
                // TODO: Print Alloy.standard().name
                """,
            expectedOutput: "Steel",
            hints: [
                "Static methods are called on the type.",
            ],
            cheatsheet: cheatsheetExtensions,
            solution: """
extension Alloy {
    static func standard() -> Alloy {
        return Alloy(name: "Steel")
    }
}

print(Alloy.standard().name)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .extensions,
            tier: .extra
        ),
        Challenge(
            number: 284,
            id: "mantle-extra-private-set",
            title: "Private(set)",
            description: "Expose a read-only setter",
            starterCode: """
                // Challenge 284: Private(set)
                // Use private(set) to limit writes.

                struct Counter {
                    private(set) var value = 0
                    mutating func increment() {
                        value += 1
                    }
                }

                var counter = Counter()
                // TODO: Call increment twice, then print counter.value
                """,
            expectedOutput: "2",
            hints: [
                "private(set) allows reads but restricts writes.",
            ],
            cheatsheet: cheatsheetAccessControl,
            solution: """
var counter = Counter()
counter.increment()
counter.increment()
print(counter.value)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .accessControl,
            tier: .extra
        ),
        Challenge(
            number: 285,
            id: "mantle-extra-error-specific",
            title: "Error Specific",
            description: "Catch a specific error case",
            starterCode: """
                // Challenge 285: Error Specific
                // Catch a specific error case.

                enum FuseError: Error {
                    case blown
                    case missing
                }

                func checkFuse(_ ok: Bool) throws {
                    if !ok {
                        throw FuseError.blown
                    }
                }

                // TODO: Call checkFuse(false) and catch FuseError.blown to print "Blown"
                """,
            expectedOutput: "Blown",
            hints: [
                "Use a specific catch clause for the enum case.",
            ],
            cheatsheet: cheatsheetErrors,
            solution: """
do {
    try checkFuse(false)
} catch FuseError.blown {
    print("Blown")
}
""",
            constraintProfile: mantleBaselineProfile,
            topic: .errors,
            tier: .extra
        ),
        Challenge(
            number: 286,
            id: "mantle-extra-generic-pair",
            title: "Generic Pair",
            description: "Store two values in a generic type",
            starterCode: """
                // Challenge 286: Generic Pair
                // Store two values in a generic type.

                // TODO: Define struct Pair<A, B> with first and second
                // TODO: Create Pair(first: "Iron", second: 3) and print first and second
                """,
            expectedOutput: "Iron 3",
            hints: [
                "Use two generic type parameters.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
struct Pair<A, B> {
    let first: A
    let second: B
}

let pair = Pair(first: "Iron", second: 3)
print("\\(pair.first) \\(pair.second)")
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 287,
            id: "mantle-extra-protocol-associated",
            title: "Protocol Associated",
            description: "Use a protocol with an associated type",
            starterCode: """
                // Challenge 287: Protocol Associated
                // Use an associated type in a protocol.

                protocol Storable {
                    associatedtype Item
                    var item: Item { get }
                }

                struct Bin: Storable {
                    let item: String
                }

                // TODO: Create a Bin and print its item
                """,
            expectedOutput: "Iron",
            hints: [
                "Associated types let the conformer choose the concrete type.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
let bin = Bin(item: "Iron")
print(bin.item)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 288,
            id: "mantle-extra-protocol-erasure",
            title: "Protocol Erasure",
            description: "Use 'any' with a protocol",
            starterCode: """
                // Challenge 288: Protocol Erasure
                // Use 'any' with a protocol type.

                protocol HeatSource {
                    var heat: Int { get }
                }

                struct Burner: HeatSource {
                    let heat: Int
                }

                // TODO: Create a variable of type 'any HeatSource'
                // TODO: Assign a Burner and print heat
                """,
            expectedOutput: "1500",
            hints: [
                "Use 'any' to spell an existential.",
                "Access heat through the protocol-typed value.",
            ],
            cheatsheet: cheatsheetProtocols,
            solution: """
let source: any HeatSource = Burner(heat: 1500)
print(source.heat)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 289,
            id: "mantle-extra-protocol-composition-any",
            title: "Protocol Composition Any",
            description: "Use any with protocol composition",
            starterCode: """
                // Challenge 289: Protocol Composition Any
                // Use any with protocol composition.

                protocol Fueling { var fuel: Int { get } }
                protocol Venting { var airflow: Int { get } }

                struct Vent: Fueling, Venting {
                    let fuel: Int
                    let airflow: Int
                }

                // TODO: Create a value of type 'any Fueling & Venting'
                // TODO: Print fuel and airflow
                """,
            expectedOutput: "Fuel 2\nAir 3",
            hints: [
                "Combine protocols with '&' and prefix with 'any'.",
            ],
            cheatsheet: cheatsheetProtocols,
            solution: """
let vent: any Fueling & Venting = Vent(fuel: 2, airflow: 3)
print("Fuel \\(vent.fuel)")
print("Air \\(vent.airflow)")
""",
            constraintProfile: mantleBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 290,
            id: "mantle-extra-where-method",
            title: "Where Method",
            description: "Constrain a generic method with where",
            starterCode: """
                // Challenge 290: Where Method
                // Constrain a generic method with where.

                struct Store<T> {
                    let items: [T]

                    // TODO: Add method allEqual() -> Bool where T: Equatable
                }

                let store = Store(items: [1, 1, 1])
                // TODO: Print store.allEqual()
                """,
            expectedOutput: "true",
            hints: [
                "Use a where clause on the method, not the type.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
struct Store<T> {
    let items: [T]

    func allEqual() -> Bool where T: Equatable {
        guard let first = items.first else { return true }
        return items.allSatisfy { $0 == first }
    }
}

let store = Store(items: [1, 1, 1])
print(store.allEqual())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 291,
            id: "mantle-extra-generic-extension",
            title: "Generic Extension",
            description: "Add behavior with a constrained extension",
            starterCode: """
                // Challenge 291: Generic Extension
                // Add behavior with a constrained extension.

                struct Crate<T> {
                    let items: [T]
                }

                // TODO: Add an extension where T == String with firstItem() -> String
                // TODO: Create Crate(items: [\"A\", \"B\"]) and print firstItem()
                """,
            expectedOutput: "A",
            hints: [
                "Constrain the extension to T == String.",
            ],
            cheatsheet: cheatsheetGenerics,
            solution: """
extension Crate where T == String {
    func firstItem() -> String {
        return items.first ?? ""
    }
}

let crate = Crate(items: ["A", "B"])
print(crate.firstItem())
""",
            constraintProfile: mantleBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 309,
            id: "mantle-extra-weak-release",
            title: "Weak Release",
            description: "Avoid retain cycles in closures",
            starterCode: """
                // Challenge 309: Weak Release
                // Avoid retain cycles in closures.

                class Forge {
                    let id: Int
                    init(id: Int) { self.id = id }
                }

                var forge: Forge? = Forge(id: 1)
                let report = { [weak forge] in
                    // TODO: Print forge?.id or "nil" if it’s gone
                }

                // TODO: Set forge = nil
                // TODO: Call report()
                """,
            expectedOutput: "nil",
            hints: [
                "Capture weakly to avoid a strong cycle.",
                "Use nil coalescing to print \"nil\" when missing.",
            ],
            cheatsheet: cheatsheetMemory,
            solution: """
class Forge {
    let id: Int
    init(id: Int) { self.id = id }
}

var forge: Forge? = Forge(id: 1)
let report = { [weak forge] in
    print(forge?.id ?? "nil")
}

forge = nil
report()
""",
            constraintProfile: mantleBaselineProfile,
            topic: .memory,
            tier: .extra
        ),
        Challenge(
            number: 310,
            id: "mantle-extra-extension-computed",
            title: "Extension Computed",
            description: "Add a computed property via extension",
            starterCode: """
                // Challenge 310: Extension Computed
                // Add a computed property via extension.

                struct Ingot {
                    let weight: Int
                }

                // TODO: Add an extension with a computed property isHeavy (>= 10)
                // TODO: Create an Ingot(weight: 12) and print isHeavy
                """,
            expectedOutput: "true",
            hints: [
                "Extensions can add computed properties.",
                "Return a Bool based on weight.",
            ],
            cheatsheet: cheatsheetExtensions,
            solution: """
struct Ingot {
    let weight: Int
}

extension Ingot {
    var isHeavy: Bool {
        return weight >= 10
    }
}

let ingot = Ingot(weight: 12)
print(ingot.isHeavy)
""",
            constraintProfile: mantleBaselineProfile,
            topic: .extensions,
            tier: .extra
        ),
        Challenge(
            number: 311,
            id: "mantle-extra-error-rethrow",
            title: "Rethrow",
            description: "Pass through a throwing closure",
            starterCode: """
                // Challenge 311: Rethrow
                // Pass through a throwing closure.

                enum HeatError: Error {
                    case tooHot
                }

                func run(_ operation: () throws -> String) rethrows -> String {
                    // TODO: Call the operation and return the result
                }

                do {
                    let value = try run {
                        throw HeatError.tooHot
                    }
                    print(value)
                } catch {
                    // TODO: Print "Caught"
                }
                """,
            expectedOutput: "Caught",
            hints: [
                "rethrows forwards errors from the closure.",
                "Handle the error in the catch block.",
            ],
            cheatsheet: cheatsheetErrors,
            solution: """
enum HeatError: Error {
    case tooHot
}

func run(_ operation: () throws -> String) rethrows -> String {
    return try operation()
}

do {
    let value = try run {
        throw HeatError.tooHot
    }
    print(value)
} catch {
    print("Caught")
}
""",
            constraintProfile: mantleBaselineProfile,
            topic: .errors,
            tier: .extra
        ),
    ]
    return challenges.map { $0.withLayer(.mantle) }
}
func makeCrustChallenges() -> [Challenge] {
    let challenges = [
        Challenge(
            number: 175,
            title: "Async/Await Basics",
            description: "Write and await a simple async function",
            starterCode: """
                // Challenge 175: Async/Await Basics
                // Write and await a simple async function.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let semaphore = DispatchSemaphore(value: 0)
                    Task {
                        await operation()
                        semaphore.signal()
                    }

                    while semaphore.wait(timeout: .now()) != .success {
                        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
                    }
                }

                // TODO: Write an async function fetchHeat() that returns 1500

                runAsync {
                    // TODO: Call fetchHeat() and print "Heat: 1500"
                }

                """,
            expectedOutput: "Heat: 1500",
            hints: [
                "Async functions are declared with async and called with await.",
                "Await the result inside the runAsync block, then report it.",
                "runAsync uses a Task to bridge async work in a script.",
            ],
            cheatsheet: cheatsheetConcurrency,
            lesson: lessonConcurrencyBasics,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await operation()
        semaphore.signal()
    }

    while semaphore.wait(timeout: .now()) != .success {
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
    }
}

func fetchHeat() async -> Int {
    return 1500
}

runAsync {
    let value = await fetchHeat()
    print("Heat: \\(value)")
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            introduces: [.asyncAwait, .task],
            topic: .concurrency,
        ),
        Challenge(
            number: 176,
            title: "Task Basics",
            description: "Run async work in a Task",
            starterCode: """
                // Challenge 176: Task Basics
                // Run async work in a Task.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                // TODO: Write an async function forgeName() that returns "Forged"

                runAsync {
                    // TODO: Start a Task that awaits forgeName()
                    // TODO: Await task.value and print the result
                }

                """,
            expectedOutput: "Forged",
            hints: [
                "Use a Task to run the async function and capture its result.",
                "task.value returns the Task result.",
            ],
            cheatsheet: cheatsheetConcurrency,
            lesson: lessonConcurrencyBasics,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

func forgeName() async -> String {
    return "Forged"
}

runAsync {
    let task = Task { await forgeName() }
    let result = await task.value
    print(result)
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .concurrency,
        ),
        Challenge(
            number: 177,
            title: "Structured Concurrency",
            description: "Sum values using a task group",
            starterCode: """
                // Challenge 177: Structured Concurrency
                // Sum values using a task group.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                runAsync {
                    // TODO: Use withTaskGroup to sum [1, 2, 3]
                    // TODO: Print "Sum: 6"
                }

                """,
            expectedOutput: "Sum: 6",
            hints: [
                "Add a task for each value and sum the results as they arrive.",
                "Return the sum from the task group scope.",
            ],
            cheatsheet: cheatsheetConcurrency,
            lesson: lessonConcurrencyBasics,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

runAsync {
    let sum = await withTaskGroup(of: Int.self) { group -> Int in
        for value in [1, 2, 3] {
            group.addTask { value }
        }

        var total = 0
        for await value in group {
            total += value
        }
        return total
    }

    print("Sum: \\(sum)")
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            introduces: [.taskGroup],
            topic: .concurrency,
        ),
        Challenge(
            number: 178,
            title: "Async Sequences",
            description: "Iterate an AsyncStream",
            starterCode: """
                // Challenge 178: Async Sequences
                // Iterate an AsyncStream of values.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                // TODO: Build an AsyncStream that yields 1, 2, 3 then finishes
                func makeStream() -> AsyncStream<Int> {
                    return AsyncStream { continuation in
                        // TODO: Yield 1, 2, 3 and finish
                    }
                }

                runAsync {
                    var total = 0
                    let stream = makeStream()

                    // TODO: Sum values from the stream with for await
                    // TODO: Print "Total: 6"
                }

                """,
            expectedOutput: "Total: 6",
            hints: [
                "Use continuation.yield to emit values and continuation.finish() to close.",
                "for await iterates async sequences.",
            ],
            cheatsheet: cheatsheetConcurrency,
            lesson: lessonConcurrencyBasics,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

func makeStream() -> AsyncStream<Int> {
    return AsyncStream { continuation in
        continuation.yield(1)
        continuation.yield(2)
        continuation.yield(3)
        continuation.finish()
    }
}

runAsync {
    var total = 0
    let stream = makeStream()

    for await value in stream {
        total += value
    }

    print("Total: \\(total)")
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .concurrency,
        ),
        Challenge(
            number: 179,
            title: "Cancellation",
            description: "Respect Task cancellation",
            starterCode: """
                // Challenge 179: Cancellation
                // Respect Task cancellation.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                runAsync {
                    let task = Task<Int, Never> {
                        await Task.yield()
                        // TODO: If Task.isCancelled, return 0
                        // TODO: Otherwise return 3
                    }

                    // TODO: Cancel the task
                    // TODO: Await task.value and print "Cancelled: 0"
                }

                """,
            expectedOutput: "Cancelled: 0",
            hints: [
                "Task.isCancelled lets you exit early.",
                "Cancel the task before awaiting task.value.",
            ],
            cheatsheet: cheatsheetConcurrency,
            lesson: lessonConcurrencyBasics,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

runAsync {
    let task = Task<Int, Never> {
        await Task.yield()
        if Task.isCancelled {
            return 0
        }
        return 3
    }

    task.cancel()
    let result = await task.value
    print("Cancelled: \\(result)")
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .concurrency,
        ),
        Challenge(
            number: 180,
            title: "Actor Basics",
            description: "Isolate state with an actor",
            starterCode: """
                // Challenge 180: Actor Basics
                // Isolate state with an actor.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                actor Counter {
                    private var value = 0
                    // TODO: Add increment() to add 1
                    // TODO: Add current() -> Int to return value
                }

                let counter = Counter()
                runAsync {
                    // TODO: Call increment twice
                    // TODO: Print "Count: 2"
                }

                """,
            expectedOutput: "Count: 2",
            hints: [
                "Actor methods are accessed with await.",
                "Store the result from current() before printing.",
            ],
            cheatsheet: cheatsheetActors,
            lesson: lessonActorsBasics,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func current() -> Int {
        return value
    }
}

let counter = Counter()
runAsync {
    await counter.increment()
    await counter.increment()
    let value = await counter.current()
    print("Count: \\(value)")
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            introduces: [.actors],
            topic: .actors,
        ),
        Challenge(
            number: 181,
            title: "MainActor",
            description: "Run work on the main actor",
            starterCode: """
                // Challenge 181: MainActor
                // Run work on the main actor.

                import Foundation

                @MainActor
                func updateStatus(value: Int) -> String {
                    // TODO: Return "Status: <value>"
                }

                // TODO: Create a Task on the main actor that prints updateStatus(value: 3)
                // TODO: Keep the run loop alive briefly so the task can finish

                """,
            expectedOutput: "Status: 3",
            hints: [
                "@MainActor functions run on the main actor.",
                "Run the work on the main actor inside a Task.",
                "Run the main run loop briefly so the task can execute.",
            ],
            cheatsheet: cheatsheetActors,
            lesson: lessonActorsBasics,
            solution: """
import Foundation

@MainActor
func updateStatus(value: Int) -> String {
    return "Status: \\(value)"
}

Task { @MainActor in
    let status = updateStatus(value: 3)
    print(status)
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            introduces: [.mainActor],
            requires: [.task],
            topic: .actors,
        ),
        Challenge(
            number: 182,
            title: "Sendable",
            description: "Mark values as safe to send across tasks",
            starterCode: """
                // Challenge 182: Sendable
                // Mark values as safe to send across tasks.

                import Foundation

                struct HeatReport: Sendable {
                    let value: Int
                }

                let report = HeatReport(value: 1200)
                // TODO: Print "Heat: 1200"

                """,
            expectedOutput: "Heat: 1200",
            hints: [
                "Sendable is a marker for concurrency safety.",
                "Use the stored value in the output.",
            ],
            cheatsheet: cheatsheetConcurrency,
            lesson: lessonConcurrencyBasics,
            solution: """
import Foundation

struct HeatReport: Sendable {
    let value: Int
}

let report = HeatReport(value: 1200)
print("Heat: \\(report.value)")

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            introduces: [.sendable],
            topic: .concurrency,
        ),
        Challenge(
            number: 183,
            title: "Property Wrapper Usage",
            description: "Use a provided property wrapper",
            starterCode: """
                // Challenge 183: Property Wrapper Usage
                // Use a provided property wrapper.

                import Foundation

                @propertyWrapper
                struct Clamped {
                    private var value: Int
                    private let range: ClosedRange<Int>

                    var wrappedValue: Int {
                        get { value }
                        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
                    }

                    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
                        self.range = range
                        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
                    }
                }

                struct Furnace {
                    // TODO: Create @Clamped(0...100) var heat = 120
                }

                var furnace = Furnace()
                // TODO: Print heat (should be 100)

                """,
            expectedOutput: "100",
            hints: [
                "The wrapper clamps values into the provided range.",
                "Declare the wrapped property on a type, then print it.",
            ],
            cheatsheet: cheatsheetPropertyWrappers,
            lesson: lessonPropertyWrappersBasics,
            solution: """
import Foundation

@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

struct Furnace {
    @Clamped(0...100) var heat = 120
}

var furnace = Furnace()
print(furnace.heat)

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            introduces: [.propertyWrappers],
            topic: .propertyWrappers,
        ),
        Challenge(
            number: 184,
            title: "Custom Property Wrapper",
            description: "Build a wrapper that normalizes input",
            starterCode: """
                // Challenge 184: Custom Property Wrapper
                // Build a wrapper that normalizes input.

                import Foundation

                @propertyWrapper
                struct Lowercased {
                    private var value: String

                    // TODO: Add wrappedValue that lowercases on set
                    // TODO: Add init(wrappedValue:) that lowercases the initial value
                }

                struct Label {
                    @Lowercased var name: String
                }

                let label = Label(name: "IRON")
                // TODO: Print label.name (should be "iron")

                """,
            expectedOutput: "iron",
            hints: [
                "wrappedValue should return the stored value and lowercased on set.",
                "Lowercase the initial wrappedValue in the initializer.",
            ],
            cheatsheet: cheatsheetPropertyWrappers,
            lesson: lessonPropertyWrappersBasics,
            solution: """
import Foundation

@propertyWrapper
struct Lowercased {
    private var value: String

    var wrappedValue: String {
        get { value }
        set { value = newValue.lowercased() }
    }

    init(wrappedValue: String) {
        value = wrappedValue.lowercased()
    }
}

struct Label {
    @Lowercased var name: String
}

let label = Label(name: "IRON")
print(label.name)

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .propertyWrappers,
        ),
        Challenge(
            number: 185,
            title: "Projected Values",
            description: "Use projected values from a wrapper",
            starterCode: """
                // Challenge 185: Projected Values
                // Use projected values from a wrapper.

                import Foundation

                @propertyWrapper
                struct Tracked {
                    private var value: Int
                    private(set) var projectedValue: Int = 0

                    var wrappedValue: Int {
                        get { value }
                        set { value = newValue; projectedValue += 1 }
                    }

                    init(wrappedValue: Int) {
                        value = wrappedValue
                    }
                }

                struct Furnace {
                    @Tracked var heat = 1200
                }

                var furnace = Furnace()
                furnace.heat = 1300
                furnace.heat = 1400
                // TODO: Print "Updates: 2" using the projected value

                """,
            expectedOutput: "Updates: 2",
            hints: [
                "Projected values are accessed with a $ prefix.",
                "Use the projected value on the instance after two assignments.",
            ],
            cheatsheet: cheatsheetPropertyWrappers,
            lesson: lessonPropertyWrappersBasics,
            solution: """
import Foundation

@propertyWrapper
struct Tracked {
    private var value: Int
    private(set) var projectedValue: Int = 0

    var wrappedValue: Int {
        get { value }
        set { value = newValue; projectedValue += 1 }
    }

    init(wrappedValue: Int) {
        value = wrappedValue
    }
}

struct Furnace {
    @Tracked var heat = 1200
}

var furnace = Furnace()
furnace.heat = 1300
furnace.heat = 1400
print("Updates: \\(furnace.$heat)")

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            introduces: [.projectedValues],
            topic: .propertyWrappers,
        ),
        Challenge(
            number: 186,
            title: "Key Path Syntax",
            description: "Read a value using a key path",
            starterCode: """
                // Challenge 186: Key Path Syntax
                // Read a value using a key path.

                import Foundation

                struct Ore {
                    let name: String
                    let purity: Int
                }

                let ore = Ore(name: "Iron", purity: 90)

                // TODO: Create a key path for name and print it
                """,
            expectedOutput: "Iron",
            hints: [
                "Key paths use the \\Type.property syntax.",
                "Access with value[keyPath: path].",
            ],
            cheatsheet: cheatsheetKeyPaths,
            lesson: lessonKeyPathsBasics,
            solution: """
import Foundation

struct Ore {
    let name: String
    let purity: Int
}

let ore = Ore(name: "Iron", purity: 90)
let nameKey = \\Ore.name
print(ore[keyPath: nameKey])
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .keyPaths,
        ),
        Challenge(
            number: 187,
            title: "Key Path Mapping",
            description: "Map values using key paths",
            starterCode: """
                // Challenge 187: Key Path Mapping
                // Map values using key paths.

                import Foundation

                struct Ore {
                    let name: String
                }

                let ores = [Ore(name: "Iron"), Ore(name: "Gold")]

                // TODO: Use map with a key path to get names
                // TODO: Print the names joined by a comma
                """,
            expectedOutput: "Iron,Gold",
            hints: [
                "map can take a key path like \\.name.",
                "Use joined(separator:) to format the array.",
            ],
            cheatsheet: cheatsheetKeyPaths,
            lesson: lessonKeyPathsBasics,
            solution: """
import Foundation

struct Ore {
    let name: String
}

let ores = [Ore(name: "Iron"), Ore(name: "Gold")]
let names = ores.map(\\.name)
print(names.joined(separator: \",\"))
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .keyPaths,
        ),
        Challenge(
            number: 188,
            title: "Lazy Collections",
            description: "Defer work with lazy",
            starterCode: """
                // Challenge 188: Lazy Collections
                // Defer work with lazy.

                import Foundation

                let numbers = [1, 2, 3]

                // TODO: Use lazy and map to double the numbers
                // TODO: Convert to Array and print the result
                """,
            expectedOutput: "[2, 4, 6]",
            hints: [
                "lazy creates a deferred sequence.",
                "Wrap the lazy result in Array(...) to print it.",
            ],
            cheatsheet: cheatsheetSequences,
            lesson: lessonSequencesBasics,
            solution: """
import Foundation

let numbers = [1, 2, 3]
let doubled = numbers.lazy.map { $0 * 2 }
print(Array(doubled))
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                requireCollectionUsage: false
            ),
            topic: .sequences,
        ),
        Challenge(
            number: 189,
            title: "Custom Sequence",
            description: "Create a sequence that counts down",
            starterCode: """
                // Challenge 189: Custom Sequence
                // Create a sequence that counts down.

                import Foundation

                struct Countdown: Sequence {
                    let start: Int
                    func makeIterator() -> CountdownIterator {
                        return CountdownIterator(current: start)
                    }
                }

                struct CountdownIterator: IteratorProtocol {
                    var current: Int
                    // TODO: Implement next() to return current, then decrement until 0
                }

                let countdown = Countdown(start: 3)
                for value in countdown {
                    print(value)
                }
                """,
            expectedOutput: "3\n2\n1",
            hints: [
                "Return nil when the sequence is done.",
                "Use defer or manual decrement to update current.",
            ],
            cheatsheet: cheatsheetSequences,
            lesson: lessonSequencesBasics,
            solution: """
import Foundation

struct Countdown: Sequence {
    let start: Int
    func makeIterator() -> CountdownIterator {
        return CountdownIterator(current: start)
    }
}

struct CountdownIterator: IteratorProtocol {
    var current: Int
    mutating func next() -> Int? {
        guard current > 0 else { return nil }
        defer { current -= 1 }
        return current
    }
}

let countdown = Countdown(start: 3)
for value in countdown {
    print(value)
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                requireCollectionUsage: false
            ),
            topic: .sequences,
        ),
        Challenge(
            number: 190,
            title: "Custom Iterator",
            description: "Implement next() manually",
            starterCode: """
                // Challenge 190: Custom Iterator
                // Implement next() manually.

                import Foundation

                struct HeatIterator: IteratorProtocol {
                    var current: Int
                    let max: Int

                    // TODO: Return current, then add 100 until max is reached
                }

                var iterator = HeatIterator(current: 1200, max: 1400)
                print(iterator.next()!)
                print(iterator.next()!)
                """,
            expectedOutput: "1200\n1300",
            hints: [
                "Return nil after current exceeds max.",
                "Update current after returning the old value.",
            ],
            cheatsheet: cheatsheetSequences,
            lesson: lessonSequencesBasics,
            solution: """
import Foundation

struct HeatIterator: IteratorProtocol {
    var current: Int
    let max: Int

    mutating func next() -> Int? {
        guard current <= max else { return nil }
        defer { current += 100 }
        return current
    }
}

var iterator = HeatIterator(current: 1200, max: 1400)
print(iterator.next()!)
print(iterator.next()!)
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                requireCollectionUsage: false
            ),
            topic: .sequences,
        ),
        Challenge(
            number: 191,
            title: "Sequence vs Collection",
            description: "Materialize a sequence to access count",
            starterCode: """
                // Challenge 191: Sequence vs Collection
                // Materialize a sequence to access count.

                import Foundation

                struct Counter: Sequence {
                    let start: Int
                    func makeIterator() -> CounterIterator {
                        return CounterIterator(current: start)
                    }
                }

                struct CounterIterator: IteratorProtocol {
                    var current: Int
                    mutating func next() -> Int? {
                        guard current > 0 else { return nil }
                        defer { current -= 1 }
                        return current
                    }
                }

                let sequence = Counter(start: 3)
                // TODO: Convert the sequence to an Array
                // TODO: Print "Count: 3" and "Last: 1"
                """,
            expectedOutput: "Count: 3\nLast: 1",
            hints: [
                "Array(sequence) materializes the values.",
                "Use items.count and items.last to format output.",
            ],
            cheatsheet: cheatsheetSequences,
            lesson: lessonSequencesBasics,
            solution: """
import Foundation

struct Counter: Sequence {
    let start: Int
    func makeIterator() -> CounterIterator {
        return CounterIterator(current: start)
    }
}

struct CounterIterator: IteratorProtocol {
    var current: Int
    mutating func next() -> Int? {
        guard current > 0 else { return nil }
        defer { current -= 1 }
        return current
    }
}

let sequence = Counter(start: 3)
let items = Array(sequence)
print("Count: \\(items.count)")
print("Last: \\(items.last ?? 0)")
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                requireCollectionUsage: false
            ),
            topic: .sequences,
        ),
        Challenge(
            number: 192,
            title: "Integration Challenge",
            description: "Combine async, actors, and wrappers",
            starterCode: """
                // Challenge 192: Integration Challenge
                // Combine async, actors, and wrappers.
                // Prereqs: async/await, actors, property wrappers.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                @propertyWrapper
                struct Clamped {
                    private var value: Int
                    private let range: ClosedRange<Int>

                    var wrappedValue: Int {
                        get { value }
                        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
                    }

                    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
                        self.range = range
                        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
                    }
                }

                actor Furnace {
                    @Clamped(0...2000) var heat: Int = 0
                    // TODO: Add addHeat(_:) to increase heat
                    // TODO: Add currentHeat() -> Int to return heat
                }

                let furnace = Furnace()
                runAsync {
                    // TODO: await furnace.addHeat(2200)
                    // TODO: Print "Heat: 2000"
                }

                """,
            expectedOutput: "Heat: 2000",
            hints: [
                "The wrapper clamps heat to 2000.",
                "Use await to call actor methods.",
            ],
            cheatsheet: cheatsheetActors,
            lesson: lessonCrustIntegration,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

actor Furnace {
    @Clamped(0...2000) var heat: Int = 0

    func addHeat(_ value: Int) {
        heat += value
    }

    func currentHeat() -> Int {
        return heat
    }
}

let furnace = Furnace()
runAsync {
    await furnace.addHeat(2200)
    let current = await furnace.currentHeat()
    print("Heat: \\(current)")
}

""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            requires: [.asyncAwait, .task, .actors, .propertyWrappers],
            topic: .concurrency,
        ),
        Challenge(
            number: 193,
            title: "Opaque Types",
            description: "Return an opaque type with some",
            starterCode: """
                // Challenge 193: Opaque Types
                // Return an opaque type with some.

                protocol Metal {
                    var name: String { get }
                }

                struct Ingot: Metal {
                    let name: String
                }

                // TODO: Return an Ingot named "Iron"
                func makeMetal() -> some Metal {
                }

                let metal = makeMetal()
                print("Metal: \\(metal.name)")
                """,
            expectedOutput: "Metal: Iron",
            hints: [
                "Return a concrete type that conforms to Metal.",
                "Use the name property when printing.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonAdvancedGenericsBasics,
            solution: """
protocol Metal {
    var name: String { get }
}

struct Ingot: Metal {
    let name: String
}

func makeMetal() -> some Metal {
    return Ingot(name: "Iron")
}

let metal = makeMetal()
print("Metal: \\(metal.name)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 194,
            title: "Existentials",
            description: "Store mixed conforming types with any",
            starterCode: """
                // Challenge 194: Existentials
                // Store mixed conforming types with any.

                protocol Sensor {
                    var name: String { get }
                }

                struct TempSensor: Sensor { let name = "Temp" }
                struct PressureSensor: Sensor { let name = "Pressure" }

                func report(_ sensors: [any Sensor]) {
                    // TODO: Print each sensor name on its own line
                }

                let sensors: [any Sensor] = [TempSensor(), PressureSensor()]
                report(sensors)
                """,
            expectedOutput: "Temp\nPressure",
            hints: [
                "any Sensor stores values with different concrete types.",
                "Loop and print the name for each sensor.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonAdvancedGenericsBasics,
            solution: """
protocol Sensor {
    var name: String { get }
}

struct TempSensor: Sensor { let name = "Temp" }
struct PressureSensor: Sensor { let name = "Pressure" }

func report(_ sensors: [any Sensor]) {
    for sensor in sensors {
        print(sensor.name)
    }
}

let sensors: [any Sensor] = [TempSensor(), PressureSensor()]
report(sensors)
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 195,
            title: "Type Erasure",
            description: "Hide concrete types behind a wrapper",
            starterCode: """
                // Challenge 195: Type Erasure
                // Hide concrete types behind a wrapper.

                protocol Reader {
                    func read() -> Int
                }

                struct FixedReader: Reader {
                    let value: Int
                    func read() -> Int { value }
                }

                struct AnyReader: Reader {
                    private let _read: () -> Int

                    // TODO: Add init that stores the base reader's read method
                    // TODO: Implement read() to call the stored closure
                }

                let readers: [AnyReader] = [AnyReader(FixedReader(value: 3)), AnyReader(FixedReader(value: 4))]
                let total = readers.reduce(0) { $0 + $1.read() }
                print("Sum: \\(total)")
                """,
            expectedOutput: "Sum: 7",
            hints: [
                "Capture the base.read method in the initializer.",
                "read() should call the stored closure.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonAdvancedGenericsBasics,
            solution: """
protocol Reader {
    func read() -> Int
}

struct FixedReader: Reader {
    let value: Int
    func read() -> Int { value }
}

struct AnyReader: Reader {
    private let _read: () -> Int

    init<R: Reader>(_ base: R) {
        _read = base.read
    }

    func read() -> Int {
        return _read()
    }
}

let readers: [AnyReader] = [AnyReader(FixedReader(value: 3)), AnyReader(FixedReader(value: 4))]
let total = readers.reduce(0) { $0 + $1.read() }
print("Sum: \\(total)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 196,
            title: "Primary Associated Types",
            description: "Use generic protocol syntax",
            starterCode: """
                // Challenge 196: Primary Associated Types
                // Use generic protocol syntax.

                protocol Stack<Element> {
                    associatedtype Element
                    var items: [Element] { get }
                }

                struct IntStack: Stack {
                    let items: [Int]
                }

                let stack: any Stack<Int> = IntStack(items: [1, 2, 3])
                // TODO: Print the top item as "Top: 3"
                """,
            expectedOutput: "Top: 3",
            hints: [
                "A primary associated type lets you write Stack<Int>.",
                "Use items.last to get the top value.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonAdvancedGenericsBasics,
            solution: """
protocol Stack<Element> {
    associatedtype Element
    var items: [Element] { get }
}

struct IntStack: Stack {
    let items: [Int]
}

let stack: any Stack<Int> = IntStack(items: [1, 2, 3])
print("Top: \\(stack.items.last ?? 0)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 197,
            title: "Where Clauses",
            description: "Add extra generic constraints",
            starterCode: """
                // Challenge 197: Where Clauses
                // Add extra generic constraints.

                // TODO: Write areEqual(_:_:), constrained to Equatable, that returns Bool
                // TODO: Print the result of areEqual(4, 4)
                """,
            expectedOutput: "true",
            hints: [
                "Use a where clause or a generic constraint on the function.",
                "Return the equality check result.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonAdvancedGenericsBasics,
            solution: """
func areEqual<T>(_ a: T, _ b: T) -> Bool where T: Equatable {
    return a == b
}

print(areEqual(4, 4))
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 198,
            title: "Copy-on-Write",
            description: "Observe value semantics in collections",
            starterCode: """
                // Challenge 198: Copy-on-Write
                // Observe value semantics in collections.

                var first = [1, 2]
                var second = first

                // TODO: Append 3 to second
                // TODO: Print first.count then second.count
                """,
            expectedOutput: "2\n3",
            hints: [
                "Arrays copy on write when mutated.",
                "Update second, then print both counts.",
            ],
            cheatsheet: cheatsheetPerformance,
            lesson: lessonPerformanceBasics,
            solution: """
var first = [1, 2]
var second = first

second.append(3)

print(first.count)
print(second.count)
""",
            constraintProfile: crustBaselineProfile,
            topic: .performance,
        ),
        Challenge(
            number: 199,
            title: "MemoryLayout",
            description: "Inspect type sizes",
            starterCode: """
                // Challenge 199: MemoryLayout
                // Inspect type sizes.

                // TODO: Print MemoryLayout<UInt8>.size
                // TODO: Print MemoryLayout<Bool>.size
                """,
            expectedOutput: "1\n1",
            hints: [
                "MemoryLayout<T>.size returns the size in bytes.",
                "Use the same pattern for both types.",
            ],
            cheatsheet: cheatsheetPerformance,
            lesson: lessonPerformanceBasics,
            solution: """
print(MemoryLayout<UInt8>.size)
print(MemoryLayout<Bool>.size)
""",
            constraintProfile: crustBaselineProfile,
            topic: .memory,
        ),
        Challenge(
            number: 200,
            title: "Profiling Mindset",
            description: "Measure before optimizing",
            starterCode: """
                // Challenge 200: Profiling Mindset
                // Measure before optimizing.
                // Use a fixed elapsed value for deterministic output.
                //
                // Expected output:
                // Total: 5000050000
                // Elapsed: 0.00

                import Foundation

                var total = 0
                for value in 1...100_000 {
                    total += value
                }
                let elapsed = 0.0

                // TODO: Print total and elapsed time (format is up to you)
                // Example: "Total: 5000050000" and "Elapsed: 0.00"
                """,
            expectedOutput: "Total: 5000050000\nElapsed: 0.00",
            hints: [
                "Use string interpolation to show the elapsed time.",
                "Print the total first, then the elapsed line.",
            ],
            cheatsheet: cheatsheetPerformance,
            lesson: lessonPerformanceBasics,
            solution: """
import Foundation

var total = 0
for value in 1...100_000 {
    total += value
}
let elapsed = 0.0

print("Total: \\(total)")
print(String(format: "Elapsed: %.2f", elapsed))
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .performance,
        ),
        Challenge(
            number: 201,
            title: "Custom Operators",
            description: "Define a new infix operator",
            starterCode: """
                // Challenge 201: Custom Operators
                // Define a new infix operator.

                // TODO: Declare infix operator +++ with AdditionPrecedence
                // TODO: Implement +++ for Int that adds two values
                // TODO: Print the result of 3 +++ 4
                """,
            expectedOutput: "7",
            hints: [
                "Use infix operator and a matching function implementation.",
                "The operator function should return an Int.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonAdvancedFeaturesBasics,
            solution: """
infix operator +++: AdditionPrecedence

func +++ (lhs: Int, rhs: Int) -> Int {
    return lhs + rhs
}

print(3 +++ 4)
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 202,
            title: "Custom Subscripts",
            description: "Add a subscript with two parameters",
            starterCode: """
                // Challenge 202: Custom Subscripts
                // Add a subscript with two parameters.

                struct Grid {
                    let values: [[Int]]
                    // TODO: Add subscript(_:_:) -> Int
                }

                let grid = Grid(values: [[1, 2], [4, 5]])
                print(grid[1, 0])
                """,
            expectedOutput: "4",
            hints: [
                "Subscripts can accept multiple parameters.",
                "Return values[row][col] inside the subscript.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonAdvancedFeaturesBasics,
            solution: """
struct Grid {
    let values: [[Int]]
    subscript(_ row: Int, _ col: Int) -> Int {
        return values[row][col]
    }
}

let grid = Grid(values: [[1, 2], [4, 5]])
print(grid[1, 0])
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 203,
            title: "dynamicMemberLookup",
            description: "Forward unknown members",
            starterCode: """
                // Challenge 203: dynamicMemberLookup
                // Forward unknown members.

                @dynamicMemberLookup
                struct Settings {
                    var values: [String: String]
                    // TODO: Add dynamicMember subscript returning String
                }

                let settings = Settings(values: ["mode": "safe", "level": "3"])
                print(settings.mode)
                print(settings.level)
                """,
            expectedOutput: "safe\n3",
            hints: [
                "dynamicMemberLookup requires a dynamicMember subscript.",
                "Return values[member] with a default if missing.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonAdvancedFeaturesBasics,
            solution: """
@dynamicMemberLookup
struct Settings {
    var values: [String: String]
    subscript(dynamicMember member: String) -> String {
        return values[member, default: ""]
    }
}

let settings = Settings(values: ["mode": "safe", "level": "3"])
print(settings.mode)
print(settings.level)
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 204,
            title: "dynamicCallable",
            description: "Forward calls to a type",
            starterCode: """
                // Challenge 204: dynamicCallable
                // Forward calls to a type.

                @dynamicCallable
                struct Multiplier {
                    // TODO: Implement dynamicallyCall(withArguments:) -> Int
                }

                let multiply = Multiplier()
                print(multiply(2, 3, 4))
                """,
            expectedOutput: "24",
            hints: [
                "dynamicallyCall receives an array of arguments.",
                "Multiply all values in the array.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonAdvancedFeaturesBasics,
            solution: """
@dynamicCallable
struct Multiplier {
    func dynamicallyCall(withArguments args: [Int]) -> Int {
        return args.reduce(1, *)
    }
}

let multiply = Multiplier()
print(multiply(2, 3, 4))
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 205,
            title: "Result Builders (Use)",
            description: "Build values with a result builder",
            starterCode: """
                // Challenge 205: Result Builders (Use)
                // Build values with a result builder.

                @resultBuilder
                struct MessageBuilder {
                    static func buildBlock(_ components: String...) -> [String] {
                        return components
                    }
                }

                func makeMessages(@MessageBuilder _ content: () -> [String]) -> [String] {
                    return content()
                }

                // TODO: Use makeMessages to build ["Forge", "Ready"]
                // TODO: Print "Forge Ready"
                """,
            expectedOutput: "Forge Ready",
            hints: [
                "The builder collects string literals into an array.",
                "Join the pieces with a separator before printing.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonAdvancedFeaturesBasics,
            solution: """
@resultBuilder
struct MessageBuilder {
    static func buildBlock(_ components: String...) -> [String] {
        return components
    }
}

func makeMessages(@MessageBuilder _ content: () -> [String]) -> [String] {
    return content()
}

let messages = makeMessages {
    "Forge"
    "Ready"
}

print(messages.joined(separator: " "))
""",
            constraintProfile: crustBaselineProfile,
            introduces: [.resultBuilders],
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 206,
            title: "Macros (Usage)",
            description: "Review how macro usage looks in Swift",
            starterCode: """
                // Challenge 206: Macros (Usage)
                // Macros expand at compile time.
                //
                // Expected output: Macro: compile-time code generation

                // TODO: Print "Macro: compile-time code generation"
                """,
            expectedOutput: "Macro: compile-time code generation",
            hints: [
                "Macros expand at compile time.",
                "Output a short summary of what macros do.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonMacrosBasics,
            solution: """
print("Macro: compile-time code generation")
""",
            constraintProfile: crustBaselineProfile,
            introduces: [.macros],
            topic: .macros,
        ),
        Challenge(
            number: 207,
            title: "SwiftPM Basics",
            description: "Read Package.swift for target types",
            starterCode: """
                // Challenge 207: SwiftPM Basics
                // Expected output: Targets: forge, forgeTests

                // TODO: Print "Targets: forge, forgeTests"
                """,
            expectedOutput: "Targets: forge, forgeTests",
            hints: [
                "Package.swift lists executable and test targets.",
                "Report the target names in a single line.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            lesson: lessonSwiftPMBasics,
            solution: """
print("Targets: forge, forgeTests")
""",
            constraintProfile: crustBaselineProfile,
            introduces: [.swiftpmBasics],
            topic: .swiftpm,
        ),
        Challenge(
            number: 208,
            title: "Dependencies & Imports",
            description: "Identify modules and dependencies",
            starterCode: """
                // Challenge 208: Dependencies & Imports
                // Expected output: Dependencies: none

                // TODO: Print "Dependencies: none"
                """,
            expectedOutput: "Dependencies: none",
            hints: [
                "Package.swift lists dependencies near the top.",
                "Summarize the dependency situation in one line.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            lesson: lessonSwiftPMBasics,
            solution: """
print("Dependencies: none")
""",
            constraintProfile: crustBaselineProfile,
            introduces: [.swiftpmDependencies],
            topic: .swiftpm,
        ),
        Challenge(
            number: 209,
            title: "Build Configs & Flags",
            description: "Print the active build configuration",
            starterCode: """
                // Challenge 209: Build Configs & Flags
                // Print the active build configuration.
                // Note: Running with `swift` uses release-style flags, so DEBUG is not set.

                // TODO: Use #if DEBUG to print "Debug", otherwise "Release"
                """,
            expectedOutput: "Release",
            hints: [
                "#if DEBUG is true in debug builds.",
                "Scripts run without DEBUG, so the release branch should print.",
            ],
            cheatsheet: cheatsheetPerformance,
            lesson: lessonSwiftPMBasics,
            solution: """
                #if DEBUG
                print("Debug")
                #else
                print("Release")
                #endif
                """,
            constraintProfile: crustBaselineProfile,
            introduces: [.buildConfigs],
            topic: .swiftpm,
        ),
        Challenge(
            number: 210,
            title: "Integration Challenge",
            description: "Plan a SwiftPM feature module",
            starterCode: """
                // Challenge 210: Integration Challenge
                // Prereqs: SwiftPM basics, dependencies, build configs.
                //
                // Expected output: Module: AnalyticsKit

                // TODO: Print "Module: AnalyticsKit"
                """,
            expectedOutput: "Module: AnalyticsKit",
            hints: [
                "Pick a small feature you could isolate into a module.",
                "Use the provided module name.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            lesson: lessonSwiftPMBasics,
            solution: """
print("Module: AnalyticsKit")
""",
            constraintProfile: crustBaselineProfile,
            requires: [.swiftpmBasics, .swiftpmDependencies, .buildConfigs],
            topic: .swiftpm,
        ),
        Challenge(
            number: 211,
            title: "Macro Authoring (Concepts)",
            description: "Review how macro authoring works",
            starterCode: """
                // Challenge 211: Macro Authoring (Concepts)
                // Expected output: Macro author: provides expansion code

                // TODO: Print "Macro author: provides expansion code"
                """,
            expectedOutput: "Macro author: provides expansion code",
            hints: [
                "Macro authors write code that generates code at compile time.",
                "Provide a concise summary of the authoring role.",
            ],
            cheatsheet: cheatsheetMacros,
            lesson: lessonMacrosBasics,
            solution: """
print("Macro author: provides expansion code")
""",
            constraintProfile: crustBaselineProfile,
            topic: .macros,
        ),
        Challenge(
            number: 212,
            title: "Reflection",
            description: "Inspect values with Mirror",
            starterCode: """
                // Challenge 212: Reflection
                // Inspect values with Mirror.

                struct ForgeLog {
                    let metal: String
                    let heat: Int
                }

                let log = ForgeLog(metal: "Iron", heat: 1200)
                let mirror = Mirror(reflecting: log)

                // TODO: Print each child label on its own line
                """,
            expectedOutput: "metal\nheat",
            hints: [
                "Mirror.children yields label/value pairs.",
                "Print the label for each child.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonAdvancedFeaturesBasics,
            solution: """
struct ForgeLog {
    let metal: String
    let heat: Int
}

let log = ForgeLog(metal: "Iron", heat: 1200)
let mirror = Mirror(reflecting: log)

for child in mirror.children {
    if let label = child.label {
        print(label)
    }
}
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 213,
            title: "Witness Tables (Concepts)",
            description: "Understand protocol witness tables",
            starterCode: """
                // Challenge 213: Witness Tables (Concepts)
                // Expected output: Witness tables map protocol implementations

                // TODO: Print "Witness tables map protocol implementations"
                """,
            expectedOutput: "Witness tables map protocol implementations",
            hints: [
                "Witness tables map protocol requirements to implementations.",
                "Provide a one-line summary of the concept.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonAdvancedGenericsBasics,
            solution: """
print("Witness tables map protocol implementations")
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
        ),
        Challenge(
            number: 214,
            title: "MVVM vs MVC",
            description: "Sketch a simple ViewModel",
            starterCode: """
                // Challenge 214: MVVM vs MVC
                // Sketch a simple ViewModel.

                struct FurnaceModel {
                    let heat: Int
                }

                struct FurnaceViewModel {
                    let model: FurnaceModel
                    // TODO: Add a computed property status returning "Ready" when heat >= 1200
                }

                let viewModel = FurnaceViewModel(model: FurnaceModel(heat: 1300))
                print("Status: \\(viewModel.status)")
                """,
            expectedOutput: "Status: Ready",
            hints: [
                "ViewModels map model data into display-ready values.",
                "Return a string based on the model's heat.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonArchitecturePatterns,
            solution: """
struct FurnaceModel {
    let heat: Int
}

struct FurnaceViewModel {
    let model: FurnaceModel
    var status: String {
        return model.heat >= 1200 ? "Ready" : "Cold"
    }
}

let viewModel = FurnaceViewModel(model: FurnaceModel(heat: 1300))
print("Status: \\(viewModel.status)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 215,
            title: "Dependency Injection",
            description: "Inject a dependency via protocol",
            starterCode: """
                // Challenge 215: Dependency Injection
                // Inject a dependency via protocol.

                protocol Logger {
                    func log(_ message: String)
                }

                struct ConsoleLogger: Logger {
                    func log(_ message: String) {
                        print(message)
                    }
                }

                struct ForgeService {
                    let logger: any Logger
                    // TODO: Add a start() method that logs "Forge started"
                }

                let service = ForgeService(logger: ConsoleLogger())
                // TODO: Call service.start()
                """,
            expectedOutput: "Forge started",
            hints: [
                "Inject the logger through the initializer or property.",
                "Use logger.log inside start().",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonArchitecturePatterns,
            solution: """
protocol Logger {
    func log(_ message: String)
}

struct ConsoleLogger: Logger {
    func log(_ message: String) {
        print(message)
    }
}

struct ForgeService {
    let logger: any Logger
    func start() {
        logger.log("Forge started")
    }
}

let service = ForgeService(logger: ConsoleLogger())
service.start()
""",
            constraintProfile: crustBaselineProfile,
            introduces: [.dependencyInjection],
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 216,
            title: "Coordinator Pattern",
            description: "Centralize navigation flow",
            starterCode: """
                // Challenge 216: Coordinator Pattern
                // Centralize navigation flow.

                protocol Coordinator {
                    func start()
                }

                struct AppCoordinator: Coordinator {
                    // TODO: Implement start() to print "Start"
                }

                let coordinator = AppCoordinator()
                coordinator.start()
                """,
            expectedOutput: "Start",
            hints: [
                "Coordinators expose a start() method.",
                "Print a simple marker string.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonArchitecturePatterns,
            solution: """
protocol Coordinator {
    func start()
}

struct AppCoordinator: Coordinator {
    func start() {
        print("Start")
    }
}

let coordinator = AppCoordinator()
coordinator.start()
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 217,
            title: "Repository Pattern",
            description: "Separate data access from logic",
            starterCode: """
                // Challenge 217: Repository Pattern
                // Separate data access from logic.

                protocol InventoryRepository {
                    func loadItems() -> [String]
                }

                struct MemoryInventoryRepository: InventoryRepository {
                    let items: [String]
                    func loadItems() -> [String] { items }
                }

                struct InventoryService {
                    let repository: any InventoryRepository
                    // TODO: Add count() -> Int that returns item count
                }

                let service = InventoryService(repository: MemoryInventoryRepository(items: ["Iron", "Gold"]))
                print("Count: \\(service.count())")
                """,
            expectedOutput: "Count: 2",
            hints: [
                "Call repository.loadItems inside count().",
                "Return the count of the items array.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonArchitecturePatterns,
            solution: """
protocol InventoryRepository {
    func loadItems() -> [String]
}

struct MemoryInventoryRepository: InventoryRepository {
    let items: [String]
    func loadItems() -> [String] { items }
}

struct InventoryService {
    let repository: any InventoryRepository
    func count() -> Int {
        return repository.loadItems().count
    }
}

let service = InventoryService(repository: MemoryInventoryRepository(items: ["Iron", "Gold"]))
print("Count: \\(service.count())")
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 218,
            title: "Protocol Mocking",
            description: "Swap in a mock for testing",
            starterCode: """
                // Challenge 218: Protocol Mocking
                // Swap in a mock for testing.

                protocol Clock {
                    func now() -> Int
                }

                struct MockClock: Clock {
                    let value: Int
                    func now() -> Int { value }
                }

                func report(_ clock: any Clock) {
                    // TODO: Print "Now: <value>"
                }

                report(MockClock(value: 5))
                """,
            expectedOutput: "Now: 5",
            hints: [
                "Mocks return a fixed value for predictable output.",
                "Call clock.now() inside report().",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonArchitecturePatterns,
            solution: """
protocol Clock {
    func now() -> Int
}

struct MockClock: Clock {
    let value: Int
    func now() -> Int { value }
}

func report(_ clock: any Clock) {
    print("Now: \\(clock.now())")
}

report(MockClock(value: 5))
""",
            constraintProfile: crustBaselineProfile,
            introduces: [.protocolMocking],
            topic: .protocols,
        ),
        Challenge(
            number: 219,
            title: "TDD Cycle (Concepts)",
            description: "Recall red/green/refactor",
            starterCode: """
                // Challenge 219: TDD Cycle (Concepts)
                // Expected output: TDD: Red, Green, Refactor

                // TODO: Print "TDD: Red, Green, Refactor"
                """,
            expectedOutput: "TDD: Red, Green, Refactor",
            hints: [
                "Red: failing test; Green: make it pass; Refactor: clean up.",
                "Output the phase names in order.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonTestingBasics,
            solution: """
print("TDD: Red, Green, Refactor")
""",
            constraintProfile: crustBaselineProfile,
            topic: .testing,
        ),
        Challenge(
            number: 220,
            title: "Async Testing (Concepts)",
            description: "Review async XCTest patterns",
            starterCode: """
                // Challenge 220: Async Testing (Concepts)
                // Expected output: Async tests can await in XCTest

                // TODO: Print "Async tests can await in XCTest"
                """,
            expectedOutput: "Async tests can await in XCTest",
            hints: [
                "XCTest supports async test methods with async/await.",
                "Summarize the async testing capability in one line.",
            ],
            cheatsheet: cheatsheetMacros,
            lesson: lessonTestingBasics,
            solution: """
print("Async tests can await in XCTest")
""",
            constraintProfile: crustBaselineProfile,
            topic: .testing,
        ),
        Challenge(
            number: 221,
            title: "UI Testing (Concepts)",
            description: "Recall UI testing focus",
            starterCode: """
                // Challenge 221: UI Testing (Concepts)
                // Expected output: UI tests verify user flows

                // TODO: Print "UI tests verify user flows"
                """,
            expectedOutput: "UI tests verify user flows",
            hints: [
                "UI tests simulate user flows and verify visible outcomes.",
                "Summarize the UI testing focus in one line.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonTestingBasics,
            solution: """
print("UI tests verify user flows")
""",
            constraintProfile: crustBaselineProfile,
            topic: .testing,
        ),
        Challenge(
            number: 222,
            title: "Unsafe Pointers",
            description: "Access memory with an unsafe pointer",
            starterCode: """
                // Challenge 222: Unsafe Pointers
                // Access memory with an unsafe pointer.

                var value = 42

                // TODO: Use withUnsafePointer(to:) to print the value
                """,
            expectedOutput: "42",
            hints: [
                "withUnsafePointer passes a pointer to a closure.",
                "Use pointer.pointee to read the value.",
            ],
            cheatsheet: cheatsheetPerformance,
            lesson: lessonPerformanceBasics,
            solution: """
var value = 42

withUnsafePointer(to: &value) { pointer in
    print(pointer.pointee)
}
""",
            constraintProfile: crustBaselineProfile,
            topic: .memory,
        ),
        Challenge(
            number: 223,
            title: "C Interop (Concepts)",
            description: "Recall how C interop works",
            starterCode: """
                // Challenge 223: C Interop (Concepts)
                // Expected output: C interop uses module maps

                // TODO: Print "C interop uses module maps"
                """,
            expectedOutput: "C interop uses module maps",
            hints: [
                "Swift can import C APIs via module maps or bridging headers.",
                "Summarize how C interop is wired.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            lesson: lessonInteropBasics,
            solution: """
print("C interop uses module maps")
""",
            constraintProfile: crustBaselineProfile,
            topic: .interop,
        ),
        Challenge(
            number: 224,
            title: "Objective-C Interop (Concepts)",
            description: "Recall Obj-C bridging basics",
            starterCode: """
                // Challenge 224: Objective-C Interop (Concepts)
                // Expected output: @objc and bridging headers

                // TODO: Print "@objc and bridging headers"
                """,
            expectedOutput: "@objc and bridging headers",
            hints: [
                "@objc exposes Swift to Obj-C; bridging headers import Obj-C to Swift.",
                "Summarize the interop mechanism in one line.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            lesson: lessonInteropBasics,
            solution: """
print("@objc and bridging headers")
""",
            constraintProfile: crustBaselineProfile,
            topic: .interop,
        ),
        Challenge(
            number: 225,
            title: "LLDB Tactics (Concepts)",
            description: "Recall common debugger commands",
            starterCode: """
                // Challenge 225: LLDB Tactics (Concepts)
                // Expected output: LLDB: po, bt

                // TODO: Print "LLDB: po, bt"
                """,
            expectedOutput: "LLDB: po, bt",
            hints: [
                "Examples: breakpoint set, po, bt.",
                "Provide a short list of common commands.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonDebuggingBasics,
            solution: """
print("LLDB: po, bt")
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 226,
            title: "Diagnostics",
            description: "Surface errors with context",
            starterCode: """
                // Challenge 226: Diagnostics
                // Surface errors with context.

                enum ForgeError: Error {
                    case overheated
                }

                func checkHeat(_ value: Int) throws {
                    if value > 2000 {
                        throw ForgeError.overheated
                    }
                }

                do {
                    try checkHeat(2200)
                    print("OK")
                } catch {
                    // TODO: Print "Error: overheating"
                }
                """,
            expectedOutput: "Error: overheating",
            hints: [
                "The catch block handles thrown errors.",
                "Print a clear message for the failure case.",
            ],
            cheatsheet: cheatsheetErrors,
            lesson: lessonErrorsBasics,
            solution: """
enum ForgeError: Error {
    case overheated
}

func checkHeat(_ value: Int) throws {
    if value > 2000 {
        throw ForgeError.overheated
    }
}

 do {
    try checkHeat(2200)
    print("OK")
} catch {
    print("Error: overheating")
}
""",
            constraintProfile: crustBaselineProfile,
            requires: [.doCatch, .throwKeyword, .tryKeyword],
            topic: .errors,
        ),
        Challenge(
            number: 227,
            title: "Git Workflows (Concepts)",
            description: "Recall basic Git workflow steps",
            starterCode: """
                // Challenge 227: Git Workflows (Concepts)
                // Expected output: Git: branch, commit, push, PR

                // TODO: Print "Git: branch, commit, push, PR"
                """,
            expectedOutput: "Git: branch, commit, push, PR",
            hints: [
                "Example: branch -> commit -> push -> PR.",
                "Summarize the workflow sequence.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonGitBasics,
            solution: """
print("Git: branch, commit, push, PR")
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
        ),
        Challenge(
            number: 228,
            title: "Integration Challenge",
            description: "Combine DI and protocol testing",
            starterCode: """
                // Challenge 228: Integration Challenge
                // Combine DI and protocol testing.
                // Prereqs: protocols, dependency injection, protocol mocking.

                protocol DataSource {
                    func values() -> [Int]
                }

                struct MemorySource: DataSource {
                    let items: [Int]
                    func values() -> [Int] { items }
                }

                struct Analyzer {
                    let source: DataSource
                    // TODO: Add sum() -> Int that totals the source values
                }

                let analyzer = Analyzer(source: MemorySource(items: [1, 2, 3]))
                print("Sum: \\(analyzer.sum())")
                """,
            expectedOutput: "Sum: 6",
            hints: [
                "Call source.values() and sum the results.",
                "Return the total from sum().",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            lesson: lessonArchitecturePatterns,
            solution: """
protocol DataSource {
    func values() -> [Int]
}

struct MemorySource: DataSource {
    let items: [Int]
    func values() -> [Int] { items }
}

struct Analyzer {
    let source: DataSource
    func sum() -> Int {
        return source.values().reduce(0, +)
    }
}

let analyzer = Analyzer(source: MemorySource(items: [1, 2, 3]))
print("Sum: \\(analyzer.sum())")
""",
            constraintProfile: crustBaselineProfile,
            requires: [.protocols, .dependencyInjection, .protocolMocking, .reduce],
            topic: .protocols,
        ),
        Challenge(
            number: 229,
            id: "crust-extra-async-sleep",
            title: "Async Sleep",
            description: "Pause an async task before printing",
            starterCode: """
                // Challenge 229: Async Sleep
                // Pause an async task before printing.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                runAsync {
                    // TODO: Sleep briefly with Task.sleep
                    // TODO: Print "Done"
                }
                """,
            expectedOutput: "Done",
            hints: [
                "Task.sleep is async and can be called with try? await.",
                "Print after the sleep call.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

runAsync {
    try? await Task.sleep(nanoseconds: 50_000_000)
    print("Done")
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            introduces: [.taskSleep],
            topic: .concurrency,
            tier: .extra
        ),
        Challenge(
            number: 230,
            id: "crust-extra-actor-balance",
            title: "Actor Balance",
            description: "Update actor state safely",
            starterCode: """
                // Challenge 230: Actor Balance
                // Update actor state safely.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                actor Ledger {
                    private var balance = 0
                    // TODO: Add add(_:) and current() methods
                }

                let ledger = Ledger()
                runAsync {
                    // TODO: Add 3 and 4, then print "Balance: 7"
                }
                """,
            expectedOutput: "Balance: 7",
            hints: [
                "Actor methods are called with await.",
                "Print the balance after both updates.",
            ],
            cheatsheet: cheatsheetActors,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

actor Ledger {
    private var balance = 0

    func add(_ value: Int) {
        balance += value
    }

    func current() -> Int {
        return balance
    }
}

let ledger = Ledger()
runAsync {
    await ledger.add(3)
    await ledger.add(4)
    let value = await ledger.current()
    print("Balance: \\(value)")
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .actors,
            tier: .extra
        ),
        Challenge(
            number: 231,
            id: "crust-extra-sendable-snapshot",
            title: "Sendable Snapshot",
            description: "Move values across tasks safely",
            starterCode: """
                // Challenge 231: Sendable Snapshot
                // Move values across tasks safely.

                struct Snapshot: Sendable {
                    let values: [Int]
                }

                let snapshot = Snapshot(values: [1, 2, 3])
                // TODO: Print "Count: 3"
                """,
            expectedOutput: "Count: 3",
            hints: [
                "Sendable marks the struct as safe for concurrency.",
                "Use values.count in the output.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
struct Snapshot: Sendable {
    let values: [Int]
}

let snapshot = Snapshot(values: [1, 2, 3])
print("Count: \\(snapshot.values.count)")
""",
            constraintProfile: ConstraintProfile(
                allowConcurrency: true
            ),
            topic: .concurrency,
            tier: .extra
        ),
        Challenge(
            number: 232,
            id: "crust-extra-keypath-average",
            title: "KeyPath Average",
            description: "Compute an average using key paths",
            starterCode: """
                // Challenge 232: KeyPath Average
                // Compute an average using key paths.

                struct Ore {
                    let name: String
                    let purity: Int
                }

                let ores = [
                    Ore(name: "Iron", purity: 70),
                    Ore(name: "Gold", purity: 90),
                ]

                // TODO: Map purity values with a key path
                // TODO: Print "Average: 80"
                """,
            expectedOutput: "Average: 80",
            hints: [
                "Use ores.map(\\.purity) to extract values.",
                "Average is sum / count with Int math.",
            ],
            cheatsheet: cheatsheetKeyPaths,
            solution: """
struct Ore {
    let name: String
    let purity: Int
}

let ores = [
    Ore(name: "Iron", purity: 70),
    Ore(name: "Gold", purity: 90),
]

let values = ores.map(\\.purity)
let average = values.reduce(0, +) / values.count
print("Average: \\(average)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .keyPaths,
            tier: .extra
        ),
        Challenge(
            number: 233,
            id: "crust-extra-lazy-even-sum",
            title: "Lazy Even Sum",
            description: "Filter and sum with lazy",
            starterCode: """
                // Challenge 233: Lazy Even Sum
                // Filter and sum with lazy.

                let numbers = [1, 2, 3, 4, 5, 6]

                // TODO: Use lazy to keep even numbers
                // TODO: Multiply each by 10
                // TODO: Print "Total: 120"
                """,
            expectedOutput: "Total: 120",
            hints: [
                "Use lazy.filter then lazy.map before reducing.",
                "Sum the transformed values to match the total.",
            ],
            cheatsheet: cheatsheetSequences,
            solution: """
let numbers = [1, 2, 3, 4, 5, 6]

let total = numbers.lazy
    .filter { $0 % 2 == 0 }
    .map { $0 * 10 }
    .reduce(0, +)

print("Total: \\(total)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .sequences,
            tier: .extra
        ),
        Challenge(
            number: 234,
            id: "crust-extra-generic-max",
            title: "Generic Max",
            description: "Compare values with generics",
            starterCode: """
                // Challenge 234: Generic Max
                // Compare values with generics.

                // TODO: Write maxValue<T: Comparable>(_:_:) -> T
                // TODO: Print maxValue(4, 9)
                """,
            expectedOutput: "9",
            hints: [
                "Return a if a > b, otherwise b.",
                "Use a generic constraint on Comparable.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            solution: """
func maxValue<T: Comparable>(_ a: T, _ b: T) -> T {
    return a > b ? a : b
}

print(maxValue(4, 9))
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 235,
            id: "crust-extra-anysequence",
            title: "AnySequence",
            description: "Erase sequence types",
            starterCode: """
                // Challenge 235: AnySequence
                // Erase sequence types.

                func makeSequence() -> AnySequence<Int> {
                    // TODO: Return AnySequence with [1, 2, 3]
                }

                let sequence = makeSequence()
                let items = Array(sequence)
                print("Count: \\(items.count)")
                """,
            expectedOutput: "Count: 3",
            hints: [
                "Wrap the array with AnySequence(...).",
                "Materialize the sequence to count it.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            solution: """
func makeSequence() -> AnySequence<Int> {
    return AnySequence([1, 2, 3])
}

let sequence = makeSequence()
let items = Array(sequence)
print("Count: \\(items.count)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .sequences,
            tier: .extra
        ),
        Challenge(
            number: 236,
            id: "crust-extra-dynamicmemberlookup-extra",
            title: "dynamicMemberLookup Extra",
            description: "Provide default values",
            starterCode: """
                // Challenge 236: dynamicMemberLookup Extra
                // Provide default values.

                @dynamicMemberLookup
                struct Defaults {
                    var values: [String: Int]
                    // TODO: Add dynamicMember subscript returning Int
                }

                let defaults = Defaults(values: ["limit": 5])
                print("Limit: \\(defaults.limit)")
                print("Missing: \\(defaults.missing)")
                """,
            expectedOutput: "Limit: 5\nMissing: 0",
            hints: [
                "Return values[member, default: 0].",
                "The missing key should return 0.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            solution: """
@dynamicMemberLookup
struct Defaults {
    var values: [String: Int]
    subscript(dynamicMember member: String) -> Int {
        return values[member, default: 0]
    }
}

let defaults = Defaults(values: ["limit": 5])
print("Limit: \\(defaults.limit)")
print("Missing: \\(defaults.missing)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
            tier: .extra
        ),
        Challenge(
            number: 237,
            id: "crust-extra-dynamiccallable-keywords",
            title: "dynamicCallable Keywords",
            description: "Sum keyword arguments",
            starterCode: """
                // Challenge 237: dynamicCallable Keywords
                // Sum keyword arguments.

                @dynamicCallable
                struct KeyedAdder {
                    // TODO: Implement dynamicallyCall(withKeywordArguments:)
                }

                let adder = KeyedAdder()
                print(adder(a: 1, b: 2, c: 3))
                """,
            expectedOutput: "6",
            hints: [
                "Keyword arguments arrive as KeyValuePairs.",
                "Sum the values and return the total.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            solution: """
@dynamicCallable
struct KeyedAdder {
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Int {
        return args.reduce(0) { $0 + $1.value }
    }
}

let adder = KeyedAdder()
print(adder(a: 1, b: 2, c: 3))
""",
            constraintProfile: crustBaselineProfile,
            topic: .advancedFeatures,
            tier: .extra
        ),
        Challenge(
            number: 238,
            id: "crust-extra-memorylayout-stride",
            title: "MemoryLayout Stride",
            description: "Inspect stride and alignment",
            starterCode: """
                // Challenge 238: MemoryLayout Stride
                // Inspect stride and alignment.

                // TODO: Print "Stride: 2" and "Alignment: 2" for UInt16
                """,
            expectedOutput: "Stride: 2\nAlignment: 2",
            hints: [
                "Use MemoryLayout<UInt16>.stride and .alignment.",
                "Format the output to include both labels.",
            ],
            cheatsheet: cheatsheetPerformance,
            solution: """
print("Stride: \\(MemoryLayout<UInt16>.stride)")
print("Alignment: \\(MemoryLayout<UInt16>.alignment)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .memory,
            tier: .extra
        ),
        Challenge(
            number: 239,
            id: "crust-extra-unsafe-mutation",
            title: "Unsafe Mutation",
            description: "Update through a pointer",
            starterCode: """
                // Challenge 239: Unsafe Mutation
                // Update through a pointer.

                var value = 5

                // TODO: Use withUnsafeMutablePointer to add 5
                // TODO: Print value (should be 10)
                """,
            expectedOutput: "10",
            hints: [
                "Use pointer.pointee to update the value.",
                "Print after the pointer scope.",
            ],
            cheatsheet: cheatsheetPerformance,
            solution: """
var value = 5

withUnsafeMutablePointer(to: &value) { pointer in
    pointer.pointee += 5
}

print(value)
""",
            constraintProfile: crustBaselineProfile,
            topic: .memory,
            tier: .extra
        ),
        Challenge(
            number: 240,
            id: "crust-extra-where-filter",
            title: "Where Filter",
            description: "Use a constrained extension",
            starterCode: """
                // Challenge 240: Where Filter
                // Use a constrained extension.

                struct Box<T> {
                    let value: T
                }

                extension Box where T == Int {
                    // TODO: Add isEven() -> Bool
                }

                let box = Box(value: 6)
                print(box.isEven())
                """,
            expectedOutput: "true",
            hints: [
                "Add a constrained extension for Int.",
                "Use value % 2 == 0.",
            ],
            cheatsheet: cheatsheetAdvancedGenerics,
            solution: """
struct Box<T> {
    let value: T
}

extension Box where T == Int {
    func isEven() -> Bool {
        return value % 2 == 0
    }
}

let box = Box(value: 6)
print(box.isEven())
""",
            constraintProfile: crustBaselineProfile,
            topic: .generics,
            tier: .extra
        ),
        Challenge(
            number: 252,
            id: "crust-extra-async-let",
            title: "Async Let",
            description: "Run async calls in parallel",
            starterCode: """
                // Challenge 252: Async Let
                // Run async calls in parallel.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                func fetchA() async -> Int {
                    return 2
                }

                func fetchB() async -> Int {
                    return 3
                }

                runAsync {
                    // TODO: Use async let for fetchA and fetchB
                    // TODO: Print "Sum: 5"
                }
                """,
            expectedOutput: "Sum: 5",
            hints: [
                "Use async let to start both calls.",
                "Await both values before summing.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

func fetchA() async -> Int {
    return 2
}

func fetchB() async -> Int {
    return 3
}

runAsync {
    async let a = fetchA()
    async let b = fetchB()
    let sum = await a + b
    print("Sum: \\(sum)")
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .concurrency,
            tier: .extra
        ),
        Challenge(
            number: 253,
            id: "crust-extra-xctest-micro",
            title: "XCTest Micro Example",
            description: "Write a minimal XCTest case (simulated)",
            starterCode: """
                // Challenge 253: XCTest Micro Example
                // Forge includes a tiny XCTest stub so this compiles as a script.
                // Expected output: XCTest ready

                class XCTestCase {}
                func XCTAssertEqual<T: Equatable>(_ lhs: T, _ rhs: T) {}

                // TODO: Create class SampleTests: XCTestCase
                // TODO: Add func testSum() with XCTAssertEqual(2 + 2, 4)

                // TODO: Print "XCTest ready"
                """,
            expectedOutput: "XCTest ready",
            hints: [
                "Subclass XCTestCase for tests.",
                "Use XCTAssertEqual inside testSum().",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            lesson: lessonTestingBasics,
            solution: """
class XCTestCase {}
func XCTAssertEqual<T: Equatable>(_ lhs: T, _ rhs: T) {}

class SampleTests: XCTestCase {
    func testSum() {
        XCTAssertEqual(2 + 2, 4)
    }
}

print("XCTest ready")
""",
            constraintProfile: crustBaselineProfile,
            topic: .testing,
            tier: .extra
        ),
        Challenge(
            number: 292,
            id: "crust-extra-async-warmup",
            title: "Async Warmup",
            description: "Await a simple async value",
            starterCode: """
                // Challenge 292: Async Warmup
                // Await a simple async value.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                func heat() async -> Int {
                    return 1500
                }

                runAsync {
                    // TODO: Await heat() and print "Heat: 1500"
                }
                """,
            expectedOutput: "Heat: 1500",
            hints: [
                "Use await to get the async value.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

func heat() async -> Int {
    return 1500
}

runAsync {
    let value = await heat()
    print("Heat: \\(value)")
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .concurrency,
            tier: .extra
        ),
        Challenge(
            number: 293,
            id: "crust-extra-actor-counter",
            title: "Actor Counter",
            description: "Use an actor for state",
            starterCode: """
                // Challenge 293: Actor Counter
                // Use an actor for state.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                actor Counter {
                    var value = 0
                    func increment() -> Int {
                        value += 1
                        return value
                    }
                }

                runAsync {
                    // TODO: Create a Counter, call increment twice, and print "1 2"
                }
                """,
            expectedOutput: "1 2",
            hints: [
                "Call actor methods with await.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

actor Counter {
    var value = 0
    func increment() -> Int {
        value += 1
        return value
    }
}

runAsync {
    let counter = Counter()
    let first = await counter.increment()
    let second = await counter.increment()
    print("\\(first) \\(second)")
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .actors,
            tier: .extra
        ),
        Challenge(
            number: 294,
            id: "crust-extra-property-wrapper",
            title: "Property Wrapper",
            description: "Clamp a value with a wrapper",
            starterCode: """
                // Challenge 294: Property Wrapper
                // Clamp a value with a wrapper.

                @propertyWrapper
                struct Clamped {
                    private var value: Int
                    init(wrappedValue: Int) {
                        value = min(max(0, wrappedValue), 100)
                    }
                    var wrappedValue: Int {
                        get { value }
                        set { value = min(max(0, newValue), 100) }
                    }
                }

                struct Gauge {
                    @Clamped var pressure: Int
                }

                var gauge = Gauge(pressure: 120)
                // TODO: Print gauge.pressure
                """,
            expectedOutput: "100",
            hints: [
                "The wrapper clamps values between 0 and 100.",
            ],
            cheatsheet: cheatsheetProperties,
            solution: """
@propertyWrapper
struct Clamped {
    private var value: Int
    init(wrappedValue: Int) {
        value = min(max(0, wrappedValue), 100)
    }
    var wrappedValue: Int {
        get { value }
        set { value = min(max(0, newValue), 100) }
    }
}

struct Gauge {
    @Clamped var pressure: Int
}

var gauge = Gauge(pressure: 120)
print(gauge.pressure)
""",
            constraintProfile: crustBaselineProfile,
            topic: .propertyWrappers,
            tier: .extra
        ),
        Challenge(
            number: 295,
            id: "crust-extra-keypath-sort",
            title: "Key Path Sort",
            description: "Sort using a key path",
            starterCode: """
                // Challenge 295: Key Path Sort
                // Sort using a key path.

                struct Alloy {
                    let name: String
                    let purity: Int
                }

                let items = [
                    Alloy(name: "Iron", purity: 80),
                    Alloy(name: "Gold", purity: 95),
                    Alloy(name: "Copper", purity: 60)
                ]

                // TODO: Sort by purity descending using a key path
                // TODO: Print the names joined by ", "
                """,
            expectedOutput: "Gold, Iron, Copper",
            hints: [
                "Use sorted with a closure reading \\Alloy.purity.",
                "Map to names and join with a separator.",
            ],
            cheatsheet: cheatsheetKeyPaths,
            solution: """
let sorted = items.sorted { $0[keyPath: \\Alloy.purity] > $1[keyPath: \\Alloy.purity] }
let names = sorted.map { $0.name }.joined(separator: ", ")
print(names)
""",
            constraintProfile: crustBaselineProfile,
            topic: .keyPaths,
            tier: .extra
        ),
        Challenge(
            number: 296,
            id: "crust-extra-opaque-return",
            title: "Opaque Return",
            description: "Return an opaque protocol type",
            starterCode: """
                // Challenge 296: Opaque Return
                // Return an opaque protocol type.

                protocol HeatSource {
                    var heat: Int { get }
                }

                struct Burner: HeatSource {
                    let heat: Int
                }

                // TODO: Create makeSource() -> some HeatSource
                // TODO: Print makeSource().heat
                """,
            expectedOutput: "1500",
            hints: [
                "Use 'some' for an opaque return type.",
            ],
            cheatsheet: cheatsheetProtocols,
            solution: """
func makeSource() -> some HeatSource {
    return Burner(heat: 1500)
}

print(makeSource().heat)
""",
            constraintProfile: crustBaselineProfile,
            topic: .protocols,
            tier: .extra
        ),
        Challenge(
            number: 297,
            id: "crust-extra-lazy-sequence",
            title: "Lazy Sequence",
            description: "Use lazy chains",
            starterCode: """
                // Challenge 297: Lazy Sequence
                // Use lazy chains to transform data.

                let temps = [1200, 1500, 1600]

                // TODO: Use lazy to filter temps >= 1500 and map to /100
                // TODO: Print the resulting array
                """,
            expectedOutput: "[15, 16]",
            hints: [
                "Use lazy.filter and lazy.map, then Array(...) to materialize.",
            ],
            cheatsheet: cheatsheetCollectionTransforms,
            solution: """
let result = Array(temps.lazy.filter { $0 >= 1500 }.map { $0 / 100 })
print(result)
""",
            constraintProfile: crustBaselineProfile,
            topic: .sequences,
            tier: .extra
        ),
        Challenge(
            number: 298,
            id: "crust-extra-macro-sample",
            title: "Macro Sample",
            description: "Reason about macro expansion (simulated)",
            starterCode: """
                // Challenge 298: Macro Sample
                // Simulate macro output for understanding.

                // Assume a macro expands: #stringify(2 + 2) -> ("2 + 2", 4)
                // TODO: Print "2 + 2 = 4"
                """,
            expectedOutput: "2 + 2 = 4",
            hints: [
                "Just print the expected expansion result.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            solution: """
print("2 + 2 = 4")
""",
            constraintProfile: crustBaselineProfile,
            topic: .macros,
            tier: .extra
        ),
        Challenge(
            number: 299,
            id: "crust-extra-swiftpm-targets",
            title: "SwiftPM Targets",
            description: "Identify targets in a package (simulated)",
            starterCode: """
                // Challenge 299: SwiftPM Targets
                // Simulate SwiftPM target awareness.

                // TODO: Print "Targets: forge, forgeTests"
                """,
            expectedOutput: "Targets: forge, forgeTests",
            hints: [
                "This is a simulated check of package structure.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            solution: """
print("Targets: forge, forgeTests")
""",
            constraintProfile: crustBaselineProfile,
            topic: .swiftpm,
            tier: .extra
        ),
        Challenge(
            number: 300,
            id: "crust-extra-performance-timing",
            title: "Performance Timing",
            description: "Measure elapsed time (simulated)",
            starterCode: """
                // Challenge 300: Performance Timing
                // Simulate a timing measurement.

                import Foundation

                let start = Date()
                let end = start.addingTimeInterval(0.25)

                // TODO: Print "Elapsed: 0.25"
                """,
            expectedOutput: "Elapsed: 0.25",
            hints: [
                "Use end.timeIntervalSince(start) for the elapsed seconds.",
            ],
            cheatsheet: cheatsheetPerformance,
            solution: """
import Foundation

let start = Date()
let end = start.addingTimeInterval(0.25)
print("Elapsed: \\(end.timeIntervalSince(start))")
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .performance,
            tier: .extra
        ),
        Challenge(
            number: 301,
            id: "crust-extra-interop-bridge",
            title: "Interop Bridge",
            description: "Use Foundation bridging types",
            starterCode: """
                // Challenge 301: Interop Bridge
                // Use Foundation bridging types.

                import Foundation

                let name = "Forge"
                let nsName = name as NSString

                // TODO: Print nsName.length
                """,
            expectedOutput: "5",
            hints: [
                "NSString length counts characters.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            solution: """
import Foundation

let name = "Forge"
let nsName = name as NSString
print(nsName.length)
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .interop,
            tier: .extra
        ),
        Challenge(
            number: 302,
            id: "crust-extra-test-assert",
            title: "Test Assert",
            description: "Simulate a tiny test assertion",
            starterCode: """
                // Challenge 302: Test Assert
                // Simulate a tiny test assertion.

                func assertEqual(_ lhs: Int, _ rhs: Int) {
                    if lhs == rhs {
                        print("Pass")
                    } else {
                        print("Fail")
                    }
                }

                // TODO: Call assertEqual(3 + 2, 5)
                """,
            expectedOutput: "Pass",
            hints: [
                "Call the helper with the computed value.",
            ],
            cheatsheet: cheatsheetAdvancedFeatures,
            solution: """
assertEqual(3 + 2, 5)
""",
            constraintProfile: crustBaselineProfile,
            topic: .testing,
            tier: .extra
        ),
        Challenge(
            number: 306,
            id: "crust-extra-error-context",
            title: "Error Context",
            description: "Attach context to a thrown error",
            starterCode: """
                // Challenge 306: Error Context
                // Attach context to a thrown error.

                enum HeatError: Error {
                    case tooLow(Int)
                }

                func checkHeat(_ value: Int) throws {
                    // TODO: Throw tooLow(value) when value < 1000
                }

                do {
                    try checkHeat(900)
                } catch HeatError.tooLow(let value) {
                    // TODO: Print "Too low: 900"
                }
                """,
            expectedOutput: "Too low: 900",
            hints: [
                "Throw the error with the value as context.",
                "Use a specific catch to extract the value.",
            ],
            cheatsheet: cheatsheetErrors,
            solution: """
enum HeatError: Error {
    case tooLow(Int)
}

func checkHeat(_ value: Int) throws {
    if value < 1000 {
        throw HeatError.tooLow(value)
    }
}

do {
    try checkHeat(900)
} catch HeatError.tooLow(let value) {
    print("Too low: \\(value)")
}
""",
            constraintProfile: crustBaselineProfile,
            topic: .errors,
            tier: .extra
        ),
        Challenge(
            number: 307,
            id: "crust-extra-performance-loop",
            title: "Performance Loop",
            description: "Compare loop costs deterministically",
            starterCode: """
                // Challenge 307: Performance Loop
                // Compare loop costs deterministically.
                //
                // Expected output:
                // Total: 15
                // Steps: 5

                var total = 0
                var steps = 0

                // TODO: Loop from 1 to 5
                // TODO: Add each value to total and increment steps
                // TODO: Print total and steps
                """,
            expectedOutput: "Total: 15\nSteps: 5",
            hints: [
                "Track both the total and number of iterations.",
                "Print the totals on separate lines.",
            ],
            cheatsheet: cheatsheetPerformance,
            solution: """
var total = 0
var steps = 0

for value in 1...5 {
    total += value
    steps += 1
}

print("Total: \\(total)")
print("Steps: \\(steps)")
""",
            constraintProfile: crustBaselineProfile,
            topic: .performance,
            tier: .extra
        ),
        Challenge(
            number: 308,
            id: "crust-extra-objc-bridge",
            title: "Objective-C Bridge",
            description: "Bridge Swift to NSString",
            starterCode: """
                // Challenge 308: Objective-C Bridge
                // Bridge Swift to NSString.

                import Foundation

                let name = "Forge"
                // TODO: Convert name to NSString and print its length
                """,
            expectedOutput: "5",
            hints: [
                "Use NSString(name) or name as NSString.",
                "Print the length property.",
            ],
            cheatsheet: cheatsheetSwiftPM,
            solution: """
import Foundation

let name = "Forge"
let nsName = name as NSString
print(nsName.length)
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"]
            ),
            topic: .interop,
            tier: .extra
        ),



    ]
    return challenges.map { $0.withLayer(.crust) }
}

func makeBridgeChallenges() -> (coreToMantle: [Challenge], mantleToCrust: [Challenge]) {
    let coreToMantle = [
        Challenge(
            number: 241,
            title: "Bridge: Struct Snapshot",
            description: "Move from loose values to a struct",
            starterCode: """
                // Bridge Challenge 1: Struct Snapshot
                // Move from loose values to a struct.
                //
                // TODO: Define a struct Snapshot with metal (String) and heat (Int)
                // TODO: Create a snapshot for "Iron" at 1400
                // TODO: Print "Iron @ 1400"
                """,
            expectedOutput: "Iron @ 1400",
            hints: [
                "A struct bundles related values together.",
                "Use its stored properties to form the output line.",
            ],
            cheatsheet: cheatsheetStructs,
            solution: """
struct Snapshot {
    let metal: String
    let heat: Int
}

let snapshot = Snapshot(metal: "Iron", heat: 1400)
print("\\(snapshot.metal) @ \\(snapshot.heat)")
""",
            topic: .structs,
            layer: .mantle
        ),
        Challenge(
            number: 242,
            title: "Bridge: Struct Method",
            description: "Add behavior to a struct",
            starterCode: """
                // Bridge Challenge 2: Struct Method
                // Add behavior to a struct.
                //
                // TODO: Define a struct ForgeLog with metal (String) and heat (Int)
                // TODO: Add a method label() -> String that returns "<metal>: <heat>"
                // TODO: Create a log for "Gold" at 1500 and print label()
                """,
            expectedOutput: "Gold: 1500",
            hints: [
                "Methods can format stored properties into strings.",
                "Call the method on the instance to get the output text.",
            ],
            cheatsheet: cheatsheetStructs,
            solution: """
struct ForgeLog {
    let metal: String
    let heat: Int

    func label() -> String {
        return "\\(metal): \\(heat)"
    }
}

let log = ForgeLog(metal: "Gold", heat: 1500)
print(log.label())
""",
            topic: .structs,
            layer: .mantle
        ),
    ]

    let mantleToCrust = [
        Challenge(
            number: 243,
            title: "Bridge: Async Warmup",
            description: "Call a simple async function",
            starterCode: """
                // Bridge Challenge 3: Async Warmup
                // Call a simple async function.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let semaphore = DispatchSemaphore(value: 0)
                    Task {
                        await operation()
                        semaphore.signal()
                    }

                    while semaphore.wait(timeout: .now()) != .success {
                        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
                    }
                }

                // TODO: Write async func status() -> String that returns "Ready"

                runAsync {
                    // TODO: Await status() and print the result
                }
                """,
            expectedOutput: "Ready",
            hints: [
                "Async functions return values just like sync ones.",
                "Await the result inside the runAsync closure and print it.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await operation()
        semaphore.signal()
    }

    while semaphore.wait(timeout: .now()) != .success {
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
    }
}

func status() async -> String {
    return "Ready"
}

runAsync {
    let value = await status()
    print(value)
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .functions,
            layer: .crust
        ),
        Challenge(
            number: 244,
            title: "Bridge: Task Result",
            description: "Await a Task value",
            starterCode: """
                // Bridge Challenge 4: Task Result
                // Await a Task value.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let semaphore = DispatchSemaphore(value: 0)
                    Task {
                        await operation()
                        semaphore.signal()
                    }

                    while semaphore.wait(timeout: .now()) != .success {
                        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
                    }
                }

                runAsync {
                    // TODO: Start a Task that returns 5
                    // TODO: Await task.value and print "Heat: 5"
                }
                """,
            expectedOutput: "Heat: 5",
            hints: [
                "Task { 5 } creates a task that returns an Int.",
                "Await task.value to get the result before printing.",
            ],
            cheatsheet: cheatsheetConcurrency,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await operation()
        semaphore.signal()
    }

    while semaphore.wait(timeout: .now()) != .success {
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
    }
}

runAsync {
    let task = Task { 5 }
    let value = await task.value
    print("Heat: \\(value)")
}
""",
            constraintProfile: ConstraintProfile(
                allowedImports: ["Foundation"],
                allowConcurrency: true
            ),
            topic: .functions,
            layer: .crust
        ),
    ]

    return (coreToMantle, mantleToCrust)
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
                // - Takes one Int parameter (Celsius temperature) labeled 'celsius'
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
                "Function signatures include the name, parameter label, and return type.",
                "Convert using the given formula and return the computed value.",
            ],
            cheatsheet: cheatsheetProjectCore1a,
            solution: """
func celsiusToFahrenheit(celsius: Int) -> Int {
    return (celsius * 9) / 5 + 32
}
""",
            tier: .mainline
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
                "Return a Bool by comparing the inputs against the readiness rules.",
                "You can use boolean operators to combine comparisons into one expression.",
            ],
            cheatsheet: cheatsheetProjectCore1b,
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
                "Return a single Int computed from both inputs.",
                "Follow the provided arithmetic relationship between base and batches.",
            ],
            cheatsheet: cheatsheetProjectCore1c,
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
                // - Takes one [Int] parameter labeled 'temperatures'
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
                "The parameter should be an array: temperatures: [Int].",
                "Track min, max, sum, and overheat count as you iterate.",
                "Use integer division when computing the average.",
                "Return a tuple with named fields for readability.",
            ],
            cheatsheet: cheatsheetProjectCore2a,
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
            tier: .mainline
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
                "Iterate the dictionary and accumulate totals.",
                "Count empty items based on a comparison.",
                "Return the two counts as a tuple.",
            ],
            cheatsheet: cheatsheetProjectCore2b,
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
                "Unwrap values safely before using them.",
                "Track valid count and total while iterating.",
                "Avoid division by zero when computing the average.",
            ],
            cheatsheet: cheatsheetProjectCore2c,
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
                "Model log entries with an enum that carries data.",
                "Use a throwing parser for malformed lines.",
                "Transform, filter, and summarize with higher-order functions.",
                "Return the summary as a named tuple.",
            ],
            cheatsheet: cheatsheetProjectCore3a,
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
            tier: .mainline
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
                "Build a pipeline with map, filter, and reduce.",
                "Return both the count and the total.",
            ],
            cheatsheet: cheatsheetProjectCore3b,
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
                "Use a parser that can throw for malformed lines.",
                "Compact-map the parsed events, then split by case.",
                "Compute aggregates while iterating events.",
            ],
            cheatsheet: cheatsheetProjectCore3c,
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
        Project(
            id: "mantle1a",
            pass: 4,
            title: "Forge Inventory Model",
            description: "Model inventory with structs and computed properties",
            starterCode: #"""
                // Mantle 1 Project A: Forge Inventory Model
                // Model inventory items and compute totals.
                //
                // Requirements:
                // - Define a struct 'InventoryItem' with:
                //   - name: String
                //   - count: Int
                //   - unitWeight: Int
                // - Add a computed property totalWeight (count * unitWeight)
                // - Add a method label() -> String that returns "<name>: <count>"
                // - Create an array of two items:
                //   - ("Iron", 3, 2)
                //   - ("Copper", 2, 3)
                // - Print:
                //   "Iron: 3"
                //   "Copper: 2"
                //   "Total weight: 12"
                //
                // TODO: Implement InventoryItem and the reporting logic.

                // Test code (don't modify):
                let items = [
                    InventoryItem(name: "Iron", count: 3, unitWeight: 2),
                    InventoryItem(name: "Copper", count: 2, unitWeight: 3),
                ]
                for item in items {
                    print(item.label())
                }
                let total = items.reduce(0) { $0 + $1.totalWeight }
                print("Total weight: \(total)")
                """#,
            testCases: [
                (input: "iron", expectedOutput: "Iron: 3"),
                (input: "copper", expectedOutput: "Copper: 2"),
                (input: "total", expectedOutput: "Total weight: 12"),
            ],
            completionTitle: "🏗️ Mantle 1 Complete!",
            completionMessage: "You can now model real data with custom types.",
            hints: [
                "Use a computed property to multiply count and unitWeight.",
                "Build label() with string interpolation.",
            ],
            cheatsheet: cheatsheetProjectMantle1a,
            solution: """
struct InventoryItem {
    let name: String
    let count: Int
    let unitWeight: Int

    var totalWeight: Int {
        return count * unitWeight
    }

    func label() -> String {
        return \"\\(name): \\(count)\"
    }
}
""",
            tier: .mainline,
            layer: .mantle
        ),
        Project(
            id: "mantle1b",
            pass: 4,
            title: "Shift Tracker",
            description: "Track shifts with mutating methods and computed totals",
            starterCode: #"""
                // Mantle 1 Project B: Shift Tracker
                // Track worker shifts and total hours.
                //
                // Requirements:
                // - Define a struct Worker with:
                //   - name: String
                //   - shifts: Int
                //   - hoursPerShift: Int
                // - Add a mutating method addShift()
                // - Add computed property totalHours (shifts * hoursPerShift)
                // - Create:
                //   - Worker "Ada" with shifts 2, hoursPerShift 4
                //   - Worker "Ben" with shifts 1, hoursPerShift 5
                // - Call addShift() once on Ada
                // - Print:
                //   "Ada: 12"
                //   "Ben: 5"
                //   "Total: 17"
                //
                // TODO: Implement Worker and the reporting logic.

                // Test code (don't modify):
                var ada = Worker(name: "Ada", shifts: 2, hoursPerShift: 4)
                let ben = Worker(name: "Ben", shifts: 1, hoursPerShift: 5)
                ada.addShift()
                print("\(ada.name): \(ada.totalHours)")
                print("\(ben.name): \(ben.totalHours)")
                print("Total: \(ada.totalHours + ben.totalHours)")
                """#,
            testCases: [
                (input: "ada", expectedOutput: "Ada: 12"),
                (input: "ben", expectedOutput: "Ben: 5"),
                (input: "total", expectedOutput: "Total: 17"),
            ],
            completionTitle: "✨ Mantle 1 Extra Project Complete!",
            completionMessage: "Great work applying mutating methods and computed properties.",
            hints: [
                "addShift should increase shifts by 1.",
                "totalHours multiplies shifts by hoursPerShift.",
            ],
            cheatsheet: cheatsheetProjectMantle1b,
            solution: """
struct Worker {
    let name: String
    var shifts: Int
    let hoursPerShift: Int

    mutating func addShift() {
        shifts += 1
    }

    var totalHours: Int {
        shifts * hoursPerShift
    }
}
""",
            tier: .extra,
            layer: .mantle
        ),
        Project(
            id: "mantle1c",
            pass: 4,
            title: "Shared Controller",
            description: "Show shared state with classes",
            starterCode: #"""
                // Mantle 1 Project C: Shared Controller
                // Show class reference behavior.
                //
                // Requirements:
                // - Define a class Controller with a mode String
                // - Create 'primary' with mode "Idle"
                // - Assign 'secondary' = primary
                // - Set secondary.mode to "Active"
                // - Print:
                //   "Primary: Active"
                //   "Secondary: Active"
                //
                // TODO: Implement the Controller class.

                // Test code (don't modify):
                let primary = Controller(mode: "Idle")
                let secondary = primary
                secondary.mode = "Active"
                print("Primary: \(primary.mode)")
                print("Secondary: \(secondary.mode)")
                """#,
            testCases: [
                (input: "primary", expectedOutput: "Primary: Active"),
                (input: "secondary", expectedOutput: "Secondary: Active"),
            ],
            completionTitle: "✨ Mantle 1 Extra Project Complete!",
            completionMessage: "Reference semantics are now clear.",
            hints: [
                "Classes share state across references.",
            ],
            cheatsheet: cheatsheetProjectMantle1c,
            solution: """
class Controller {
    var mode: String

    init(mode: String) {
        self.mode = mode
    }
}
""",
            tier: .extra,
            layer: .mantle
        ),
        Project(
            id: "mantle2a",
            pass: 5,
            title: "Component Inspector",
            description: "Use protocols, extensions, and access control",
            starterCode: #"""
                // Mantle 2 Project A: Component Inspector
                // Define components and print inspection reports.
                //
                // Requirements:
                // - Define a protocol Inspectable with:
                //   - id: String
                //   - status: String
                // - Add a default method report() -> String in a protocol extension
                // - Create a struct 'Valve' that conforms (id: "V1", status: "OK")
                // - Create a struct 'Sensor' that conforms (id: "S2", status: "WARN")
                // - Print:
                //   "V1: OK"
                //   "S2: WARN"
                //
                // TODO: Implement Inspectable, the extension, and the structs.

                // Test code (don't modify):
                let items: [Inspectable] = [
                    Valve(id: "V1", status: "OK"),
                    Sensor(id: "S2", status: "WARN"),
                ]
                for item in items {
                    print(item.report())
                }
                """#,
            testCases: [
                (input: "v1", expectedOutput: "V1: OK"),
                (input: "s2", expectedOutput: "S2: WARN"),
            ],
            completionTitle: "🏗️ Mantle 2 Complete!",
            completionMessage: "Protocols and extensions are now part of your toolkit.",
            hints: [
                "Use a protocol extension to format the report string.",
                "Conform both structs to Inspectable.",
            ],
            cheatsheet: cheatsheetProjectMantle2a,
            solution: """
protocol Inspectable {
    var id: String { get }
    var status: String { get }
}

extension Inspectable {
    func report() -> String {
        return \"\\(id): \\(status)\"
    }
}

struct Valve: Inspectable {
    let id: String
    let status: String
}

struct Sensor: Inspectable {
    let id: String
    let status: String
}
""",
            tier: .mainline,
            layer: .mantle
        ),
        Project(
            id: "mantle2b",
            pass: 5,
            title: "Inspection Line",
            description: "Use protocol composition with shared formatting",
            starterCode: #"""
                // Mantle 2 Project B: Inspection Line
                // Compose protocols and build a report.
                //
                // Requirements:
                // - Define protocol Identifiable (id: String)
                // - Define protocol Statused (status: String)
                // - Define protocol Inspectable that inherits Identifiable and Statused
                // - Add an extension on Inspectable with report() -> String
                // - Create a struct Valve and Sensor that conform to Inspectable
                // - Print:
                //   "V1: OK"
                //   "S2: WARN"
                //
                // TODO: Implement the protocols, extension, and structs.

                // Test code (don't modify):
                let valve = Valve(id: "V1", status: "OK")
                let sensor = Sensor(id: "S2", status: "WARN")
                print(valve.report())
                print(sensor.report())
                """#,
            testCases: [
                (input: "v1", expectedOutput: "V1: OK"),
                (input: "s2", expectedOutput: "S2: WARN"),
            ],
            completionTitle: "✨ Mantle 2 Extra Project Complete!",
            completionMessage: "Nice use of protocol composition.",
            hints: [
                "Inherit both protocols in Inspectable, then add report() in an extension.",
            ],
            cheatsheet: cheatsheetProjectMantle2b,
            solution: """
protocol Identifiable {
    var id: String { get }
}

protocol Statused {
    var status: String { get }
}

protocol Inspectable: Identifiable, Statused {}

extension Inspectable {
    func report() -> String {
        return \"\\(id): \\(status)\"
    }
}

struct Valve: Inspectable {
    let id: String
    let status: String
}

struct Sensor: Inspectable {
    let id: String
    let status: String
}
""",
            tier: .extra,
            layer: .mantle
        ),
        Project(
            id: "mantle2c",
            pass: 5,
            title: "Safe Heater",
            description: "Throw and handle errors safely",
            starterCode: #"""
                // Mantle 2 Project C: Safe Heater
                // Throw errors and handle them with do/try/catch.
                //
                // Requirements:
                // - Define enum HeatError: Error with case tooCold
                // - Define struct Heater with func heat(to:) throws
                // - Throw tooCold if level < 1000
                // - In test code, call with 900 and 1200
                // - Print:
                //   "Too cold"
                //   "Heated"
                //
                // TODO: Implement HeatError and Heater.

                // Test code (don't modify):
                let heater = Heater()
                do {
                    try heater.heat(to: 900)
                } catch {
                    print("Too cold")
                }
                do {
                    try heater.heat(to: 1200)
                    print("Heated")
                } catch {
                    print("Too cold")
                }
                """#,
            testCases: [
                (input: "cold", expectedOutput: "Too cold"),
                (input: "heated", expectedOutput: "Heated"),
            ],
            completionTitle: "✨ Mantle 2 Extra Project Complete!",
            completionMessage: "Solid error handling practice.",
            hints: [
                "Throw when the temperature is below the threshold.",
            ],
            cheatsheet: cheatsheetProjectMantle2c,
            solution: """
enum HeatError: Error {
    case tooCold
}

struct Heater {
    func heat(to level: Int) throws {
        if level < 1000 {
            throw HeatError.tooCold
        }
    }
}
""",
            tier: .extra,
            layer: .mantle
        ),
        Project(
            id: "mantle3a",
            pass: 6,
            title: "Task Manager",
            description: "Combine generics, protocol defaults, and ARC safety",
            starterCode: #"""
                // Mantle 3 Project A: Task Manager
                // Build a small model with generics and safe references.
                //
                // Requirements:
                // - Define a protocol Named with name: String
                // - Add a default method label() -> String in a protocol extension
                // - Define a generic struct Box<T> to store a value
                // - Define a class Manager with a Worker reference
                // - Define a class Worker with name and a weak Manager reference
                // - Print:
                //   "Task: Forge"
                //   "Boxed: 5"
                //   "Link ok"
                //
                // TODO: Implement the types and prints.

                // Test code (don't modify):
                let worker = Worker(name: "Forge")
                let manager = Manager()
                manager.worker = worker
                worker.manager = manager
                print(worker.label())

                let boxed = Box(value: 5)
                print("Boxed: \(boxed.value)")

                print("Link ok")
                """#,
            testCases: [
                (input: "task", expectedOutput: "Task: Forge"),
                (input: "boxed", expectedOutput: "Boxed: 5"),
                (input: "link", expectedOutput: "Link ok"),
            ],
            completionTitle: "🏗️ Mantle 3 Complete!",
            completionMessage: "You can now build more structured systems in Swift.",
            hints: [
                "Use a protocol extension for the label.",
                "Make the Manager reference weak on the Worker side.",
            ],
            cheatsheet: cheatsheetProjectMantle3a,
            solution: """
protocol Named {
    var name: String { get }
}

extension Named {
    func label() -> String {
        return \"Task: \\(name)\"
    }
}

struct Box<T> {
    let value: T
}

class Manager {
    var worker: Worker?
}

class Worker: Named {
    let name: String
    weak var manager: Manager?

    init(name: String) {
        self.name = name
    }
}
""",
            tier: .mainline,
            layer: .mantle
        ),
        Project(
            id: "mantle3b",
            pass: 6,
            title: "Generic Stack",
            description: "Build a generic stack with push/pop",
            starterCode: #"""
                // Mantle 3 Project B: Generic Stack
                // Implement a basic generic stack.
                //
                // Requirements:
                // - Define struct Stack<T> with items: [T]
                // - Add mutating push(_:) and pop() -> T
                // - Use it with Ints:
                //   - Push 3, push 5, pop and print
                //   - Push 7, pop and print
                // - Output:
                //   "5"
                //   "7"
                //
                // TODO: Implement Stack.

                // Test code (don't modify):
                var stack = Stack(items: [])
                stack.push(3)
                stack.push(5)
                print(stack.pop())
                stack.push(7)
                print(stack.pop())
                """#,
            testCases: [
                (input: "first", expectedOutput: "5"),
                (input: "second", expectedOutput: "7"),
            ],
            completionTitle: "✨ Mantle 3 Extra Project Complete!",
            completionMessage: "Generics are becoming second nature.",
            hints: [
                "pop should remove and return the last element.",
            ],
            cheatsheet: cheatsheetProjectMantle3b,
            solution: """
struct Stack<T> {
    var items: [T]

    mutating func push(_ item: T) {
        items.append(item)
    }

    mutating func pop() -> T {
        return items.removeLast()
    }
}
""",
            tier: .extra,
            layer: .mantle
        ),
        Project(
            id: "mantle3c",
            pass: 6,
            title: "Constraint Report",
            description: "Combine where clauses and protocol defaults",
            starterCode: #"""
                // Mantle 3 Project C: Constraint Report
                // Use generic constraints and protocol extensions.
                //
                // Requirements:
                // - Define protocol Named with name: String
                // - Add default method label() -> String returning "Boxed: <name>"
                // - Define struct Box<T> { let value: T }
                // - Extend Box where T: Named with method label()
                // - Define generic function isEqual<T: Equatable>(_:_:) -> Bool
                // - Print:
                //   "Boxed: Steel"
                //   "true"
                //
                // TODO: Implement the types and function.

                // Test code (don't modify):
                struct Alloy: Named { let name: String }
                let boxed = Box(value: Alloy(name: "Steel"))
                print(boxed.label())
                print(isEqual(2, 2))
                """#,
            testCases: [
                (input: "label", expectedOutput: "Boxed: Steel"),
                (input: "equal", expectedOutput: "true"),
            ],
            completionTitle: "✨ Mantle 3 Extra Project Complete!",
            completionMessage: "Great control of constraints and defaults.",
            hints: [
                "Use a constrained extension for Box where T: Named.",
                "isEqual should return a Bool comparison.",
            ],
            cheatsheet: cheatsheetProjectMantle3c,
            solution: """
protocol Named {
    var name: String { get }
}

extension Named {
    func label() -> String {
        return \"Boxed: \\(name)\"
    }
}

struct Box<T> {
    let value: T
}

extension Box where T: Named {
    func label() -> String {
        return value.label()
    }
}

func isEqual<T: Equatable>(_ first: T, _ second: T) -> Bool {
    return first == second
}
""",
            tier: .extra,
            layer: .mantle
        ),
        Project(
            id: "crust1a",
            pass: 7,
            title: "Async Client",
            description: "Coordinate async work with a cache actor",
            starterCode: #"""
                // Crust 1 Project A: Async Client
                // Coordinate async work and an actor-backed cache.
                //
                // Requirements:
                // - Write async function fetchStatus() -> String that returns "OK"
                // - Add actor StatusCache with:
                //   - store(_:) to save a status
                //   - current() -> String to read the saved status
                // - Use runAsync to:
                //   - await fetchStatus()
                //   - store it in the cache
                //   - print:
                //     "Status: OK"
                //     "Cached: OK"
                //
                // TODO: Implement the async flow.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                // TODO: Write fetchStatus() async

                actor StatusCache {
                    // TODO: Store a status and return it
                }

                // Test code (don't modify):
                let cache = StatusCache()
                runAsync {
                    // TODO: Fetch status, store it, then print Status/Cached lines
                }
                """#,
            testCases: [
                (input: "status", expectedOutput: "Status: OK"),
                (input: "cached", expectedOutput: "Cached: OK"),
            ],
            completionTitle: "⚡ Crust 1 Complete!",
            completionMessage: "You can now coordinate async work safely.",
            hints: [
                "Use await for fetchStatus and actor calls.",
                "Store the result before printing both lines.",
            ],
            cheatsheet: cheatsheetProjectCrust1a,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

func fetchStatus() async -> String {
    return "OK"
}

actor StatusCache {
    private var status = ""

    func store(_ value: String) {
        status = value
    }

    func current() -> String {
        return status
    }
}

let cache = StatusCache()
runAsync {
    let status = await fetchStatus()
    await cache.store(status)
    let cached = await cache.current()
    print("Status: \\(status)")
    print("Cached: \\(cached)")
}
""",
            tier: .mainline,
            layer: .crust
        ),
        Project(
            id: "crust1b",
            pass: 7,
            title: "KeyPath Transformer",
            description: "Aggregate values with key paths",
            starterCode: #"""
                // Crust 1 Project B: KeyPath Transformer
                // Aggregate values with key paths.
                //
                // Requirements:
                // - Create an array of readings:
                //   - ("Iron", 2)
                //   - ("Gold", 4)
                // - Use a key path to map values
                // - Sum them and print "Total: 6"
                //
                // TODO: Implement the transformer.

                struct Reading {
                    let label: String
                    let value: Int
                }

                let readings = [
                    Reading(label: "Iron", value: 2),
                    Reading(label: "Gold", value: 4),
                ]

                // TODO: Map values with a key path and print the total
                """#,
            testCases: [
                (input: "total", expectedOutput: "Total: 6"),
            ],
            completionTitle: "✨ Crust 1 Extra Project Complete!",
            completionMessage: "Great work using key paths for aggregation.",
            hints: [
                "Use map(\\.value) to extract values.",
                "Reduce the values to a total before printing.",
            ],
            cheatsheet: cheatsheetProjectCrust1b,
            solution: """
struct Reading {
    let label: String
    let value: Int
}

let readings = [
    Reading(label: "Iron", value: 2),
    Reading(label: "Gold", value: 4),
]

let values = readings.map(\\.value)
let total = values.reduce(0, +)
print("Total: \\(total)")
""",
            tier: .extra,
            layer: .crust
        ),
        Project(
            id: "crust1c",
            pass: 7,
            title: "Task Orchestrator",
            description: "Coordinate task-group work",
            starterCode: #"""
                // Crust 1 Project C: Task Orchestrator
                // Coordinate task-group work.
                //
                // Requirements:
                // - Use withTaskGroup to sum [2, 4, 6]
                // - Print "Sum: 12"
                //
                // TODO: Implement the task group.

                import Foundation

                func runAsync(_ operation: @escaping () async -> Void) {
                    let group = DispatchGroup()
                    group.enter()
                    Task {
                        await operation()
                        group.leave()
                    }
                    group.wait()
                }

                runAsync {
                    // TODO: Sum the values with a task group
                    // TODO: Print the result
                }
                """#,
            testCases: [
                (input: "sum", expectedOutput: "Sum: 12"),
            ],
            completionTitle: "✨ Crust 1 Extra Project Complete!",
            completionMessage: "Nice job coordinating async tasks.",
            hints: [
                "Add a task for each value and sum with for await.",
                "Print the final total after the group finishes.",
            ],
            cheatsheet: cheatsheetProjectCrust1c,
            solution: """
import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

runAsync {
    let total = await withTaskGroup(of: Int.self) { group -> Int in
        for value in [2, 4, 6] {
            group.addTask { value }
        }

        var sum = 0
        for await value in group {
            sum += value
        }
        return sum
    }

    print("Sum: \\(total)")
}
""",
            tier: .extra,
            layer: .crust
        ),
        Project(
            id: "crust2a",
            pass: 8,
            title: "Config DSL",
            description: "Build settings with a result builder",
            starterCode: #"""
                // Crust 2 Project A: Config DSL
                // Build settings with a result builder.
                //
                // Requirements:
                // - Use ConfigBuilder to build two settings:
                //   - mode = fast
                //   - retries = 3
                // - Print:
                //   "mode=fast"
                //   "retries=3"
                //
                // TODO: Implement the DSL.

                struct Setting {
                    let key: String
                    let value: String
                }

                @resultBuilder
                struct ConfigBuilder {
                    static func buildBlock(_ components: Setting...) -> [Setting] {
                        return components
                    }
                }

                func makeConfig(@ConfigBuilder _ content: () -> [Setting]) -> [Setting] {
                    return content()
                }

                // Test code (don't modify):
                let settings = makeConfig {
                    // TODO: Add Setting(key:value:) items
                }

                for setting in settings {
                    print("\(setting.key)=\(setting.value)")
                }
                """#,
            testCases: [
                (input: "mode", expectedOutput: "mode=fast"),
                (input: "retries", expectedOutput: "retries=3"),
            ],
            completionTitle: "🚀 Crust 2 Complete!",
            completionMessage: "You can now build small DSLs in Swift.",
            hints: [
                "Return two Setting values from the builder block.",
                "Order matters for the output.",
            ],
            cheatsheet: cheatsheetProjectCrust2a,
            solution: """
struct Setting {
    let key: String
    let value: String
}

@resultBuilder
struct ConfigBuilder {
    static func buildBlock(_ components: Setting...) -> [Setting] {
        return components
    }
}

func makeConfig(@ConfigBuilder _ content: () -> [Setting]) -> [Setting] {
    return content()
}

let settings = makeConfig {
    Setting(key: "mode", value: "fast")
    Setting(key: "retries", value: "3")
}

for setting in settings {
    print("\\(setting.key)=\\(setting.value)")
}
""",
            tier: .mainline,
            layer: .crust
        ),
        Project(
            id: "crust2b",
            pass: 8,
            title: "Lazy Metrics",
            description: "Aggregate values with lazy transforms",
            starterCode: #"""
                // Crust 2 Project B: Lazy Metrics
                // Aggregate values with lazy transforms.
                //
                // Requirements:
                // - Double the numbers [1, 2, 3, 4, 5] using lazy map
                // - Sum the results and print "Total: 30"
                //
                // TODO: Implement the aggregation.

                let numbers = [1, 2, 3, 4, 5]

                // TODO: Use lazy map + reduce
                """#,
            testCases: [
                (input: "total", expectedOutput: "Total: 30"),
            ],
            completionTitle: "✨ Crust 2 Extra Project Complete!",
            completionMessage: "Nice work combining lazy and reduce.",
            hints: [
                "Use numbers.lazy.map { $0 * 2 }.",
                "Reduce the mapped values to a sum.",
            ],
            cheatsheet: cheatsheetProjectCrust2b,
            solution: """
let numbers = [1, 2, 3, 4, 5]

let doubled = numbers.lazy.map { $0 * 2 }
let total = doubled.reduce(0, +)
print("Total: \\(total)")
""",
            tier: .extra,
            layer: .crust
        ),
        Project(
            id: "crust2c",
            pass: 8,
            title: "Feature Flags",
            description: "Check enabled flags",
            starterCode: #"""
                // Crust 2 Project C: Feature Flags
                // Check enabled flags.
                //
                // Requirements:
                // - Define enum FeatureFlag with cases darkMode and newUI
                // - Implement isEnabled(flags:flag:) -> Bool
                // - Print:
                //   "Dark: true"
                //   "NewUI: false"
                //
                // TODO: Implement the flag checks.

                enum FeatureFlag: String {
                    case darkMode = "dark"
                    case newUI = "new-ui"
                }

                let enabled: Set<FeatureFlag> = [.darkMode]

                // TODO: Write isEnabled and print the results
                """#,
            testCases: [
                (input: "dark", expectedOutput: "Dark: true"),
                (input: "newui", expectedOutput: "NewUI: false"),
            ],
            completionTitle: "✨ Crust 2 Extra Project Complete!",
            completionMessage: "Feature flags are now in your toolkit.",
            hints: [
                "Use flags.contains(flag) inside isEnabled.",
                "Print the two booleans in the requested format.",
            ],
            cheatsheet: cheatsheetProjectCrust2c,
            solution: """
enum FeatureFlag: String {
    case darkMode = "dark"
    case newUI = "new-ui"
}

let enabled: Set<FeatureFlag> = [.darkMode]

func isEnabled(flags: Set<FeatureFlag>, flag: FeatureFlag) -> Bool {
    return flags.contains(flag)
}

print("Dark: \\(isEnabled(flags: enabled, flag: .darkMode))")
print("NewUI: \\(isEnabled(flags: enabled, flag: .newUI))")
""",
            tier: .extra,
            layer: .crust
        ),
        Project(
            id: "crust3a",
            pass: 9,
            title: "Mini Framework",
            description: "Track events through a protocol boundary",
            starterCode: #"""
                // Crust 3 Project A: Mini Framework
                // Track events through a protocol boundary.
                //
                // Requirements:
                // - Define protocol EventSink with send(_:) method
                // - Implement class MemorySink storing events
                // - Define Analytics that depends on EventSink
                // - Track two events: "start" and "finish"
                // - Print "Count: 2"
                //
                // TODO: Implement the mini framework.

                protocol EventSink {
                    func send(_ event: String)
                }

                class MemorySink: EventSink {
                    // TODO: Store events and expose count
                }

                struct Analytics {
                    let sink: EventSink
                    // TODO: Add track(_:) to send "Event: <name>"
                }

                // Test code (don't modify):
                let sink = MemorySink()
                let analytics = Analytics(sink: sink)
                analytics.track("start")
                analytics.track("finish")
                print("Count: \(sink.count)")
                """#,
            testCases: [
                (input: "count", expectedOutput: "Count: 2"),
            ],
            completionTitle: "🛠️ Crust 3 Complete!",
            completionMessage: "You can now structure professional Swift systems.",
            hints: [
                "Store events in an array and expose a count property.",
                "Analytics should call sink.send with the Event prefix.",
            ],
            cheatsheet: cheatsheetProjectCrust3a,
            solution: """
protocol EventSink {
    func send(_ event: String)
}

class MemorySink: EventSink {
    private var events: [String] = []
    var count: Int { events.count }

    func send(_ event: String) {
        events.append(event)
    }
}

struct Analytics {
    let sink: EventSink
    func track(_ name: String) {
        sink.send("Event: \\(name)")
    }
}

let sink = MemorySink()
let analytics = Analytics(sink: sink)
analytics.track("start")
analytics.track("finish")
print("Count: \\(sink.count)")
""",
            tier: .mainline,
            layer: .crust
        ),
        Project(
            id: "crust3b",
            pass: 9,
            title: "Modular CLI Tool",
            description: "Dispatch commands by name",
            starterCode: #"""
                // Crust 3 Project B: Modular CLI Tool
                // Dispatch commands by name.
                //
                // Requirements:
                // - Define protocol Command with name and run() -> String
                // - Implement StatusCommand and ListCommand
                // - Use a dictionary to select "status"
                // - Print the selected command output
                //
                // TODO: Implement the command system.

                protocol Command {
                    var name: String { get }
                    func run() -> String
                }

                struct StatusCommand: Command {
                    let name = "status"
                    // TODO: Return "Status: OK"
                }

                struct ListCommand: Command {
                    let name = "list"
                    // TODO: Return "List: 2"
                }

                let commands: [String: Command] = [
                    "status": StatusCommand(),
                    "list": ListCommand(),
                ]

                if let command = commands["status"] {
                    print(command.run())
                }
                """#,
            testCases: [
                (input: "status", expectedOutput: "Status: OK"),
            ],
            completionTitle: "✨ Crust 3 Extra Project Complete!",
            completionMessage: "Great command routing discipline.",
            hints: [
                "Return a string from each run() implementation.",
                "Look up the command by its key in the dictionary.",
            ],
            cheatsheet: cheatsheetProjectCrust3b,
            solution: """
protocol Command {
    var name: String { get }
    func run() -> String
}

struct StatusCommand: Command {
    let name = "status"
    func run() -> String {
        return "Status: OK"
    }
}

struct ListCommand: Command {
    let name = "list"
    func run() -> String {
        return "List: 2"
    }
}

let commands: [String: Command] = [
    "status": StatusCommand(),
    "list": ListCommand(),
]

if let command = commands["status"] {
    print(command.run())
}
""",
            tier: .extra,
            layer: .crust
        ),
        Project(
            id: "crust3c",
            pass: 9,
            title: "DSL Builder",
            description: "Compose steps with a builder",
            starterCode: #"""
                // Crust 3 Project C: DSL Builder
                // Compose steps with a builder.
                //
                // Requirements:
                // - Use StepsBuilder to build ["forge", "cool", "ship"]
                // - Print "forge -> cool -> ship"
                //
                // TODO: Implement the builder usage.

                @resultBuilder
                struct StepsBuilder {
                    static func buildBlock(_ components: String...) -> [String] {
                        return components
                    }
                }

                func buildSteps(@StepsBuilder _ content: () -> [String]) -> [String] {
                    return content()
                }

                let steps = buildSteps {
                    // TODO: Add the steps
                }

                print(steps.joined(separator: " -> "))
                """#,
            testCases: [
                (input: "steps", expectedOutput: "forge -> cool -> ship"),
            ],
            completionTitle: "✨ Crust 3 Extra Project Complete!",
            completionMessage: "Nice work shaping a tiny DSL.",
            hints: [
                "Return three string literals from the builder block.",
                "Join with -> between steps to match the output.",
            ],
            cheatsheet: cheatsheetProjectCrust3c,
            solution: """
@resultBuilder
struct StepsBuilder {
    static func buildBlock(_ components: String...) -> [String] {
        return components
    }
}

func buildSteps(@StepsBuilder _ content: () -> [String]) -> [String] {
    return content()
}

let steps = buildSteps {
    "forge"
    "cool"
    "ship"
}

print(steps.joined(separator: " -> "))
""",
            tier: .extra,
            layer: .crust
        ),

    ]
}
