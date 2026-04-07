# Toolchain Discovery

Skills MUST detect available tooling before executing commands. Do not assume any specific toolchain exists.

## Discovery Procedure

Before running any project commands, check what's available:

```
1. Check for package.json → read "scripts" keys
2. Check for Makefile → read target names
3. Check for Pipfile / pyproject.toml / requirements.txt → Python project
4. Check for Cargo.toml → Rust project
5. Check for go.mod → Go project
```

## Command Resolution

For each command a skill needs, resolve it in this order:

| Need | Check for | Fallback | If nothing found |
|------|-----------|----------|------------------|
| **Lint** | `npm run lint`, `make lint`, `cargo clippy`, `go vet`, `ruff check` | Run linter binary directly if installed | WARN: "No linter detected — lint gate skipped" |
| **Unit tests** | `npm run test:unit`, `npm test`, `make test`, `cargo test`, `go test ./...`, `pytest` | Look for test runner in PATH (`jest`, `vitest`, `pytest`, `go`) | WARN: "No test runner detected — test gate skipped" |
| **E2E tests** | `npm run test:e2e`, `npx playwright test`, `make test-e2e` | Check for playwright/cypress/selenium config | WARN: "No E2E framework detected — E2E gate skipped" |
| **Coverage** | `npm run test:unit:cov`, `npm run coverage`, `pytest --cov`, `go test -cover` | `npx nyc`, `coverage.py` | WARN: "No coverage tool detected — coverage metrics unavailable" |
| **Lint fix** | `npm run lint:fix`, `make lint-fix`, `cargo fmt`, `ruff check --fix` | — | Skip auto-fix, report lint errors only |
| **Doc tools** | `npm run lint:doc-coverage`, `npm run lint:config-register` | — | WARN: "No doc linting detected — doc audit is manual only" |
| **Registry gen** | `npm run generate-registry` | — | WARN: "No registry generator — TEST_REGISTRY must be maintained manually" |

## Rules

1. **Never fail silently.** If a command is unavailable, emit a clear WARNING in output and in the `quality_gates` JSON (`"result": "skipped"`, `"evidence": "no lint tool detected"`).
2. **Never fake a pass.** A skipped gate is not a passed gate. The gate result must reflect reality.
3. **Adapt, don't prescribe.** If the project uses `pytest` instead of `npm run test:unit`, use `pytest`. Match the project's toolchain.
4. **Log what you found.** In the initialization status report, list discovered tools so the user can verify.
