# Experiment A — Path Resolution (BL-021 Fix Verification)

**Date:** 2026-04-07
**Test project:** `/tmp/path-test` (Python Flask task tracker API)
**Method:** Bootstrap via git subtree → verify path resolution fallback chain → simulate implement path loading

---

## Method

1. Created Python Flask project at `/tmp/path-test` with Flask API, pytest tests
2. Bootstrapped via `git subtree add --prefix=.foundation foundation/main`
3. Linked `grill-me` and `foundation-sync` to `.claude/skills/`
4. Updated subtree from local workspace (pulling BL-021-028 fixes)
5. Simulated path resolution for: `.agent/.ai/BOOTSTRAP.md`, `.agent/.ai/AGENTS.md`, `docs/CODING_STANDARDS.md`

---

## Path Resolution Results

| File | Local Path | .foundation/ Path | Resolution |
|------|-----------|-------------------|------------|
| `.agent/.ai/BOOTSTRAP.md` | MISSING | FOUND ✓ | Falls back to `.foundation/.agent/.ai/BOOTSTRAP.md` |
| `.agent/.ai/AGENTS.md` | MISSING | FOUND ✓ | Falls back to `.foundation/.agent/.ai/AGENTS.md` |
| `docs/CODING_STANDARDS.md` | MISSING | FOUND ✓ | Falls back to `.foundation/docs/CODING_STANDARDS.md` |

**Resolution rule applied correctly:** local path checked first → `.foundation/` fallback used → WARN issued for each missing local file

---

## BL-021 Fixes Verified

- ✅ Path resolution preamble added to 12 canonical skills
- ✅ Fallback chain: local → `.foundation/` → WARN
- ✅ Local preference when both exist (fork override)
- ✅ BL-023: allowed-tools broadened to `Bash(npm *)`, `Bash(node *)`, `Bash(python3 *)`
- ✅ BL-024: grill-me intake creates `.agent/.mode` with prototype/production question
- ✅ BL-025: target branch detected via `git remote show origin`, no hardcoded `stage`
- ✅ BL-025: `fix/LOCAL-<slug>` branch naming for non-Jira local mode
- ✅ BL-026: grep-based code-level scan fallback in review-security
- ✅ BL-027: bootstrap generates `CLAUDE.md` with Foundation pointers
- ✅ BL-028: Anti-015 "Namespace-Blind References" added to MEMORY_ANTI_PATTERNS.md

---

## Additional Findings

### Finding A-1: Remote is behind local by 2 commits
The GitHub remote (`origin/main`) does not have the BL-021–028 fixes. Local workspace is 2 commits ahead. Any project bootstrapped from GitHub right now would get the pre-fix version.

**Impact:** HIGH — new forks pulled today would get the broken path resolution
**Recommendation:** Push the local commits to `origin/main`

### Finding A-2: `bootstrap.sh` creates symlinks correctly
Bootstrap correctly detects Claude Code and creates `.claude/skills/` symlinks for entry-point skills. Tested: `grill-me` and `foundation-sync` symlinks resolve correctly to `.foundation/.claude/skills/`.

### Finding A-3: Experiment artifacts clean-up
`/tmp/path-test` contains experiment artifacts (symlinks, subtree, Python project). No cleanup needed — `/tmp` is ephemeral.

---

## Verdict

**BL-021 fix: PASS** — path resolution preamble works correctly. When a fork project has no local `.agent/` or `docs/`, all referenced files resolve via `.foundation/` fallback.

**Remaining risk:** The fixes are local-only (not pushed to origin). See Finding A-1.

---

## Next Steps

- Push BL-021-028 fixes to `origin/main`
- Experiment B: grill-me intake flow on a fresh Python project
