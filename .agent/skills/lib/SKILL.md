# Skill: LIB (Librarian Proactive Doc Audit)

## Path Resolution (Fork Support)

This skill references files under `.agent/` and `docs/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/.ai/Librarian.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/.ai/Librarian.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

## Purpose
Post-implementation documentation audit. Runs after OPS tests pass and before PR creation. Ensures code changes are reflected in project documentation.

## Trigger
Called by `implement` after OPS phase completes (BOOTSTRAP §5).

## Mandatory Checklist

For every file modified in the change, answer each item with evidence (file checked, grep result, or "N/A"):

| # | Check | Where to Look | Severity |
|---|-------|---------------|----------|
| 1 | **Constants registered?** | `git diff` for new `const` at module scope with `UPPER_SNAKE_CASE`. Cross-reference `CONFIGURATION_REGISTER.md`. | MED — add entries |
| 2 | **API fields documented?** | New fields in request/response bodies → check `API_Reference.md`. | MED — add entries |
| 3 | **Error codes documented?** | New error codes or status codes → check API docs. | LOW — add entries |
| 4 | **TEST_REGISTRY updated?** | If test files added/modified → check `TEST_REGISTRY.md` for rows. | MED — add rows |
| 5 | **Flash Lesson needed?** | Did implementation reveal a non-obvious pattern or gotcha? | LOW — record lesson |

## Automated Check
If available, run `npm run lint:doc-coverage` to catch unregistered constants automatically.

## Audit Report Format

Post as a Jira comment (interactive mode) or include in PR description:

```
### LIB Doc Audit
- Constants: [X registered / Y found] 
- API fields: [documented / N/A]
- Test registry: [updated / N/A]
- Flash lessons: [recorded / none]
- Gaps found: [list or "none"]
```

## References
- `.agent/.ai/Librarian.md` — LIB persona and mandates
- `docs/agent/technical/CONFIGURATION_REGISTER.md` — constant registry
- `docs/agent/technical/API_Reference.md` — API field documentation
