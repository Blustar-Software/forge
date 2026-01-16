# Curriculum Changes Log

## 2026-01-08
- Rebuilt Core 1 challenge sequence to explicitly cover type inference and make arithmetic, compound assignment, comparison, and logical operators exhaustive.
- Reordered Core 1 to keep math and operator coverage before strings, booleans, and functions.
- Reorganized Core 2 to introduce ranges without properties, add a collection-properties challenge after arrays/loops, and move tuples closer to collections.
- Added an "Array Metrics" challenge to prepare for Core 2 Project A (min/max/average/overheat count).
- Expanded Core 3 with a slower closure ramp (basic closure -> parameters -> trailing -> shorthand -> capture), and moved higher-order functions after closure fundamentals.
- Added explicit tuple and enum micro-sequences (raw tuple -> labeled tuple -> typealias -> struct; basic enum -> raw values -> associated values -> pattern matching).
- Added missing topic coverage for void argument labels and strengthened guidance for variadics, inout, nested functions, throwing, and simulated IO/test challenges.
- Updated Core 2 project guidance for tuple returns; expanded Core 3 project instructions for parsing/aggregation steps.

## 2026-01-08 (Fixes)
- Repaired corrupted `makeProjects()` block in `Sources/forge/Challenges.swift` after curriculum edits.
- Normalized all `expectedOutput` strings to escaped `\n` forms.
- Escaped interpolation in project starter code so `\(report.*)` stays literal in strings.
- Restored `getCurrentProgress` in `Sources/forge/forge.swift` to keep tests compiling.

## 2026-01-08 (Core 2 Arrays/Collections Pass)
- Added a basic array-creation challenge before append/count.
- Renumbered Core 2 to 19–39 and Core 3 to 40–70 to keep a clean sequence.
- Expanded Collection Properties to cover `count`, `isEmpty`, `first` (with `??`), and dictionary `keys.count`.

## 2026-01-09 (Core 3 min/max)
- Added a Core 3 `min()`/`max()` challenge after `reduce` and renumbered Core 3 to 40–71.

## 2026-01-09 (Core 3 Closure Compression)
- Added closure compression steps for stored and trailing closures (implicit return, inferred types) and inserted a non-trailing closure argument challenge before trailing syntax.
- Added Shorthand Closure Syntax I/II (assigned vs trailing) and an annotated closure assignment challenge; renumbered Core 3 to accommodate the new sequence.
- Moved the annotated closure assignment to sit with assigned-closure steps before argument/trailing closure challenges.

## 2026-01-10 (Hints & Solutions)
- Added progressive hints and solution snippets for all challenges and projects.
- Removed inline hint comments from starter code and stored them in structured fields.

## 2026-01-10 (Tuples Placement)
- Removed tuple challenges from Core 3 and expanded the Core 2 tuple challenge to include positional access.

## 2026-01-10 (Structs Placement)
- Removed the Structs challenge from Core 3 to align with the Mantle roadmap section.

## 2026-01-11 (Random Practice + Extras)
- Added challenge topics/tiers to support future random/adaptive modes.
- Introduced extra fundamentals challenges (conditionals, loops, optionals, collections, functions) for practice variety.
- Added new Core 3 fundamentals coverage (string methods, dictionary iteration, struct basics) and extended total challenges to 1–88.
- Added a random practice mode in the CLI (`swift run forge random`) with optional count/topic/tier filters.

## 2026-01-11 (Extra Projects)
- Added extra projects for each core level (core1b/core1c, core2b/core2c, core3b/core3c) with tier metadata.
- Kept extra projects out of the default flow; they are accessible via `project:<id>` progress tokens.

## 2026-01-12 (Hints + Cheatsheets)
- Added a cheatsheet command (`c`) and attached cheatsheets to challenges and projects.
- Created shared topic cheatsheets and project-specific cheatsheets.
- Rewrote Core 1–3 challenge hints and Core 1–3 project hints to follow the hint rules.

## 2026-01-12 (Tuple Returns Placement)
- Moved tuple-return coverage into Core 2 (Challenge 40) to precede the Core 2 project.
- Renumbered Core 3 challenges to 41–78 and kept totals at 1–88.

## 2026-01-13 (Extra Core Expansion)
- Added 20 extra challenges across conditionals, loops, collections, functions, and optionals.
- Expanded total challenges to 1–108.

## 2026-01-13 (Strings, Comparisons, Ranges Extras)
- Added 12 extra challenges for strings, comparison operators, and ranges practice.
- Expanded total challenges to 1–120.

## 2026-01-13 (Mantle Challenge Stubs)
- Added Mantle challenge stubs (121–153) with placeholder manual-check outputs.
- Added cheatsheets for classes, properties, protocols, extensions, access control, generics, and memory.
- Expanded total challenges to 1–153.

## 2026-01-13 (Mantle Wiring)
- Wired Mantle challenges into the main CLI flow and random mode.

## 2026-01-13 (Mantle 1 Implemented)
- Implemented Mantle 1 challenges (121–134) with expected output, hints, and solutions.

## 2026-01-13 (Mantle 2 Implemented)
- Implemented Mantle 2 challenges (135–144) with expected output, hints, and solutions.

## 2026-01-13 (Mantle 3 Implemented)
- Implemented Mantle 3 challenges (145–153) with expected output, hints, and solutions.

## 2026-01-13 (Mantle Projects)
- Added Mantle core projects: mantle1a, mantle2a, mantle3a.
- Wired Mantle projects into the main flow after Mantle challenges.

## 2026-01-13 (Mantle Project Gating)
- Interleaved Mantle challenges with pass-level projects (121–134 → mantle1a, 135–144 → mantle2a, 145–153 → mantle3a).

## 2026-01-13 (Mantle Extra Projects)
- Added Mantle extra projects: mantle1b, mantle1c, mantle2b, mantle2c, mantle3b, mantle3c.

## 2026-01-13 (Mantle Extra Challenges)
- Added 18 Mantle extra challenges (154–171) spanning structs/properties, protocols/extensions/errors, and generics/ARC.
- Expanded total challenges to 1–171.

## 2026-01-16 (Status)
- Core + Mantle challenges and projects are implemented and wired into the CLI.
- Crust layer is planned but not yet built.
