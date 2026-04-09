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

## Step 0.5 — Path Resolution (Fork Support)

This skill references files under `.agent/` and `docs/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/.ai/Security.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/.ai/Security.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

## Step 0.6 — Toolchain Discovery (Mandatory)

Follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect available linters, dependency audit tools, and config-register checks. Adapt all commands in this skill to the project's actual toolchain. If a tool is unavailable, WARN and mark that check's findings as "skipped — tool not available."

## Step 1 — Load context

Read these files:

- `.agent/.ai/Security.md` — security constitution
- `docs/SECURITY_STANDARDS.md` — risk classification, checklists, approval policy
- `docs/SECURITY_STANDARDS.md` — security standards and incident response (if exists)
- `docs/CONFIGURATION_REGISTER.md` — documented constants (if exists)
- `docs/LOW_RISK_WHITELIST.md` — whitelisted patterns (if exists)

## Step 2 — Secrets scan (always runs — no tooling required)

This step is **grep-based** and works on any project regardless of stack.

Scan source code for secrets patterns:

```bash
# API keys, tokens, passwords in source files
grep -rn "AKIA[0-9A-Z]\{16\}\|sk-[a-zA-Z0-9]\{20,\}\|password\s*=\s*['\"][^'\"]\+['\"]\|api[_-]\?key\s*=\s*['\"][^'\"]\+['\"]" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.env" --include="*.yml" --include="*.yaml" --include="*.json" . | grep -v node_modules | grep -v vendor | grep -v '.test.' | head -30

# Private keys, certificates
find . -name "*.pem" -o -name "*.key" -o -name "*.p12" -o -name "*.pfx" | grep -v node_modules | grep -v vendor

# .env files tracked in git
git ls-files '*.env' '.env.*' | head -10

# Secrets in git history (last 50 commits)
git log -50 --diff-filter=A --name-only -- '*.env' '*.pem' '*.key' 'keys/' | head -20
```

## Step 3 — Dependency audit

Use the project's dependency audit tool (detected via Toolchain Discovery):

| Stack | Command |
|-------|---------|
| Node.js | `npm audit --json 2>&1 \| head -100` |
| Python | `pip audit --format json 2>&1` or `safety check --json` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit` |
| Ruby | `bundle audit check` |

If no dependency audit tool is available, skip this step with: "**Skipped:** No dependency audit tool found. Install dependencies and run your stack's audit command (e.g., `npm audit`, `pip audit`) for CVE scanning."

Classify findings:
- **CRITICAL/HIGH CVE:** Flag as CRITICAL finding
- **MODERATE CVE:** Flag as MEDIUM finding
- **LOW CVE:** Flag as LOW finding

## Step 4 — Auth & access control review

Scan for common auth vulnerabilities using **stack-adaptive** patterns:

```bash
# Auth bypass patterns outside test code (adapt paths to project structure)
grep -rn "dummy.token\|TEST_AUTH_BYPASS\|auth.*disabled\|skip.*auth" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" | grep -v node_modules | grep -v vendor | grep -v '.test.' | grep -v '__test__' | head -20

# IDOR patterns — fetching by ID without ownership check
grep -rn "params\.\(id\|userId\|user_id\)" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" | grep -v node_modules | grep -v vendor | head -20
```

Check:
- All API routes use authentication middleware
- Resource access includes ownership checks
- No test-only auth bypasses leak into production code

## Step 5 — OWASP Top 10 code-level scan

Scan for common vulnerability patterns. These checks are **grep-based** and work on any project:

| OWASP Category | Check |
|----------------|-------|
| A01 Broken Access Control | Missing auth middleware, IDOR, privilege escalation |
| A02 Cryptographic Failures | Weak hashing, hardcoded secrets, insecure JWT config |
| A03 Injection | SQL string concatenation, unescaped user input in HTML |
| A04 Insecure Design | Missing rate limiting, no CSRF protection |
| A05 Security Misconfiguration | Verbose error messages, debug mode, missing security headers |
| A06 Vulnerable Components | Dependency audit findings (Step 3) |
| A07 Auth Failures | Weak password policy, missing brute-force protection |
| A08 Data Integrity Failures | Unsigned/unverified updates, missing integrity checks |
| A09 Logging Failures | Missing audit logging for security events |
| A10 SSRF | Unvalidated URLs in server-side requests |

```bash
# SQL injection patterns (string concatenation in queries)
grep -rn "query.*+.*\(req\|request\|params\|input\)\|execute.*+\|\.format.*SELECT\|f\"SELECT\|f'SELECT" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" | grep -v node_modules | grep -v vendor | grep -v '.test.' | head -20

# XSS patterns (innerHTML, dangerouslySetInnerHTML, unescaped template output)
grep -rn "innerHTML\|outerHTML\|document\.write\|dangerouslySetInnerHTML\|v-html\|\|safe\b" . --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.html" --include="*.py" | grep -v node_modules | grep -v vendor | head -20

# Hardcoded credentials
grep -rn "password\s*[:=]\s*['\"][^'\"]\{3,\}['\"]" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.yml" --include="*.yaml" | grep -v node_modules | grep -v vendor | grep -v '.test.' | grep -v 'example\|placeholder\|changeme\|TODO' | head -20
```

## Step 6 — Configuration & governance audit

### Security constants

If a config register linting tool is available (detected via Toolchain Discovery), run it. Otherwise, manually grep for hardcoded security constants:

```bash
# Find hardcoded security-relevant constants (adapt to project structure)
grep -rn "maxAge\|expiresIn\|algorithm.*HS\|algorithm.*RS\|sameSite\|httpOnly\|secure:\s*\(true\|false\)\|cors\|helmet\|rateLimit\|HSTS" . --include="*.js" --include="*.ts" --include="*.py" --include="*.go" | grep -v node_modules | grep -v vendor | grep -v '.test.' | head -20
```

If `CONFIGURATION_REGISTER.md` exists, cross-reference found constants against it.

### Governance compliance

- [ ] `.github/CODEOWNERS` or equivalent exists and covers security-sensitive paths
- [ ] Branch protection enabled on default branch
- [ ] CI gate runs on all PRs
- [ ] Secret scanning enabled (pre-commit hooks, CI scanner, or equivalent)

## Step 7 — Classify and deduplicate

For each finding:
1. Assign severity: CRITICAL / HIGH / MEDIUM / LOW
2. If Jira is available, check if already tracked
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
- `docs/SECURITY_STANDARDS.md` — security standards and incident response (if exists)
- `docs/CONFIGURATION_REGISTER.md` — documented constants (if exists)
- Autonomy bounds documentation (if exists)
