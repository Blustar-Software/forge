# Session Log

## Current State
- Forge is a SwiftPM CLI with challenges defined in `Sources/forge/Challenges.swift` (now 1–56).
- Challenge headers live inside each `starterCode`; the CLI no longer prepends headers when writing files.
- Output validation trims whitespace/newlines before comparison.
- File watching includes a debounce to avoid mid-write validation.
- SwiftPM tests exist in `Tests/forgeTests/forgeTests.swift`, plus a check script at `scripts/check.sh`.
- Docs updated: `README.md` includes run/reset + learning overview; `AGENTS.md` includes structure + commands; `ROADMAP.md` added.
- System design docs added under `System Design Docs/`, including the phased FTS spec and an evolution roadmap.
- Core 3 Project A (`core3a`) is implemented and wired into the step flow after Core 3 challenges.

## Recent Changes
- Inserted Core 3 challenges 36–56 based on the draft list (deterministic versions for input/files/tests).
- Adjusted the Core 3 closure syntax challenge to use ASCII output ("deg").
- Added `System Design Docs/Forge Evolution.md` and `System Design Docs/03.1 Evolution Roadmap.md` to track future enhancements.
- Updated the FTS spec to phase heavy requirements and clarify compliance.
- Added Core 3 Project A (Forge Log Interpreter) with deterministic test output.

## Notes
- Core 2 project `core2a` requires tuple usage; tuples are now taught in Challenge 35.
- Core 3 challenges 52–56 simulate stdin/args/files/tests to keep deterministic validation.
- Test runs may require elevated permissions for SwiftPM cache access in sandboxed environments.
