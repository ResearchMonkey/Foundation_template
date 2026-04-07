# Low-Risk Whitelist

<!-- TODO: Fork projects — add patterns that are safe to fast-lane past @SEC -->

Patterns on this list allow ARCH to self-authorize and **skip SEC review** (SDLC §4.2).

## Whitelisted Patterns

| # | Pattern | Scope | Rationale |
|---|---------|-------|-----------|
| 1 | Documentation-only changes | `docs/`, `*.md`, `README` | No runtime impact |
| 2 | Test-only changes | `tests/`, `__tests__/`, `*.test.*`, `*.spec.*` | No production code |
| 3 | Linter/formatter config | `.eslintrc`, `.prettierrc`, `.editorconfig` | Style only |
| 4 | CI pipeline — non-deploy steps | `.github/workflows/` (lint, test jobs only) | No prod deployment |
| 5 | Copy/string changes | i18n files, UI labels, error messages | No logic change |
| 6 | Dependency patch bumps | Lock file only, patch version | Security fixes |
| 7 | Type-only changes | Type definitions, interfaces (no runtime) | No runtime impact |

## Exclusions (Never Whitelisted)

These always require SEC review regardless of scope:

- Auth / session / token handling
- Payment / billing logic
- PII storage or transmission
- Database schema changes
- Third-party credential configuration
- CORS, CSP, or security header changes
