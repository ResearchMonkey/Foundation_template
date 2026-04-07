# Security Operations

<!-- TODO: Fork projects — customize OWASP mapping and incident response for your stack -->

## OWASP Top 10 Mapping

| OWASP | Category | Check | Gate |
|-------|----------|-------|------|
| A01 | Broken Access Control | Auth on every protected endpoint | §21 |
| A02 | Cryptographic Failures | No plaintext secrets, proper hashing | §11 |
| A03 | Injection | Parameterized queries, input sanitization | §5 (CODING_STANDARDS) |
| A04 | Insecure Design | Threat model for HIGH/CRITICAL changes | §21 |
| A05 | Security Misconfiguration | CORS, CSP, security headers reviewed | §11 |
| A06 | Vulnerable Components | Dependency audit, CVE check | §14 |
| A07 | Auth Failures | Session management, token handling | §21 |
| A08 | Data Integrity Failures | Signed artifacts, verified updates | §14 |
| A09 | Logging Failures | Security events logged, no PII in logs | — |
| A10 | SSRF | URL validation, allowlists for outbound | §5 |

## Dependency Audit

Run periodically:
- `npm audit` / `pip audit` / language-specific tool
- Check results against CVE databases
- CRITICAL/HIGH CVEs block merge; MEDIUM creates a ticket

## Secrets Scan

- Scan for hardcoded secrets before every commit
- Tools: `git-secrets`, `trufflehog`, `detect-secrets`, or equivalent
- Any finding is a **CRITICAL** blocker

## Incident Response Checklist

1. **Identify** — What is compromised? Scope the blast radius.
2. **Contain** — Revoke tokens, rotate secrets, disable affected endpoints.
3. **Notify** — Alert stakeholders per `APPROVAL_POLICY.md`.
4. **Fix** — Patch the vulnerability with CRITICAL risk classification.
5. **Review** — Post-incident AAR; update `MEMORY_SECURITY.md` with lessons.

## References

- `.agent/.ai/Security.md` — SEC constitution
- `.agent/.ai/RISK_LEVELS.md` — risk tier definitions
- `docs/agent/technical/APPROVAL_POLICY.md` — escalation and sign-off
