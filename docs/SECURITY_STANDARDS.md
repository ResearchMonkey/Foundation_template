# Security Standards

<!-- TODO: Fork projects — customize risk tiers, checklists, and approval policy for your domain -->

> **Owner:** This is a user-owned standards document. Edit this file to change the rules your AI agents follow for security review and risk classification.  
> **Consumer:** `@Security` persona, `review-security` skill, `implement` skill.

## 1. Pre-Merge Security Checklist

For every PR:

- [ ] **Secrets hygiene:** Run secrets scan — no secrets in working tree or staged files.
- [ ] **Parameterized queries:** No raw SQL interpolation in search or user-input paths.
- [ ] **IDOR guard:** Any data fetch for a user must filter by user ownership — never fetch by ID alone.
- [ ] **XSS escaping:** All user-supplied strings interpolated into HTML must be escaped.
- [ ] **Auth bypass:** Never gate security bypasses on environment variables alone.

## 2. Risk Classification Rubric

Score each change against these criteria. The **highest matching tier** wins.

### LOW — Auto-approve
A change is LOW if **all** of the following are true:
- Does not modify server-side logic (docs, comments, CSS, static text)
- Does not add/change API endpoints, routes, or middleware
- Does not touch database schemas, queries, or migrations
- Does not handle user input or render user-supplied content
- Examples: typo fixes, README updates, log message changes, UI copy, test-only changes

### MEDIUM — Proxy approve (SEC delegates)
A change is MEDIUM if **any** of the following are true (and none from HIGH/CRITICAL):
- Adds or modifies an API endpoint (but not auth/authz logic)
- Adds new database columns or tables (no PII fields)
- Changes client-side form handling or validation
- Modifies non-auth middleware (logging, caching, rate limiting)
- Adds new dependencies (non-security-critical)
- Changes CI/CD configuration
- Examples: new CRUD endpoint, UI form changes, adding a cache layer, new npm package

### HIGH — Escalate, await approval
A change is HIGH if **any** of the following are true (and none from CRITICAL):
- Modifies authentication logic (login, session, JWT, OAuth)
- Modifies authorization logic (roles, permissions, access control)
- Adds or changes PII fields (email, name, phone, address, IP)
- Changes data export or reporting endpoints
- Modifies security headers, CORS, or CSP configuration
- Adds or modifies file upload handling
- Changes error handling in auth/security paths
- Examples: new role type, adding user email field, changing CORS origins, file upload endpoint

### CRITICAL — Halt board, require human review
A change is CRITICAL if **any** of the following are true:
- Modifies credential storage, rotation, or retrieval
- Changes payment or financial transaction logic
- Modifies encryption or hashing algorithms
- Changes qualification/certification records (compliance-regulated data)
- Introduces or modifies auth bypass mechanisms (even for testing)
- Bulk data deletion or migration of production user data
- Changes to secrets management or environment variable handling for credentials
- Examples: password hashing change, payment flow, bulk user data migration, API key rotation

### Tie-breaking rules
1. If a change spans multiple tiers, use the **highest** tier
2. If unsure between two adjacent tiers, choose the **higher** one
3. A change to test files that exercises auth/security code is **one tier below** the code it tests
4. Reverting a previous change inherits the **same tier** as the original change

## 3. Risk Level Summary

| Tier | Description | SEC Required? | Human-in-the-Loop? |
|------|-------------|---------------|---------------------|
| **LOW** | Cosmetic, docs, tests, whitelisted patterns | No (ARCH self-authorizes) | No |
| **MEDIUM** | Business logic, non-auth API changes, UI state | Yes (review) | No |
| **HIGH** | Auth, payments, PII, data model changes | Yes (full audit) | Recommended |
| **CRITICAL** | Security incident, data breach, compliance | Yes (full audit) | **Required** |

## 4. Security Review Checklist

- [ ] No SQL injection — parameterized queries only
- [ ] No XSS — user content escaped before DOM insertion
- [ ] No IDOR — ownership checks on all resource access
- [ ] No hardcoded secrets or test bypasses in production code
- [ ] Auth middleware on all protected routes
- [ ] Error responses don't leak stack traces or secrets

For CI/CD security conventions, see `docs/OPS_STANDARDS.md` §4.

## 5. Human-in-the-Loop Template

For HIGH/CRITICAL tasks, present this to the user before proceeding:

```
RISK: [HIGH|CRITICAL]
AREA: [auth|payments|PII|etc.]
CHANGE: [1-line summary]
IMPACT: [what could go wrong]
RECOMMENDATION: [proceed with review | stop and discuss]
```

## 6. Low-Risk Whitelist

See `docs/agent/technical/LOW_RISK_WHITELIST.md` for patterns that allow ARCH to self-authorize and skip SEC review.

## 7. Approval Policy

See `docs/agent/technical/APPROVAL_POLICY.md` for the full approval matrix, escalation paths, and sign-off format.
