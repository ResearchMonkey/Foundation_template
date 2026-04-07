---
name: foundation-sync
description: "Bidirectional sync between a fork project and Foundation_template using git subtree. Pull canonical skills/agents/lessons into the fork, or push contributions back. Use when Caleb says 'run foundation-sync pull/push/status/init'."
argument-hint: "<init|pull|push|status> [local-project-path]"
---

# Foundation Sync (git subtree)

Bidirectional sync between a fork project and Foundation_template using `git subtree`.

Reads `skills/foundation-sync/SKILL.md` for full implementation details.

## Quick Reference

```
EDI, run foundation-sync init [local-project-path]    # first-time setup
EDI, run foundation-sync pull [local-project-path]     # merge upstream changes
EDI, run foundation-sync push [local-project-path]     # push contributions back
EDI, run foundation-sync status [local-project-path]   # show sync state
```

## How It Works

| Direction | Mechanism | Scope | Conflict handling |
|-----------|-----------|-------|-------------------|
| Foundation → Fork | `git subtree pull --prefix=.foundation` | Full template content | Git 3-way merge; conflicts surface for manual resolution |
| Fork → Foundation | `git subtree push --prefix=.foundation` | Commits touching `.foundation/` | Pushed to `contrib/<project>` branch for review |

## Key Rules

- `.foundation/` is the subtree prefix — contains synced Foundation_template content
- Pull merges upstream changes, preserving fork customizations (no silent overwrites)
- Push goes to a contribution branch, not main — requires review
- Merge conflicts surface as real git conflicts — user resolves, never auto-dropped
- Portability check (BL-013): push scans for project-specific language before sending
