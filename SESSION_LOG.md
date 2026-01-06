# Session Log

## Current State
- Forge is a SwiftPM CLI with challenges defined in `Sources/forge/Challenges.swift` (now 1–35).
- Challenge headers live inside each `starterCode`; the CLI no longer prepends headers when writing files.
- Output validation trims whitespace/newlines before comparison.
- File watching includes a debounce to avoid mid-write validation.
- SwiftPM tests exist in `Tests/forgeTests/forgeTests.swift`, plus a check script at `scripts/check.sh`.
- Docs updated: `README.md` includes run/reset + learning overview; `AGENTS.md` includes structure + commands; `ROADMAP.md` added.

## Recent Changes
- Inserted full-numbered challenges to cover missing topics: compound assignment, logical operators, pattern matching, ranges, and tuples.
- Renumbered Core 1 and Core 2 challenges to remove x.5 entries and updated headers/expected outputs accordingly.
- Updated docs to reflect the expanded challenge count.

## Notes
- Core 2 project `core2a` requires tuple usage; tuples are now taught in Challenge 35.
- Test runs may require elevated permissions for SwiftPM cache access in sandboxed environments.
