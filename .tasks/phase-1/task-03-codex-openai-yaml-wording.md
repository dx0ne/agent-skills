---
id: task-03
title: Update Codex openai.yaml wording brief -> spec
status: pending
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
- [ ] `default_prompt` references creating a plan from a spec in `.tasks/specs/`.
- [ ] Extend wording reflects the unified dated-spec mechanism (extension.md as deprecated
      fallback), consistent with task-02.
- [ ] YAML remains valid.

## Notes
