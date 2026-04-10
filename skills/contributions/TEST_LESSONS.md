# Test Lessons — Generalized from Production Experience

**Source:** QA Lessons Learned + Periodic Review [DATE]
**Status:** Active — update when new patterns emerge
**Purpose:** Lessons that apply to any web project with E2E tests

---

## 1. E2E Testing Lessons

### Rate Limit Contention
**Problem:** Parallel E2E workers exhaust API rate limits → 429 errors.
**Mitigation:** Use `workers: 1` for specs that submit many requests; set test-mode flags to relax limits in test environments.

### E2E Coverage ≠ Test Quality
**Problem:** An E2E hitting an endpoint marks code "covered" but may not validate logic.
**Mitigation:** Treat merged coverage as informational; require unit tests for business logic validation.

### Test Timing / Race Conditions
**Problem:** After creating a resource, the list view may not update immediately.
**Mitigation:** Add explicit waits or retry logic; use `data-testid` attributes for stable selectors; verify the full flow including post-save state.

### Modal Blocking
**Problem:** Overlay modals can intercept pointer events and stall tests.
**Mitigation:** Prefer inline validation; ensure modals are dismissible; add explicit dismiss steps in tests.

### Post-Save Navigation
**Problem:** Save operations may land on different pages depending on state.
**Mitigation:** Use deterministic post-save navigation; assert on specific page/section after save.

---

## 2. Data Validation Lessons

### Impossible State Combinations
**Problem:** Business rules may allow logically impossible combinations (e.g., hits > shots).
**Mitigation:** Add explicit validation rejecting impossible states at submission time, not just at display.

### Negative Values
**Problem:** Partial operations may allow negative values that make no sense.
**Mitigation:** Add explicit rejection with error messages for negative values in numeric fields.

---

## 3. Environment Lessons

### Connectivity Assumptions
**Problem:** Tests assuming stable connectivity fail in field/degraded network conditions.
**Mitigation:** Document retry-when-online behavior; add larger touch targets for poor connectivity; consider manual fallbacks for critical flows.

### Environment-Specific URLs / Paths
**Problem:** Hardcoded URLs or filesystem paths break across environments.
**Mitigation:** Use environment-aware configuration; prefer API helpers over direct URL construction.

---

## 4. Test Quality Lessons

### Happy Path Only
**Problem:** Tests only checking the success case miss failure mode coverage.
**Mitigation:** Every test must verify a failure mode or error state in addition to the happy path.

### Dropping Planned Tests
**Problem:** Planned tests get skipped under time pressure and never get implemented.
**Mitigation:** If a planned test is skipped, the plan must be updated and the gap filed as a follow-up issue — never silently drop.

### Retry-Masked Failures
**Problem:** Using test retries (`retries: N`) to hide flaky tests instead of fixing root cause.
**Mitigation:** Retries are only acceptable for post-deploy smoke tests, not pre-merge quality gates.

---

## 5. Defect Tracking

| Lesson | Category | Mitigation |
|--------|----------|------------|
| Rate limit exhaustion in parallel E2E | Infrastructure | Workers config + test-mode flags |
| E2E coverage inflated by non-validating hits | Test Quality | Unit tests for logic, E2E for flows |
| Race conditions on post-create list refresh | Timing | Explicit waits + data-testid |
| Impossible state combinations allowed | Validation | Server-side invariant checks |
| Missing script tags (manual HTML injection) | Init Race | CI lint for canonical script references |
| Ghost features (documented but not coded) | Process | Feature completeness checklist in PR template |
| Swallowed errors (catch without user feedback) | Error Handling | ESLint rule + Anti-006 enforcement |
