import Foundation

// MARK: - CLIModels

enum TopLevelCommand {
    case run(overrideToken: String?)
    case help
    case reset(args: [String])
    case aiGenerate(args: [String])
    case stats(args: [String])
    case reportOverrides(args: [String])
    case catalog(args: [String])
    case catalogProjects(args: [String])
    case report(args: [String])
    case verify(args: [String])
    case review(args: [String])
    case practice(args: [String])
    case audit(args: [String])
    case random(args: [String])
    case project(args: [String])
    case remapProgress(args: [String])
    case progress(args: [String])
}

struct GlobalFlags {
    let gatePasses: Int
    let gateCount: Int
    let enforceConstraints: Bool
    let enableDiMockHeuristics: Bool
    let enableConstraintProfiles: Bool
    let adaptiveThreshold: Int
    let adaptiveCount: Int
    let adaptiveEnabled: Bool
    let adaptiveMinTopicFailures: Int
    let adaptiveMinChallengeFailures: Int
    let adaptiveCooldownSteps: Int
    let confirmCheckEnabled: Bool
    let confirmSolutionEnabled: Bool
}

struct CLIPaths {
    let practiceWorkspace = "workspace_random"
    let projectWorkspace = "workspace_projects"
    let explicitPracticeWorkspace = "workspace_practice"
}

struct AIGenerateSettings {
    let live: Bool
    let dryRun: Bool
    let provider: String
    let model: String?
    let outputPath: String
}

let helpTokens: Set<String> = ["help", "-h", "--help"]

let topLevelCommands: Set<String> = [
    "reset",
    "ai-generate",
    "practice",
    "random",
    "project",
    "progress",
    "remap-progress",
    "verify-solutions",
    "verify",
    "review-progression",
    "review",
    "stats",
    "audit",
    "report",
    "catalog",
    "catalog-projects"
]

// MARK: - CLIParsing

func parseGlobalFlags(_ rawArgs: [String]) -> (flags: GlobalFlags, remaining: [String]) {
    let parsed = parseGateSettings(rawArgs)
    let constraintParsed = parseConstraintSettings(parsed.remaining)
    let adaptiveParsed = parseAdaptiveSettings(constraintParsed.remaining)
    let confirmParsed = parseConfirmSettings(adaptiveParsed.remaining)
    let confirmSolutionEnabled = enforceAdaptiveConfirmPolicy(
        adaptiveEnabled: adaptiveParsed.enabled,
        confirmSolutionEnabled: confirmParsed.confirmSolution
    )

    let flags = GlobalFlags(
        gatePasses: parsed.passes,
        gateCount: parsed.count,
        enforceConstraints: constraintParsed.enforce,
        enableDiMockHeuristics: constraintParsed.enableDiMockHeuristics,
        enableConstraintProfiles: constraintParsed.enableConstraintProfiles,
        adaptiveThreshold: adaptiveParsed.threshold,
        adaptiveCount: adaptiveParsed.count,
        adaptiveEnabled: adaptiveParsed.enabled,
        adaptiveMinTopicFailures: adaptiveParsed.minTopicFailures,
        adaptiveMinChallengeFailures: adaptiveParsed.minChallengeFailures,
        adaptiveCooldownSteps: adaptiveParsed.cooldownSteps,
        confirmCheckEnabled: confirmParsed.enabled,
        confirmSolutionEnabled: confirmSolutionEnabled
    )

    return (flags, confirmParsed.remaining)
}

func parseTopLevelCommand(_ args: [String]) -> TopLevelCommand {
    if let first = args.first?.lowercased(), helpTokens.contains(first) {
        return .help
    }

    let overrideToken: String? = {
        guard let first = args.first else { return nil }
        let lowered = first.lowercased()
        if topLevelCommands.contains(lowered) || helpTokens.contains(lowered) {
            return nil
        }
        return first
    }()

    guard let firstRaw = args.first else {
        return .run(overrideToken: overrideToken)
    }

    let firstArg = firstRaw.lowercased()
    let remaining = Array(args.dropFirst())
    if firstRaw == "reset" {
        return .reset(args: remaining)
    }
    if firstArg == "ai-generate" {
        return .aiGenerate(args: remaining)
    }
    if firstRaw == "stats" {
        return .stats(args: remaining)
    }
    if firstRaw == "report-overrides" {
        return .reportOverrides(args: remaining)
    }
    if firstRaw == "catalog" {
        return .catalog(args: remaining)
    }
    if firstRaw == "catalog-projects" {
        return .catalogProjects(args: remaining)
    }
    if firstRaw == "report" {
        return .report(args: remaining)
    }

    if ["verify-solutions", "verify"].contains(firstArg) {
        return .verify(args: remaining)
    }
    if ["review-progression", "review"].contains(firstArg) {
        return .review(args: remaining)
    }
    if ["practice"].contains(firstArg) {
        return .practice(args: remaining)
    }
    if ["audit"].contains(firstArg) {
        return .audit(args: remaining)
    }
    if firstRaw == "random" {
        return .random(args: remaining)
    }
    if firstRaw == "project" {
        return .project(args: remaining)
    }
    if firstArg == "remap-progress" {
        return .remapProgress(args: remaining)
    }
    if firstArg == "progress" {
        return .progress(args: remaining)
    }

    return .run(overrideToken: overrideToken)
}

func parseStatsSettings(_ args: [String]) -> (reset: Bool, resetAll: Bool, limit: Int?) {
    var reset = false
    var resetAll = false
    var limit: Int?

    var index = 0
    while index < args.count {
        let lowered = args[index].lowercased()
        if lowered == "--reset" {
            reset = true
            index += 1
            continue
        }
        if lowered == "--reset-all" {
            resetAll = true
            index += 1
            continue
        }
        if lowered == "--stats-limit", index + 1 < args.count, let value = Int(args[index + 1]) {
            limit = max(value, 1)
            index += 2
            continue
        }
        index += 1
    }

    return (reset, resetAll, limit)
}

func parseAIGenerateSettings(_ args: [String]) -> (settings: AIGenerateSettings?, error: String?) {
    var live = false
    var dryRun = false
    var provider = "phi"
    var model: String?
    var outputPath = "workspace_verify/ai_candidates"

    var index = 0
    while index < args.count {
        let arg = args[index]
        let lowered = arg.lowercased()

        if lowered == "--live" {
            live = true
            index += 1
            continue
        }
        if lowered == "--dry-run" {
            dryRun = true
            index += 1
            continue
        }
        if lowered == "--provider" {
            guard index + 1 < args.count else {
                return (nil, "Missing value for --provider")
            }
            let value = args[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else {
                return (nil, "Provider value cannot be empty.")
            }
            provider = value
            index += 2
            continue
        }
        if lowered == "--model" {
            guard index + 1 < args.count else {
                return (nil, "Missing value for --model")
            }
            let value = args[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else {
                return (nil, "Model value cannot be empty.")
            }
            model = value
            index += 2
            continue
        }
        if lowered == "--out" {
            guard index + 1 < args.count else {
                return (nil, "Missing value for --out")
            }
            let value = args[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else {
                return (nil, "Output path cannot be empty.")
            }
            outputPath = value
            index += 2
            continue
        }
        return (nil, "Unknown ai-generate option: \(arg)")
    }

    if live && dryRun {
        return (nil, "Use either --dry-run or --live, not both.")
    }

    return (
        AIGenerateSettings(live: live, dryRun: dryRun, provider: provider, model: model, outputPath: outputPath),
        nil
    )
}

func parseRandomArguments(
    _ args: [String]
) -> (count: Int, topic: ChallengeTopic?, tier: ChallengeTier?, layer: ChallengeLayer?, adaptive: Bool, bridge: Bool) {
    var count = 5
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?
    var adaptive = false
    var bridge = false

    for value in args {
        if let number = Int(value) {
            count = max(number, 1)
            continue
        }
        let lowered = value.lowercased()
        if lowered == "help" || lowered == "-h" || lowered == "--help" {
            continue
        }
        if lowered == "adaptive" {
            adaptive = true
            continue
        }
        if lowered == "bridge" {
            bridge = true
            continue
        }
        if let parsedTopic = ChallengeTopic(rawValue: lowered) {
            topic = parsedTopic
            continue
        }
        if let parsedTier = ChallengeTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ChallengeLayer(rawValue: lowered) {
            layer = parsedLayer
        }
    }

    return (count, topic, tier, layer, adaptive, bridge)
}

func practiceRangeToken(_ raw: String) -> (layer: ChallengeLayer, range: ClosedRange<Int>)? {
    switch raw.lowercased() {
    case "core1":
        return (.core, 1...20)
    case "core2":
        return (.core, 21...42)
    case "core3":
        return (.core, 43...81)
    case "mantle1":
        return (.mantle, 1...11)
    case "mantle2":
        return (.mantle, 12...22)
    case "mantle3":
        return (.mantle, 23...33)
    case "crust1":
        return (.crust, 1...18)
    case "crust2":
        return (.crust, 19...36)
    case "crust3":
        return (.crust, 37...54)
    default:
        return nil
    }
}

func parsePracticeArguments(
    _ args: [String]
) -> (
    count: Int,
    topic: ChallengeTopic?,
    tier: ChallengeTier?,
    layer: ChallengeLayer?,
    range: ClosedRange<Int>?,
    includeAll: Bool,
    bridge: Bool
) {
    var count = 5
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?
    var range: ClosedRange<Int>?
    var includeAll = false
    var bridge = false

    for value in args {
        if let number = Int(value) {
            count = max(number, 1)
            continue
        }
        let lowered = value.lowercased()
        if lowered == "help" || lowered == "-h" || lowered == "--help" {
            continue
        }
        if lowered == "--all" {
            includeAll = true
            continue
        }
        if lowered == "bridge" {
            bridge = true
            continue
        }
        if let sublayer = practiceRangeToken(lowered) {
            range = sublayer.range
            if layer == nil {
                layer = sublayer.layer
            }
            continue
        }
        if let parsedTopic = ChallengeTopic(rawValue: lowered) {
            topic = parsedTopic
            continue
        }
        if let parsedTier = ChallengeTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ChallengeLayer(rawValue: lowered) {
            layer = parsedLayer
        }
    }

    return (count, topic, tier, layer, range, includeAll, bridge)
}

func parseGateSettings(
    _ args: [String]
) -> (passes: Int, count: Int, remaining: [String]) {
    var passes = 1
    var count = 3
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--gate-passes", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                passes = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--gate-count", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                count = max(1, value)
            }
            index += 2
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (passes, count, remaining)
}

func parseAdaptiveSettings(
    _ args: [String]
) -> (
    threshold: Int,
    count: Int,
    enabled: Bool,
    minTopicFailures: Int,
    minChallengeFailures: Int,
    cooldownSteps: Int,
    remaining: [String]
) {
    var threshold = 3
    var count = 3
    var enabled = false
    var minTopicFailures = 2
    var minChallengeFailures = 2
    var cooldownSteps = 2
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--adaptive-on" {
            enabled = true
            index += 1
            continue
        }
        if arg == "--adaptive-threshold", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                threshold = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-count", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                count = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-topic-failures", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                minTopicFailures = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-challenge-failures", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                minChallengeFailures = max(1, value)
            }
            index += 2
            continue
        }
        if arg == "--adaptive-cooldown", index + 1 < args.count {
            if let value = Int(args[index + 1]) {
                cooldownSteps = max(0, value)
            }
            index += 2
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (threshold, count, enabled, minTopicFailures, minChallengeFailures, cooldownSteps, remaining)
}

func parseConfirmSettings(
    _ args: [String]
) -> (enabled: Bool, confirmSolution: Bool, remaining: [String]) {
    var enabled = false
    var confirmSolution = false
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--confirm-check" {
            enabled = true
            index += 1
            continue
        }
        if arg == "--confirm-solution" {
            confirmSolution = true
            index += 1
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (enabled, confirmSolution, remaining)
}

func enforceAdaptiveConfirmPolicy(adaptiveEnabled: Bool, confirmSolutionEnabled: Bool) -> Bool {
    if adaptiveEnabled {
        return true
    }
    return confirmSolutionEnabled
}

func parseConstraintSettings(
    _ args: [String]
) -> (enforce: Bool, enableDiMockHeuristics: Bool, enableConstraintProfiles: Bool, remaining: [String]) {
    var enforce = true
    var enableDiMockHeuristics = true
    var enableConstraintProfiles = true
    var remaining: [String] = []
    var index = 0

    while index < args.count {
        let arg = args[index]
        if arg == "--allow-early-concepts" {
            enforce = false
            index += 1
            continue
        }
        if arg == "--disable-di-mock-heuristics" {
            enableDiMockHeuristics = false
            index += 1
            continue
        }
        if arg == "--disable-constraint-profiles" {
            enableConstraintProfiles = false
            index += 1
            continue
        }
        remaining.append(arg)
        index += 1
    }

    return (enforce, enableDiMockHeuristics, enableConstraintProfiles, remaining)
}

func parseVerifyArguments(
    _ args: [String]
) -> (range: ClosedRange<Int>?, topic: ChallengeTopic?, tier: ChallengeTier?, layer: ChallengeLayer?) {
    var range: ClosedRange<Int>?
    var topic: ChallengeTopic?
    var tier: ChallengeTier?
    var layer: ChallengeLayer?

    for value in args {
        let lowered = value.lowercased()
        if ["help", "-h", "--help"].contains(lowered) {
            continue
        }
        if let parsedTopic = ChallengeTopic(rawValue: lowered) {
            topic = parsedTopic
            continue
        }
        if let parsedTier = ChallengeTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ChallengeLayer(rawValue: lowered) {
            layer = parsedLayer
            continue
        }
        if let number = Int(lowered) {
            range = number...number
            continue
        }
        if let dashIndex = lowered.firstIndex(of: "-") {
            let startPart = String(lowered[..<dashIndex])
            let endPart = String(lowered[lowered.index(after: dashIndex)...])
            if let start = Int(startPart), let end = Int(endPart), start <= end {
                range = start...end
            }
        }
    }

    return (range, topic, tier, layer)
}

func parseVerifySettings(_ args: [String]) -> (constraintsOnly: Bool, remaining: [String]) {
    var constraintsOnly = false
    var remaining: [String] = []

    for value in args {
        let lowered = value.lowercased()
        if lowered == "--constraints-only" {
            constraintsOnly = true
            continue
        }
        remaining.append(value)
    }

    return (constraintsOnly, remaining)
}

func parseProjectListArguments(_ args: [String]) -> (tier: ProjectTier?, layer: ProjectLayer?) {
    var tier: ProjectTier?
    var layer: ProjectLayer?

    for value in args {
        let lowered = value.lowercased()
        if let parsedTier = ProjectTier(rawValue: lowered) {
            tier = parsedTier
            continue
        }
        if let parsedLayer = ProjectLayer(rawValue: lowered) {
            layer = parsedLayer
        }
    }

    return (tier, layer)
}

func parseProjectRandomArguments(_ args: [String]) -> (tier: ProjectTier?, layer: ProjectLayer?) {
    return parseProjectListArguments(args)
}

func parseProgressTarget(_ token: String, projects: [Project]) -> ProgressTarget {
    let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed == "999" {
        return .completed
    }
    let lowered = trimmed.lowercased()
    if lowered.hasPrefix("challenge:") {
        let value = String(trimmed.dropFirst("challenge:".count))
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(trimmedValue) {
            return .challenge(number)
        }
        return .challengeId(trimmedValue.lowercased())
    }
    if lowered.hasPrefix("project:") {
        let projectId = String(trimmed.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        return .project(projectId.lowercased())
    }
    if let number = Int(trimmed) {
        return .step(number)
    }
    let projectIdRaw = trimmed
    let projectId = projectIdRaw.lowercased()
    if projects.contains(where: { $0.id.lowercased() == projectId }) {
        return .project(projectId)
    }
    if lowered.hasPrefix("core:") || lowered.hasPrefix("mantle:") || lowered.hasPrefix("crust:") {
        return .challengeId(lowered)
    }
    return .step(1)
}

func parseProgressInput(_ args: [String]) -> ProgressInput? {
    guard let raw = args.first?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
        return nil
    }
    let lowered = raw.lowercased()
    if lowered.hasPrefix("challenge:") {
        let value = String(raw.dropFirst("challenge:".count))
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let number = Int(trimmedValue) {
            return .challenge(number)
        }
        if !trimmedValue.isEmpty {
            return .challengeId(trimmedValue.lowercased())
        }
        return nil
    }
    if lowered.hasPrefix("project:") {
        let value = String(raw.dropFirst("project:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty {
            return nil
        }
        return .project(value.lowercased())
    }
    if lowered.hasPrefix("step:") {
        let value = String(raw.dropFirst("step:".count))
        if let number = Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return .step(number)
        }
        return nil
    }
    if let number = Int(raw) {
        return .challenge(number)
    }
    if lowered.hasPrefix("core:") || lowered.hasPrefix("mantle:") || lowered.hasPrefix("crust:") {
        return .challengeId(lowered)
    }
    return nil
}

// MARK: - CLIUsage

func printMainUsage() {
    print("""
    Usage:
      swift run forge

    Core commands:
      swift run forge reset [--all] [--start]
      swift run forge ai-generate [--dry-run] [--live] [--provider <name>] [--model <id>] [--out <path>]
      swift run forge stats [--reset]
      swift run forge remap-progress [target]
      swift run forge catalog
      swift run forge catalog-projects
      swift run forge practice [count] [topic] [tier] [layer]
      swift run forge random [count] [topic] [tier] [layer]
      swift run forge project <id>
      swift run forge progress <target>
      swift run forge report
      swift run forge report-overrides


    Progress shortcuts:
      swift run forge challenge:<layer>:<number>
      swift run forge challenge:<layer>:<number>.<extra>
      swift run forge challenge:<id>
      swift run forge project:<id>
      swift run forge <project-id>

    Flow + behavior flags:
      --gate-passes <n>
      --gate-count <n>
      --allow-early-concepts
      --confirm-check
      --confirm-solution
      --disable-constraint-profiles
      --disable-di-mock-heuristics

    Adaptive flags:
      --adaptive-on
      --adaptive-threshold <n>
      --adaptive-count <n>
      --adaptive-topic-failures <n>
      --adaptive-challenge-failures <n>
      --adaptive-cooldown <n>

    Help:
      swift run forge --help
      swift run forge remap-progress --help
      swift run forge practice --help
      swift run forge random --help
      swift run forge project --help
      swift run forge stats --help
      swift run forge ai-generate --help
      swift run forge report --help
      swift run forge report-overrides --help
      swift run forge catalog --help
      swift run forge catalog-projects --help

    Examples:
      swift run forge practice 8
      swift run forge practice optionals
      swift run forge practice core2
      swift run forge practice --all
      swift run forge random 8
      swift run forge random adaptive
      swift run forge project --list core
      swift run forge project:core2a
      swift run forge challenge:core:36
      swift run forge challenge:core:18.1
      swift run forge progress challenge:core:36
      swift run forge progress project:core2a
      swift run forge progress step:19
      swift run forge remap-progress challenge:18
      swift run forge verify-solutions crust
      swift run forge verify-solutions core --constraints-only
      swift run forge review-progression core 1-80
      swift run forge audit core
      swift run forge ai-generate --dry-run
      swift run forge report
      swift run forge catalog
      swift run forge catalog-projects

    Notes:
      - Random mode uses workspace_random/. Project mode uses workspace_projects/.
      - Stage review uses workspace_review/.
      - Adaptive gating is off by default; enable with --adaptive-on.
      - Adaptive practice is weighted by per-topic performance and per-challenge recency.
      - Practice mode uses workspace_practice/ and adaptive weighting when stats are available.
      - Viewing a solution may queue short practice when adaptive is enabled.
      - Assisted practice resumes after restart if it was interrupted.
      - Use --confirm-check to require a second Enter before running checks.
      - Use --confirm-solution to require confirmation before showing solutions.
      - Use --disable-constraint-profiles to skip Phase 2 constraint profiles.
      - Constraint profiles can require specific constructs (like functions or collections).

    Testing commands:
      swift run forge verify-solutions [filters] [bridge] [--constraints-only]
      swift run forge review-progression [filters] [bridge]
      swift run forge audit [filters] [bridge]
      swift run forge verify-solutions --help
      swift run forge review-progression --help
      swift run forge audit --help
      swift run forge catalog --help
      swift run forge catalog-projects --help
    """)
}

func printProgressUsage() {
    print("""
    Usage:
      swift run forge progress <target>

    Targets:
      challenge:<layer>:<number>
      challenge:<layer>:<number>.<extra>
      challenge:<id>
      project:<id>
      step:<number>

    Examples:
      swift run forge progress challenge:core:20
      swift run forge progress challenge:core:18.1
      swift run forge progress project:core1a
      swift run forge progress step:19
      swift run forge progress 20
    """)
}

func printRemapProgressUsage() {
    print("""
    Usage:
      swift run forge remap-progress [target]

    Targets:
      challenge:<number>
      challenge:<layer>:<number>
      challenge:<layer>:<number>.<extra>
      challenge:<id>
      project:<id>
      step:<number>

    Notes:
      - This helper is intended to translate legacy challenge numbers after renumbering.
      - If no target is provided, the command will read workspace/.progress.
      - If workspace/.progress is a plain number, it may be a step index; provide an explicit target to avoid ambiguity.

    Examples:
      swift run forge remap-progress challenge:18
      swift run forge remap-progress challenge:core:18.1
      swift run forge remap-progress project:core1a
      swift run forge remap-progress step:42
    """)
}

func printCatalogUsage() {
    print("""
    Usage:
      swift run forge catalog

    Output:
      - Prints a table to stdout
    """)
}

func printProjectCatalogUsage() {
    print("""
    Usage:
      swift run forge catalog-projects

    Output:
      - Prints a table to stdout
    """)
}

func printRandomUsage() {
    print("""
    Usage: swift run forge random [count] [topic] [tier] [layer] [bridge]

    Topics: conditionals, loops, optionals, collections, functions, strings, structs, classes, properties, protocols, extensions, accessControl, errors, generics, memory, concurrency, actors, keyPaths, sequences, propertyWrappers, macros, swiftpm, testing, interop, performance, advancedFeatures, general
    Tiers: mainline, extra
    Layers: core, mantle, crust
    Bridge: use 'bridge' to focus on bridge challenges (otherwise excluded)
    Adaptive: use 'adaptive' to bias toward weaker topics and stale challenges

    Examples:
      swift run forge random 8
      swift run forge random conditionals
      swift run forge random 6 loops extra
      swift run forge random 10 mantle
      swift run forge random 12 mainline
      swift run forge random adaptive
    """)
}

func printProjectUsage() {
    print("""
    Usage:
      swift run forge project <id>
      swift run forge project --list [tier] [layer]
      swift run forge project --random [tier] [layer]

    Tiers: mainline, extra
    Layers: core, mantle, crust

    Examples:
      swift run forge project core2b
      swift run forge project --list
      swift run forge project --list extra
      swift run forge project --list mantle
      swift run forge project --random
      swift run forge project --random extra mantle
    """)
}

func printAIGenerateUsage() {
    print("""
    Usage:
      swift run forge ai-generate [--dry-run] [--live] [--provider <name>] [--model <id>] [--out <path>]
      swift run forge ai-generate --help

    Options:
      --live              Opt in to live provider calls (not yet implemented).
      --dry-run           Writes scaffold output paths only. No model calls.
      --provider <name>   Provider key (default: phi).
      --model <id>        Model identifier (optional).
      --out <path>        Output directory (default: workspace_verify/ai_candidates).

    Notes:
      - Live mode must be explicitly enabled with --live.
      - This command is a scaffold for maintainer AI generation workflows.
      - Writes request.json, candidate.json, and report.json in the output directory.
      - Generated candidates are intended to land in workspace_verify/ai_candidates/.
      - Learner runtime flow is unchanged.
    """)
}

func printStatsUsage() {
    print("""
    Usage:
      swift run forge stats
      swift run forge stats --reset
      swift run forge stats --reset-all
      swift run forge stats --stats-limit <n>
      swift run forge stats --help

    Prints per-topic adaptive stats from workspace/.adaptive_stats.
    Per-challenge adaptive stats are stored in workspace/.adaptive_challenge_stats.
    Also shows top failing challenges when per-challenge stats are available.
    Also summarizes constraint violations from workspace/.performance_log with per-challenge detail.
    Use --reset to clear the stats file.
    Use --reset-all to clear stats, constraint mastery, and the performance log.
    Use --stats-limit to limit the number of topics shown in the summary table.
    """)
}

func printPracticeUsage() {
    print("""
    Usage:
      swift run forge practice [count] [topic] [tier] [layer] [core1|core2|core3|mantle1|mantle2|mantle3|crust1|crust2|crust3] [bridge] [--all]
      swift run forge practice --help

    Practice mode always uses adaptive weighting when stats are available.
    Filters match random mode: topics, tiers, layers, bridge.
    Bridge challenges are excluded unless you include the 'bridge' filter.
    By default, practice is limited to challenges you've already reached in the main flow,
    plus relevant extra challenges for layers you've reached.
    Use --all to practice across the entire curriculum.
    """)
}

func printReportUsage() {
    print("""
    Usage:
      swift run forge report

    Prints a summary of stage review results, constraint mastery state, and adaptive stats.
    """)
}

func printOverrideReportUsage() {
    print("""
    Usage:
      swift run forge report-overrides [--threshold <n>]

    Prints suggested extra parent overrides when an extra is far from its parent.
    """)
}

func printAuditUsage() {
    print("""
    Usage:
      swift run forge audit [filters] [bridge]

    Runs:
      - Sequencing review (early-concept warnings)
      - Constraint profile verification
      - Fixture presence audit
    Filters match verify-solutions/review-progression (range/topic/tier/layer/bridge).
    """)
}
