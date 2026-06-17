---
phase: 2
title: Status unconsumed-spec detection
status: pending
opened: ~
closed: ~
---
## Goal
Update `project-status` in both trees so it reports *unconsumed specs* in
`.tasks/specs/` — files present in the folder but not yet listed in `project.md`'s
`## Specs` log — instead of sniffing the root `extension.md`. It must remain
read-only and never modify any file.

## Exit Criteria
- `skills/agentflow/project-status/SKILL.md` and `codex-skills/project-status/SKILL.md`
  detect unconsumed specs in `.tasks/specs/` and surface them with a suggested next
  action (invoke `project-orchestrate`).
- The old root-`extension.md` detection is updated/replaced (kept only as a deprecated
  fallback mention, consistent with Phase 1).
- `project-status` remains strictly read-only.
- Claude and Codex versions stay consistent apart from known intentional differences.

## Tasks
