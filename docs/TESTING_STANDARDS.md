# Testing Standards

<!-- TODO: Fork projects — customize coverage requirements, test types, and anti-patterns for your stack -->

> **Owner:** This is a user-owned standards document. Edit this file to change the rules your AI agents follow when writing and validating tests.  
> **Consumer:** `@QA` persona, `@QA Validator`, `test-runner` skill, `review-tests` skill.

## 1. Pre-Merge Quality Review

Before granting "Green" status on any PR, verify:

1. **Null Safety:** All chained property accesses on API data have null guards.
2. **Modal Compliance:** All modals use the shared modal component — no inline hidden modals.
3. **Mutation → Refresh:** Every create/update/delete: (a) closes modal, (b) shows user feedback, (c) refreshes list, (d) navigates correctly.
4. **Error Feedback:** Every catch block shows user-facing feedback.
5. **API Contract:** Frontend parameter types and field names match backend expectations.
6. **Edge-Case Personas:** Tests include at least one minimal/new user scenario.
7. **Coverage:** New code has corresponding tests (unit or E2E as appropriate).
8. **No Regression:** Existing passing tests still pass.

## 2. Test Strategy

- **Unit tests** for business logic and API handlers
- **E2E tests** for user-facing flows and mutations
- **Negative path tests** for error and edge cases
- **Mutation verification** — lists/views must update after create/update/delete

## 3. Test Naming

- Name tests to describe behavior: `should return 404 when user not found`
- Do not name after implementation: `test_getUserById_function`

## 4. Test Structure

- **Arrange / Act / Assert** — three clear sections per test
- One assertion per test (or closely related assertions)
- No logic in tests (no `if`, no loops, no try/catch)

## 5. Coverage Requirements

- Happy path: always required
- Primary failure case: always required
- Edge cases: required for MEDIUM+ risk changes
- Integration tests: required when touching auth, payments, or data mutations

## 6. Test Anti-Patterns

See `docs/CODING_STANDARDS.md` §12 for the full anti-pattern list. Anti-002 (Happy-path-only testing) and Anti-011 (Dropped planned tests) are particularly relevant to testing.

| ID | Anti-Pattern | Rule |
|----|-------------|------|
| T-001 | Test depends on execution order | Each test must be independently runnable |
| T-002 | Overly broad mocks | Mock at boundaries, not internals |
| T-003 | Snapshot overuse | Snapshots for stable output only; not for evolving UI |
| T-004 | Flaky timing | No `setTimeout` in tests; use proper async patterns |

## 7. Registry Requirement

Every test file must have a corresponding entry in `docs/agent/quality/TEST_REGISTRY.md`.

## 8. Validation Checklist

Before granting "Green" status:

- [ ] Tests pass (unit + integration as applicable)
- [ ] Quality gates from `.agent/workflows/quality-gates.md` satisfied
- [ ] No new lint errors introduced
- [ ] Anti-patterns from `docs/CODING_STANDARDS.md` §6 not violated
- [ ] TEST_REGISTRY updated if test files changed
