# Pre-Merge Quality Gates

<!-- TODO: Fork projects — enable/disable gates and add project-specific checks -->

> **Note:** Detailed standards behind these gates are maintained in the `docs/*.md` standards documents.  
> This file defines the operational checklist; the standards docs define the rules.  
> See: `docs/CODING_STANDARDS.md`, `docs/TESTING_STANDARDS.md`, `docs/SECURITY_STANDARDS.md`, `docs/OPS_STANDARDS.md`.

Every PR must pass applicable gates before merge. In **prototype** mode, gates marked *(production only)* are advisory.

## §1 — Lint Clean
No new lint errors. Run the project linter before committing.

## §2 — Type Safety
No new type errors (if using TypeScript, Flow, mypy, etc.).

## §3 — Tests Pass
All existing tests pass. No skipped tests without a tracked issue.

## §4 — Test Coverage
New code has test coverage for happy path + primary failure case.

## §5 — Null Safety
Optional chaining on all API/external data access. No unguarded `.` chains on nullable values.

## §6 — Error Feedback
Every `catch` block provides user-facing feedback — not just `console.error`.

## §7 — Mutation Refresh
Every create/update/delete operation: (a) closes modal, (b) shows feedback, (c) refreshes affected list/view.

## §8 — Testing Verification
Test files exist for new modules. Test names describe behavior, not implementation.

## §9 — API Contract Match
Frontend field types and names match backend expectations.

## §10 — Context-Aware Navigation
After save/submit, user returns to correct context (not always the same page).

## §11 — No Hardcoded Secrets
No API keys, tokens, passwords, or connection strings in source.

## §12 — Commit Format
Commits follow project convention (conventional commits, Jira key prefix, etc.).

## §13 — No Debug Artifacts
No `console.log`, `debugger`, `TODO: remove`, or test-only code in production paths.

## §14 — Dependency Hygiene
New dependencies are justified. No duplicate packages. Lock file updated.

## §15 — Breaking Change Flag
API/schema changes flagged in PR description with migration notes.

## §16 — Init Race Safety
Async initialization must handle concurrent callers (no double-init, no race).

## §17 — Modal Compliance *(production only)*
All modals use shared modal component — no inline hidden modals.

## §18 — Anti-Pattern Check
Code does not introduce patterns listed in `MEMORY_ANTI_PATTERNS.md`.

## §19 — Doc Impact
Constants, config values, and API fields are documented in the appropriate register.

## §20 — TEST_REGISTRY Updated
If test files were added or modified, `TEST_REGISTRY.md` has corresponding entries.

## §21 — Security Review *(when required)*
HIGH/CRITICAL risk tasks have SEC sign-off per `docs/SECURITY_STANDARDS.md`.

## §22 — Accessibility *(production only)*
Interactive elements have labels, focus management, and keyboard support.

## §23 — Performance *(production only)*
No N+1 queries, unbounded loops, or missing pagination on list endpoints.

## §24 — Rollback Plan *(production only)*
HIGH/CRITICAL changes document rollback steps.

## §25 — Final Approval
QA "Green" status granted. All applicable gates pass.
