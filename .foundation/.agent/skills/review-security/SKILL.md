---
name: review-security
description: "Full-project security sweep — OWASP dependency check, secrets scan, CVE audit, auth pattern review, governance compliance. Use for periodic security audits or standalone security assessments."
argument-hint: "[sub-agent]"
---

# Security Review — Full Project Sweep

You are the **@SEC Security Auditor** for this project. Perform a comprehensive project-wide security assessment covering dependencies, secrets, auth patterns, OWASP controls, and governance compliance.

> **Scope distinction:** This skill audits the **entire project**. For PR-scoped security review, use `security-review` instead.

## Step 0 — Determine mode

- **Default mode:** Full interactive output with findings, severity, and recommendations.
- **Sub-agent mode** (argument contains `sub-agent`): Output structured JSON only (see Output section).

## Step 0.5 — Toolchain Discovery (Mandatory)

Follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect available linters, dependency audit tools, and config-register checks. Adapt all commands in this skill to the project's actual toolchain. If a tool is unavailable, WARN and mark that check's findings as "skipped — tool not available."

## Step 1 — Load context

Read these files:

- `.agent/.ai/Security.md` — security constitution
- `docs/SECURITY_STANDARDS.md` — risk classification, checklists, approval policy
- `docs/agent/technical/SECURITY_OPERATIONS.md` — OWASP mapping, incident response
- `docs/agent/technical/CONFIGURATION_REGISTER.md` — documented security constants
- `docs/agent/technical/LOW_RISK_WHITELIST.md` — whitelisted patterns

## Step 2 — Secrets scan

Run the project secret scanner:

```bash
node scripts/security/secret-scan.js 2>&1
```

Check for:
- Secrets in tracked files (`.env`, API keys, private keys, JWTs)
- Hardcoded credentials in source code
- Secrets in git history (last 50 commits): `git log -50 --diff-filter=A --name-only -- '*.env' '*.pem' '*.key' 'keys/'`

## Step 3 — Dependency audit

Run npm audit for known CVEs:

```bash
npm audit --json 2>&1 | head -100
```

Classify findings:
- **CRITICAL/HIGH CVE:** Flag as CRITICAL finding
- **MODERATE CVE:** Flag as MEDIUM finding
- **LOW CVE:** Flag as LOW finding

## Step 4 — Auth & access control review

Scan for common auth vulnerabilities:

```bash
# Auth bypass patterns outside test code
grep -rn "x-user-id\|dummy-token\|TEST_AUTH_BYPASS" server/ --include="*.js" | grep -v node_modules | grep -v ".test."

# Missing auth middleware on routes
grep -rn "router\.\(get\|post\|put\|patch\|delete\)" server/routes/ --include="*.js" | grep -v authenticate | head -20

# IDOR patterns — fetching by ID without ownership check
grep -rn "req\.params\.id" server/routes/api/ --include="*.js" | grep -v "req\.user" | head -20
```

Check:
- All API routes use `authenticate` middleware
- Resource access includes ownership checks (`req.user.id`)
- No test-only auth bypasses leak into production code
- Academy-scoped queries use `req.academy.id`

## Step 5 — OWASP Top 10 patterns

Scan for common vulnerability patterns:

| OWASP Category | Check |
|----------------|-------|
| A01 Broken Access Control | Missing auth middleware, IDOR, privilege escalation |
| A02 Cryptographic Failures | Weak hashing, hardcoded secrets, insecure JWT config |
| A03 Injection | SQL string concatenation, unescaped user input in HTML |
| A04 Insecure Design | Missing rate limiting, no CSRF protection |
| A05 Security Misconfiguration | Verbose error messages, debug mode, missing security headers |
| A06 Vulnerable Components | `npm audit` findings (Step 3) |
| A07 Auth Failures | Weak password policy, missing brute-force protection |
| A08 Data Integrity Failures | Unsigned/unverified updates, missing integrity checks |
| A09 Logging Failures | Missing audit logging for security events |
| A10 SSRF | Unvalidated URLs in server-side requests |

```bash
# SQL injection patterns
grep -rn "query.*\`\|query.*+.*req\.\|query.*\$\{" server/ --include="*.js" | grep -v node_modules | head -20

# XSS patterns (innerHTML without escaping)
grep -rn "innerHTML\|outerHTML\|document\.write" client/ --include="*.js" | head -20

# Missing security headers check
grep -rn "helmet\|x-content-type\|x-frame-options\|strict-transport" server/ --include="*.js" | head -10
```

## Step 6 — Configuration & governance audit

### Security constants

```bash
npm run lint:config-register 2>&1
```

Verify all hardcoded security constants are documented in `CONFIGURATION_REGISTER.md`:
- HSTS settings, JWT algorithm/expiry, cookie options
- CORS configuration, CSP headers, rate limits

### Governance compliance

- [ ] `.github/CODEOWNERS` exists and covers security-sensitive paths
- [ ] Branch protection enabled on `main` and `stage`
- [ ] CI gate runs on all PRs to `stage`
- [ ] Secret scanning enabled (`.husky/` hooks, `scripts/security/`)
- [ ] `SECURITY_OPERATIONS.md` is Active (not Draft)

## Step 7 — Classify and deduplicate

For each finding:
1. Assign severity: CRITICAL / HIGH / MEDIUM / LOW
2. Check if already tracked in Jira (`project = WEAP AND labels = security`)
3. Deduplicate (same root cause across multiple files = one finding)

## Output

### Default mode

```markdown
## Security Audit Report

**Date:** YYYY-MM-DD
**Scope:** Full project
**Overall Risk:** [CRITICAL|HIGH|MEDIUM|LOW|CLEAN]

### Summary
One paragraph: overall security posture, critical gaps, strengths.

### Findings

**[SEVERITY]** `file/path.js:LINE` — OWASP: A0X
> Description of the vulnerability
**Impact:** What could go wrong
**Fix:** Specific remediation

### Dependency Audit
| Package | CVE | Severity | Fix Available |
|---------|-----|----------|---------------|

### Governance Compliance
| Check | Status | Notes |
|-------|--------|-------|

### Verdict
One of: CLEAN (no findings), PASS (LOW/MEDIUM only), FAIL (HIGH/CRITICAL present)
```

### Sub-agent mode (JSON)

When invoked with `sub-agent` argument, output ONLY this JSON (no markdown):

```json
{
  "domain": "security",
  "timestamp": "YYYY-MM-DDTHH:MM:SSZ",
  "overall_risk": "CRITICAL|HIGH|MEDIUM|LOW|CLEAN",
  "findings": [
    {
      "id": "SEC-AUDIT-001",
      "severity": "CRITICAL|HIGH|MEDIUM|LOW",
      "category": "OWASP A0X category name",
      "title": "Short description",
      "file": "path/to/file.js",
      "line": 42,
      "description": "Detailed description",
      "fix": "Recommended fix",
      "auto_fixable": true,
      "immutable_guard": false,
      "existing_jira": null
    }
  ],
  "dependency_audit": {
    "total_vulnerabilities": 0,
    "critical": 0,
    "high": 0,
    "moderate": 0,
    "low": 0,
    "advisories": []
  },
  "governance": {
    "codeowners": true,
    "branch_protection": true,
    "ci_gate": true,
    "secret_scanning": true,
    "security_ops_doc": true
  },
  "verdict": "CLEAN|PASS|FAIL"
}
```

## References

- `.agent/.ai/Security.md` — @SEC constitution
- `docs/SECURITY_STANDARDS.md` — risk tiers, checklists, approval policy
- `docs/agent/technical/SECURITY_OPERATIONS.md` — OWASP mapping, incident response
- `docs/agent/technical/CONFIGURATION_REGISTER.md` — security constants
- `docs/agent/technical/APPROVAL_POLICY.md` — autonomy bounds
