---
id: task-02
title: Mirror spec-folder contract into Codex project-orchestrate
status: pending
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
- [ ] Codex `project-orchestrate` reads/select specs from `.tasks/specs/` with the same
      selection rules (explicit → newest unconsumed → ask) and `## Specs` log.
- [ ] `kind: bootstrap | extension` handling and mode validation match the Claude version.
- [ ] Extend flow consumes a `kind: extension` spec without deleting it.
- [ ] `brief.md` / `extension.md` documented as deprecated fallbacks.
- [ ] Pre-existing intentional Claude/Codex differences preserved (no model routing or
      co-author behavior introduced).
- [ ] Contract semantics match task-01 with no contradictions.

## Notes
