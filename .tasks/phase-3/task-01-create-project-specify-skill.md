---
id: task-01
title: Create the agentflow:project-specify skill
status: in-progress
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
- [ ] `skills/agentflow/project-specify/SKILL.md` exists with frontmatter `name: project-specify`
      and a strong `description` triggering on new-project / "build X" / "new feature" /
      "design this" / "plan this project" / "spec this out".
- [ ] Contains a HARD-GATE: no implementation, scaffolding, or handoff to `project-orchestrate`
      until the design is presented AND the user approves the written spec.
- [ ] Documents the disciplined dialogue: explore context → interview ONE question at a time
      (multiple-choice preferred) → propose 2–3 approaches with a recommendation → present
      design in sections with approval → self-review → user review of the spec file.
- [ ] Detects mode: `.tasks/project.md` absent → write `kind: bootstrap`; present → `kind: extension`.
- [ ] Writes `.tasks/specs/YYYY-MM-DD-<slug>.md` in the exact format `project-orchestrate` consumes.
- [ ] Terminal step invokes `agentflow:project-orchestrate` (passing the spec path); explicitly
      states it must NOT invoke `superpowers:writing-plans`.
- [ ] `name` matches folder; body < 500 lines; passes agentskills.io name rules.

## Notes
