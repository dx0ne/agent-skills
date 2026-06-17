---
id: task-02
title: Register project-specify in manifest and document it
status: done
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
- [x] `.claude-plugin/marketplace.json` adds `"./project-specify"` to the agentflow `skills`
      array; JSON stays valid and the path resolves to the new folder containing SKILL.md.
- [x] `CLAUDE.md` documents `project-specify` in the agentflow plugin table/structure, notes
      the `.tasks/specs/` dated-spec contract, and adds a routing tie-breaker rule: prefer
      `agentflow:project-specify` over `superpowers:brainstorming` for new project work.
- [x] `README.md` documents `project-specify` and the specify → orchestrate → phase-execute flow,
      consistent with how the other agentflow skills are described.
- [x] No Codex port added this iteration (scope guard).
- [x] Skill folder name matches its `name` frontmatter (validation rule).

## Notes

All three files updated in one pass.

**Files modified:**
- `.claude-plugin/marketplace.json` — added `"./project-specify"` as the first entry in the agentflow `skills` array; JSON validated with Python.
- `CLAUDE.md` — updated structure diagram to include `project-specify/`; updated plugin table to list all 5 skills with updated description; added "Skill routing tie-breaker" section and "`.tasks/specs/` dated-spec contract" section documenting immutability, selection logic, consumption tracking, mode inference, and `brief.md`/`extension.md` as deprecated fallbacks.
- `README.md` — updated pipeline diagram to `project-specify -> project-orchestrate -> phase-execute -> task-implement`; added `project-specify` skill description including HARD-GATE note and routing preference; updated `project-orchestrate` description to reflect spec-folder input contract; updated Typical Workflow section with separate Claude Code (full pipeline) and Codex paths.

**Key decisions:**
- Placed `project-specify` first in the `skills` array (logical pipeline order: design comes before orchestrate).
- In CLAUDE.md, added the routing tie-breaker and spec contract as distinct subsections under the Plugins section for easy scanning.
- In README.md, updated `project-orchestrate` description to remove `brief.md`-as-primary framing and replace with spec-folder-primary + deprecated-fallback framing, matching the design doc.
- No Codex port files touched — scope guard honored.
