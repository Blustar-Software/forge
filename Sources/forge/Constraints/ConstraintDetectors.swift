import Foundation

// MARK: - ConstraintTokenizer

func tokenizeSource(_ source: String) -> [String] {
    let chars = Array(source)
    var tokens: [String] = []
    var i = 0

    func isIdentifierStart(_ ch: Character) -> Bool {
        return ch.isLetter || ch == "_"
    }

    func isIdentifierPart(_ ch: Character) -> Bool {
        return ch.isLetter || ch.isNumber || ch == "_"
    }

    while i < chars.count {
        let current = chars[i]

        if current.isWhitespace {
            i += 1
            continue
        }

        if isIdentifierStart(current) {
            var j = i + 1
            while j < chars.count && isIdentifierPart(chars[j]) {
                j += 1
            }
            tokens.append(String(chars[i..<j]))
            i = j
            continue
        }

        if current == "$" {
            var j = i + 1
            if j < chars.count && isIdentifierStart(chars[j]) {
                j += 1
                while j < chars.count && isIdentifierPart(chars[j]) {
                    j += 1
                }
            } else {
                while j < chars.count && chars[j].isNumber {
                    j += 1
                }
            }
            tokens.append(String(chars[i..<j]))
            i = j
            continue
        }

        if current == "." {
            if i + 2 < chars.count, chars[i + 1] == ".", chars[i + 2] == "." {
                tokens.append("...")
                i += 3
                continue
            }
            if i + 2 < chars.count, chars[i + 1] == ".", chars[i + 2] == "<" {
                tokens.append("..<")
                i += 3
                continue
            }
            tokens.append(".")
            i += 1
            continue
        }

        if current == "=" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("==")
                i += 2
                continue
            }
            tokens.append("=")
            i += 1
            continue
        }

        if current == "!" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("!=")
                i += 2
                continue
            }
            tokens.append("!")
            i += 1
            continue
        }

        if current == "<" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("<=")
                i += 2
                continue
            }
            tokens.append("<")
            i += 1
            continue
        }

        if current == ">" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append(">=")
                i += 2
                continue
            }
            tokens.append(">")
            i += 1
            continue
        }

        if current == "&" {
            if i + 1 < chars.count, chars[i + 1] == "&" {
                tokens.append("&&")
                i += 2
                continue
            }
            tokens.append("&")
            i += 1
            continue
        }

        if current == "|" {
            if i + 1 < chars.count, chars[i + 1] == "|" {
                tokens.append("||")
                i += 2
                continue
            }
            tokens.append("|")
            i += 1
            continue
        }

        if current == "+" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("+=")
                i += 2
                continue
            }
            tokens.append("+")
            i += 1
            continue
        }

        if current == "-" {
            if i + 1 < chars.count, chars[i + 1] == ">" {
                tokens.append("->")
                i += 2
                continue
            }
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("-=")
                i += 2
                continue
            }
            tokens.append("-")
            i += 1
            continue
        }

        if current == "*" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("*=")
                i += 2
                continue
            }
            tokens.append("*")
            i += 1
            continue
        }

        if current == "/" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("/=")
                i += 2
                continue
            }
            tokens.append("/")
            i += 1
            continue
        }

        if current == "%" {
            if i + 1 < chars.count, chars[i + 1] == "=" {
                tokens.append("%=")
                i += 2
                continue
            }
            tokens.append("%")
            i += 1
            continue
        }

        if current == "?" {
            if i + 1 < chars.count, chars[i + 1] == "?" {
                tokens.append("??")
                i += 2
                continue
            }
            tokens.append("?")
            i += 1
            continue
        }

        if current == "{" || current == "}" || current == "(" || current == ")" || current == "," || current == "@" || current == "#" {
            tokens.append(String(current))
            i += 1
            continue
        }

        tokens.append(String(current))
        i += 1
    }

    return tokens
}

func isIdentifierToken(_ token: String) -> Bool {
    guard let first = token.first else { return false }
    guard first.isLetter || first == "_" else { return false }
    for ch in token.dropFirst() where !(ch.isLetter || ch.isNumber || ch == "_") {
        return false
    }
    return true
}

func hasToken(_ tokens: [String], _ token: String) -> Bool {
    return tokens.contains(token)
}

func hasSequence(_ tokens: [String], _ sequence: [String]) -> Bool {
    guard !sequence.isEmpty, tokens.count >= sequence.count else { return false }
    let lastStart = tokens.count - sequence.count
    for index in 0...lastStart {
        let slice = Array(tokens[index..<index + sequence.count])
        if slice == sequence {
            return true
        }
    }
    return false
}

func hasDotMember(_ tokens: [String], _ member: String) -> Bool {
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) where tokens[index] == "." && tokens[index + 1] == member {
        return true
    }
    return false
}

func hasInitializerLabel(_ tokens: [String], typeName: String, firstLabel: String) -> Bool {
    guard tokens.count >= 3 else { return false }
    for index in 0..<(tokens.count - 2) where tokens[index] == typeName {
        if tokens[index + 1] == "(", tokens[index + 2] == firstLabel {
            return true
        }
    }
    return false
}

func containsStringInterpolation(in source: String) -> Bool {
    let chars = Array(source)
    var i = 0
    var inLineComment = false
    var inBlockComment = false
    var inString = false
    var stringHashCount = 0
    var stringQuoteCount = 0
    var stringIsRaw = false

    func hasHashes(from index: Int, count: Int) -> Bool {
        if count == 0 {
            return true
        }
        guard index + count <= chars.count else {
            return false
        }
        for offset in 0..<count where chars[index + offset] != "#" {
            return false
        }
        return true
    }

    while i < chars.count {
        let current = chars[i]
        let next = i + 1 < chars.count ? chars[i + 1] : "\0"

        if inLineComment {
            if current == "\n" {
                inLineComment = false
            }
            i += 1
            continue
        }

        if inBlockComment {
            if current == "*" && next == "/" {
                inBlockComment = false
                i += 2
                continue
            }
            i += 1
            continue
        }

        if inString {
            if current == "\\" {
                let startIndex = i + 1
                if startIndex < chars.count {
                    var hashCount = 0
                    var j = startIndex
                    while j < chars.count && chars[j] == "#" {
                        hashCount += 1
                        j += 1
                    }
                    if !stringIsRaw && hashCount == 0 && j < chars.count && chars[j] == "(" {
                        return true
                    }
                    if stringIsRaw && hashCount == stringHashCount && j < chars.count && chars[j] == "(" {
                        return true
                    }
                }
                i += stringIsRaw ? 1 : 2
                continue
            }

            if current == "\"" {
                if stringQuoteCount == 3 {
                    if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                        let endIndex = i + 3
                        if hasHashes(from: endIndex, count: stringHashCount) {
                            i = endIndex + stringHashCount
                            inString = false
                            continue
                        }
                    }
                } else if stringQuoteCount == 1 {
                    let endIndex = i + 1
                    if hasHashes(from: endIndex, count: stringHashCount) {
                        i = endIndex + stringHashCount
                        inString = false
                        continue
                    }
                }
            }
            i += 1
            continue
        }

        if current == "/" && next == "/" {
            inLineComment = true
            i += 2
            continue
        }

        if current == "/" && next == "*" {
            inBlockComment = true
            i += 2
            continue
        }

        if current == "#" {
            var hashCount = 0
            var j = i
            while j < chars.count, chars[j] == "#" {
                hashCount += 1
                j += 1
            }
            if j < chars.count, chars[j] == "\"" {
                if j + 2 < chars.count, chars[j + 1] == "\"", chars[j + 2] == "\"" {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 3
                    stringIsRaw = true
                    i = j + 3
                    continue
                } else {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 1
                    stringIsRaw = true
                    i = j + 1
                    continue
                }
            }
        }

        if current == "\"" {
            if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 3
                stringIsRaw = false
                i += 3
                continue
            } else {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 1
                stringIsRaw = false
                i += 1
                continue
            }
        }

        i += 1
    }

    return false
}

func stripCommentsAndStrings(from source: String) -> String {
    let chars = Array(source)
    var output = ""
    var i = 0
    var inLineComment = false
    var inBlockComment = false
    var inString = false
    var stringHashCount = 0
    var stringQuoteCount = 0
    var stringIsRaw = false

    func hasHashes(from index: Int, count: Int) -> Bool {
        if count == 0 {
            return true
        }
        guard index + count <= chars.count else {
            return false
        }
        for offset in 0..<count where chars[index + offset] != "#" {
            return false
        }
        return true
    }

    while i < chars.count {
        let current = chars[i]
        let next = i + 1 < chars.count ? chars[i + 1] : "\0"

        if inLineComment {
            if current == "\n" {
                inLineComment = false
                output.append("\n")
            }
            i += 1
            continue
        }

        if inBlockComment {
            if current == "*" && next == "/" {
                inBlockComment = false
                i += 2
                output.append(" ")
                continue
            }
            i += 1
            continue
        }

        if inString {
            if !stringIsRaw && current == "\\" {
                i += 2
                continue
            }
            if current == "\"" {
                if stringQuoteCount == 3 {
                    if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                        let endIndex = i + 3
                        if hasHashes(from: endIndex, count: stringHashCount) {
                            i = endIndex + stringHashCount
                            inString = false
                            output.append(" ")
                            continue
                        }
                    }
                } else if stringQuoteCount == 1 {
                    let endIndex = i + 1
                    if hasHashes(from: endIndex, count: stringHashCount) {
                        i = endIndex + stringHashCount
                        inString = false
                        output.append(" ")
                        continue
                    }
                }
            }
            i += 1
            continue
        }

        if current == "/" && next == "/" {
            inLineComment = true
            i += 2
            continue
        }

        if current == "/" && next == "*" {
            inBlockComment = true
            i += 2
            continue
        }

        if current == "#" {
            var hashCount = 0
            var j = i
            while j < chars.count, chars[j] == "#" {
                hashCount += 1
                j += 1
            }
            if j < chars.count, chars[j] == "\"" {
                if j + 2 < chars.count, chars[j + 1] == "\"", chars[j + 2] == "\"" {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 3
                    stringIsRaw = true
                    i = j + 3
                    output.append(" ")
                    continue
                } else {
                    inString = true
                    stringHashCount = hashCount
                    stringQuoteCount = 1
                    stringIsRaw = true
                    i = j + 1
                    output.append(" ")
                    continue
                }
            }
        }

        if current == "\"" {
            if i + 2 < chars.count, chars[i + 1] == "\"", chars[i + 2] == "\"" {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 3
                stringIsRaw = false
                i += 3
                output.append(" ")
                continue
            } else {
                inString = true
                stringHashCount = 0
                stringQuoteCount = 1
                stringIsRaw = false
                i += 1
                output.append(" ")
                continue
            }
        }

        output.append(current)
        i += 1
    }

    return output
}

// MARK: - ConstraintSyntaxDetectors

func hasOptionalType(_ tokens: [String]) -> Bool {
    guard tokens.count >= 2 else { return false }
    let typeContextTokens: Set<String> = [":", "->", "[", ",", "("]
    for index in 1..<tokens.count where tokens[index] == "?" {
        let prev = tokens[index - 1]
        guard isIdentifierToken(prev) else { continue }
        let prevPrev = index >= 2 ? tokens[index - 2] : ""
        if typeContextTokens.contains(prevPrev) {
            return true
        }
    }
    return false
}

func hasOptionalUsage(_ tokens: [String]) -> Bool {
    return hasOptionalType(tokens)
        || hasToken(tokens, "nil")
        || hasToken(tokens, "??")
        || hasSequence(tokens, ["if", "let"])
        || hasSequence(tokens, ["guard", "let"])
        || hasSequence(tokens, ["as", "?"])
}

func hasShorthandClosureArg(_ tokens: [String]) -> Bool {
    for token in tokens where token.first == "$" && token.count > 1 {
        let suffix = token.dropFirst()
        if suffix.allSatisfy({ $0.isNumber }) {
            return true
        }
    }
    return false
}

func hasClosureAssignment(_ tokens: [String]) -> Bool {
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) {
        let token = tokens[index]
        let next = tokens[index + 1]
        if (token == "=" || token == "return") && next == "{" {
            return true
        }
    }
    return false
}

func hasClosureUsage(_ tokens: [String]) -> Bool {
    return hasClosureToken(tokens) || hasShorthandClosureArg(tokens) || hasClosureAssignment(tokens)
}

func hasCollectionUsage(tokens: [String], source: String) -> Bool {
    if tokens.contains("Array") || tokens.contains("Dictionary") || tokens.contains("Set") {
        return true
    }
    if hasCollectionLiteral(tokens: tokens) {
        return true
    }
    return false
}

func hasCollectionLiteral(tokens: [String]) -> Bool {
    let starterTokens: Set<String> = [":", "=", "return", "in", ",", "(", "["]
    var index = 0
    while index < tokens.count {
        if tokens[index] == "[" {
            let prev = index > 0 ? tokens[index - 1] : ""
            if prev == "{" {
                index += 1
                continue
            }
            var j = index + 1
            while j < tokens.count && tokens[j] != "]" {
                j += 1
            }
            if j < tokens.count {
                if starterTokens.contains(prev) {
                    return true
                }
                let innerTokens = tokens[(index + 1)..<j]
                if innerTokens.contains(where: { $0 == "," || $0 == ":" }) {
                    return true
                }
            }
        }
        index += 1
    }
    return false
}

func hasTupleUsage(_ tokens: [String]) -> Bool {
    let anchors: Set<String> = ["=", ":", "->", "return"]
    var index = 0
    while index < tokens.count - 1 {
        let token = tokens[index]
        if anchors.contains(token), tokens[index + 1] == "(" {
            if hasTupleParens(tokens, startIndex: index + 1) {
                return true
            }
        }
        index += 1
    }
    return false
}

func hasTupleParens(_ tokens: [String], startIndex: Int) -> Bool {
    var depth = 0
    var sawComma = false
    var index = startIndex
    while index < tokens.count {
        let token = tokens[index]
        if token == "(" {
            depth += 1
        } else if token == ")" {
            depth -= 1
            if depth == 0 {
                return sawComma
            }
        } else if token == "," && depth == 1 {
            sawComma = true
        }
        index += 1
    }
    return false
}

func hasTryOptional(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["try", "?"])
}

func hasCommandLineArguments(_ tokens: [String]) -> Bool {
    if hasSequence(tokens, ["CommandLine", ".", "arguments"]) {
        return true
    }
    if hasSequence(tokens, ["ProcessInfo", ".", "processInfo", ".", "arguments"]) {
        return true
    }
    return false
}

func hasFileIO(_ tokens: [String]) -> Bool {
    if hasToken(tokens, "contentsOfFile") {
        return true
    }
    if hasInitializerLabel(tokens, typeName: "Data", firstLabel: "contentsOf") {
        return true
    }
    if hasInitializerLabel(tokens, typeName: "String", firstLabel: "contentsOf") {
        return true
    }
    if hasInitializerLabel(tokens, typeName: "URL", firstLabel: "fileURLWithPath") {
        return true
    }
    for (index, token) in tokens.enumerated() where token == "FileHandle" || token == "FileManager" {
        let prev = index > 0 ? tokens[index - 1] : ""
        let next = index + 1 < tokens.count ? tokens[index + 1] : ""
        if prev == "." || next == "." || next == "(" {
            return true
        }
    }
    return false
}

func hasPropertyWrapperUsage(_ tokens: [String]) -> Bool {
    let ignoredAttributes: Set<String> = ["MainActor"]
    guard tokens.count >= 3 else { return false }
    for index in 0..<(tokens.count - 2) where tokens[index] == "@" {
        let next = tokens[index + 1]
        if ignoredAttributes.contains(next) {
            continue
        }
        let limit = min(index + 4, tokens.count)
        for j in (index + 1)..<limit {
            if tokens[j] == "var" || tokens[j] == "let" {
                return true
            }
        }
    }
    return false
}

func hasPropertyDeclaration(_ tokens: [String]) -> Bool {
    guard hasToken(tokens, "struct") || hasToken(tokens, "class") else { return false }
    return hasToken(tokens, "var") || hasToken(tokens, "let")
}

func hasExtensionClause(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "extension")
}

func hasWhereClause(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "where")
}

func hasAssociatedType(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "associatedtype")
}

func hasGenericDefinition(_ tokens: [String]) -> Bool {
    guard tokens.count >= 4 else { return false }
    let anchors = Set(["func", "struct", "class", "enum", "protocol", "extension"])
    for (index, token) in tokens.enumerated() where anchors.contains(token) {
        let next = index + 1
        guard next < tokens.count else { continue }
        var j = next
        if tokens[j] == "<" {
            return true
        }
        // Only inspect the declaration header (up to the first "{").
        // This avoids misclassifying `switch case ... where ...` inside bodies as generics.
        while j < tokens.count && tokens[j] != "{" {
            if tokens[j] == "<" || tokens[j] == "where" {
                return true
            }
            j += 1
        }
    }
    return false
}

func hasTaskUsage(_ tokens: [String]) -> Bool {
    let nextTokens: Set<String> = ["{", "(", ".", "<", "?", "!"]
    let prevTokens: Set<String> = [":", "->"]
    let declarationPrevTokens: Set<String> = [
        "struct", "class", "enum", "protocol", "typealias",
        "let", "var", "func", "case", "init", "extension"
    ]
    for (index, token) in tokens.enumerated() where token == "Task" {
        if index > 0 {
            let prev = tokens[index - 1]
            if declarationPrevTokens.contains(prev) {
                continue
            }
            if prevTokens.contains(prev) {
                return true
            }
        }
        let nextIndex = index + 1
        if nextIndex < tokens.count, nextTokens.contains(tokens[nextIndex]) {
            return true
        }
    }
    return false
}

func hasMainActorUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "MainActor") || hasSequence(tokens, ["@", "MainActor"])
}

func hasSendableUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "Sendable") || hasSequence(tokens, ["@", "Sendable"])
}


func hasComparisonOperator(_ tokens: [String]) -> Bool {
    let operators: Set<String> = ["==", "!=", "<", ">", "<=", ">="]
    return tokens.contains(where: { operators.contains($0) })
}

func hasLogicalOperator(_ tokens: [String]) -> Bool {
    let operators: Set<String> = ["&&", "||", "!"]
    return tokens.contains(where: { operators.contains($0) })
}

func hasCompoundAssignment(_ tokens: [String]) -> Bool {
    let operators: Set<String> = ["+=", "-=", "*=", "/=", "%="]
    return tokens.contains(where: { operators.contains($0) })
}

func hasStringInterpolation(_ tokens: [String]) -> Bool {
    return tokens.contains("\\(")
}

func hasClosureToken(_ tokens: [String]) -> Bool {
    var index = 0
    while index < tokens.count {
        if tokens[index] == "{" {
            var depth = 1
            var j = index + 1
            while j < tokens.count && depth > 0 {
                let token = tokens[j]
                if token == "{" {
                    depth += 1
                } else if token == "}" {
                    depth -= 1
                    if depth == 0 {
                        break
                    }
                } else if token == "in" && depth == 1 {
                    let windowStart = max(index + 1, j - 4)
                    if tokens[windowStart..<j].contains("for") {
                        j += 1
                        continue
                    }
                    return true
                }
                j += 1
            }
            index = j
            continue
        }
        index += 1
    }
    return false
}

// MARK: - ConstraintOOPDetectors

func hasProtocolConformance(_ tokens: [String]) -> Bool {
    let ignoredTypes: Set<String> = ["String", "Int", "Double", "Bool", "Error"]
    guard tokens.count >= 3 else { return false }

    for (index, token) in tokens.enumerated() where token == "struct" || token == "class" || token == "enum" {
        var j = index + 1
        while j < tokens.count && tokens[j] != "{" {
            if tokens[j] == ":" {
                var hasNonIgnored = false
                var k = j + 1
                while k < tokens.count && tokens[k] != "{" {
                    let next = tokens[k]
                    if next == "," {
                        k += 1
                        continue
                    }
                    if !ignoredTypes.contains(next) && next != "where" {
                        hasNonIgnored = true
                        break
                    }
                    k += 1
                }
                if hasNonIgnored {
                    return true
                }
            }
            j += 1
        }
    }
    for (index, token) in tokens.enumerated() where token == "extension" {
        var j = index + 1
        while j < tokens.count && tokens[j] != "{" {
            if tokens[j] == ":" {
                var hasConformance = false
                var k = j + 1
                while k < tokens.count && tokens[k] != "{" {
                    let next = tokens[k]
                    if next == "," {
                        k += 1
                        continue
                    }
                    if !ignoredTypes.contains(next) && next != "where" {
                        hasConformance = true
                        break
                    }
                    k += 1
                }
                if hasConformance {
                    return true
                }
            }
            j += 1
        }
    }
    return false
}

func protocolNames(in tokens: [String]) -> Set<String> {
    var names: Set<String> = []
    var index = 0

    func isIdentifierToken(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        return first.isLetter || first == "_"
    }

    while index < tokens.count - 1 {
        if tokens[index] == "protocol" {
            let name = tokens[index + 1]
            if isIdentifierToken(name) {
                names.insert(name)
            }
        }
        index += 1
    }

    return names
}

func hasDependencyInjection(_ tokens: [String]) -> Bool {
    let protocols = protocolNames(in: tokens)
    guard !protocols.isEmpty else { return false }

    var scopeStack: [Bool] = []
    var pendingTypeScope = false

    func isInsideType() -> Bool {
        return scopeStack.last == true
    }

    var index = 0
    while index < tokens.count {
        let token = tokens[index]

        if token == "struct" || token == "class" || token == "actor" {
            pendingTypeScope = true
            index += 1
            continue
        }

        if token == "{" {
            scopeStack.append(pendingTypeScope)
            pendingTypeScope = false
            index += 1
            continue
        }

        if token == "}" {
            _ = scopeStack.popLast()
            index += 1
            continue
        }

        if (token == "let" || token == "var") && isInsideType() {
            var j = index + 1
            while j < tokens.count {
                let next = tokens[j]
                if next == "let" || next == "var" || next == "func" || next == "}" || next == "{" {
                    break
                }
                if next == ":" {
                    let typeIndex = j + 1
                    if typeIndex < tokens.count, tokens[typeIndex] == "any" {
                        let protoIndex = typeIndex + 1
                        if protoIndex < tokens.count, protocols.contains(tokens[protoIndex]) {
                            return true
                        }
                    }
                }
                j += 1
            }
        }

        index += 1
    }

    return false
}

func hasProtocolMocking(_ tokens: [String]) -> Bool {
    let protocols = protocolNames(in: tokens)
    guard !protocols.isEmpty else { return false }

    var index = 0
    while index < tokens.count {
        let token = tokens[index]
        if token == "struct" || token == "class" || token == "enum" {
            guard index + 1 < tokens.count else { break }
            let name = tokens[index + 1]
            if name.hasPrefix("Mock") {
                var j = index + 2
                while j < tokens.count && tokens[j] != "{" {
                    if tokens[j] == ":" {
                        var k = j + 1
                        while k < tokens.count && tokens[k] != "{" {
                            let next = tokens[k]
                            if next == "," {
                                k += 1
                                continue
                            }
                            if protocols.contains(next) {
                                return true
                            }
                            k += 1
                        }
                    }
                    j += 1
                }
            }
        }
        index += 1
    }

    return false
}

func hasProtocolExtension(_ tokens: [String]) -> Bool {
    let protocols = protocolNames(in: tokens)
    guard !protocols.isEmpty else { return false }

    func isIdentifierToken(_ token: String) -> Bool {
        guard let first = token.first else { return false }
        return first.isLetter || first == "_"
    }

    var index = 0
    while index < tokens.count - 1 {
        if tokens[index] == "extension" {
            var j = index + 1
            while j < tokens.count && tokens[j] != "{" && tokens[j] != ":" && tokens[j] != "where" {
                let name = tokens[j]
                if isIdentifierToken(name), protocols.contains(name) {
                    return true
                }
                if tokens[j] == "<" {
                    break
                }
                j += 1
            }
        }
        index += 1
    }
    return false
}

// MARK: - ConstraintConcurrencyErrorDetectors

func hasTaskSleepUsage(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["Task", ".", "sleep"])
}

func hasTaskGroupUsage(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "withTaskGroup")
        || hasToken(tokens, "withThrowingTaskGroup")
        || hasToken(tokens, "TaskGroup")
        || hasToken(tokens, "ThrowingTaskGroup")
}

func hasAccessControlKeyword(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "private") || hasToken(tokens, "fileprivate")
        || hasToken(tokens, "internal") || hasToken(tokens, "public")
        || hasToken(tokens, "open")
}

func hasAccessControlOpen(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "public") || hasToken(tokens, "open")
}

func hasAccessControlFileprivate(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "fileprivate")
}

func hasAccessControlInternal(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "internal")
}

func hasAccessControlSetter(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["private", "(", "set", ")"])
}

func hasErrorType(_ tokens: [String]) -> Bool {
    if hasSequence(tokens, [":", "Error"]) || hasToken(tokens, "Error") {
        return true
    }
    var index = 0
    while index < tokens.count - 1 {
        if tokens[index] == "Result", tokens[index + 1] == "<" {
            return true
        }
        index += 1
    }
    return false
}

func hasThrowingFunction(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "throws") || hasToken(tokens, "rethrows")
}

func hasDoTryCatch(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "do") && hasToken(tokens, "catch") && hasToken(tokens, "try")
}

func hasTryForce(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["try", "!"])
}

func hasResultBuilder(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "resultBuilder")
}

func hasMacroUsage(_ tokens: [String]) -> Bool {
    if hasToken(tokens, "macro") {
        return true
    }
    guard tokens.count >= 2 else { return false }
    for index in 0..<(tokens.count - 1) where tokens[index] == "#" {
        let next = tokens[index + 1]
        guard let first = next.first else { continue }
        if first.isLetter || first == "_" {
            return true
        }
    }
    return false
}

func hasProjectedValues(_ tokens: [String]) -> Bool {
    for token in tokens where token.hasPrefix("$") && token.count > 1 {
        let suffix = token.dropFirst()
        if suffix.allSatisfy({ $0.isNumber }) {
            continue
        }
        return true
    }
    return false
}

func hasSwiftPMBasics(_ tokens: [String]) -> Bool {
    return hasToken(tokens, "Package")
        || hasToken(tokens, "Target")
        || hasToken(tokens, "PackageDescription")
}

func hasSwiftPMDependencies(_ tokens: [String]) -> Bool {
    if hasSequence(tokens, [".", "package", "("]) {
        return true
    }
    for (index, token) in tokens.enumerated() where token == "package" || token == "dependencies" {
        let prev = index > 0 ? tokens[index - 1] : ""
        let next = index + 1 < tokens.count ? tokens[index + 1] : ""
        if prev == "." || next == ":" || next == "(" {
            return true
        }
    }
    return false
}

func hasBuildConfigs(_ tokens: [String]) -> Bool {
    return hasSequence(tokens, ["#", "if"]) || hasSequence(tokens, ["#", "elseif"]) || hasSequence(tokens, ["#", "else"])
}

func hasNetworkUsage(tokens: [String], source: String) -> Bool {
    if source.contains("http://") || source.contains("https://") {
        return true
    }
    return tokens.contains("URLSession") || tokens.contains("URLRequest")
}

func hasConcurrencyUsage(tokens: [String]) -> Bool {
    return tokens.contains("async")
        || tokens.contains("await")
        || hasTaskUsage(tokens)
        || hasToken(tokens, "actor")
        || hasMainActorUsage(tokens)
        || hasSendableUsage(tokens)
        || hasTaskGroupUsage(tokens)
}
