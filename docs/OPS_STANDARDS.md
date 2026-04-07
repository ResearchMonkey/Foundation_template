# Operations Standards

<!-- TODO: Fork projects — customize failure classification, deployment rules, and CI/CD conventions for your infrastructure -->

> **Owner:** This is a user-owned standards document. Edit this file to change the rules your AI agents follow for operations, deployment, and infrastructure.  
> **Consumer:** `@DevOps` persona, `implement` skill.

## 1. Failure Classification

| Category | Description | Action |
|----------|-------------|--------|
| Flaky Test | Inconsistent failure, passes on retry | Quarantine and file issue |
| Dependency Conflict | Package version mismatch | Update and pin |
| Migration Failure | DB migration error | Block deploy, escalate |
| Health Check Fail | Post-deploy health check failing | Rollback investigation |
| Production Issue | Any failure in production path | Escalate immediately |

## 2. Key Rules

- Never auto-fix production-impacting failures without human review
- All pipeline changes should be reviewed before merge
- Secrets must never appear in logs or error messages
- Path portability: use forward slashes in script paths (Linux CI compatibility)

## 3. Environment Variable Policy

- All environment variables documented in `.env.example`
- No hardcoded secrets in code or config
- Environment-specific settings clearly separated (dev / staging / prod)
- Configuration drift between environments flagged and resolved

## 4. CI/CD Conventions

- Pipeline failures must be diagnosed and classified (see §1) before retry
- Lint, tests, and secrets scan must all pass before merge
- Non-deploy CI steps (lint, test) are LOW risk per `docs/SECURITY_STANDARDS.md`
- Deploy steps require the same risk tier as the code being deployed

## 5. Deployment Rules

- Deployments must be atomic and rollback-safe
- Migrations must run cleanly before deploy
- Health checks must pass post-deploy
- Rollback procedures must exist and be tested for MEDIUM+ risk changes
- Pre-release checklists must be run before tagging or merging to main

## 6. Release Checklist

Before any release:

- [ ] Lint passes
- [ ] All tests pass
- [ ] Secrets scan clean
- [ ] Migrations verified
- [ ] All quality gates green
- [ ] Rollback procedure documented (HIGH/CRITICAL changes)
