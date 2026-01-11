# Session Log

## Current State
- Forge is a SwiftPM CLI with challenges defined in `Sources/forge/Challenges.swift` (now 1–74).
- Challenge headers live inside each `starterCode`; the CLI no longer prepends headers when writing files.
- Output validation trims whitespace/newlines before comparison.
- Challenge and project checks are triggered manually by pressing Enter.
- SwiftPM tests exist in `Tests/forgeTests/forgeTests.swift`, plus a check script at `scripts/check.sh`.
- Docs updated: `README.md` includes run/reset + learning overview; `AGENTS.md` includes structure + commands; `ROADMAP.md` added.
- Challenges and projects now support stored hints and solutions.

## Recent Changes
- Rebuilt Core 1 to explicitly cover type inference and make arithmetic, compound assignment, comparison, and logical operators exhaustive.
- Reordered Core 2 to introduce ranges without properties, add a collection-properties challenge after arrays/loops, and move tuples closer to collections.
- Added an Array Metrics challenge to prepare learners for Core 2 Project A.
- Expanded Core 3 with a slower closure ramp and added explicit tuple and enum micro-sequences.
- Added void-argument label coverage and more guidance in variadics, inout, nested functions, error handling, and simulated I/O/test challenges.
- Added guidance to Core 2 and Core 3 projects to improve preparation for tuple and parsing work.
- Inserted a basic array-creation challenge before append/count; expanded collection properties coverage.
- Renumbered Core 2 to 19–39 and Core 3 to 40–70, then to 40–71 after adding min/max.
- Added a Core 3 `min()`/`max()` challenge after `reduce`.
- Repaired `makeProjects()` and normalized `expectedOutput` strings after curriculum edits; restored `getCurrentProgress` for tests.
- Added a non-trailing closure call challenge before trailing closures; added block-comment hints for early closures with fully expanded closure literals.
- Expanded the Core 3 closure sequence with compression steps (implicit return, inferred types, inferred trailing closures), added a Shorthand Closure Syntax I/II split, and moved the annotated closure assignment to sit with assigned-closure steps.
- Logged curriculum changes in `CURRICULUM_CHANGES_LOG.md`.
- Ran `scripts/check.sh`; build and tests passed.
- Replaced file watching with manual Enter-to-check flow; added hint/solution commands in the CLI for challenges and projects.
- Ran `scripts/check.sh` after enabling project hints; build and tests passed.
- Migrated inline starter hints into `hints` and `solution` fields for closure and collection challenges.
- Populated hints and solutions for all challenges and projects.
- Ran `scripts/check.sh`; build and tests passed.
- Moved tuple reinforcement into Core 2 and removed tuple challenges from Core 3.
- Ran `scripts/check.sh`; build and tests passed.
- Removed Structs from Core 3 to align with the roadmap; renumbered subsequent challenges.
- Ran `scripts/check.sh`; build and tests passed.
- Rewrote all challenge and project hints to be more actionable and less redundant.
- Updated hints for challenges 1–30 to per-block guidance and regenerated hints for challenges 31–74 and projects from solution blocks.

## Notes
- Core 2 project `core2a` requires tuple usage; tuples are now taught in Core 2.
- Test runs may require elevated permissions for SwiftPM cache access in sandboxed environments.
