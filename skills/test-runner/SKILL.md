---
name: test-runner
description: "Run, triage, and improve tests — executes test suites, triages failures/flaky tests, and drives coverage increase. Use when running tests, CI fails, or coverage needs improvement."
argument-hint: "[suite-name or 'coverage' or 'triage']"
---

# Test Runner, Triage & Coverage

This skill combines test execution, failure triage, and coverage improvement into a single workflow.

## Modes

- **Run** (default): Execute all test suites and report results
- **Triage** (argument contains "triage"): Diagnose and fix failing/flaky tests
- **Coverage** (argument contains "coverage"): Three-phase plan to raise coverage thresholds

---

## Path Resolution (Fork Support)

This skill references files under `.agent/` and `docs/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/TOOLCHAIN_DISCOVERY.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/TOOLCHAIN_DISCOVERY.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

## Toolchain Discovery (Mandatory)

Before executing any commands, follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect available test runners, linters, and coverage tools. Do not assume any specific test command exists — discover the project's actual commands and adapt. If no test runner is found, WARN clearly and stop.

---

## Mode: Run

### Step 1 — Execute Test Suites

Use TOOLCHAIN_DISCOVERY to find the project's test command. Examples:
- Node.js: `npm run test:unit`, `npm test`, `npx jest`
- Python: `pytest`, `python -m pytest`
- Go: `go test ./...`
- Rust: `cargo test`

Run the discovered command. If E2E tests are available:
- Node.js: `npm run test:e2e`, `npx playwright test`
- Python: `pytest tests/e2e/`

### Step 2 — Report Results

For each suite, report: pass/fail count, duration, any failures with error messages.

If any tests fail, automatically enter **Triage** mode for those failures.

---

## Mode: Triage

### Step 1 — Identify Failure

Run the failing test locally and capture the exact error. Save output for root cause analysis.

### Step 2 — Root Cause Analysis

**For E2E flakiness, check:**
- Timing/race conditions — missing waits (`waitForSelector`, `waitForResponse`, explicit delays)
- Null safety (Anti-005) — state not loaded before assertion
- Overlay/modals blocking interaction
- Auth context not set for the request

**For unit/API failures, check:**
- DB state — test isolation, missing fixtures
- Environment variables — missing `JWT_SECRET`, `DATABASE_URL`, or other envs
- Mock setup — stale mocks or missing stubs
- Timing dependencies — `setTimeout`, `setInterval` in test

### Step 3 — Fix or Quarantine

1. **Fix root cause** when possible — always preferred
2. **For flaky tests:** Add retry or mark as skip with a comment explaining why
3. **Record if not fixed:** Create a bug issue in your project's tracker

### Step 4 — Commit

After fixing tests, commit the changes with a reference to the test file(s) modified.

---

## Mode: Coverage

### Targets (adjust per project)

- **Lines:** ≥80%
- **Statements:** ≥80%
- **Functions:** ≥60%
- **Branches:** ≥40%

> Adjust thresholds based on project type. CLI tools may prioritize functions over branches. Libraries may be more strict on statements.

### Rules

1. **No regressions.** All tests must pass after coverage changes.
2. **Observable assertions only.** Tests assert observable behavior (response status/body, DB state, mock call args). Avoid mock-only tests without real verification.
3. **Stop when:** (a) All thresholds met, or (b) two consecutive cycles add <0.5% lines (plateau). On plateau, report which files need refactoring.

### Phase A — Refactor for Testability

Improve the project's testability by identifying untestable patterns:
1. **Hardcoded DB references** — extract to dependency injection or fixtures
2. **Unmocked external calls** — add interfaces for network, file I/O
3. **Inaccessible state** — ensure app state is reachable via request context

### Phase B — Batched API Test Suites

Create API test suites covering:
- Happy path for each endpoint
- Error cases (400, 401, 403, 404)
- Edge cases (empty input, max length, special characters)

### Phase C — Targeted Unit Tests

Add unit tests for:
- Complex business logic (sorting, calculation, transformation)
- Error/edge cases
- State machines and conditional branches

### After Each Phase

1. Run full test suite — all must pass
2. Measure coverage — note which metrics improved
3. Update testing documentation for new fixtures/mocks/suites

---

## References

- `.agent/TOOLCHAIN_DISCOVERY.md` — detect available test runners and coverage tools
- `.agent/workflows/quality-gates.md` — pre-merge quality gates
- `.agent/.ai/MEMORY_ANTI_PATTERNS.md` — Anti-002 (happy-path-only), Anti-005 (null-blind), Anti-013 (environment-blind)
- `docs/TESTING_STANDARDS.md` — project-specific test quality standards (if exists)