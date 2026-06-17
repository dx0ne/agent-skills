# agentflow:project-specify — Design Spec

**Date:** 2026-06-16
**Status:** Approved (pending written review)

## Problem

The agentflow pipeline (`project-orchestrate` → `phase-execute` → `task-implement` → `project-status`) has no front-end for turning a raw idea into a structured project. Users currently rely on the superpowers `brainstorming` skill for the design dialogue, but that skill **hard-codes its terminal state to `superpowers:writing-plans`** — which produces a flat `docs/superpowers/plans/*.md` file, not agentflow's `.tasks/` phased structure.

The result: after a spec is written, the user must *explicitly* redirect the agent into agentflow's `project-orchestrate`. Nothing routes there automatically. The handoff seam between "spec" and "agentflow planning" is the entire pain point.

Separately, `project-orchestrate`'s current input contract uses two fixed-name files in the repo root — `brief.md` (Bootstrap) and `extension.md` (Extend). A fixed name can hold only one spec at a time, has no provenance, and gives the user no way to keep or point at a *particular* spec across a project's life.

## Goal

1. Add a self-contained agentflow skill, **`agentflow:project-specify`**, that owns the design dialogue end-to-end and hands off to `project-orchestrate` instead of `writing-plans`. It replaces `superpowers:brainstorming` for agentflow project work.
2. Replace `project-orchestrate`'s fixed-name input files (`brief.md`, `extension.md`) with a **dated-spec folder** at `.tasks/specs/`, holding immutable `YYYY-MM-DD-<slug>.md` specs selected by content, with consumption tracked in `project.md`.

## Non-Goals (YAGNI)

- No separate planning layer (`af-plan`). `project-orchestrate` *is* the planner — it converts a selected spec (with a `phases:` list) into the `.tasks/` structure. A planning skill between spec and `.tasks/` would duplicate it.
- No agentflow-native discipline skills (TDD, debugging, verification) this iteration.
- No code-review / branch-finishing skills this iteration.
- No Codex port of `project-specify` itself (Claude-only first; agent-agnostic, portable later). **Note:** the spec-folder contract change *does* touch the existing Codex `project-orchestrate` and `project-status`, because the input contract must stay identical across both trees.
- No separate `docs/specs/` artifact at runtime — the dated spec in `.tasks/specs/` *is* the reviewable spec.

## Design

### Spec storage & naming

- Specs live in **`.tasks/specs/`**, one file per spec, named **`YYYY-MM-DD-<slug>.md`**. No fixed `spec.md` / `brief.md` name — `project-orchestrate` selects by scanning the folder and reading frontmatter, not by filename.
- Specs are **immutable history**: never edited or deleted after consumption (unlike today's `extension.md`, which is deleted after use).
- At bootstrap, `.tasks/` does not yet exist; `project-specify` creates `.tasks/specs/` and writes the first spec there. `project-orchestrate` then builds the rest of `.tasks/` around it without clobbering `specs/`.

### Spec file format

**Bootstrap spec** (`kind: bootstrap`):
```yaml
---
kind: bootstrap
title: My App
repo: private            # public | private
date: 2026-06-17
goal: |
  What the project builds and why.
phases:
  - name: Foundation
    goal: Set up database, auth, and core models
  - name: API Layer
    goal: REST endpoints for all resources
---
## Design
<approaches considered, the decision, rationale — the reviewable narrative>
```

**Extension spec** (`kind: extension`) — mirrors today's `extension.md` shape; `title`/`repo` already live in `project.md`:
```yaml
---
kind: extension
date: 2026-07-02
phases:
  - name: UI Polish
    goal: Address feedback from user testing
    exit-criteria: |
      - All flagged issues resolved
---
## Notes
<free-form context to read before generating tasks>
```

The structured fields drive `project-orchestrate`; the prose sections make the file double as the reviewable spec. One artifact, not two.

### Selection & consumption

- **Explicit wins:** if the user/skill names a spec (e.g. "orchestrate `.tasks/specs/2026-06-17-auth.md`"), use it.
- **Otherwise:** consume the newest *unconsumed* spec by date prefix. If exactly one unconsumed spec exists, use it; if several, list them and ask which.
- **Consumed-tracking lives in `project.md`**, not in the spec files. `project.md` gains a `## Specs` provenance log:
  ```markdown
  ## Specs
  - specs/2026-06-17-auth-system.md (bootstrap) → phases 1-3
  - specs/2026-07-02-billing.md (extension) → phases 4-5
  ```
  "Unconsumed" = a file in `.tasks/specs/` not listed in this log. After building phases from a spec, `project-orchestrate` appends its entry here.
- **Mode is inferred from state**, validated against `kind`: no `.tasks/project.md` → Bootstrap (expect `kind: bootstrap`); `project.md` exists → Extend (expect `kind: extension`). A mismatch is an error, not an auto-fix.
- **Backward compatibility:** if `.tasks/specs/` has no usable spec, fall back to a root `brief.md` (bootstrap) or `extension.md` (extend), treated as deprecated.

### project-specify behavior

Mirrors the disciplined dialogue of `superpowers:brainstorming`:

1. Explore project context (files, docs, recent commits).
2. Interview the user **one question at a time** (multiple-choice preferred): purpose, constraints, success criteria.
3. Propose **2–3 approaches** with trade-offs and a recommendation.
4. Present the design in sections scaled to complexity; get approval after each.
5. Detect mode: `.tasks/project.md` absent → write a `kind: bootstrap` spec; present → `kind: extension`.
6. Write `.tasks/specs/YYYY-MM-DD-<slug>.md` (creating `.tasks/specs/` if needed).
7. Spec self-review (placeholder scan, internal consistency, scope, ambiguity).
8. Ask the user to review the written spec file.
9. **Terminal state:** invoke `agentflow:project-orchestrate`, passing the spec path (never `writing-plans`).

A `<HARD-GATE>`: no implementation, no scaffolding, no invoking `project-orchestrate` until the design is presented and the user approves the written spec.

### Flow

```
user: "let's build X"
   ↓
agentflow:project-specify
   - interview (one Q at a time)
   - propose 2-3 approaches + recommendation
   - present design sections, get approval
   - write .tasks/specs/2026-06-17-x.md  (kind: bootstrap)
   - user reviews the spec file
   ↓ (hard-coded terminal — Skill: agentflow:project-orchestrate <spec path>)
agentflow:project-orchestrate
   - selects spec, builds .tasks/, logs it under ## Specs
   ↓
phase-execute → task-implement
```

### Winning the trigger over superpowers

Both skills claim the same "before creative work" territory, so two reinforcing mechanisms make `project-specify` win:

1. A strong `description` triggering on "new project," "build X," "new feature," "design this," "plan this project," "spec this out."
2. A routing line in this repo's `CLAUDE.md` (and optionally the user's global one): *"For new project work, prefer `agentflow:project-specify` over `superpowers:brainstorming`."*

## Files Changed

**New skill:**
- **Create** `skills/agentflow/project-specify/SKILL.md` — frontmatter `name: project-specify` must match folder.

**Spec-folder contract (both trees):**
- **Modify** `skills/agentflow/project-orchestrate/SKILL.md` — read selected spec from `.tasks/specs/`; selection + `## Specs` log; rewrite Extend flow to consume `kind: extension` specs; `brief.md`/`extension.md` as deprecated fallbacks; update diagrams/schema.
- **Modify** `codex-skills/project-orchestrate/SKILL.md` — same.
- **Modify** `codex-skills/project-orchestrate/agents/openai.yaml` — "from a brief" → "from a spec".
- **Modify** `skills/agentflow/project-status/SKILL.md` — detect *unconsumed specs* in `.tasks/specs/` (vs. the `## Specs` log) instead of root `extension.md`.
- **Modify** `codex-skills/project-status/SKILL.md` — same.

**Registration + docs:**
- **Modify** `.claude-plugin/marketplace.json` — add `"./project-specify"` to agentflow's `skills` array.
- **Modify** `CLAUDE.md` — document the skill, the routing tie-breaker, and the `.tasks/specs/` contract.
- **Modify** `README.md` — document `project-specify`, the specify→orchestrate flow, and the spec-folder contract.

## Acceptance Criteria

- [ ] `skills/agentflow/project-specify/SKILL.md` exists; `name` frontmatter equals `project-specify`; passes agentskills.io name rules; body < 500 lines.
- [ ] `project-specify` writes `.tasks/specs/YYYY-MM-DD-<slug>.md` with `kind` and the documented fields, and its terminal step invokes `agentflow:project-orchestrate` (not `writing-plans`).
- [ ] `project-orchestrate` (both trees) selects a spec from `.tasks/specs/` (explicit path, else newest unconsumed, else ask), validates `kind` against mode, and records consumption in `project.md`'s `## Specs` log.
- [ ] Extend mode consumes a `kind: extension` spec from `.tasks/specs/`; closed phases untouched.
- [ ] `brief.md` / `extension.md` still work as documented deprecated fallbacks.
- [ ] `project-status` (both trees) flags unconsumed specs in `.tasks/specs/` and no longer relies solely on root `extension.md`.
- [ ] `marketplace.json` lists `"./project-specify"` and the path resolves.
- [ ] `CLAUDE.md` and `README.md` document the skill and the new contract.
