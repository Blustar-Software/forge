*Forge Training System (FTS) — Formal Specification*

---

# 1. Scope
This document defines the Forge Training System (FTS): a controlled, repeatable Swift training environment that develops operational fluency through structured units, constraints, and adaptive feedback. It is not an IDE or tutorial system.

# 2. Definitions
- **Unit**: A single, focused training exercise (challenge or project) with a clear objective and success criteria.
- **Stage**: A contiguous sequence of units grouped by syllabus intent (e.g., Core 1, Mantle 2).
- **Scenario**: The narrative wrapper and constraints around a unit’s objective.
- **Mastery**: Demonstrated stability in correctness, speed, and technique under defined constraints.
- **Constraint**: A deliberate restriction on tools, syntax, inputs, or environment to shape correct technique.

# 3. Requirements (Phase 1 Baseline)
## 3.1 Skill Isolation
- **FTS‑1.1** Each unit shall target a single primary skill. (Implemented via challenge design and `Sources/forge/Challenges.swift` structure.)
- **FTS‑1.2** Secondary concepts shall not be introduced until the primary skill is demonstrated. (Reflected in sequential challenge progression and `requires` metadata.)
- **FTS‑1.3** Multi‑skill scenarios shall only unlock after prerequisite units are completed. (Enforced by challenge sequencing and stage gates.)

## 3.2 Repeatability
- **FTS‑3.1** Units shall be repeatable with identical initial conditions. (Mainline challenges are repeatable via starter code reset.)
- **FTS‑3.2** Deterministic behavior shall be preserved for a given configuration. (Mainline challenges are deterministic.)
- **FTS‑3.3** The learner shall be able to repeat any unit without penalty. (Supported by repeat functionality.)

Implementation note: Mainline challenges provide an immediate repeat option after a pass that resets the file to starter code and does not advance progress.

## 3.3 Safe Failure
- **FTS‑4.1** Errors shall be non‑destructive and contained. (Swift's error handling and CLI sandboxing provide containment.)
- **FTS‑4.2** Failures shall be diagnostic, not punitive. (Compiler/runtime errors and output diffs serve diagnostic purposes.)
- **FTS‑4.3** The system shall recover cleanly from errors. (System allows retries after failure.)

## 3.4 Immediate Feedback
- **FTS‑5.1** Provide pass/fail validation and show expected vs actual output where applicable. (Implemented via challenge validation logic comparing actual vs. expected output.)

## 3.5 Progressive Difficulty
- **FTS‑6.1** Difficulty shall increase only after demonstrated competence. (Achieved through staged progression and challenge sequencing.)
- **FTS‑6.2** Each stage shall build directly on the previous one. (Syllabus structure ensures this.)

## 3.6 Scenario Clarity
- **FTS‑7.1** Each unit shall define a clear objective, constraints, and success criteria. (Defined in challenge JSONs: `description`, `constraints`, `expectedOutput`.)
- **FTS‑7.2** Scenarios shall be structured and single‑skill where possible. (Core design principle reflected in challenge structure.)

## 3.7 Syllabus‑Driven Progression
- **FTS‑12.1** The system shall define a hierarchical syllabus. (Implemented via staged JSON files like `core1_challenges.json`, `mantle2_challenges.json`, etc., aggregated by `CurriculumLoader.swift`.)
- **FTS‑12.2** Each stage shall include entry and exit criteria. (Stage gates mentioned in Flow Notes and implemented via progression logic.)
- **FTS‑12.3** Learners shall not bypass stages without demonstrated competence. (Enforced by the sequential nature of the default flow.)

## 3.8 Modular Architecture
- **FTS‑13.1** Units shall be modular and independently loadable. (Supported by separate JSON files per stage, loaded by `CurriculumLoader.swift`.)
- **FTS‑13.2** Modules shall compose into higher‑order skills. (Challenges build upon each other to form skills.)

# 4. Phase 1 Implementation Notes
## 4.1 Adaptive Practice (Opt‑in)
Adaptive practice uses per‑topic performance and per‑challenge recency to weight selections in practice/random modes and adaptive gates. Adaptive is opt‑in; default progression remains deterministic. (Current implementation status: Partially Implemented; opt-in for adaptive features as described.)

## 4.2 Assisted Solutions
- Pre‑pass solution access is allowed with confirmation and recorded as `pass_assisted`.
- Viewing a solution before a pass queues a short practice set after completion (when adaptive is enabled).
- Post‑pass solution access is penalty‑free.

## 4.3 Performance Logging
- Attempts and timing: `workspace/.performance_log`
- Adaptive topic stats: `workspace/.adaptive_stats`
- Per‑challenge stats: `workspace/.adaptive_challenge_stats`
- Reporting: `swift run forge report` and `swift run forge practice --report`

# 5. Phase 2+ Targets (Design Intent)
## 5.1 Controlled Environment
- Enforce per‑challenge constraints beyond heuristic token checks. (Planned; currently uses heuristic token checks. `Sources/forge/Constraints/ConstraintDetectors.swift` and `Constraints/ConstraintRules.swift` are key modules for this.)
- Restrict APIs/imports based on profile.

## 5.2 Adaptive Engine v2
- Make adaptive on by default (with opt‑out). (Planned feature)
- Add stability gates and scaffolding variants.

## 5.3 Constraint Mastery Ladder
- Soft warn → hard fail → relax based on performance. (Design intent for future enhancement.)

## 5.4 Debriefing
- Stage debriefs summarizing pass rate, weak topics, and time. (Planned feature.)
- Recommendations and next steps.

# 6. Compliance Summary (Current)
- **Determinism**: Mainline deterministic; practice/random/adaptive are nondeterministic.
- **Repeatability**: Manual-check units remain environment-sensitive (as noted in FTS-3.3).
- **Adaptive integrity**: Assisted passes tracked; practice queued when adaptive is enabled.
- **Constraint enforcement**: Heuristic (token-level) and opt-out is available for early-concept checks via `Sources/forge/Constraints/ConstraintDetectors.swift` and `Constraints/ConstraintRules.swift`.

# 7. Non‑Goals
- Not a general Swift IDE.
- Not an open‑ended project environment.
- Not a replacement for documentation.
