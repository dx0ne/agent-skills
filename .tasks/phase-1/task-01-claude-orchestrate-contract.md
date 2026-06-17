---
id: task-01
title: Rewrite Claude project-orchestrate input contract to .tasks/specs/
status: in-progress
complexity: high
blocked-by: ~
---
## Goal
Update `skills/agentflow/project-orchestrate/SKILL.md` so the skill reads dated specs
from `.tasks/specs/` instead of the root `brief.md` / `extension.md`, selects the spec
by content, records consumption in `project.md`'s `## Specs` log, and unifies the
Bootstrap and Extend flows under one `kind`-tagged spec mechanism.

## Context
- Design spec: `docs/specs/2026-06-16-project-specify-design.md` (sections "Spec storage
  & naming", "Spec file format", "Selection & consumption").
- Current file uses Bootstrap (`brief.md`) and Extend (`extension.md`) as fixed-name root
  files; Extend deletes `extension.md` after use.
- This is the canonical contract; tasks 02/03 mirror it into the Codex tree.

## Acceptance Criteria
- [ ] Bootstrap reads a `kind: bootstrap` spec selected from `.tasks/specs/`: explicit
      path → else newest spec not in the `## Specs` log → else ask which.
- [ ] `project.md` template gains a `## Specs` provenance log; orchestrate appends the
      consumed spec (path, kind, phase range) after building phases.
- [ ] Spec file format documented: frontmatter `kind`, plus `title`/`repo`/`goal`/`phases`
      for bootstrap, `phases` (+ `## Notes`) for extension. Mode inferred from project
      state and validated against `kind` (mismatch = error, not auto-fix).
- [ ] Extend flow consumes a `kind: extension` spec from `.tasks/specs/`; it does NOT
      delete the spec (specs are immutable history); closed phases untouched.
- [ ] `brief.md` (bootstrap) and `extension.md` (extend) documented as deprecated
      fallbacks used only when `.tasks/specs/` has no usable spec.
- [ ] The orchestrate dot-diagram and the field-schema block reflect the new contract.
- [ ] Edge cases section updated (e.g. multiple unconsumed specs, kind/mode mismatch).
- [ ] SKILL.md body stays < 500 lines; `name` frontmatter unchanged.

## Notes
