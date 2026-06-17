---
phase: 1
title: Orchestrate spec-folder contract
status: open
opened: 2026-06-17
closed: ~
---
## Goal
Change `project-orchestrate`'s input contract (both Claude and Codex trees) so it
reads dated specs from `.tasks/specs/` instead of the fixed-name root files. A spec
is selected by explicit path, else the newest unconsumed spec (a file not yet listed
in `project.md`'s `## Specs` log), else by asking. Frontmatter `kind: bootstrap |
extension` unifies both orchestrate modes; mode is inferred from project state and
validated against `kind`. Consumption is recorded in `project.md`'s `## Specs` log.
`brief.md` / `extension.md` remain documented deprecated fallbacks.

## Exit Criteria
- Both `project-orchestrate` SKILL.md files document `.tasks/specs/` selection
  (explicit path → newest unconsumed → ask), the `## Specs` provenance log, and
  `kind` validation against inferred mode.
- The Extend flow consumes a `kind: extension` spec from `.tasks/specs/` rather than
  deleting a root `extension.md`; closed phases stay untouched.
- `brief.md` / `extension.md` are documented as deprecated fallbacks (still work).
- Diagrams and the `brief.md` field schema are updated to the new contract.
- `codex-skills/project-orchestrate/agents/openai.yaml` wording reflects "spec" not "brief".
- Claude and Codex versions stay consistent apart from their known intentional differences.

## Tasks
- [ ] task-01-claude-orchestrate-contract.md
- [ ] task-02-codex-orchestrate-contract.md
- [ ] task-03-codex-openai-yaml-wording.md
