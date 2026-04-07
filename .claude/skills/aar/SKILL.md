---
name: aar
description: "After Action Review — audit recent work for dropped tests, missing docs, stale memory, and process gaps. Use after any session, hotfix, batch, or epic close."
argument-hint: "[issue key(s), 'session', 'epic EPIC-KEY', or branch name]"
---

# After Action Review (AAR)

Audit recent work for gaps that shipped silently.

Reads `.agent/skills/aar/SKILL.md` for full implementation details.

## Quick Reference

```
/aar                     — review current session
/aar PROJ-123            — review single issue
/aar PROJ-123 PROJ-456   — review batch
/aar epic PROJ-100       — full epic retrospective
/aar feature/my-branch   — review all commits on branch
```

## What It Checks

1. **Plan compliance** — were promised tests delivered? (Anti-011)
2. **Doc impact** — new constants/fields/schema documented? (Anti-010)
3. **Flash lessons** — non-obvious insights worth preserving?
4. **Config register** — hardcoded constants registered?
5. **Test registry** — new test files in registry?
6. **Jira state** — issues in correct status?
7. **Acceptance criteria** — epic criteria have evidence? (epic scope)

## Verdicts

- **CLEAN** — no HIGH/MEDIUM findings
- **ACTION REQUIRED** — HIGH findings must be resolved
- **PROCESS GAP** — repeated pattern suggests process improvement needed
