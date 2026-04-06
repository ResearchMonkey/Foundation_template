---
name: foundation-sync
description: "Bidirectional sync between a fork project and Foundation_template. Pull canonical skills/agents/lessons into the fork, or push contributions back. Use when Caleb says 'run foundation-sync pull/push/status'."
argument-hint: "<pull-from-foundation|push-to-foundation|status> [local-project-path]"
---

# Foundation Sync

Bidirectional sync between a fork project and Foundation_template.

Reads `skills/foundation-sync/SKILL.md` for full implementation details.

## Quick Reference

```
EDI, run foundation-sync pull [local-project-path]
EDI, run foundation-sync push [local-project-path]
EDI, run foundation-sync status [local-project-path]
```

## What Gets Synced

| Direction | Scope | Quality Gate |
|-----------|-------|--------------|
| Foundation → Fork | `.claude/skills/`, `.agent/skills/`, `skills/`, `.agent/.ai/MEMORY_ANTI_PATTERNS.md` | grill-me before commit |
| Fork → Foundation | `contributions/` only | grill-me before push |

## Key Rules

- Only `contributions/` is ever pushed back to Foundation_template
- Everything else in the fork is project-local
- Conflicts: drop, log, continue
- API failures: alert and move on
