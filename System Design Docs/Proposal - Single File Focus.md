# Proposal: Single File Focus Model for Forge

## 1. Objective
Currently, Forge generates a new Swift file for every challenge (e.g., `challenge-core-1.swift`, `challenge-core-2.swift`), leading to a cluttered `workspace/` directory. This proposal suggests moving to a "Single File Focus" model, where a single designated file is "flashed" with the current challenge's starter code, concentrating all practice in one place and reinforcing the "crucible" philosophy of Forge.

## 2. Proposed Strategies

### Strategy A: The "Pure" Single File (The Forge.swift Model)
Every challenge is written to the exact same file (e.g., `workspace/Challenge.swift`).
*   **Experience**: The user stays in one file for the entire stage. Tab clutter is eliminated.
*   **Pros**:
    *   Maximum focus.
    *   Simple implementation.
    *   Aligns with Forge’s emphasis on "The Work" in the moment.
*   **Cons**:
    *   No local history of previous work.
    *   Users must rely on the Forge catalog or memory to reference past solutions.
*   **Implementation**: Update `loadChallenge` to always use a hardcoded filename.

### Strategy B: The "Active File" with Archive
Challenges are written to `workspace/Challenge.swift`. Upon a successful pass, the file is renamed to its canonical name and moved to an `archive/` folder.
*   **Experience**: The active area is always clean, but the history of your work is preserved nearby.
*   **Pros**:
    *   Maintains a clean active workspace.
    *   Preserves a record of the learner's specific solutions.
*   **Cons**:
    *   Increased file system complexity.
    *   The user still has to deal with many files in the `archive/` folder if they want to clean it up.
*   **Implementation**: Modify `validateChallenge` to move the passed file into an `archive/` directory.

### Strategy C: The "Playground as Main" Model
Utilize the existing `forge_playground.playground` as the primary workspace. The challenge instructions and starter code are written directly into the playground's `Contents.swift`.
*   **Experience**: Deep integration with Xcode Playgrounds. The user gets the benefit of live execution while completing challenges.
*   **Pros**:
    *   Interactive and immediate.
    *   No separate `.swift` files required.
*   **Cons**:
    *   Playgrounds can be slower to load or more resource-heavy than simple scripts.
    *   The "Single File" is hidden inside a directory package (`.playground`).
*   **Implementation**: Redirect all `loadChallenge` write operations to the playground's internal `Contents.swift`.

### Strategy D: The "Flashed" Challenge Comment
The challenge instructions are "flashed" as a multi-line comment at the top of the single working file.
*   **Experience**: The file contains its own context. The user reads the instructions in their editor, writes the code below, and runs it.
*   **Pros**:
    *   The editor is the only tool needed (no switching back to CLI for every detail).
    *   Context is always visible alongside the code.
*   **Cons**:
    *   Can make the file feel "heavy" if the lesson content is long.
*   **Implementation**: Update `loadChallenge` to prepend the challenge description and lesson as a comment block.

## 3. Comparative Summary

| Strategy | Focus | History | Complexity | Philosophical Alignment |
| :--- | :--- | :--- | :--- | :--- |
| **A: Pure Single File** | Maximum | None | Very Low | Highest (The Crucible) |
| **B: Archive Model** | High | Preserved | Moderate | High |
| **C: Playground Main** | High | None | Moderate | High (Interactive) |
| **D: Comment Flash** | High | None | Low | High (Focus) |

## 4. Design Questions
1.  **File Naming**: Should it be `Challenge.swift`, `Practice.swift`, or `Forge.swift`?
2.  **Referencing Past Work**: Is the loss of local history a feature (forcing recall) or a bug?
3.  **The Playground Role**: If we move to a single file model, does the separate `forge_playground` still have a distinct purpose, or do they merge?

## 5. Next Steps
*   Gather feedback on the preferred strategy.
*   Determine if "History" is required or if Forge should prioritize memory and repetition.
*   Prototyping Strategy A or D for a single stage.

---
*Brainstorming note: Moving to a single-file focus reinforces the idea that Forge is a place where you work on 'The Thing' until it is done, then move on to the next 'Thing' in the same spot.*
