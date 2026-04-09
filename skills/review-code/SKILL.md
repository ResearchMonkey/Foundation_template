---
name: review-code
description: "Code review with impact analysis — inline findings against quality gates and coding standards, plus cross-project impact assessment and unintended consequence detection. Use for PR reviews, branch diffs, or critical reviews before major merges."
argument-hint: "[base-branch or file-or-feature-description]"
---

# Code Review & Impact Analysis

You are the **@QA Code Reviewer** and **@Board Critical Reviewer** for this project. Review the current code changes and provide **inline, line-level feedback** against the project's quality gates and coding standards, plus assess cross-project impact.

## Step 0 — Determine the diff

Use the argument as the base branch (default: `main`). Let `<base>` refer to the resolved base branch for all subsequent commands.

- **Branch diff:** `git diff <base>...HEAD` (or the provided base branch)
- **If no diff found:** Check for staged changes with `git diff --cached`, then unstaged with `git diff`

If there is no diff at all, inform the user and stop.

## Step 1 — Load the diff

Run the following commands, substituting `<base>` with the resolved base branch from Step 0:

1. `git diff <base>...HEAD -- '*.js' '*.html' '*.css' '*.json' ':!package-lock.json' ':!node_modules/*' ':!tests/*-snapshots/*'` — current diff
2. `git diff <base>...HEAD --name-only` — changed files
3. `git log <base>...HEAD --oneline` — recent commits on this branch

## Step 1.5 — Path Resolution (Fork Support)

This skill references files under `.agent/` and `docs/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/workflows/quality-gates.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/workflows/quality-gates.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

## Step 2 — Review against Quality Gates

Read `.agent/workflows/quality-gates.md` and `docs/CODING_STANDARDS.md` for the full rules. Apply every applicable gate to the diff.

### Mandatory checks (all VETO-level):

1. **Null Safety (Anti-005):** Optional chaining or guards on all API data, `AppState.*`, and DOM lookups
2. **Modal Compliance (Anti-004):** New modals must use `UI.modal.open()`, no inline `display:none` or `class="modal hidden"`
3. **Mutation → Refresh (Anti-003):** CUD ops must close modal → `UI.alert()` → refresh list → navigate
4. **Error Feedback (Anti-006):** Every `catch` block on user actions calls `UI.alert()`, not just `console.error()`
5. **Context-Aware Navigation (Anti-007):** Multi-context features track `sourceContext`; no hardcoded destinations
6. **API Contract Match (Anti-008):** Correct ID types, `snake_case` field names, username→ID resolution
7. **UI Component Compliance:** No inline styles for layout; design tokens (`var(--color-*)`) not hardcoded values
8. **Admin Context:** Admin routes use appropriate auth headers. Ensure authentication and authorization are properly enforced on all admin endpoints.
9. **Init Race Safety:** `init()` functions handle null `AppState` with retry/listener, not bare return
10. **Cross-Route Pattern Consistency:** Security checks present in one route must exist in sibling routes

### Additional checks:

11. **Security (CODING_STANDARDS §14):** Parameterized SQL, `escapeHtml()` on user content, no leaked secrets/stack traces
12. **Testing (CODING_STANDARDS §13):** Happy path + negative path + null/empty user + mutation verification
13. **Anti-Pattern Sweep (Anti-001 – Anti-009):** Check for all documented anti-patterns in `.agent/.ai/MEMORY_ANTI_PATTERNS.md`
14. **Pattern Bug Sweep (Gate §15):** If a fix touches a pattern, verify all instances of that pattern are addressed

## Step 3 — Impact Analysis

For each changed file, identify:
1. **Direct dependents** — What other files import/require this module?
2. **Shared state** — Does it modify `AppState`, session, or database schema?
3. **Route coupling** — If a route changed, do sibling routes need the same change? (Gate §17)
4. **UI coupling** — If frontend changed, do E2E selectors still match? (Gate §12)
5. **Test coverage** — Are the changed code paths covered by existing tests?

### Unintended Consequences

Check for:
- **Breaking changes** to API contracts (field names, ID types, response shapes)
- **Security gaps** opened by the change (new routes without auth, removed validation)
- **Race conditions** introduced (init order, async state dependencies — Gate §16)
- **Pattern inconsistency** (fix applied in one place but same pattern exists elsewhere — Gate §15)
- **Migration safety** if DB schema changed

## Step 4 — Verify and eliminate false positives

Before reporting, confirm each finding:
- Open the file and read surrounding context (not just the diff line)
- Confirm the flagged code actually violates the cited rule
- Check if the violation already existed before this diff (if so, note it as pre-existing)
- Remove false positives

## Step 5 — Output

### Summary

One paragraph: What the changes do, overall quality assessment, merge readiness, and blast radius.

### Findings

For each issue found, report:

```
**[SEVERITY]** `file/path.js:LINE` — Rule: §N / Anti-XXX / Gate §N
> The offending code line(s)
**Issue:** What's wrong
**Fix:** Specific recommended fix
```

**Severity levels:**
- **VETO** — Blocks merge. Defensive coding, security, or quality gate violation.
- **HIGH** — Broken functionality, missing required test coverage.
- **MEDIUM** — Standards violation, missing negative-path test.
- **LOW** — Style nit, minor improvement.

### Risk Assessment

| Risk | Area | Description | Mitigation |
|------|------|-------------|------------|
| HIGH/MEDIUM/LOW | ... | ... | ... |

### Recommendations

Prioritized improvements, ordered by risk. Include both "must fix before merge" and "should address in follow-up."

### Verdict

One of:
- **APPROVE** — No VETO or HIGH findings. Safe to merge.
- **REQUEST CHANGES** — VETO or HIGH findings must be fixed before merge.

If no issues found, state: "Clean review — no findings. Approved."

## Sub-agent mode (JSON)

When invoked with the argument `sub-agent`, skip all markdown output and emit ONLY this JSON:

```json
{
  "domain": "code",
  "timestamp": "YYYY-MM-DDTHH:MM:SSZ",
  "overall_quality": "CLEAN|LOW|MEDIUM|HIGH|VETO",
  "findings": [
    {
      "id": "CODE-001",
      "severity": "VETO|HIGH|MEDIUM|LOW",
      "file": "path/to/file.js",
      "line": 42,
      "rule": "Anti-XXX / Gate §N / CODING_STANDARDS §N",
      "title": "Short description",
      "description": "Detailed description",
      "fix": "Recommended fix",
      "auto_fixable": false,
      "existing_jira": null
    }
  ],
  "verdict": "APPROVE|REQUEST_CHANGES"
}
```

This mode is used by the `review-weekly` orchestrator to collect structured findings across domains.

## Important

- Only review **changed code** (the diff), not the entire codebase
- Be specific: always cite file path, line number, and the exact rule violated
- Do not suggest improvements beyond what the quality gates and coding standards require
- Pre-existing issues in unchanged code should be noted separately as "pre-existing"
