# Forge Beginner Manual

This is a step‑by‑step, no‑stress guide to using Forge. If you are brand‑new to programming or Swift, start here.

---

## 1) What Forge Is
Forge is a training environment for learning Swift by doing small, focused challenges.
You edit a generated file, run a check, and move forward.

You do **not** need to set up a project or IDE. You only need a terminal and a text editor.

---

## 2) What You Need Installed
- **macOS** with Xcode installed (or Swift toolchain).
- A **text editor** (VS Code, Xcode, Zed, etc.).
- Terminal access.

If `swift` is not available, install Xcode and open it once so it finishes setup.

---

## 3) First Run (Start Here)
In a terminal:

```bash
swift run forge
```

Forge will generate a challenge file and tell you where it is:

```
Edit: workspace/challenge-core-1.swift
```

Open that file in your editor and follow the TODOs.

---

## 4) How A Challenge Works
Each challenge looks like this:

- You edit the file shown in the prompt.
- Press **Enter** in the terminal to check your work.
- If the output matches, the challenge is complete.

While you’re in a challenge:
- `h` = hint
- `c` = cheatsheet
- `l` = lesson
- `s` = solution (requires confirmation)

After you pass:
- Press **Enter** to continue
- Or type **r** to repeat the same challenge

Repeat resets the file to starter code and does not advance progress.

---

## 5) Where Your Files Live
Forge generates files in these folders:

- `workspace/` → main progression
- `workspace_practice/` → practice mode
- `workspace_random/` → random mode
- `workspace_projects/` → projects

You only edit the file Forge tells you to edit.

---

## 6) Resume Later (Progress)
Progress is stored in:

```
workspace/.progress
```

If you stop and run `swift run forge` again, it resumes automatically.

---

## 7) Reset Progress
To reset everything:

```bash
swift run forge reset
```

To reset **progress + stats**:

```bash
swift run forge reset --all
```

---

## 8) Jump To A Specific Challenge
Use the `challenge:<number>` syntax:

```bash
swift run forge challenge:60
```

You can also include a layer:

```bash
swift run forge challenge:core:60
swift run forge challenge:mantle:10
```

To see a full list of challenge IDs:

```bash
swift run forge catalog
```

Note: Jumping does **not** change your saved progress unless you explicitly set it.

To set progress safely, use the progress command:

```bash
swift run forge progress challenge:core:60
swift run forge progress project:core2a
swift run forge progress step:19
```

---

## 9) Practice Mode (Focused Review)
Practice gives you challenges from your current progress.

```bash
swift run forge practice
```

Optional filters:

```bash
swift run forge practice 8
swift run forge practice loops
swift run forge practice core
swift run forge practice --all
```

To see what practice is using:

```bash
swift run forge practice --report
```

---

## 9.1) Adaptive Mode (Optional)
Adaptive mode adjusts practice and review based on your performance.
If you view a solution before passing, Forge can queue a short practice set.

You can enable it like this:

```bash
swift run forge --adaptive-on
```

You can also combine it with a jump:

```bash
swift run forge challenge:60 --adaptive-on
```

---

## 10) Random Mode (Wide Practice)
Random ignores progress and pulls from the full pool.

```bash
swift run forge random
swift run forge random 10
swift run forge random optionals
swift run forge random extra
```

---

## 11) Projects
Projects are longer challenges.

```bash
swift run forge project --list
swift run forge project core2a
swift run forge project --random
```

---

## 12) Common Problems (Quick Fixes)

**“No such module ‘XCTest’”**
- You likely need Xcode installed or to run Xcode once to finish setup.

**Build fails in terminal**
- Run `swift build` to see errors.
- Make sure you’re in the repo root.

**Challenge output doesn’t match**
- The output must match exactly (same lines, same text).
- Extra warnings count as output too.

---

## 13) Tips To Move Faster
- Use hints before solutions.
- If you view a solution before passing, Forge will mark it “assisted.”
- Use repeat (`r`) after a pass to lock in the idea.
- Practice mode is for reinforcement; main flow is for progression.

---

## 14) Want A Catalog
Print the challenge and project catalogs:

```bash
swift run forge catalog
swift run forge catalog-projects
```

These also generate:
- `challenge_catalog.txt`
- `project_catalog.txt`

---

## 15) Getting Back On Track
If you feel stuck:
1. Run practice mode on the topic you’re failing.
2. Use the lesson and cheatsheet.
3. Repeat the challenge once you pass.

---

That’s it. Open the file Forge gives you, edit, press Enter, and keep going.
