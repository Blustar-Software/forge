# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` defines a single Swift Package Manager executable target named `forge`.
- `Sources/forge/forge.swift` contains the CLI entry point and all challenge logic.
- `Sources/forge/Challenges.swift` defines `Challenge` data and the curriculum (currently 1–88).
- `workspace/` holds generated challenge files (`challenge1.swift`, etc.) and the `.progress` marker used to resume.
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
- During challenges/projects, press Enter to check your work; use `h` for hints and `s` for solutions.
- You can set `workspace/.progress` to jump to a specific challenge or project:
  - Challenge number: `challenge:36` starts at Challenge 36.
  - Project id: `project:core2a` or `core3a` (case-insensitive).

Manual-check challenges
- Some challenges (real CLI/file I/O) require running the generated file manually and verifying output yourself. Forge labels these as manual checks; press Enter after you run them to mark complete.

Projects
- Core projects in the default flow: `core1a`, `core2a`, `core3a`.
- Extra projects (not in the default flow): `core1b`, `core1c`, `core2b`, `core2c`, `core3b`, `core3c`.
- To jump directly to a project, set `workspace/.progress` to `project:<id>` (case-insensitive).

Random mode
- Run `swift run forge random` to practice a random set (default 5).
- Optional: add a count (e.g., `swift run forge random 10`).
- Optional: filter by topic (`conditionals`, `loops`, `optionals`, `collections`, `functions`, `strings`, `structs`, `general`) or tier (`core`, `extra`).
- Extra challenges are for random practice and are not part of the main progression.
- Random mode uses `workspace_random/` so it does not overwrite your main `workspace/`.
- Examples:
  - `swift run forge random 8`
  - `swift run forge random conditionals`
  - `swift run forge random extra`
  - `swift run forge random 6 loops extra`
  - `swift run forge random 12 core`

Project mode
- Run `swift run forge project <id>` to launch a specific project (example: `swift run forge project core2b`).
- When the project passes, its generated file is deleted from `workspace_projects/`.
- Project mode uses `workspace_projects/` so it does not overwrite your main `workspace/`.
