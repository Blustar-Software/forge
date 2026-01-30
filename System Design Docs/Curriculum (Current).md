# Current Curriculum

This document summarizes the curriculum as implemented in `Sources/forge/Challenges.swift`
(Challenges 1–311). For the authoritative per‑challenge list, use:

- `swift run forge catalog` (prints the table)
- `challenge_catalog.txt` (generated at repo root; keep in sync)
- `swift run forge catalog-projects` / `project_catalog.txt` for projects

## Structure Overview
- **Core mainline**: 81 challenges  
  - Core 1: 1–20  
  - Core 2: 21–42  
  - Core 3: 43–81  
- **Mantle mainline**: 35 challenges  
  - Includes bridge challenges 241–242 (tagged as Mantle).  
- **Crust mainline**: 56 challenges  
  - Includes bridge challenges 243–244 (tagged as Crust).  
- **Extras**: Core 75, Mantle 36, Crust 28  
  - Extras are spread across the global numbering range; use the catalog for exact ids.  
- **Total challenges**: 311

## Projects
### Core Projects (in default flow)
- core1a: Temperature Converter (pass 1)
- core2a: Forge Log Analyzer (pass 2)
- core3a: Forge Log Interpreter (pass 3)

### Mantle Projects (in default flow)
- mantle1a: Forge Inventory Model (pass 4)
- mantle2a: Component Inspector (pass 5)
- mantle3a: Task Manager (pass 6)

### Crust Projects (in default flow)
- crust1a: Async Client (pass 7)
- crust2a: Config DSL (pass 8)
- crust3a: Mini Framework (pass 9)

### Extra Projects (optional)
- core1b: Forge Checklist (pass 1)
- core1c: Ingot Calculator (pass 1)
- core2b: Inventory Audit (pass 2)
- core2c: Optional Readings (pass 2)
- core3b: Temperature Pipeline (pass 3)
- core3c: Event Router (pass 3)
- mantle1b: Shift Tracker (pass 4)
- mantle1c: Shared Controller (pass 4)
- mantle2b: Inspection Line (pass 5)
- mantle2c: Safe Heater (pass 5)
- mantle3b: Generic Stack (pass 6)
- mantle3c: Constraint Report (pass 6)
- crust1b: KeyPath Transformer (pass 7)
- crust1c: Task Orchestrator (pass 7)
- crust2b: Lazy Metrics (pass 8)
- crust2c: Feature Flags (pass 8)
- crust3b: Modular CLI Tool (pass 9)
- crust3c: DSL Builder (pass 9)

## Flow Notes
- Default flow gates a stage review before each project.
- Bridge challenges are tagged to Mantle/Crust and run at the end of those passes.
- Practice/random run in `workspace_practice/` and `workspace_random/`; main flow uses `workspace/`.
- Practice/adaptive stats are recorded to `workspace/.adaptive_stats` and `workspace/.adaptive_challenge_stats`.

## Practice Filters
Topics:
- conditionals
- loops
- optionals
- collections
- functions
- strings
- structs
- general

Tiers:
- mainline
- extra

Layers:
- core
- mantle
- crust

