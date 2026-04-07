# Test Quality Rules

<!-- TODO: Fork projects — add project-specific test quality standards -->

## 1. Test Naming

- Name tests to describe behavior: `should return 404 when user not found`
- Do not name after implementation: `test_getUserById_function`

## 2. Test Structure

- **Arrange / Act / Assert** — three clear sections per test
- One assertion per test (or closely related assertions)
- No logic in tests (no `if`, no loops, no try/catch)

## 3. Coverage Requirements

- Happy path: always required
- Primary failure case: always required
- Edge cases: required for MEDIUM+ risk changes
- Integration tests: required when touching auth, payments, or data mutations

## 4. Anti-Patterns to Reject

| ID | Anti-Pattern | Rule |
|----|-------------|------|
| Anti-002 | Happy-path-only testing | Must include at least one failure case |
| T-001 | Test depends on execution order | Each test must be independently runnable |
| T-002 | Overly broad mocks | Mock at boundaries, not internals |
| T-003 | Snapshot overuse | Snapshots for stable output only; not for evolving UI |
| T-004 | Flaky timing | No `setTimeout` in tests; use proper async patterns |

## 5. Registry Requirement

Every test file must have a corresponding entry in `docs/agent/quality/TEST_REGISTRY.md`.
