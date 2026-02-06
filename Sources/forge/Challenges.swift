import Foundation

enum ChallengeTopic: String, Codable {
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

enum ChallengeTier: String, Codable {
    case mainline
    case extra
}

enum ChallengeLayer: String, Codable {
    case core
    case mantle
    case crust
}

enum ProjectTier: String, Codable {
    case mainline
    case extra
}

enum ProjectLayer: String, Codable {
    case core
    case mantle
    case crust
}

enum ConstraintConcept: String, Codable {
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


struct ConstraintProfile: Codable {
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
struct Challenge: Codable {
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

struct ProjectTestCase: Codable {
    let input: String
    let expectedOutput: String
}

struct Project: Codable {
    let id: String
    let pass: Int
    let title: String
    let description: String
    let starterCode: String
    let testCases: [ProjectTestCase]
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
        self.testCases = testCases.map { ProjectTestCase(input: $0.input, expectedOutput: $0.expectedOutput) }
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

