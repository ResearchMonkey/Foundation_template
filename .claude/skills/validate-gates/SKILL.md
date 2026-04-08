---
name: validate-gates
description: "Second-pass validator that audits the quality_gates output from implement. Catches skipped gates, missing evidence, and self-reported passes without proof. Use after implement completes."
argument-hint: "[path to implement JSON output, or 'last' to use most recent]"
---

Canonical skill: **`.agent/skills/validate-gates/SKILL.md`**

Second-pass quality audit of implement output. Reads the canonical file for the full protocol.
