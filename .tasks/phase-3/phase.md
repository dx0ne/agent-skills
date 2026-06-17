---
phase: 3
title: project-specify skill, registration & docs
status: closed
opened: 2026-06-17
closed: 2026-06-17
---
## Goal
Create the new `agentflow:project-specify` skill (Claude-only this iteration), register
it in the plugin manifest, and document it. The skill runs a disciplined design dialogue
(interview one question at a time → propose 2–3 approaches → present design → approval),
writes a `kind: bootstrap` (or `kind: extension`) spec to `.tasks/specs/YYYY-MM-DD-<slug>.md`,
and hands off by invoking `agentflow:project-orchestrate` (never `superpowers:writing-plans`).

## Exit Criteria
- `skills/agentflow/project-specify/SKILL.md` exists; `name` frontmatter equals
  `project-specify`; passes agentskills.io name rules; body < 500 lines.
- Skill includes a HARD-GATE (no implementation/handoff before user approves the spec),
  the one-question-at-a-time interview, mode detection (bootstrap vs extension), the spec
  file format, and a terminal step invoking `project-orchestrate` with the spec path.
- `.claude-plugin/marketplace.json` lists `"./project-specify"` under agentflow and the
  path resolves to the new folder.
- `CLAUDE.md` documents the skill, the `.tasks/specs/` contract, and a routing tie-breaker
  ("prefer `agentflow:project-specify` over `superpowers:brainstorming`" for new project work).
- `README.md` documents `project-specify` and the specify→orchestrate flow.

## Tasks
- [ ] task-01-create-project-specify-skill.md
- [ ] task-02-register-and-document.md
