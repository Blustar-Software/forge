# forge

Forge is a beginner-friendly Swift CLI that serves interactive coding challenges and checks your output.

## How it works
- Generates a challenge file in `workspace/` and waits for you to press Enter to check.
- Runs your edited Swift file and compares its output to the expected answer.
- Tracks progress in `workspace/.progress` so you can resume later.
- Current curriculum includes Challenges 1–74 in `Sources/forge/Challenges.swift`.

## What you’ll learn
- Early challenges cover comments, constants, variables, and basic math.
- Later challenges add strings, booleans, comparisons, and functions.
- Integration challenges combine multiple concepts to reinforce learning.
- Core 3 includes a stepped closure sequence that moves from full syntax to shorthand.

## Run the CLI
```sh
swift run forge
```
When prompted, press Enter to check your work. Type `h` for a hint or `s` for a solution (challenges and projects).

## Reset your progress
```sh
swift run forge reset
```

## Jump to a challenge or project
You can set `workspace/.progress` manually to jump ahead.

- Challenge number: use `challenge:<number>` (e.g., `challenge:36`).
- Project id: use `project:<id>` or just `<id>` (case-insensitive).

Examples:
```
challenge:36
project:core3a
core2a
```

## Build
```sh
swift build
```
