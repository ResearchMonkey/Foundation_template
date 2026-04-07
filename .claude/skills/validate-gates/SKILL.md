---
name: validate-gates
description: "Second-pass validator that audits the quality_gates output from implement. Catches skipped gates, missing evidence, and self-reported passes without proof. Use after implement completes."
argument-hint: "[path to implement JSON output, or 'last' to use most recent]"
---

# Validate Gates

Second-pass quality audit of implement output.

Reads `.agent/skills/validate-gates/SKILL.md` for full implementation details.

## Quick Reference

```
EDI, run validate-gates last
EDI, run validate-gates /tmp/ctx/PROJ-123-output.json
```

## What It Checks

1. **Structural completeness** — all required gates present in output
2. **Evidence quality** — no empty, generic, or self-referential evidence
3. **Spot-check verification** — independently re-checks lint, tests, constants, anti-patterns where possible

## Verdicts

- **PASS** — all gates verified, no HIGH findings
- **WARN** — MEDIUM findings only; evidence should be strengthened
- **FAIL** — HIGH findings; implement output cannot be trusted
