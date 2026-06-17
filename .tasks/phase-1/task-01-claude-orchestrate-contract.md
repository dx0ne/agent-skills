---
id: task-01
title: Rewrite Claude project-orchestrate input contract to .tasks/specs/
status: done
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
- [x] Bootstrap reads a `kind: bootstrap` spec selected from `.tasks/specs/`: explicit
      path → else newest spec not in the `## Specs` log → else ask which.
- [x] `project.md` template gains a `## Specs` provenance log; orchestrate appends the
      consumed spec (path, kind, phase range) after building phases.
- [x] Spec file format documented: frontmatter `kind`, plus `title`/`repo`/`goal`/`phases`
      for bootstrap, `phases` (+ `## Notes`) for extension. Mode inferred from project
      state and validated against `kind` (mismatch = error, not auto-fix).
- [x] Extend flow consumes a `kind: extension` spec from `.tasks/specs/`; it does NOT
      delete the spec (specs are immutable history); closed phases untouched.
- [x] `brief.md` (bootstrap) and `extension.md` (extend) documented as deprecated
      fallbacks used only when `.tasks/specs/` has no usable spec.
- [x] The orchestrate dot-diagram and the field-schema block reflect the new contract.
- [x] Edge cases section updated (e.g. multiple unconsumed specs, kind/mode mismatch).
- [x] SKILL.md body stays < 500 lines; `name` frontmatter unchanged.

## Notes
Rewrote `skills/agentflow/project-orchestrate/SKILL.md` (Claude tree only) to the
dated-spec contract. Final file is 226 lines; `name: project-orchestrate` unchanged.

Key changes:
- Added a shared **Spec Selection** section used by both flows: explicit path → newest
  unconsumed (not in `## Specs` log) → ask if several → deprecated root-file fallback if
  none. Includes a `kind`-vs-mode validation step (mismatch = error, no auto-fix).
- Documented both spec formats (`kind: bootstrap` with title/repo/goal/phases/`## Design`;
  `kind: extension` with phases/`## Notes`).
- `project.md` template now includes an (initially empty) `## Specs` provenance log; both
  flows append the consumed spec as `specs/<file> (kind) → phases X-Y` (Steps 5 / E5).
- Bootstrap "Step 1" now selects+reads a bootstrap spec; `.tasks/specs/` is preserved and
  never clobbered in Step 3.
- Extend flow (E3) selects a `kind: extension` spec and **no longer deletes it** — the old
  "delete extension.md" behavior is now scoped only to the deprecated root fallback.
- Rewrote the dot-diagram around `project.md exists?` routing, kind validation, the
  spec-log step, and the two flows.
- Edge cases: added "multiple unconsumed specs", "kind/mode mismatch", "already-consumed
  spec named explicitly"; reworded the extension-without-project case.

Decisions:
- Kept a single shared "Spec Selection" block rather than duplicating logic per flow, so
  the Codex port (tasks 02/03) has one canonical algorithm to mirror.
- Allowed the deprecated root `extension.md` fallback to still be deleted after use (it has
  no dated identity and would otherwise be re-detected), while dated specs are immutable.
  This matches the spec's "deprecated fallback" framing without weakening immutability.

No other files touched (verified via `git status`: only the one SKILL.md modified).
