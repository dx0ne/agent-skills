---
id: task-01
title: Claude project-status detects unconsumed specs in .tasks/specs/
status: in-progress
complexity: medium
blocked-by: ~
---
## Goal
Update `skills/agentflow/project-status/SKILL.md` so it reports *unconsumed specs*
in `.tasks/specs/` — spec files present in the folder but not listed in
`project.md`'s `## Specs` log — instead of sniffing a root `extension.md`. Stay
strictly read-only.

## Context
- Design spec: `docs/specs/2026-06-16-project-specify-design.md` (Phase 2 / "Files Changed").
- The new input contract (Phase 1) lives in `skills/agentflow/project-orchestrate/SKILL.md`:
  specs are dated `.tasks/specs/YYYY-MM-DD-<slug>.md` files; consumption is tracked in
  `project.md`'s `## Specs` log (lines like `specs/<file> (kind) → phases X-Y`).
- Current behavior to change: Edge Cases line — *"`extension.md` exists at repo root →
  append 'Pending extension brief detected — invoke `project-orchestrate` to append.'"*
- This is the canonical version; task-02 mirrors it into the Codex tree.

## Acceptance Criteria
- [ ] A processing step globs `.tasks/specs/*.md` and compares against the `## Specs`
      log in `project.md`; spec files whose path is not in the log are "unconsumed".
- [ ] The report surfaces unconsumed specs (e.g. an "Unconsumed Specs" line/section)
      with a suggested next action: invoke `project-orchestrate` to consume them.
- [ ] Deprecated root `brief.md` / `extension.md` are still mentioned as a fallback
      signal, consistent with Phase 1, but the primary detection is `.tasks/specs/`.
- [ ] The skill remains strictly read-only (no Edit/Write, no mutating git, no file reads
      that modify). It must not read spec bodies unnecessarily — name/frontmatter is enough.
- [ ] Process diagram / steps / Edge Cases updated coherently; `name` frontmatter unchanged.

## Notes
