# Memory: Active Anti-Patterns (What NOT to Do)

> **Authority:** Project-specific coding standards (`CODING_STANDARDS.md`) take precedence over this file.

Loaded during code review, @QA validation, or when the relevant domain is active.

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
* **[Anti-011] "Dropped Planned Tests":** Committing code without implementing the tests stated in the implementation plan. If skipped due to time pressure, the plan must be updated and the gap filed as a follow-up issue.
* **[Anti-012] "Retry-Masked Failures":** Using test retries to make flaky tests pass instead of fixing the root cause. Retries are only acceptable for post-deploy smoke tests, not for pre-merge quality gates.
* **[Anti-013] "Environment-Blind Tests":** Writing tests that only work in one environment (e.g. direct DB access, hardcoded URLs) without documenting constraints or making them environment-aware.
* **[Anti-014] "Batch Collapse":** When processing multiple issues in batch mode, collapsing all updates into a single comment instead of updating each issue individually. Each issue must receive its own updates.

---

## Adding Project-Specific Anti-Patterns

Anti-001 through Anti-014 above are generic and portable across all projects. Fork projects may add their own project-specific anti-patterns below this line, using their own numbering scheme. When in doubt: keep project-specific patterns in the fork, don't push them upstream.
