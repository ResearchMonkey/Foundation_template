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

Before executing any commands, follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect available test runners, linters, and coverage tools. Do not assume `npm run test:unit` exists — discover the project's actual commands and adapt. If no test runner is found, WARN clearly and stop.

---

## Mode: Run

### Step 1 — Execute Test Suites

Run discovered test command (e.g., `npm run test:unit`, `pytest`, `go test ./...`, `cargo test`):

```bash
<TEST_CMD>
```

If E2E tests requested:

```bash
npm run test:e2e
```

Lint check:

```bash
npm run lint
```

### Step 2 — Report Results

For each suite, report: pass/fail count, duration, any failures with error messages.

If any tests fail, automatically enter **Triage** mode for those failures.

---

## Mode: Triage

### Step 1 — Identify Failure

Run the failing test suite locally and capture the exact error:

!`npm run test:unit 2>&1 | tail -30`

### Step 2 — Check Registry

Verify the test is in `docs/agent/quality/TEST_REGISTRY.md`. If it's a new test:
- Add `(FR-XXX)` to Playwright test title or `[FR-XXX]` to Python docstring
- Run `npm run generate-registry`

### Step 3 — Root Cause Analysis

**For E2E flakiness, check:**
- Timing/race conditions — missing `waitForSelector` or `waitForResponse`
- Null safety (Anti-005) — `AppState` not loaded yet
- Modal overlays blocking clicks
- Academy context not set (`X-Academy-ID` header missing)
- Init race (Gate §16) — bare `if (!X) return` without retry

**For unit/API failures, check:**
- DB state — test isolation, missing fixtures
- Environment variables — `JWT_SECRET`, `REGISTRATION_CODE`
- Mock setup — stale mocks or missing stubs

### Step 4 — Fix or Quarantine

1. **Fix root cause** when possible — always preferred
2. **For Tier B flaky tests:** Add retry or `test.skip()` with a comment explaining why
3. **Record if not fixed:** Create a Jira bug issue in your tracker with label `test-failure`

### Step 5 — Update Registry

After adding/fixing tests:
```bash
npm run generate-registry
```
Commit `docs/agent/quality/TEST_REGISTRY.md`.

---

## Mode: Coverage

### Targets

- **Lines:** ≥80%
- **Statements:** ≥80%
- **Functions:** ≥60%
- **Branches:** ≥40%
- **Primary metric:** Lines

### Current Coverage

!`npx nyc -r text-summary npm run -s test:unit 2>&1 | tail -10`

**Excluded:** `tests/`, `client/`, `server/seed_*.js`, `server/jobs/`, `server/socket.js`, config files, DTOs, pure type definitions.

### Rules

1. **No regressions.** `npm run test:unit` must pass after every change.
2. **Observable assertions only.** Every test asserts observable behavior (response status/body, DB state, mock call args). No mock-only tests.
3. **Stop when:** (a) All four thresholds met, or (b) two consecutive cycles add <0.5% lines (plateau). On plateau, report which files need refactoring.

### Phase A — Refactor for Testability

1. **App-level DB:** In `server/server.js`, ensure `app.set('db', db)`. In route handlers, use `const db = (req.app && req.app.get('db')) || require('../../database')`.
2. **Authenticate DI:** Export `createAuthenticate(opts)` factory from `server/middleware/authenticate.js` with `opts = { db?, jwtSecret? }`.
3. **Mock DB:** Ensure `tests/mocks/db_mock.js` exists with `createDbMock(config)`.

**Exit:** One route uses injected db; authenticate uses factory; one test uses mock db.

### Phase B — Batched API Test Suites

1. **Fixtures:** Extend `tests/fixtures/users.js` and `tests/fixtures/cofs.js`.
2. **Attempts suite:** `tests/api/attempts_api.test.js` — POST (400, 404, 400, 400, 201), GET 200, POST media 201, cross-user 403.
3. **Social + leaderboards:** `tests/api/social_leaderboards_api.test.js` — feed, posts, connections, blocks, leaderboards.
4. **Auth + users:** `tests/api/auth_users_api.test.js` — register validation, login errors, forgot/reset, PATCH/PUT/GET users.

**Exit:** All suites in `npm run test:unit`; re-measure coverage.

### Phase C — Targeted Unit Tests

1. **Middleware:** `tests/unit/middleware.test.js` — requirePolicy, loadAcademyContext, tenant_alpha.
2. **Authenticate:** `tests/unit/authenticate.test.js` — using DI factory, test all auth paths.
3. **Grading:** `tests/unit/grading.test.js` — calculatePercentile both branches.

**Exit:** All thresholds met or plateau reported.

### After Each Phase

1. Run `npm run test:unit` — all must pass
2. Run `npx nyc -r lcov -r text-summary npm run -s test:unit` — note coverage
3. Update `docs/technical/Testing_Guide.md` for new fixtures/mocks/suites

---

## CLI Reference

| Command | Purpose |
|---------|---------|
| `npm run test:unit` | Unit + API tests |
| `npm run test:e2e` | E2E Playwright tests |
| `npm run lint` | ESLint check |
| `npm run lint:fix` | ESLint auto-fix |
| `npm run test:unit:cov` | Coverage report |
| `npm run test:migrate:fresh` | Fresh migration check |
| `npm run test:migrate:v30` | IDPA seed check |
| `npm run test:type:parity` | SQLite/Postgres parity |

## References

- `docs/agent/quality/TEST_REGISTRY.md` — test inventory
- `docs/TESTING_STANDARDS.md` — test quality standards
- `.agent/workflows/quality-gates.md` §16 — init race safety
- `.agent/.ai/MEMORY_ANTI_PATTERNS.md` — Anti-002 (happy-path-only)
- `.agent/workflows/quality-gates.md` — pre-merge quality gates
- `tests/api/api_validation.test.js` — existing pattern
