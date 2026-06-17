---
id: task-02
title: Mirror spec-folder contract into Codex project-orchestrate
status: done
complexity: medium
blocked-by: task-01
---
## Goal
Apply the same `.tasks/specs/` input-contract changes from task-01 to
`codex-skills/project-orchestrate/SKILL.md`, preserving the intentional
Claude/Codex differences already documented in the repo (e.g. Codex defaults,
dropped Claude-specific model routing / co-author behavior).

## Context
- Design spec: `docs/specs/2026-06-16-project-specify-design.md`.
- Canonical wording comes from task-01 (Claude `project-orchestrate`). Read the
  updated Claude file first, then port — do not invent divergent semantics.
- Repo convention: `skills/` (Claude) and `codex-skills/` (Codex) stay in sync on
  behavior, differing only where intentionally noted (see CLAUDE.md "Codex parallel layout").

## Acceptance Criteria
- [x] Codex `project-orchestrate` reads/select specs from `.tasks/specs/` with the same
      selection rules (explicit → newest unconsumed → ask) and `## Specs` log.
- [x] `kind: bootstrap | extension` handling and mode validation match the Claude version.
- [x] Extend flow consumes a `kind: extension` spec without deleting it.
- [x] `brief.md` / `extension.md` documented as deprecated fallbacks.
- [x] Pre-existing intentional Claude/Codex differences preserved (no model routing or
      co-author behavior introduced).
- [x] Contract semantics match task-01 with no contradictions.

## Notes

Ported the full spec-folder contract from `skills/agentflow/project-orchestrate/SKILL.md` (task-01 canonical source) into `codex-skills/project-orchestrate/SKILL.md`.

**Files modified:**
- `codex-skills/project-orchestrate/SKILL.md` — full rewrite to incorporate new spec-folder contract

**What was added/changed:**
- Added "Spec Selection" section with the three-rule selection algorithm (explicit path → newest unconsumed → ask)
- Added spec file format examples for both `kind: bootstrap` and `kind: extension`
- Added "Deprecated fallbacks" subsection documenting `brief.md` / `extension.md` as backward-compat fallbacks
- Added `## Specs` provenance log to `project.md` template (starts empty, filled at end of run)
- Updated Step E1 to read existing `## Specs` log for consumed-spec tracking
- Updated Step E5 to use "do not delete dated specs" semantics (immutable history); kept the scoped deletion note for deprecated root `extension.md` only
- Added `kind` validation against inferred mode in Routing section and Spec Selection
- Expanded Edge Cases to match Claude version (already-consumed spec, extension-spec-without-project, etc.)
- Updated description frontmatter to reflect dated-spec input

**Preserved Codex differences:**
- Local-first stance: no automatic GitHub push in bootstrap or extension flows
- `$skill-name` references throughout (not `agentflow:skill-name`)
- No model routing table
- No co-author trailer behavior
- GitHub repo creation is optional / user-requested only
