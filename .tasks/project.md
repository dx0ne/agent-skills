---
title: project-specify skill & spec-folder contract
status: done
current-phase: 3
repo: public
github: https://github.com/dx0ne/agent-skills.git
created: 2026-06-17
---
## Goal
Add the `agentflow:project-specify` brainstorming front-end that hands off to
`project-orchestrate` instead of `superpowers:writing-plans`, and replace
`project-orchestrate`'s fixed-name input files (`brief.md` / `extension.md`)
with a dated-spec folder at `.tasks/specs/` selected by content, with
consumption tracked in `project.md`. Full design:
`docs/specs/2026-06-16-project-specify-design.md`.

## Phases
- [x] Phase 1: Orchestrate spec-folder contract
- [x] Phase 2: Status unconsumed-spec detection
- [x] Phase 3: project-specify skill, registration & docs

## Specs
- docs/specs/2026-06-16-project-specify-design.md (design — this meta-project's own spec; not a `.tasks/specs/` runtime spec)
