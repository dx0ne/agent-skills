---
id: task-02
title: Register project-specify in manifest and document it
status: in-progress
complexity: medium
blocked-by: task-01
---
## Goal
Register the new skill in the plugin manifest and document it (and the new `.tasks/specs/`
contract + the superpowers routing tie-breaker) in `CLAUDE.md` and `README.md`.

## Context
- Design: `docs/specs/2026-06-16-project-specify-design.md` ("Files Changed", "Winning the trigger").
- Manifest: `.claude-plugin/marketplace.json` — the `agentflow` plugin has a `skills` array
  currently listing `project-orchestrate`, `phase-execute`, `task-implement`, `project-status`.
- The skill folder `skills/agentflow/project-specify/` must already exist (task-01).
- This is Claude-only this iteration — do NOT add a `codex-skills/project-specify/` port or
  touch `install-codex.sh` / `install-codex.ps1`.

## Acceptance Criteria
- [ ] `.claude-plugin/marketplace.json` adds `"./project-specify"` to the agentflow `skills`
      array; JSON stays valid and the path resolves to the new folder containing SKILL.md.
- [ ] `CLAUDE.md` documents `project-specify` in the agentflow plugin table/structure, notes
      the `.tasks/specs/` dated-spec contract, and adds a routing tie-breaker rule: prefer
      `agentflow:project-specify` over `superpowers:brainstorming` for new project work.
- [ ] `README.md` documents `project-specify` and the specify → orchestrate → phase-execute flow,
      consistent with how the other agentflow skills are described.
- [ ] No Codex port added this iteration (scope guard).
- [ ] Skill folder name matches its `name` frontmatter (validation rule).

## Notes
