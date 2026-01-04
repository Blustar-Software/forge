# forge

Forge is a beginner-friendly Swift CLI that serves interactive coding challenges and checks your output.

## How it works
- Generates a challenge file in `workspace/` and watches for edits.
- Runs your edited Swift file and compares its output to the expected answer.
- Tracks progress in `workspace/.progress` so you can resume later.

## Run the CLI
```sh
swift run forge
```

## Reset your progress
```sh
swift run forge reset
```

## Build
```sh
swift build
```
