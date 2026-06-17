---
id: task-02
title: Mirror unconsumed-spec detection into Codex project-status
status: done
complexity: low
blocked-by: task-01
---
## Goal
Apply the same unconsumed-spec detection from task-01 to
`codex-skills/project-status/SKILL.md`, preserving the intentional Codex
conventions (`$skill-name` references, local-first, no co-author behavior).

## Context
- Design spec: `docs/specs/2026-06-16-project-specify-design.md`.
- Canonical wording comes from task-01 (Claude `project-status`). Read the updated
  Claude file first, then port — keep semantics identical.
- Current Codex behavior to change: *"If `extension.md` exists at the repo root, append
  one line: 'Pending extension brief detected — invoke `$project-orchestrate` to append.'"*

## Acceptance Criteria
- [ ] Codex `project-status` detects unconsumed specs in `.tasks/specs/` vs the
      `## Specs` log and surfaces them with a next-action hint (`$project-orchestrate`).
- [ ] Deprecated root `brief.md` / `extension.md` mentioned as fallback, consistent with task-01.
- [ ] Skill stays strictly read-only (no `apply_patch`, shell writes, edits, commits).
- [ ] Codex conventions preserved (`$skill-name`, no model routing, no co-author trailer).
- [ ] Semantics match task-01 with no contradictions.

## Notes
