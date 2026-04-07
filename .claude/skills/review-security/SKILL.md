---
name: review-security
description: "Full-project security sweep — OWASP dependency check, secrets scan, CVE audit, auth pattern review, governance compliance. Use for periodic security audits."
argument-hint: "[sub-agent]"
allowed-tools: Read, Grep, Glob, Bash(npm *), Bash(npx *), Bash(node *), Bash(python3 *), Bash(make *), Bash(cargo *), Bash(go *), Bash(git log:*), Bash(git diff:*)
---

# Security Review — Full Project Sweep

Canonical skill: **`.agent/skills/review-security/SKILL.md`**

This skill performs a comprehensive project-wide security assessment. For PR-scoped security review, use `security-review` instead. See the canonical file for the full protocol.
