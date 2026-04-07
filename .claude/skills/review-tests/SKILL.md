---
name: review-tests
description: "Test quality and coverage review — coverage metrics, gap analysis, flaky test identification, test quality audit, registry completeness. Use for periodic test health assessments."
argument-hint: "[sub-agent]"
allowed-tools: Read, Grep, Glob, Bash(npm *), Bash(npx *), Bash(node *), Bash(python3 *), Bash(make *), Bash(cargo *), Bash(go *)
---

# Test Quality Review

Canonical skill: **`.agent/skills/review-tests/SKILL.md`**

This skill reviews test quality across the project. For running tests, triaging failures, or driving coverage increase, use `test-runner` instead. See the canonical file for the full protocol.
