---
name: test-runner
description: "Run, triage, and improve tests — executes test suites, triages failures/flaky tests, and drives coverage increase. Use when running tests, CI fails, or coverage needs improvement."
argument-hint: "[suite-name or 'coverage' or 'triage']"
allowed-tools: Read, Grep, Glob, Bash(npm run test:unit), Bash(npm run -s test:unit), Bash(npm run lint), Bash(npm run lint:fix), Bash(npm run generate-registry), Bash(npx nyc:*), Bash(npx playwright test:*), Bash(node --test:*)
---

# Test Runner, Triage & Coverage

Canonical skill: **`.agent/skills/test-runner/SKILL.md`**

This skill is the consolidated replacement for `test-triage` and `coverage-increase`. See the canonical file for the full protocol.
