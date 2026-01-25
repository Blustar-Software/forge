# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` defines a single Swift Package Manager executable target named `forge`.
- `Sources/forge/forge.swift` contains the CLI entry point and all challenge logic.
- `Sources/forge/Challenges.swift` defines `Challenge` data and the curriculum (currently 1–254).
- `workspace/` holds generated challenge files (`challenge-core-1.swift`, etc.) and the `.progress` marker used to resume.
  - Core 3 includes a stepped closure sequence from full syntax to shorthand.

## Build, Test, and Development Commands
- `swift build`: builds the executable.
- `swift run forge`: runs the CLI and starts (or resumes) the challenge flow.
- `swift run forge reset`: clears `workspace/.progress` and deletes generated `workspace/challenge*.swift` files.
- `scripts/check.sh`: runs the automated checks (`swift test`).

## Coding Style & Naming Conventions
- Use Swift’s standard formatting with 4-space indentation and a line length that keeps code readable.
- Follow Swift API Design Guidelines: `lowerCamelCase` for functions/variables, `UpperCamelCase` for types.
- Keep string literals readable; prefer multiline strings for banner output as in `forge.swift`.
- No formatter or linter is configured; keep changes consistent with existing style.

## Testing Guidelines
- SwiftPM tests live in `Tests/forgeTests/` and run with `swift test`.
- Manual verification is done by running the CLI and editing files in `workspace/` until output matches expected values.
- Name test classes `SomethingTests` and test methods `testX()` to match SwiftPM defaults.

## Commit & Pull Request Guidelines
- This directory is not a Git repository, so commit conventions cannot be derived from history.
- If a repo is initialized later, prefer short, imperative commit subjects (e.g., "Add challenge 7").
- PRs should describe the user-visible behavior change (CLI output, challenge flow) and include steps to verify.

## Configuration Notes
- Progress is stored in `workspace/.progress`; deleting it resets the starting challenge.
- Challenge files are generated and overwritten by the CLI; avoid committing edited challenge files unless intentional.
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
- Optional: filter by topic (`conditionals`, `loops`, `optionals`, `collections`, `functions`, `strings`, `structs`, `general`).
- Optional: filter by tier (`mainline`, `extra`) and/or layer (`core`, `mantle`, `crust`).
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
