---
id: task-01
title: Create the agentflow:project-specify skill
status: done
complexity: high
blocked-by: ~
---
## Goal
Create `skills/agentflow/project-specify/SKILL.md` — a self-contained design-dialogue
skill that replaces `superpowers:brainstorming` for agentflow work. It runs a disciplined
interview, writes a dated spec to `.tasks/specs/`, and hands off to
`agentflow:project-orchestrate` (NEVER `superpowers:writing-plans`).

## Context
- Authoritative design: `docs/specs/2026-06-16-project-specify-design.md` (read it fully —
  sections "project-specify behavior", "Spec file format", "Flow", "Winning the trigger").
- The input contract it must produce is defined in the now-updated
  `skills/agentflow/project-orchestrate/SKILL.md` ("Spec Selection", "Spec file format").
  The spec this skill writes MUST match that format exactly (frontmatter `kind`,
  `title`/`repo`/`goal`/`phases` for bootstrap; `phases`/`## Notes` for extension).
- Spec naming/location: `.tasks/specs/YYYY-MM-DD-<slug>.md` (create `.tasks/specs/` if needed).
- Repo spec rules (CLAUDE.md "Spec Rules"): `name` lowercase/hyphens, must equal the folder
  name `project-specify`; `description` ≤ 1024 chars stating what it does AND when to use it;
  SKILL.md body < 500 lines.

## Acceptance Criteria
- [x] `skills/agentflow/project-specify/SKILL.md` exists with frontmatter `name: project-specify`
      and a strong `description` triggering on new-project / "build X" / "new feature" /
      "design this" / "plan this project" / "spec this out".
- [x] Contains a HARD-GATE: no implementation, scaffolding, or handoff to `project-orchestrate`
      until the design is presented AND the user approves the written spec.
- [x] Documents the disciplined dialogue: explore context → interview ONE question at a time
      (multiple-choice preferred) → propose 2–3 approaches with a recommendation → present
      design in sections with approval → self-review → user review of the spec file.
- [x] Detects mode: `.tasks/project.md` absent → write `kind: bootstrap`; present → `kind: extension`.
- [x] Writes `.tasks/specs/YYYY-MM-DD-<slug>.md` in the exact format `project-orchestrate` consumes.
- [x] Terminal step invokes `agentflow:project-orchestrate` (passing the spec path); explicitly
      states it must NOT invoke `superpowers:writing-plans`.
- [x] `name` matches folder; body < 500 lines; passes agentskills.io name rules.

## Notes
- Created `skills/agentflow/project-specify/SKILL.md` (179 lines, well under the 500-line cap).
- `name: project-specify` matches the folder; passes agentskills.io name rules (lowercase,
  single hyphens, no leading/trailing/consecutive hyphens). `description` is 528 chars (< 1024)
  and triggers on new-project / "build X" / "new feature" / "design this" / "plan this project" /
  "spec this out", plus a tie-breaker line preferring it over `superpowers:brainstorming`.
- `<HARD-GATE>` block forbids any building/scaffolding/repo-creation/orchestrate-handoff until
  BOTH the design is approved AND the written spec file is approved.
- Process documents the full disciplined dialogue (explore → one-question interview → 2–3
  approaches + recommendation → sectioned design with per-section approval → mode-detected spec
  write → self-review → user file review → terminal handoff), mirrored in a dot diagram.
- Spec templates (bootstrap `kind: bootstrap` with title/repo/date/goal/phases + `## Design`;
  extension `kind: extension` with date/phases + `## Notes`) were verified byte-identical to the
  `## Spec file format` block in `skills/agentflow/project-orchestrate/SKILL.md` — producer and
  consumer are consistent.
- Terminal step invokes `agentflow:project-orchestrate` with the spec path and explicitly forbids
  `superpowers:writing-plans` (stated in description, body, and Key Rules).
- Scope honored: did NOT modify marketplace.json, CLAUDE.md, or README.md (task-02's job) and did
  NOT create a Codex port. Verified via `git status` / `git diff --name-only`.
