# Pre-Merge Quality Gates

<!-- TODO: Fork projects - enable/disable gates and add project-specific checks -->

> **Note:** Detailed standards behind these gates are maintained in the `docs/*.md` standards documents.
> This file defines the operational checklist; the standards docs define the rules.
> See: `docs/CODING_STANDARDS.md` (includes architecture standards), `docs/TESTING_STANDARDS.md`, `docs/SECURITY_STANDARDS.md`, `docs/OPS_STANDARDS.md`.

Every PR must pass applicable gates before merge. In **prototype** mode, gates marked *(production only)* are advisory.

> **Project-Type Filtering:** Each gate below is tagged with `[types]` indicating which project types it applies to.
> Tags: `all`, `web-app`, `cli`, `library`, `automation`, `fullstack`, `tui`, `embedded`, `lambda`.
> **Universal gates apply to all projects regardless of type.** Type-specific gates are relevant for
> the listed types but still require judgment. Noise reduction, not ceiling.

## Universal Gates (`[all]`)
§1 Lint Clean | §2 Type Safety | §3 Tests Pass | §4 Test Coverage | §5 Null Safety | §6 Error Feedback | §8 Testing Verification | §11 No Hardcoded Secrets | §12 Commit Format | §13 No Debug Artifacts | §14 Dependency Hygiene | §15 Breaking Change Flag | §16 Init Race Safety | §18 Anti-Pattern Check | §19 Doc Impact | §20 TEST_REGISTRY Updated | §21 Security Review | §24 Rollback Plan | §25 Final Approval

## Type-Specific Gates
| Gate | Types | Notes |
|------|-------|-------|
| §7 Mutation Refresh | web-app, fullstack, tui | Modal/UI projects only |
| §9 API Contract Match | web-app, fullstack, cli, library, automation | Excludes purely local scripts |
| §10 Context-Aware Navigation | web-app, fullstack, tui | Non-interactive = N/A |
| §17 Modal Compliance | web-app, fullstack | Non-UI = N/A |
| §22 Accessibility | web-app, fullstack | Browser only |
| §23 Performance | web-app, fullstack, cli, automation | CLI: unbounded I/O checks |

## Gate Tag Key
| Tag | Meaning |
|-----|---------|
| `all` | Applies to every project regardless of type |
| `web-app` | Browser-based web applications |
| `cli` | Command-line tools |
| `library` | Reusable packages/libraries |
| `automation` | CI runners, bots, cron jobs, webhooks |
| `fullstack` | Apps with both frontend and backend |
| `tui` | Terminal user interfaces |
| `embedded` | Firmware, IoT |
| `lambda` | Serverless functions |

## §1 — Lint Clean `[all]`
No new lint errors. Run the project linter before committing.

## §2 — Type Safety `[all]`
No new type errors (if using TypeScript, Flow, mypy, etc.).

## §3 — Tests Pass `[all]`
All existing tests pass. No skipped tests without a tracked issue.

## §4 — Test Coverage `[all]`
New code has test coverage for happy path + primary failure case.

## §5 — Null Safety `[all]`
Optional chaining on all API/external data access. No unguarded `.` chains on nullable values.

## §6 — Error Feedback `[all]`
Every `catch` block provides user-facing feedback — not just `console.error`.

## §7 — Mutation Refresh `[web-app, fullstack, tui]` *(production only)*
Every create/update/delete operation: (a) closes modal, (b) shows feedback, (c) refreshes affected list/view. N/A for read-only, batch, or CLI projects.

## §8 — Testing Verification `[all]`
Test files exist for new modules. Test names describe behavior, not implementation.

## §9 — API Contract Match `[web-app, fullstack, cli, library, automation]`
Frontend field types and names match backend expectations. N/A for purely local scripts with no inter-process API.

## §10 — Context-Aware Navigation `[web-app, fullstack, tui]` *(production only)*
After save/submit, user returns to correct context (not always the same page). N/A for non-interactive projects.

## §11 — No Hardcoded Secrets `[all]`
No API keys, tokens, passwords, or connection strings in source.

## §12 — Commit Format `[all]`
Commits follow project convention (conventional commits, Jira key prefix, etc.).

## §13 — No Debug Artifacts `[all]`
No `console.log`, `debugger`, `TODO: remove`, or test-only code in production paths.

## §14 — Dependency Hygiene `[all]`
New dependencies are justified. No duplicate packages. Lock file updated.

## §15 — Breaking Change Flag `[all]`
API/schema changes flagged in PR description with migration notes.

## §16 — Init Race Safety `[all]` *(production only)*
Async initialization must handle concurrent callers (no double-init, no race).

## §17 — Modal Compliance `[web-app, fullstack]` *(production only)*
All modals use shared modal component — no inline hidden modals. N/A for non-UI projects.

## §18 — Anti-Pattern Check `[all]`
Code does not introduce patterns listed in `MEMORY_ANTI_PATTERNS.md`. See project-type tags on Anti-001 through Anti-015 for type-specific relevance.

## §19 — Doc Impact `[all]`
Constants, config values, and API fields are documented in the appropriate register.

## §20 — TEST_REGISTRY Updated `[all]`
If test files were added or modified, `TEST_REGISTRY.md` has corresponding entries. N/A if project has no TEST_REGISTRY.

## §21 — Security Review `[all]` *(when required)*
HIGH/CRITICAL risk tasks have SEC sign-off per `docs/SECURITY_STANDARDS.md`.

## §22 — Accessibility `[web-app, fullstack]` *(production only)*
Interactive elements have labels, focus management, and keyboard support. N/A for non-browser projects.

## §23 — Performance `[web-app, fullstack, cli, automation]` *(production only)*
No N+1 queries, unbounded loops, or missing pagination on list endpoints. CLI tools: no unbounded file reads or unbounded process spawning.

## §24 — Rollback Plan `[all]` *(production only)*
HIGH/CRITICAL changes document rollback steps.

## §25 — Final Approval `[all]`
QA "Green" status granted. All applicable gates pass.
