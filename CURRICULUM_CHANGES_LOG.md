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
