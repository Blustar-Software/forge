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
- Current curriculum includes Challenges 1–250 in `Sources/forge/Challenges.swift`.
- Each stage ends with a brief stage review (three challenges repeated twice) before its project unlocks.
  - You can tune the review with `--gate-passes <n>` and `--gate-count <n>`.
- Stage review selection is deterministic by default; enable adaptive weighting with `--adaptive-on`.
- Forge blocks early-concept usage by default using heuristic checks; use `--allow-early-concepts` to warn only.
- Use `--disable-di-mock-heuristics` to ignore DI/mock heuristic checks.

## What you’ll learn
- Early challenges cover comments, constants, variables, and basic math.
- Later challenges add strings, booleans, comparisons, and functions.
- Integration challenges combine multiple concepts to reinforce learning.
- Core 3 includes a stepped closure sequence that moves from full syntax to shorthand.
- Crust introduces advanced topics like concurrency, actors, key paths, advanced language features, and professional practices.

## Run the CLI
```sh
swift run forge
```
When prompted, press Enter to check your work. Type `h` for a hint, `c` for a cheatsheet, or `s` for a solution (challenges and projects).
Use `swift run forge --help` for usage and `swift run forge <command> --help` for subcommands.

## Flags and options
Flow control:
- `--gate-passes <n>`: set the number of stage review passes (default 2).
- `--gate-count <n>`: set the number of challenges per stage review (default 3).

Constraints:
- `--allow-early-concepts`: warn instead of block early-concept usage.
- `--disable-di-mock-heuristics`: ignore DI/mock heuristic checks.
- `--disable-constraint-profiles`: skip Phase 2 constraint profiles when present.
- Phase 2 adds constraint profiles (per-challenge plus topic defaults) to enforce allowed imports/APIs and require certain constructs.
 - `swift run forge verify-solutions --constraints-only`: fast constraint-only scan (skips compilation).

Adaptive gating:
- `--adaptive-on`: enable adaptive practice in the main flow (off by default).
- `--adaptive-threshold <n>`: set the score threshold to queue practice (default 3).
- `--adaptive-count <n>`: set the number of adaptive practice challenges (default 3).
- `--adaptive-topic-failures <n>`: require N consecutive failures on the same topic before queueing (default 2).
- `--adaptive-challenge-failures <n>`: require N failures on the same challenge before queueing (default 2).
- `--adaptive-cooldown <n>`: cooldown in steps between adaptive queues (default 2).
- `--adaptive-off`: explicitly disable adaptive gating.

Confirmation:
- `--confirm-check`: require a second Enter before running checks.

## Stats
```sh
swift run forge stats
swift run forge stats --reset
swift run forge stats --reset-all
swift run forge stats --stats-limit 5
```
Stats also summarize constraint violations recorded in `workspace/.performance_log`.
Stats include constraint-violation counts by mode, topic, and challenge, plus a top-topic list.
Stats print a small topic summary table when constraint violations exist.
Use `--stats-limit` to cap the number of rows shown in the topic summary table.
Use `--reset-all` to clear adaptive stats, constraint mastery, and the performance log.
Per-challenge adaptive stats are stored in `workspace/.adaptive_challenge_stats`.

## Report
```sh
swift run forge report
```
Shows stage review summaries, constraint mastery state, and adaptive stats.

## Audit
```sh
swift run forge audit
swift run forge audit core
swift run forge audit 1-80
```
Runs sequencing review, constraint profile verification, and fixture presence checks (same filters as verify/review).

Stage review tuning examples:
```sh
swift run forge --gate-passes 1
swift run forge --gate-count 2
```

## Reset your progress
```sh
swift run forge reset
```
Reset clears progress and exits.
Reset also removes non-hidden files in `workspace/`, `workspace_random/`, `workspace_projects/`, and `workspace_verify/`.
To remove all files (including dotfiles) in those folders:
```sh
swift run forge reset --all
```
To reset and immediately start the flow:
```sh
swift run forge reset --start
```
To reset, wipe all files, and start:
```sh
swift run forge reset --all --start
```
Reset does not clear adaptive stats; use `swift run forge stats --reset` for that.
To clear stats and the performance log, use `swift run forge stats --reset-all`.

## Constraint smoke checks
Use `scripts/constraints_check.sh` to run a constraint-only sweep for core, mantle, and crust.

## Progress shortcuts
You can set `workspace/.progress` manually to jump ahead.
You can also use `swift run forge progress <target>` to update it for you.
You can also pass the same tokens directly to Forge (for example, `swift run forge challenge:36`).

- Challenge number: use `challenge:<number>` (e.g., `challenge:36`).
- Challenge id: use `challenge:<id>` for extras (e.g., `challenge:crust-extra-async-sleep`).
- Project id: use `project:<id>` or just `<id>` (case-insensitive).

Examples:
```
swift run forge challenge:36
swift run forge project:core2a
swift run forge core2a
swift run forge progress challenge:36
swift run forge progress project:core2a
swift run forge progress step:19
swift run forge verify-solutions core --constraints-only
challenge:36
challenge:crust-extra-async-sleep
project:core3a
core2a
```

## Fixtures for input/args/files
- Some challenges use fixture files in `fixtures/` to provide stdin, command-line arguments, or file input.
- Forge copies fixture files into the active workspace and injects stdin/args when needed, so the challenge stays deterministic.
- A few testing-focused challenges simulate XCTest in script form with a tiny stub so they compile under `swift` while still teaching the test structure.

## Constraint profiles (Phase 2)
- Constraints run before compilation and can block a check if they detect disallowed usage.
- Each challenge can define a `ConstraintProfile`, and topic-level profiles add defaults.
- Topic profiles currently:
  - `functions`: blocks stdin/argv by default.
  - `optionals`: requires optional usage; blocks stdin/argv by default.
  - `collections`: requires collection usage; blocks stdin/argv by default.
  - `strings`: blocks stdin/argv by default.
  - `conditionals`: blocks loop keywords (`for`, `while`, `repeat`).
  - `structs`: requires a `struct` definition.
- Some topic profiles also disallow advanced operations until they are introduced (for example, `map`/`filter`/`reduce` in collections, `??`/`guard` in optionals, string interpolation and higher-order collection ops in strings, error handling across topics, or switch/loop control and ranges in conditionals/loops).
- Challenge profiles can override topic requirements (e.g., disable `requireCollectionUsage`).
- Use `--disable-constraint-profiles` to skip profile enforcement.

## Projects
- Core projects in the default flow: `core1a`, `core2a`, `core3a`, `mantle1a`, `mantle2a`, `mantle3a`, `crust1a`, `crust2a`, `crust3a`.
- Extra projects (not in the default flow): `core1b`, `core1c`, `core2b`, `core2c`, `core3b`, `core3c`, `mantle1b`, `mantle1c`, `mantle2b`, `mantle2c`, `mantle3b`, `mantle3c`, `crust1b`, `crust1c`, `crust2b`, `crust2c`, `crust3b`, `crust3c`.
- To jump directly to a project, set `workspace/.progress` to `project:<id>` (case-insensitive).

## Random mode
- Run `swift run forge random` to practice a random set (default 5).
- Optional: add a count (e.g., `swift run forge random 10`).
- Optional: filter by topic (`conditionals`, `loops`, `optionals`, `collections`, `functions`, `strings`, `structs`, `general`).
- Optional: filter by tier (`mainline`, `extra`) and/or layer (`core`, `mantle`, `crust`).
- Optional: add `adaptive` to bias toward weaker topics.
- Add `--help` to print the random-mode filter list.
- Extra challenges (`tier: extra`) are intended for random practice and are not part of the main progression.
- Random mode uses `workspace_random/` so it does not overwrite your main `workspace/`.
- Examples:
  - `swift run forge random 8`
  - `swift run forge random conditionals`
  - `swift run forge random extra`
  - `swift run forge random 6 loops extra`
  - `swift run forge random 12 mainline`
  - `swift run forge random 10 mantle`
  - `swift run forge random --help`
  - `swift run forge random adaptive`

## Project mode
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

## Build
```sh
swift build
```

## Verify solutions
```sh
swift run forge verify-solutions
```
Optional filters (range/layer/topic/tier):
```
swift run forge verify-solutions 190-237
swift run forge verify-solutions crust
swift run forge verify-solutions loops extra
```

## Review progression
```sh
swift run forge review-progression
```
Uses the same optional filters (range/layer/topic/tier) to flag early concept usage in solutions:
```
swift run forge review-progression 1-80
swift run forge review-progression core
```

## Quick diagnostics
- `swift run forge review-progression` for early‑concept usage.
- `swift run forge verify-solutions` to confirm solution outputs.

## Stage review summary
Forge stores the last stage review summary in `workspace/.stage_gate_summary` with pass count and elapsed time per stage. Stage review challenge files are written to `workspace_review/`.

## Performance log (Phase 2+ stub)
Forge appends JSON lines to `workspace/.performance_log` for stage reviews and challenge/project attempts (event name, identifiers, result, elapsed time, timestamp).

## Adaptive stats (Phase 2+ stub)
Forge stores per-topic attempt counts in `workspace/.adaptive_stats` and per-challenge attempts in `workspace/.adaptive_challenge_stats` to support adaptive progression.

Format:
```
topic|pass=0,fail=0,compile_fail=0,manual_pass=0
```

Random mode now weights topic selection using these stats (more fails → higher weight), and adaptive random selection uses per-challenge recency + failures.
When adaptive is enabled, the main flow may insert short practice sets after repeated failures; practice is scoped to the same topic/layer, avoids the current challenge, and favors a recent window of nearby challenges.
Stats output includes a small "top failing challenges" list when per-challenge stats exist.
Constraint violation stats now include a per-challenge detail list for quick debugging.

To view stats:
```sh
swift run forge stats
```
To reset stats:
```sh
swift run forge stats --reset
```
