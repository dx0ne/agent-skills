---
id: task-01
title: Claude project-status detects unconsumed specs in .tasks/specs/
status: done
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
- [x] A processing step globs `.tasks/specs/*.md` and compares against the `## Specs`
      log in `project.md`; spec files whose path is not in the log are "unconsumed".
- [x] The report surfaces unconsumed specs (e.g. an "Unconsumed Specs" line/section)
      with a suggested next action: invoke `project-orchestrate` to consume them.
- [x] Deprecated root `brief.md` / `extension.md` are still mentioned as a fallback
      signal, consistent with Phase 1, but the primary detection is `.tasks/specs/`.
- [x] The skill remains strictly read-only (no Edit/Write, no mutating git, no file reads
      that modify). It must not read spec bodies unnecessarily — name/frontmatter is enough.
- [x] Process diagram / steps / Edge Cases updated coherently; `name` frontmatter unchanged.

## Notes
Updated `skills/agentflow/project-status/SKILL.md` with the following changes:

**Files modified:**
- `skills/agentflow/project-status/SKILL.md`

**Changes made:**
1. Added new Step 4 "Detect unconsumed specs": globs `.tasks/specs/*.md`, reads filenames only (not bodies), compares against the `## Specs` log captured in Step 1. A spec is consumed if its relative path (e.g. `specs/2026-06-17-foo.md`) appears in any log line. Unconsumed = present on disk but absent from log.
2. Updated Step 1 to also capture the `## Specs` log section (needed by Step 4).
3. Steps renumbered: old Steps 4-5 (git context, render) → new Steps 5-6.
4. Process dot diagram updated: added `"Glob .tasks/specs/ + check ## Specs log"` node with edges from both the open-phase path and the no-open-phase path, flowing into git context.
5. Report template updated: added `## Unconsumed Specs` section with filenames + `project-orchestrate` call-to-action hint; section is conditional (omitted when no unconsumed specs).
6. Edge Cases updated: replaced old single `extension.md` line with two entries — primary `.tasks/specs/` detection, and secondary deprecated `brief.md`/`extension.md` fallback signal.
7. Key Rules updated: added "Spec detection is read-only" rule.
8. `name` frontmatter field unchanged (`project-status`).

**Design decisions:**
- Deprecated root files kept as secondary signal only, consistent with Phase 1's `project-orchestrate` contract which still supports them as fallbacks.
- Spec detection uses filename matching only — no spec body reads required, keeping the skill lightweight and strictly read-only.
- The `## Unconsumed Specs` section is conditional and positioned between `## Next Action` and `## Recent Activity` in the report template, so it appears as a natural "pending input" alert.
