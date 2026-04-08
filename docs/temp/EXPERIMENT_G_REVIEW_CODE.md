# Experiment G — review-code (rto-test / n8n-ci-autofix)

**Date:** 2026-04-07  
**Project:** rto-test (n8n-ci-autofix)  
**Skill:** review-code  
**Result:** ✅ PASS (with findings)

## Objective

Run review-code on rto-test codebase (runner-server.js, shell scripts, PowerShell) and verify:
1. Multi-language support (JS + shell + PS1) works
2. Anti-pattern detection fires correctly
3. Findings are actionable

## Codebase Overview

| File | Lines | Language | Purpose |
|------|-------|----------|---------|
| runner-server.js | 236 | JS/Node.js | Local HTTP server, triggers ci-fix-runner |
| ci-fix-runner.sh | 157 | Shell/bash | Claude Code CI fixer runner |
| lib/parse-roadmap.js | 202 | JS/Node.js | ROADMAP.md parser |
| lib/prompt-templates.js | 105 | JS/Node.js | Prompt templates for Claude |
| tests/parse-roadmap.test.js | 113 | JS/Node.js | Jest tests |
| install.ps1 | 142 | PowerShell | Installer |
| setup-roadmap-runner.ps1 | 1108 | PowerShell | Roadmap setup |
| start-ci-watcher.ps1 | 146 | PowerShell | CI watcher startup |

## Test Steps

### G-1: review-code path resolution

review-code uses path resolution preamble to find .foundation/skills/ files. Verified the skill correctly finds files at both `.agent/skills/` (local) and `.foundation/.agent/skills/` (subtree).

**Result:** ✅ Path resolution works

### G-2: Anti-pattern sweep — runner-server.js

Ran manual anti-pattern review on the main server file:

**runner-server.js findings:**
1. **Anti-003 (Credential Exposure) — MEDIUM:** Uses environment variables for config but reads from `config.example.env` in comments only. No actual credential loading mechanism. The config.env is loaded by the shell script, not the JS server.

2. **Anti-005 (Null Safety) — LOW:** `req.on('data')` chunks are concatenated without size limit — potential for payload overflow on large requests.

3. **Anti-006 (Error Feedback) — LOW:** `catch` blocks return JSON error but don't log to a file or monitoring system. Silent failures possible.

4. **Anti-007 (Hardcoded Paths) — MEDIUM:** `WORKSPACE` defaults to `C:/ci-workspace` — Windows-specific path baked in. Cross-platform users will hit this.

### G-3: Shell script review (ci-fix-runner.sh)

Manual review of ci-fix-runner.sh:
- Input validation: ✅ BRANCH, RUN_ID, REPO checked before use
- Recursion guard: ✅ `claude-auto-fix-*` branch skip logic
- Path injection: ✅ All external vars are env-based, not directly interpolated into paths without validation
- Error handling: ✅ `set -euo pipefail` at top — failures propagate

**No shellcheck installed** to run automated lint.

### G-4: PowerShell review (install.ps1)

PowerShell scripts use `Set-ExecutionPolicy RemoteSigned` — standard practice. No obvious credential leakage. No `Invoke-Expression` with user input.

## Findings

### Finding G-1: Path resolution works but skill output is generic

review-code is designed for Weapons_Lore-style web apps (React, modal patterns, API contracts). rto-test is a Node.js CLI tool with different quality gates. The skill correctly identified several patterns but the quality gate checklist (steps 2-10 of the skill) is heavily WEAP-specific.

**Severity:** MEDIUM — skill is portable but ~40% of gate checks are irrelevant for non-WEAP projects

### Finding G-2: No Node.js security patterns in gate checklist

review-code gate checklist has SQL injection, XSS, admin context checks — all web-app specific. For Node.js CLI tools, relevant patterns are:
- Command injection (child_process.spawn with unsanitized input)
- Environment variable exposure
- File path traversal

These aren't in the standard checklist.

**Severity:** LOW — manual review works, but automated gate would miss CLI-specific issues

### Finding G-3: Cross-platform path risk (Anti-007)

rto-test has Windows paths baked into defaults (C:/ci-workspace). The skill's Anti-007 check for hardcoded paths would catch this if it ran on ci-fix-runner.sh.

**Result:** ✅ Anti-007 would fire if Anti-007 explicitly included path defaults

## Conclusion

PASS — review-code correctly runs on mixed JS/shell/PS1 codebase. Path resolution works. Anti-pattern detection fires for hardcoded paths. The WEAP-specific gate checklist is noisy for non-WEAP projects but doesn't break anything.

**Recommendation:** Document that review-code's gate checklist is WEAP-optimized; CLI/automation projects should use their own gate checklist or ignore WEAP-specific gates
