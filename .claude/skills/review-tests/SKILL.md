---
name: review-tests
description: "Test quality and coverage review — coverage metrics, gap analysis, flaky test identification, test quality audit, registry completeness. Use for periodic test health assessments."
argument-hint: "[sub-agent]"
allowed-tools: Read, Grep, Glob, Bash(npm run test:unit*), Bash(npm run -s test:unit*), Bash(npm run generate-registry), Bash(npx nyc*), Bash(grep*)
---

# Test Quality Review

Canonical skill: **`.agent/skills/review-tests/SKILL.md`**

This skill reviews test quality across the project. For running tests, triaging failures, or driving coverage increase, use `test-runner` instead. See the canonical file for the full protocol.
