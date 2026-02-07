# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` defines one executable target (`forge`) and one test target (`forgeTests`), and copies `Sources/forge/Curriculum/` as bundled resources.
- `Sources/forge/App/forge.swift` is the executable entrypoint plus shared rendering/output helpers.
- Runtime logic is modularized:
  - CLI parsing/help: `Sources/forge/CLI.swift`
  - Command routing and app coordination: `Sources/forge/App/CommandHandlers.swift`, `Sources/forge/App/FlowRunner.swift`, `Sources/forge/App/RuntimeContext.swift`
  - Learning flows: `Sources/forge/Flow/ChallengeFlow.swift`, `Sources/forge/Flow/PracticeFlow.swift`, `Sources/forge/Flow/ProjectFlow.swift`
  - Persistence/migrations: `Sources/forge/Storage/Stores.swift`, `Sources/forge/Storage/WorkspaceStore.swift`
  - Constraints: `Sources/forge/Constraints/ConstraintEngine.swift`, `Sources/forge/Constraints/ConstraintRules.swift`, `Sources/forge/Constraints/ConstraintDetectors.swift`, `Sources/forge/Constraints/ConstraintDiagnostics.swift`, `Sources/forge/Constraints/ConstraintTopicProfiles.swift`, `Sources/forge/Constraints/ConstraintMasteryStore.swift`
  - Catalog output: `Sources/forge/Catalog.swift`
- `Sources/forge/Challenges.swift` defines shared model types (`Challenge`, `Project`, enums, profiles).
- `Sources/forge/Curriculum/*.json` is the curriculum source of truth (mainline, extras, bridge, projects).
- `Sources/forge/CurriculumLoader.swift` decodes JSON resources into model arrays.
- `workspace/` holds generated main-flow challenge files and `.progress`.
- `workspace_random/`, `workspace_practice/`, `workspace_projects/`, `workspace_review/`, and `workspace_verify/` isolate other modes.

## Build, Test, and Development Commands
- `swift build`: builds the executable.
- `swift run forge`: runs the CLI and starts (or resumes) the challenge flow.
- `swift run forge reset`: clears `workspace/.progress` and deletes generated `workspace/challenge*.swift` files.
- `swift run forge catalog`: prints a challenge catalog map and writes `challenge_catalog.txt`.
- `swift run forge catalog-projects`: prints a project catalog map and writes `project_catalog.txt`.
- `scripts/check.sh`: runs the automated checks (`swift test`).

## Coding Style & Naming Conventions
- Use Swift’s standard formatting with 4-space indentation and a line length that keeps code readable.
- Follow Swift API Design Guidelines: `lowerCamelCase` for functions/variables, `UpperCamelCase` for types.
- Keep string literals readable; use multiline strings for usage/help text where appropriate.
- No formatter or linter is configured; keep changes consistent with existing style.

## Testing Guidelines
- SwiftPM tests live in `Tests/forgeTests/` and run with `swift test`.
- Manual verification is done by running the CLI and editing files in `workspace/` until output matches expected values.
- Name test classes `SomethingTests` and test methods `testX()` to match SwiftPM defaults.
- For CLI behavior checks, prefer non-interactive smoke commands first (for example `--help`, `catalog`, `project --list`, `stats --help`).

## Commit & Pull Request Guidelines
- This is a Git repository with semver-style release tags (`v0.3.x` currently).
- Prefer short, imperative commit subjects (for example, "Simplify architecture and externalize curriculum data").
- Keep commits scoped to one intent (curriculum data update, flow logic change, docs sync, etc.).
- Release tags are annotated (`Release vX.Y.Z`) and should point to the release commit.
- PRs should describe the user-visible behavior change (CLI output, challenge flow) and include steps to verify.

## Configuration Notes
- Progress is stored in `workspace/.progress`; deleting it resets the starting challenge.
- Challenge files are generated and overwritten by the CLI; avoid committing edited challenge files unless intentional.
- The catalog commands are the intended "curriculum map" for learners who do not want to inspect source JSON/files.
- During challenges/projects, press Enter to check your work; use `h` for hints, `c` for cheatsheets, `l` for lessons, and `s` for solutions.
- You can set `workspace/.progress` to jump to a specific challenge or project:
  - Challenge number: `challenge:36` starts at Challenge 36.
  - Challenge id: `challenge:crust-extra-async-sleep` starts at that extra challenge.
  - Project id: `project:core2a` or `core3a` (case-insensitive).
- Use `swift run forge remap-progress <target>` to translate legacy challenge numbers after renumbering.

Manual-check challenges
- Some challenges (real CLI/file I/O) require running the generated file manually and verifying output yourself. Forge labels these as manual checks; press Enter after you run them to mark complete.

Projects
- Core projects in the default flow: `core1a`, `core2a`, `core3a`, `mantle1a`, `mantle2a`, `mantle3a`, `crust1a`, `crust2a`, `crust3a`.
- Extra projects (not in the default flow): `core1b`, `core1c`, `core2b`, `core2c`, `core3b`, `core3c`, `mantle1b`, `mantle1c`, `mantle2b`, `mantle2c`, `mantle3b`, `mantle3c`, `crust1b`, `crust1c`, `crust2b`, `crust2c`, `crust3b`, `crust3c`.
- To jump directly to a project, set `workspace/.progress` to `project:<id>` (case-insensitive).

Random mode
- Run `swift run forge random` to practice a random set (default 5).
- Optional: add a count (e.g., `swift run forge random 10`).
- Optional: filter by topic (`conditionals`, `loops`, `optionals`, `collections`, `functions`, `strings`, `structs`, `classes`, `properties`, `protocols`, `extensions`, `accessControl`, `errors`, `generics`, `memory`, `concurrency`, `actors`, `keyPaths`, `sequences`, `propertyWrappers`, `macros`, `swiftpm`, `testing`, `interop`, `performance`, `advancedFeatures`, `general`).
- Optional: filter by tier (`mainline`, `extra`) and/or layer (`core`, `mantle`, `crust`).
- Optional: include `bridge` to pull only bridge challenges.
- Optional: include `adaptive` to bias selection toward weaker topics/stale challenges.
- Add `--help` to print the random-mode filter list.
- Extra challenges are for random practice and are not part of the main progression.
- Random mode uses `workspace_random/` so it does not overwrite your main `workspace/`.
- Examples:
  - `swift run forge random 8`
  - `swift run forge random conditionals`
  - `swift run forge random extra`
  - `swift run forge random 6 loops extra`
  - `swift run forge random 12 mainline`
  - `swift run forge random 10 mantle`
  - `swift run forge random --help`

Project mode
- Run `swift run forge project <id>` to launch a specific project (example: `swift run forge project core2b`).
- Use `swift run forge project --list` to list projects; add tier/layer filters as needed.
- Use `swift run forge project --random` to pick a random project; add tier/layer filters as needed.
- Add `--help` to print project-mode usage and filters.
- When the project passes, its generated file is deleted from `workspace_projects/`.
- Project mode uses `workspace_projects/` so it does not overwrite your main `workspace/`.

Project tiers: `mainline`, `extra`  
Project layers: `core`, `mantle`, `crust`

Examples:
```
swift run forge project --list
swift run forge project --list extra
swift run forge project --list mantle
swift run forge project --random
swift run forge project --random extra mantle
swift run forge project --help
```
