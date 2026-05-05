# Proposal - Engine Evolution: Scaffolding & Multi-File Context

## Status
**Draft** - Proposed following Audit of Crust Layer (Challenge 177).

## Context
The current "Single File Focus" model of Forge excels at isolating logic in the Core and Mantle stages. However, as the curriculum reaches the **Crust Layer** (Concurrency, Actors, SwiftPM), a "Paradigm Wall" has been identified. 

Lessons now require significant "plumbing" (e.g., `runAsync` loops, `DispatchSemaphores`, or `@main` wrappers) just to make the CLI environment compatible with the advanced feature being taught. This results in:
1. **High Cognitive Load:** Students must look past complex boilerplate to find the actual lesson.
2. **Noise over Signal:** The ratio of "taught code" to "scaffolding code" is inverted.
3. **Artificial Complexity:** Students are exposed to low-level runtime mechanics before they have mastered the high-level syntax.

## Objective
To evolve the Forge engine to support **Hidden Scaffolding** and **Implicit Contexts**, preserving the "Instrument Only" Link Trainer experience while removing the "Plumbing."

## Proposed Solutions

### 1. The "Support.swift" Hidden Layer
Introduce a mechanism where a challenge can include a `Support.swift` file that is compiled alongside the user's `challenge.swift` but is never shown in the workspace.
- **Benefit:** Moves `runAsync`, Mock Data, or Protocol definitions out of the user's sight.
- **Experience:** The user sees only the "Cockpit" (the lesson logic).

### 2. The "Pre-amble/Post-amble" Injection
Modify the `validateChallenge` logic to wrap the user's code in a hidden template before compilation.
- **Example:** The user writes `func fetch() async`, and Forge automatically wraps it in a `@main` struct or a `runAsync` block at compile-time.
- **Risk:** Error messages (line numbers) might become confusing if the compiler reports an error in the "hidden" part of the file.

### 3. The "Stage Evolution" (Multi-file)
Allow Crust-level challenges to exist as mini-packages.
- **Experience:** Forge sets up a 2-3 file workspace where `Main.swift` is the focus, but `Core.swift` holds the prerequisite architecture.

## Design Principles for Evolution
- **The "Link Trainer" Rule:** The user should only see the instruments they are currently learning to fly.
- **The "Checkride" Rule:** Complexity should be "earned." If the user didn't write it, and isn't learning it yet, it shouldn't be in the file.
- **Transparent Failure:** If the user's code causes a crash in the scaffolding, the error must be mapped back to the user's logic, not the hidden boilerplate.

## Next Steps
1. Prototype a "Hidden Scaffolding" loader in `CurriculumLoader.swift`.
2. Refactor Challenge 177 (Async/Await) to use this loader.
3. Verify if the "Slog" is reduced and the "Signal" is clearer.
