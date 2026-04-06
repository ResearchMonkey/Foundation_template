---
name: review-security
description: "Full-project security sweep — OWASP dependency check, secrets scan, CVE audit, auth pattern review, governance compliance. Use for periodic security audits."
argument-hint: "[sub-agent]"
allowed-tools: Read, Grep, Glob, Bash(node scripts/security/*), Bash(npm audit*), Bash(npm run lint:config-register), Bash(git log*), Bash(git diff*), Bash(grep*)
---

# Security Review — Full Project Sweep

Canonical skill: **`.agent/skills/review-security/SKILL.md`**

This skill performs a comprehensive project-wide security assessment. For PR-scoped security review, use `security-review` instead. See the canonical file for the full protocol.
