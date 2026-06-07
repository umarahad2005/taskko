# Taskko Agent System

A multi-agent build system for **Taskko** (see `../docs/SRS.md`). It defines the **skills**, **agents**, **subagents**, and **workflows** that build the app, and a **master orchestration** layer that assigns, monitors, and coordinates them in real time across the SRS milestones (M1–M9).

## Folder layout
```
agents/
├── README.md                  ← you are here (overview + legend)
├── master-orchestration.md    ← the controller: dependency graph, live status board, control loop
├── skills/                    ← reusable knowledge packs (the "how-to" + project conventions)
├── agents/                    ← primary agents: own a whole surface (app / backend / admin / release / QA)
├── subagents/                 ← narrow workers spawned by agents for one focused task
└── workflows/                 ← ordered orchestration per milestone (M1–M9)
```

## How the pieces relate
- **Skills** = capability + knowledge (design tokens, BLoC conventions, Gemini prompting). Agents and subagents *load* skills; they don't act on their own.
- **Agents** = persistent owners of a surface. They plan a milestone, spawn subagents, integrate results, and report status to the master.
- **Subagents** = single-purpose workers with a strict input/output contract (e.g. "build one screen", "write one Cubit", "author one API endpoint").
- **Workflows** = the recipe for a milestone: which agents/subagents run, in what order, what's parallel, and the exit criteria (mapped to SRS FRs).
- **Master orchestration** = the real-time brain. Holds the dependency graph + live status board, decides what runs now, enforces quality gates between milestones, and handles blocks/handoffs.

## Conventions
- Every agent/subagent/skill file has YAML frontmatter (`name`, `description`, `tools`, `model`) so it can double as an actual Claude Code subagent definition.
- Every deliverable traces to an SRS requirement (`FR-x.y` / `NFR-x` / `§n`).
- Subagents return **structured output** (a small JSON-like result block) so the master can track state without re-reading files.
- Source of truth for visuals: `../design_reference/project/frames/*.png`; tokens in SRS §7.

## How to run it
1. Open `master-orchestration.md` → check the **Live Status Board** for the active milestone.
2. Run that milestone's `workflows/mN-*.md`.
3. The owning **agent** spawns its **subagents** (each loads the relevant **skills**), integrates, and reports back.
4. The master applies the milestone's **quality gate**; on pass, it unblocks the next milestone.

> This is a planning/coordination layer. It does not replace the SRS — it operationalizes it.
