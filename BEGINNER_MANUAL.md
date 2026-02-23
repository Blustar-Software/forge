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

## 3.1) Run `forge` Without `swift run` (Optional)
If you want to run Forge like any normal command, build it once and put it on your `PATH`.

Build the release binary:
```bash
swift build -c release
```

Then choose one:

Option A: symlink into a PATH directory (recommended)
```bash
ln -s "$(pwd)/.build/release/forge" /usr/local/bin/forge
```

Option B: copy into a PATH directory
```bash
cp "$(pwd)/.build/release/forge" /usr/local/bin/forge
```

If `/usr/local/bin` is not on your `PATH`, use `~/.local/bin` instead:
```bash
mkdir -p ~/.local/bin
ln -s "$(pwd)/.build/release/forge" ~/.local/bin/forge
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

After that, you can run:
```bash
forge
```

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
- `t` = AI tutor
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

### 5.1) Using the Playground (`forge_playground.playground`)
You can use `forge_playground.playground` located in your `workspace/` directory to quickly test Swift code snippets outside the current challenge. This is useful for:
- Experimenting with new syntax.
- Testing assumptions without affecting your challenge file.
- Trying out different approaches before committing to your solution.

To use it:
1.  Open `workspace/forge_playground.playground` in Xcode.
2.  Type your Swift code in the playground.
3.  View instant results in the Xcode results area.

Note: Changes to this playground do not affect your challenge progress and it won't be overwritten by Forge.

---

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

To reset and also remove all generated files in workspace folders (including dotfiles):

```bash
swift run forge reset --all
```

To reset and immediately start the flow again:

```bash
swift run forge reset --start
```

To clear stats:

```bash
swift run forge stats --reset
swift run forge stats --reset-all
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

## 11.1) Tutor (Optional)
The main way to open the tutor is from a challenge/project prompt by typing:

```bash
t
```

You can also run Tutor in another terminal while Forge is open:

```bash
swift run forge tutor
```

How it behaves:
- Tutor follows your current challenge/project automatically.
- If you move to another challenge, go back, or choose to redo/repeat, Tutor clears and resets to the new context.
- If Forge stops, Tutor stops too.

Requirements:
- Ollama must be running (`http://localhost:11434`).
- You need at least one local model (example: `ollama pull llama3`).

Tutor commands:
- `model` picks the AI model and remembers it for future sessions.
- `reset` clears the current tutor chat.
- `exit` closes Tutor mode.

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

These commands are your curriculum map: they show IDs and titles so you can browse the path without opening source files.

These also generate:
- `challenge_catalog.txt`
- `project_catalog.txt`

---

## 15) If You Explore The Source (Optional)
- Curriculum data is in `Sources/forge/Curriculum/*.json`.
- JSON is loaded by `Sources/forge/CurriculumLoader.swift`.
- Challenge/project model types are in `Sources/forge/Challenges.swift`.
- CLI parsing/help lives in `Sources/forge/CLI.swift`.
- Progress/stats persistence lives in `Sources/forge/Storage/Stores.swift`.
- Constraint tokenization/detectors live in `Sources/forge/Constraints/ConstraintDetectors.swift`.

---

## 16) Getting Back On Track
If you feel stuck:
1. Run practice mode on the topic you’re failing.
2. Use the lesson and cheatsheet.
3. Repeat the challenge once you pass.

---

## 17) Advanced Command Index
If you want deeper tooling beyond day-to-day challenge work:

- `swift run forge stats` -> performance/adaptive summaries (`--reset`, `--reset-all`, `--stats-limit`).
- `swift run forge report` -> stage review + mastery + adaptive summary.
- `swift run forge report-overrides` -> suggested extra-parent remaps.
- `swift run forge verify-solutions [filters] [--constraints-only]` -> check solution files at scale.
- `swift run forge review-progression [filters]` -> sequencing/early-concept review.
- `swift run forge audit [filters]` -> review + constraints + fixture presence.
- `swift run forge state-export [file]` -> export progress/state snapshot.
- `swift run forge state-import [file]` -> import progress/state snapshot.
- `swift run forge remap-progress [target]` -> convert legacy numeric challenge targets.

Use `swift run forge --help` for the full command surface and examples.
Use `README.md` for the detailed reference.

---

That’s it. Open the file Forge gives you, edit, press Enter, and keep going.
