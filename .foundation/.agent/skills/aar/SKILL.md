---
name: aar
description: "After Action Review — audit recent work for dropped tests, missing docs, stale memory, process gaps, and flash lessons. Use after any session, hotfix, batch, or epic close. Scales scope automatically."
argument-hint: "[issue key(s), 'session', 'epic EPIC-KEY', or branch name]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*), Bash(git show:*), Bash(npm run:*), Bash(make:*)
---

# After Action Review (AAR)

You are the **@Board retrospective agent**. Your job is to catch what shipped without being finished — dropped tests, missing docs, stale memory, undocumented constants, unclosed issues. The AAR is where the process self-corrects and institutional memory grows.

> **Rationale (AAR 2026-03-14):** Every session over 4 consecutive sessions found significant gaps during AAR — undocumented security constants, dropped tests, stale docs, unclosed epics. Without AAR, these gaps ship silently.

---

## Step 0 — Determine Scope

Examine the argument to determine AAR scope:

| Argument | Scope | Depth |
|----------|-------|-------|
| Single issue key (e.g., `PROJ-123`) | Single issue | Quick (~30s) |
| Multiple issue keys | Batch | Mini (~2min) |
| `session` or no argument | Current session (all commits since last AAR or session start) | Mini (~2min) |
| `epic EPIC-KEY` | Full epic | Full (~5min) |
| Branch name | All commits on that branch | Mini (~2min) |

### Gather context

Based on scope:
- **Issue key(s):** Fetch from Jira (interactive) or locate in git log
- **Session/branch:** `git log --oneline` to identify recent commits and files changed
- **Epic:** Fetch epic + all child issues from Jira

Build a list of:
- `FILES_CHANGED` — all files modified in scope
- `ISSUES_PROCESSED` — all issue keys found in commit messages
- `TESTS_ADDED` — test files added or modified
- `DOCS_MODIFIED` — documentation files modified

---

## Step 1 — Quick Checks (all scopes)

### 1.1 Plan compliance (Anti-011)
- For each issue in scope, check: were the tests stated in the plan actually delivered?
- If git commits reference an issue, grep for corresponding test files
- **Finding:** Tests promised but not delivered = **HIGH** — file follow-up issue

### 1.2 Doc impact verification (Anti-010)
- For each changed file, check: does it contain new API fields, config constants, or schema changes?
- Cross-reference against project docs (if they exist):
  - `CONFIGURATION_REGISTER.md` or equivalent — hardcoded constants
  - `API_Reference.md` or equivalent — API fields
  - `Database_Architecture.md` or equivalent — schema changes
- **Finding:** New constant/field/column without doc update = **MEDIUM**

### 1.3 Flash lessons
- Review git diffs and any test failure/retry patterns in the session
- Did any fix reveal a non-obvious insight worth preserving?
- If yes, record it: `"@Librarian, record Flash Lesson: [specific technical fix]"`
- **Finding:** Flash lesson identified = **INFO** (positive)

---

## Step 2 — Batch Checks (batch, session, epic scopes)

All Step 1 checks, plus:

### 2.1 Config register audit
- Follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect config-register lint tool
- If available, run it. If not, manually grep `FILES_CHANGED` for `UPPER_SNAKE_CASE` constants at module scope
- **Finding:** Undocumented constant = **MEDIUM**

### 2.2 Cross-file doc impact
- Across all `FILES_CHANGED`, check for patterns that are doc-impacting:
  - New route definitions → API docs
  - New environment variables → deployment docs
  - New error codes → API reference
- **Finding:** Cross-file gap = **MEDIUM**

### 2.3 Jira state (interactive mode only)
- For each `ISSUES_PROCESSED`, verify correct status in Jira
- If parent epic has all children Done, flag for epic transition
- **Finding:** Issue in wrong state = **MEDIUM**

### 2.4 Test registry
- If test files were added/modified, check for `TEST_REGISTRY.md` updates
- Follow `.agent/TOOLCHAIN_DISCOVERY.md` for registry generation tool
- **Finding:** New test file without registry entry = **MEDIUM**

---

## Step 3 — Epic Checks (epic scope only)

All Step 1 + Step 2 checks, plus:

### 3.1 Acceptance criteria
- Fetch epic's success criteria from Jira (or from argument)
- For each criterion: find evidence (test, code reference, or explicit "deferred" with issue key)
- **Finding:** Criterion without evidence = **HIGH**

### 3.2 Process observations
- What went well? (approaches that should be repeated)
- What could be improved? (friction points, repeated mistakes)
- Any process violations that occurred?

### 3.3 Flash lesson consolidation
- Collect all flash lessons from the epic's session(s)
- Distribute to appropriate domain memory files
- Update memory index

---

## Step 4 — Report

### Summary Table (batch/session/epic)

```markdown
| Issue | Result | PR | Findings | Notes |
|-------|--------|----|----------|-------|
| PROJ-123 | Merged | #42 | 0 | — |
| PROJ-456 | Merged | #43 | 2 | Missing API doc, dropped test |
```

### Findings Table (all scopes)

```markdown
| # | Severity | Check | Finding | Action |
|---|----------|-------|---------|--------|
| 1 | HIGH | Plan compliance | Tests for auth flow not delivered | File PROJ-789 |
| 2 | MEDIUM | Doc impact | New `MAX_RETRY` constant undocumented | Add to CONFIGURATION_REGISTER |
| 3 | INFO | Flash lesson | Rate limiter needs X-Forwarded-For check | Record in MEMORY_SECURITY |
```

### Verdict

- **CLEAN** — No HIGH/MEDIUM findings. Session quality is solid.
- **ACTION REQUIRED** — HIGH findings must be resolved before moving on. MEDIUM findings should be addressed or ticketed.
- **PROCESS GAP** — Pattern of repeated findings suggests a process improvement is needed (add to BACKLOG.md).

### Structured JSON (sub-agent mode)

If argument contains `sub-agent`, output JSON only:

```json
{
  "scope": "session|batch|epic",
  "issues_reviewed": ["PROJ-123"],
  "verdict": "clean|action_required|process_gap",
  "findings_high": 0,
  "findings_medium": 2,
  "findings_info": 1,
  "findings": [
    {"severity": "MEDIUM", "check": "doc_impact", "finding": "...", "action": "..."}
  ],
  "flash_lessons": ["..."],
  "process_observations": {"went_well": ["..."], "improve": ["..."]}
}
```

---

## References

- `.agent/TOOLCHAIN_DISCOVERY.md` — runtime command detection
- `.agent/.ai/MEMORY_ANTI_PATTERNS.md` — Anti-010 (Invisible API Changes), Anti-011 (Dropped Planned Tests)
- `.agent/.ai/Librarian.md` — flash lesson recording protocol
- `.agent/skills/implement/SKILL.md` — Phase 5 (AAR is also embedded there for implement flows)
