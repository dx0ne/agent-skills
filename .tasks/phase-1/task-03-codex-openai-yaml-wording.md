---
id: task-03
title: Update Codex openai.yaml wording brief -> spec
status: done
complexity: low
blocked-by: task-01
---
## Goal
Update `codex-skills/project-orchestrate/agents/openai.yaml` so the
`default_prompt` describes creating a project plan "from a spec" (in `.tasks/specs/`)
rather than "from a brief", consistent with the new input contract.

## Context
- Current line: `default_prompt: "Use $project-orchestrate to create a `.tasks/`
  project plan from a brief, or to append phases to an existing project via extension.md."`
- Design spec: `docs/specs/2026-06-16-project-specify-design.md` ("Files Changed").

## Acceptance Criteria
- [x] `default_prompt` references creating a plan from a spec in `.tasks/specs/`.
- [x] Extend wording reflects the unified dated-spec mechanism (extension.md as deprecated
      fallback), consistent with task-02.
- [x] YAML remains valid.

## Notes
- Commit: 4309218 — Updated openai.yaml line 4 to reflect spec-folder contract
- Wording kept concise (one sentence) and preserves `$project-orchestrate` reference
- YAML structure and quoting style preserved
