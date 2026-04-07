# Risk Level Definitions

<!-- TODO: Fork projects — adjust thresholds and examples for your domain -->

## Tier Definitions

| Tier | Description | SEC Required? | Human-in-the-Loop? |
|------|-------------|---------------|---------------------|
| **LOW** | Cosmetic, docs, tests, whitelisted patterns | No (ARCH self-authorizes) | No |
| **MEDIUM** | Business logic, non-auth API changes, UI state | Yes (review) | No |
| **HIGH** | Auth, payments, PII, data model changes | Yes (full audit) | Recommended |
| **CRITICAL** | Security incident, data breach, compliance | Yes (full audit) | **Required** |

## Classification Guide

### LOW — Fast Lane
- Typo fixes, copy changes
- Adding/updating tests (no logic change)
- Documentation updates
- Patterns listed in `docs/agent/technical/LOW_RISK_WHITELIST.md`

### MEDIUM — Standard Lane
- New UI components or views
- Non-auth API endpoints
- Business logic changes
- Database queries (read-only)

### HIGH — Slow Lane
- Authentication / authorization changes
- Payment processing
- PII handling or storage
- Database schema migrations
- Third-party integration credentials

### CRITICAL — Stop & Escalate
- Active security incidents
- Data breach response
- Compliance-related changes
- Production hotfixes to auth/payments

## Human-in-the-Loop Template

For HIGH/CRITICAL tasks, present this to the user before proceeding:

```
RISK: [HIGH|CRITICAL]
AREA: [auth|payments|PII|etc.]
CHANGE: [1-line summary]
IMPACT: [what could go wrong]
RECOMMENDATION: [proceed with review | stop and discuss]
```
