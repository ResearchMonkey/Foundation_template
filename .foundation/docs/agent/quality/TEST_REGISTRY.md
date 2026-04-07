# Test Registry

<!-- TODO: Fork projects — add rows as you create test files -->

This file inventories every test file in the project. Keep it updated when adding, renaming, or removing tests. The `test-runner` and `validate-gates` skills check this file for completeness.

## How to Use

When adding or modifying a test file:
1. Add or update the row in the table below.
2. If a registry generator exists (`npm run generate-registry`), run it instead of editing manually.

## Registry

| Test File | Module Under Test | Type | Added In | Notes |
|-----------|-------------------|------|----------|-------|
| <!-- e.g. tests/auth/login.test.ts --> | <!-- e.g. src/auth/login.ts --> | <!-- unit / integration / e2e --> | <!-- e.g. PROJ-042 --> | <!-- e.g. covers SSO + password flows --> |

## Test Types

| Type | Description | When Required |
|------|-------------|---------------|
| **unit** | Single function/module, mocked dependencies | All new logic |
| **integration** | Multiple modules, real DB/services | Auth, payments, data mutations |
| **e2e** | Full user flow through UI or API | Critical paths (login, checkout) |

## Coverage Gaps

Track known gaps here so they can be prioritized:

| Module | Gap | Priority | Ticket |
|--------|-----|----------|--------|
| <!-- e.g. src/billing/invoice.ts --> | <!-- e.g. no test for partial refund --> | <!-- HIGH --> | <!-- e.g. PROJ-099 --> |
