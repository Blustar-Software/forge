# Forge Evolution Roadmap: Toward the Ultimate Crucible

## 1. Vision Statement
Forge is a controlled training environment designed to develop operational fluency in Swift through structured repetition, constraint-based learning, and skill isolation. This roadmap outlines the architectural and pedagogical evolutions required to transition Forge from a linear challenge runner to a dynamic, mastery-driven learning engine.

---

## 2. Phase 1: The "Workbench" Model (Single-File Focus)
**Objective**: Eliminate file system "noise" and concentrate the learner’s focus on a persistent working area.

### 2.1 Strategy: Dynamic Flash
*   **The Change**: Replace individual challenge files (e.g., `challenge-124.swift`) with a single designated file: `workspace/Workbench.swift`.
*   **Mechanism**:
    1.  Upon loading a challenge, Forge "flashes" the starter code into `Workbench.swift`.
    2.  The challenge instructions and lesson are prepended as a multi-line comment block (The "Comment Flash").
    3.  `Workbench.swift` is tracked by Git, but its contents are overwritten at the start of every session/challenge.
*   **Benefit**: Users never have to switch tabs or manage workspace clutter. The editor becomes a persistent workbench.

---

## 3. Phase 2: Mastery-Based Progression (Adaptive Gates)
**Objective**: Transition from linear progression to performance-based reinforcement.

### 3.1 Friction Detection
*   **Tracking**: Record time-to-pass and total error counts (compilation vs. logic) per challenge.
*   **The Logic**: If a learner’s metrics exceed a "Struggle Threshold" for a specific concept (e.g., Optionals), Forge triggers an **Adaptive Reinforcement Event**.

### 3.2 Dynamic Remediation
*   **Remediation**: Before unlocking the next mainline challenge, Forge injects 2–3 "Remedial Drills" targeting the weak concept.
*   **Drill Generation**: These drills use the same logic as the mainline but with varied scenarios or slightly modified syntax requirements to force generalization.

---

## 4. Phase 3: Advanced Socratic AI (Deep Conceptual Inquiry)
**Objective**: Move the AI Tutor from "Helpful Assistant" to "Deep Instructor."

### 4.1 Constraint-Driven Tutoring
*   **The "No-Code" Rule**: Update the AI system prompt to strictly forbid providing code solutions.
*   **Conceptual Redirects**: When a user asks "How do I fix this error?", the tutor responds by asking about the underlying concept (e.g., "What does it mean for a value type to be 'mutating'?").
*   **Earned Revelation**: Code snippets are only revealed after the learner has correctly answered a conceptual question related to their current hurdle.

---

## 4.2 Diagnostic Context Analysis
*   **The Change**: The AI should analyze not just the current code, but the *history of failures* in the current challenge to identify recurring patterns of misunderstanding.

---

## 5. Phase 4: Integrated Narratives (The Modular Forge)
**Objective**: Transform projects into a cohesive system-building experience.

### 5.1 The "Forge Controller" Project
*   **Current State**: 15 projects are isolated scenarios (Valves, Sensors, Ingots).
*   **Future State**: Projects across a Layer (e.g., Core 1-3) build toward a single persistent module.
    *   **Core 1a**: Temp Converter.
    *   **Core 2a**: Log Analyzer (uses the converter).
    *   **Core 3a**: Event Router (manages the analyzer).
*   **Benefit**: Learners see their code compose into a complex, functional system, reinforcing architectural principles like dependency injection and protocol boundaries.

---

## 6. Implementation Priority
| Priority | Phase | Title | Effort | Impact |
| :--- | :--- | :--- | :--- | :--- |
| **1** | 1 | The Workbench | Low | High (UX/Focus) |
| **2** | 3 | Socratic AI | Moderate | High (Deep Learning) |
| **3** | 2 | Mastery Gates | High | Very High (Pedagogy) |
| **4** | 4 | Integrated Narratives | High | Moderate (Motivation) |

---
*Roadmap Note: Every evolution step must adhere to the Forge Philosophy: No noise. No shortcuts. Only the work.*
