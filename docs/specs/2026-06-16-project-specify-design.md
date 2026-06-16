# agentflow:project-specify — Design Spec

**Date:** 2026-06-16
**Status:** Approved (pending written review)

## Problem

The agentflow pipeline (`project-orchestrate` → `phase-execute` → `task-implement` → `project-status`) has no front-end for turning a raw idea into a structured project. Users currently rely on the superpowers `brainstorming` skill for the design dialogue, but that skill **hard-codes its terminal state to `superpowers:writing-plans`** — which produces a flat `docs/superpowers/plans/*.md` file, not agentflow's `.tasks/` phased structure.

The result: after a spec is written, the user must *explicitly* redirect the agent into agentflow's `project-orchestrate`. Nothing routes there automatically. The handoff seam between "spec" and "agentflow planning" is the entire pain point.

## Goal

Add a self-contained agentflow skill, **`agentflow:project-specify`**, that owns the design dialogue end-to-end and hands off to `project-orchestrate` instead of `writing-plans`. It replaces `superpowers:brainstorming` for agentflow project work.

## Non-Goals (YAGNI)

- No separate planning layer (`af-plan`). `project-orchestrate` *is* the planner — it already converts a `brief.md` (with a `phases:` list) into the `.tasks/` structure. Adding a planning skill between spec and `.tasks/` would duplicate it.
- No agentflow-native discipline skills (TDD, debugging, verification) in this iteration.
- No code-review / branch-finishing skills in this iteration.
- No Codex port in this iteration (Claude-only first; the skill is agent-agnostic and can be ported later).
- No separate `docs/specs/` artifact at runtime — the `brief.md` doubles as the reviewable spec.

## Design

### Behavior

`project-specify` mirrors the disciplined dialogue of `superpowers:brainstorming`:

1. Explore project context (files, docs, recent commits).
2. Interview the user **one question at a time** (multiple-choice preferred) to establish purpose, constraints, and success criteria.
3. Propose **2–3 approaches** with trade-offs and a recommendation.
4. Present the design in sections scaled to complexity; get approval after each.
5. Write **`brief.md`** in the repo root.
6. Spec self-review (placeholder scan, internal consistency, scope, ambiguity).
7. Ask the user to review `brief.md`.
8. **Terminal state:** invoke `agentflow:project-orchestrate` (never `writing-plans`).

A `<HARD-GATE>`: no implementation, no scaffolding, no invoking `project-orchestrate` until the design is presented and the user approves the written `brief.md`.

### The handoff seam

`project-orchestrate`'s Bootstrap path already reads `brief.md` and supports these fields:

```yaml
title: My App
goal: |
  What the project builds and why.
repo: private           # public | private
phases:
  - name: Foundation
    goal: Set up database, auth, and core models
  - name: API Layer
    goal: REST endpoints for all resources
```

So `project-specify`'s job is to **fill `brief.md` completely** — including the phase breakdown and a `repo:` choice — then invoke `project-orchestrate`, which skips its own interview (brief exists) and builds `.tasks/`.

`brief.md` carries the structured fields **plus** a free-form `## Design` / `## Rationale` section capturing approaches considered and the decision, so the single file doubles as the reviewable spec. One artifact, not two.

### Flow

```
user: "let's build X"
   ↓
agentflow:project-specify
   - interview (one Q at a time)
   - propose 2-3 approaches + recommendation
   - present design sections, get approval
   - write brief.md  (title/goal/repo + phases[] + design narrative)
   - user reviews brief.md
   ↓ (hard-coded terminal — Skill: agentflow:project-orchestrate)
agentflow:project-orchestrate   ← reads brief.md, builds .tasks/
   ↓
phase-execute → task-implement
```

### Winning the trigger over superpowers

Both skills claim the same "before creative work" territory, so two reinforcing mechanisms make `project-specify` win:

1. A strong `description` triggering on "new project," "build X," "new feature," "design this," "plan this project," "spec this out."
2. A routing line in this repo's `CLAUDE.md` (and optionally the user's global one): *"For new project work, prefer `agentflow:project-specify` over `superpowers:brainstorming`."* This is the reliable tie-breaker.

## Files Changed

- **Create** `skills/agentflow/project-specify/SKILL.md` — the skill (frontmatter `name: project-specify` must match folder).
- **Modify** `.claude-plugin/marketplace.json` — add `"./project-specify"` to the agentflow plugin's `skills` array.
- **Modify** `CLAUDE.md` — document the skill in the agentflow table + add the routing tie-breaker rule.
- **Modify** `README.md` — document the skill and the brainstorm→orchestrate flow.

## Acceptance Criteria

- [ ] `skills/agentflow/project-specify/SKILL.md` exists; `name` frontmatter equals `project-specify`.
- [ ] `name` passes the agentskills.io rules (lowercase, hyphens, ≤64 chars).
- [ ] SKILL.md body < 500 lines.
- [ ] Skill dialogue produces a `brief.md` whose fields match `project-orchestrate`'s documented `brief.md` schema (`title`, `goal`, `repo`, `phases[]`).
- [ ] Skill's terminal step invokes `agentflow:project-orchestrate`, not `writing-plans`.
- [ ] `marketplace.json` lists `"./project-specify"` under agentflow and the path resolves.
- [ ] `CLAUDE.md` documents the skill and the routing tie-breaker.
- [ ] `README.md` documents the skill.
