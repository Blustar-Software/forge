# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` defines a single Swift Package Manager executable target named `forge`.
- `Sources/forge/forge.swift` contains the CLI entry point and all challenge logic.
- `workspace/` holds generated challenge files (`challenge1.swift`, etc.) and the `.progress` marker used to resume.

## Build, Test, and Development Commands
- `swift build`: builds the executable.
- `swift run forge`: runs the CLI and starts (or resumes) the challenge flow.
- `swift run forge reset`: clears `workspace/.progress` and deletes generated `workspace/challenge*.swift` files.

## Coding Style & Naming Conventions
- Use Swift’s standard formatting with 4-space indentation and a line length that keeps code readable.
- Follow Swift API Design Guidelines: `lowerCamelCase` for functions/variables, `UpperCamelCase` for types.
- Keep string literals readable; prefer multiline strings for banner output as in `forge.swift`.
- No formatter or linter is configured; keep changes consistent with existing style.

## Testing Guidelines
- No automated tests or test target are configured in `Package.swift`.
- Manual verification is done by running the CLI and editing files in `workspace/` until output matches expected values.
- If adding tests, consider adding a SwiftPM test target and name tests `SomethingTests` with `testX()` methods.

## Commit & Pull Request Guidelines
- This directory is not a Git repository, so commit conventions cannot be derived from history.
- If a repo is initialized later, prefer short, imperative commit subjects (e.g., "Add challenge 7").
- PRs should describe the user-visible behavior change (CLI output, challenge flow) and include steps to verify.

## Configuration Notes
- Progress is stored in `workspace/.progress`; deleting it resets the starting challenge.
- Challenge files are generated and overwritten by the CLI; avoid committing edited challenge files unless intentional.
