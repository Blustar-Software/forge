# forge

Forge is a beginner-friendly Swift CLI that serves interactive coding challenges and checks your output.

## Quickstart
```sh
swift run forge
```
Edit the generated file in `workspace/`, then press Enter to check. Use `h` for a hint, `c` for a cheatsheet, and `s` for a solution.

## How it works
- Generates a challenge file in `workspace/` and waits for you to press Enter to check.
- Runs your edited Swift file and compares its output to the expected answer.
- Tracks progress in `workspace/.progress` so you can resume later.
- Current curriculum includes Challenges 1–88 in `Sources/forge/Challenges.swift`.

## What you’ll learn
- Early challenges cover comments, constants, variables, and basic math.
- Later challenges add strings, booleans, comparisons, and functions.
- Integration challenges combine multiple concepts to reinforce learning.
- Core 3 includes a stepped closure sequence that moves from full syntax to shorthand.

## Run the CLI
```sh
swift run forge
```
When prompted, press Enter to check your work. Type `h` for a hint, `c` for a cheatsheet, or `s` for a solution (challenges and projects).

## Reset your progress
```sh
swift run forge reset
```

## Progress shortcuts
You can set `workspace/.progress` manually to jump ahead.

- Challenge number: use `challenge:<number>` (e.g., `challenge:36`).
- Project id: use `project:<id>` or just `<id>` (case-insensitive).

Examples:
```
challenge:36
project:core3a
core2a
```

## Manual-check challenges
- Some challenges (real CLI/file I/O) require you to run the generated file yourself and verify the output manually. Forge will label these as manual checks; press Enter after you run them to mark complete.

## Projects
- Core projects in the default flow: `core1a`, `core2a`, `core3a`.
- Extra projects (not in the default flow): `core1b`, `core1c`, `core2b`, `core2c`, `core3b`, `core3c`.
- To jump directly to a project, set `workspace/.progress` to `project:<id>` (case-insensitive).

## Random mode
- Run `swift run forge random` to practice a random set (default 5).
- Optional: add a count (e.g., `swift run forge random 10`).
- Optional: filter by topic (`conditionals`, `loops`, `optionals`, `collections`, `functions`, `strings`, `structs`, `general`) or tier (`core`, `extra`).
- Extra challenges (`tier: extra`) are intended for random practice and are not part of the main progression.
- Random mode uses `workspace_random/` so it does not overwrite your main `workspace/`.
- Examples:
  - `swift run forge random 8`
  - `swift run forge random conditionals`
  - `swift run forge random extra`
  - `swift run forge random 6 loops extra`
  - `swift run forge random 12 core`

## Project mode
- Run `swift run forge project <id>` to launch a specific project (example: `swift run forge project core2b`).
- When the project passes, its generated file is deleted from `workspace_projects/`.
- Project mode uses `workspace_projects/` so it does not overwrite your main `workspace/`.

## Build
```sh
swift build
```
