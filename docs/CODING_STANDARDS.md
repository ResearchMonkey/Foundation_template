# Coding Standards

<!-- TODO: Fork projects — customize these standards for your team and stack -->

> **Owner:** This is a user-owned standards document. Edit this file to change the rules your AI agents follow when writing code.  
> **Consumer:** `@Developer` persona, `implement` skill, `review-code` skill.

## 1. General Principles

- **Clarity over cleverness** — code is read more than written.
- **Consistency** — follow existing patterns in the file/module you're editing.
- **Small, focused changes** — one concern per commit.

## 2. Naming

- Use descriptive names that reveal intent.
- Prefer full words over abbreviations (`getUserById` not `getUsrById`).
- Constants: `UPPER_SNAKE_CASE`.
- Functions/variables: follow language convention (camelCase for JS/TS, snake_case for Python, etc.).

## 3. Error Handling

- Never swallow errors silently — always log or surface to the user.
- Use typed errors where the language supports them.
- Validate at system boundaries (user input, external APIs); trust internal code.

## 4. Implementation Checklist

Before committing, verify:

- [ ] **Null Safety** — optional chaining on API/external data
- [ ] **Error Feedback** — user-facing errors on all catch blocks
- [ ] **Mutation → Refresh** — lists/views update after create/update/delete
- [ ] **Context-Aware Navigation** — returns to correct context after save
- [ ] **API Contract Match** — field types and names match backend expectations
- [ ] **Tests Written** — happy path + failure cases
- [ ] **Lint Passes**
- [ ] **Tests Pass**

## 5. Quality Score (Self-Assessment)

Rate code before presenting to @QA:

| Dimension | Weight | Score (0-10) |
|-----------|--------|---------------|
| Defensive coding compliance | 60% | |
| Testability & simplicity | 20% | |
| Risk smell & failure modes | 20% | |

* **≥9.0** → Present to @QA with confidence
* **7.5–8.9** → Fix issues before presenting
* **<7.5** → Escalate to @QA early

## 6. Anti-Patterns

These patterns are prohibited. The highest-numbered matching anti-pattern determines severity.

* **[Anti-001] "Ghost Features":** Documenting features that are not yet coded.
* **[Anti-002] "Happy Path" Testing:** Writing tests that only check for success, ignoring failure modes.
* **[Anti-003] "Silent Mutations":** Create/update/delete operations that don't refresh the affected view afterward. Every mutation MUST close modal → show feedback → refresh list → navigate to correct context.
* **[Anti-004] "Inline Modals":** Rendering modals as hidden inline HTML instead of using the shared modal component.
* **[Anti-005] "Null-Blind Rendering":** Accessing chained properties without null guards. Any property access on external/API data MUST use optional chaining or explicit null checks.
* **[Anti-006] "Swallowed Errors":** Catch blocks that only log without user feedback. Every catch for a user-initiated action MUST surface a meaningful error to the user.
* **[Anti-007] "Context-Blind Navigation":** Save/create flows that always navigate to the same page regardless of origin. Multi-context features MUST track source context and return to the originating page.
* **[Anti-008] "ID Format Mismatch":** Frontend sending a slug/username where the API expects a numeric ID (or vice versa). API contracts MUST document parameter types.
* **[Anti-009] "Unusable Options in Dropdowns":** Showing options a user cannot successfully use. Dropdowns MUST only include choices valid for that action.
* **[Anti-010] "Invisible API Changes":** Adding a new field to an API endpoint without updating the API documentation. A new API field is always doc-impacting.
* **[Anti-011] "Dropped Planned Tests":** Committing code without implementing the tests stated in the implementation plan. If skipped, file a follow-up issue.
* **[Anti-012] "Retry-Masked Failures":** Using test retries to make flaky tests pass instead of fixing the root cause. Retries are only acceptable for post-deploy smoke tests.
* **[Anti-013] "Environment-Blind Tests":** Writing tests that only work in one environment without documenting constraints or making them environment-aware.
* **[Anti-014] "Batch Collapse":** When processing multiple issues in batch mode, collapsing all updates into a single comment instead of updating each issue individually.

### Adding Project-Specific Anti-Patterns

Anti-001 through Anti-014 above are generic and portable across all projects. Fork projects may add their own project-specific anti-patterns below this line, using their own numbering scheme.

## 7. Key Anti-Patterns for Implementation

These are the most common violations during code generation — check these first:

- Anti-005: Null-blind rendering
- Anti-006: Swallowed errors
- Anti-003: Silent mutations
- Anti-007: Context-blind navigation
- Anti-008: ID format mismatch

## 8. Security

- No secrets in source code — use environment variables or secret managers.
- Sanitize user input before use in queries, HTML, or shell commands.
- Use parameterized queries — never string-concatenate SQL.
- See `docs/SECURITY_STANDARDS.md` for risk classification and security checklists.

## 9. Dependencies

- Justify new dependencies in the PR description.
- Prefer well-maintained packages with active security support.
- Pin versions in lock files.

## 10. Git Hygiene

- Conventional commit messages (or project-specific format).
- No merge commits on feature branches — rebase onto main.
- Reference issue/ticket keys in commit messages.
