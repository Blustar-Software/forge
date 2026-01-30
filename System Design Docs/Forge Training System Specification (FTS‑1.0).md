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
- **FTS‑1.1** Each unit shall target a single primary skill.
- **FTS‑1.2** Secondary concepts shall not be introduced until the primary skill is demonstrated.
- **FTS‑1.3** Multi‑skill scenarios shall only unlock after prerequisite units are completed.

## 3.2 Repeatability
- **FTS‑3.1** Units shall be repeatable with identical initial conditions.
- **FTS‑3.2** Deterministic behavior shall be preserved for a given configuration.
- **FTS‑3.3** The learner shall be able to repeat any unit without penalty.

Implementation note: Mainline challenges provide an immediate repeat option after a pass that resets the file to starter code and does not advance progress.

## 3.3 Safe Failure
- **FTS‑4.1** Errors shall be non‑destructive and contained.
- **FTS‑4.2** Failures shall be diagnostic, not punitive.
- **FTS‑4.3** The system shall recover cleanly from errors.

## 3.4 Immediate Feedback
- **FTS‑5.1** Provide pass/fail validation and show expected vs actual output where applicable.

## 3.5 Progressive Difficulty
- **FTS‑6.1** Difficulty shall increase only after demonstrated competence.
- **FTS‑6.2** Each stage shall build directly on the previous one.

## 3.6 Scenario Clarity
- **FTS‑7.1** Each unit shall define a clear objective, constraints, and success criteria.
- **FTS‑7.2** Scenarios shall be structured and single‑skill where possible.

## 3.7 Syllabus‑Driven Progression
- **FTS‑12.1** The system shall define a hierarchical syllabus.
- **FTS‑12.2** Each stage shall include entry and exit criteria.
- **FTS‑12.3** Learners shall not bypass stages without demonstrated competence.

## 3.8 Modular Architecture
- **FTS‑13.1** Units shall be modular and independently loadable.
- **FTS‑13.2** Modules shall compose into higher‑order skills.

# 4. Phase 1 Implementation Notes
## 4.1 Adaptive Practice (Opt‑in)
Adaptive practice uses per‑topic performance and per‑challenge recency to weight selections in practice/random modes and adaptive gates. Adaptive is opt‑in; default progression remains deterministic.

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
- Enforce per‑challenge constraints beyond heuristic token checks.
- Restrict APIs/imports based on profile.

## 5.2 Adaptive Engine v2
- Make adaptive on by default (with opt‑out).
- Add stability gates and scaffolding variants.

## 5.3 Constraint Mastery Ladder
- Soft warn → hard fail → relax based on performance.

## 5.4 Debriefing
- Stage debriefs summarizing pass rate, weak topics, and time.
- Recommendations and next steps.

# 6. Compliance Summary (Current)
- **Determinism**: Mainline deterministic; practice/random/adaptive are nondeterministic.
- **Repeatability**: Manual‑check units remain environment‑sensitive.
- **Adaptive integrity**: Assisted passes tracked; practice queued when adaptive is enabled.
- **Constraint enforcement**: Heuristic (token‑level) and opt‑out is available for early‑concept checks.

# 7. Non‑Goals
- Not a general Swift IDE.
- Not an open‑ended project environment.
- Not a replacement for documentation.
