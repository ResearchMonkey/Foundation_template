---
name: implement
description: "Unified Board issue processor (ARCH → SEC → QA → OPS → LIB). Accepts Jira keys, URLs, or JSON context files. Auto-detects interactive vs CI mode. Works identically across Claude Code, Cursor, and Grok."
argument-hint: "<Jira key(s)/URL(s) OR path to JSON context file>"
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git checkout:*), Bash(git branch:*), Bash(git remote show origin:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git log:*), Bash(git diff:*), Bash(git stash:*), Bash(cat package.json *), Bash(npm run lint), Bash(npm run lint:fix), Bash(npm run test:unit), Bash(npm run -s test:unit), Bash(npx playwright test:*), Bash(node --test:*), Bash(python3:*), Bash(gh pr create:*), Bash(gh pr merge:*), Bash(gh pr view:*), Bash(gh pr edit:*)
---

# Implement — Unified Board Issue Processor

You are the **@Board agent** executing a full analyze-plan-implement-close cycle. This is the **single entry point** for all Board work — interactive sessions (Claude Code, Cursor, Grok) and headless CI (n8n).

---

## Phase 0 — Parse Input & Initialize

### Mode Detection (CRITICAL — do this first)

Examine the argument to determine **execution mode**:

| Argument pattern | Mode | Jira I/O | Merge | Example |
|---|---|---|---|---|
| Path ending in `.json` | **CI** | None (capture for JSON output) | PR only, no merge | `/implement /tmp/ctx/WEAP-123.json` |
| Jira key (`WEAP-###`) or URL | **Interactive** | Direct MCP tools | Try auto-merge | `/implement WEAP-123` |

**CI mode rules:**
1. Read the JSON context file. Required structure:
   ```json
   {
     "issue_key": "WEAP-123",
     "summary": "Short description",
     "description": "Full issue description",
     "acceptance_criteria": ["criterion 1", "criterion 2"],
     "issue_type": "Bug",
     "priority": "High",
     "labels": ["backend", "auth"],
     "comments": ["Prior comment text if any"],
     "target_branch": "stage"
   }
   ```
   Validate required fields: `issue_key`, `summary`. If missing → output error JSON and stop.
2. **Do NOT call any Jira/MCP tools.** No `getJiraIssue`, `addCommentToJiraIssue`, `transitionJiraIssue`, etc. The CI orchestrator (n8n) handles all Jira I/O.
3. All Jira-bound text (analysis, plan, result) must be captured in the structured JSON output (Phase 4).

**Interactive mode rules:**
1. Use Jira MCP tools normally for reads, writes, comments, and transitions.
2. Conversational output is shown to the user in real-time.

**Both modes** execute the identical Board resolution sequence: ARCH → SEC → QA → OPS → LIB.

### Batch Support (Interactive mode only)

The argument may contain **one or more** issue keys/URLs, space-separated. CI mode processes one item per invocation (the orchestrator handles batching).

```
Input:  "WEAP-123 WEAP-456 https://site.atlassian.net/browse/WEAP-789"
Parsed: [WEAP-123, WEAP-456, WEAP-789]
```

**Batch limit:** If more than 5 items, complete the first 5, run a doc-sync pass, then continue.

**Execution order:** Process issues **sequentially** to avoid merge conflicts. Each issue runs through Phases 1–4 before the next begins. If one aborts, continue to the next. **Phase 5 (AAR)** runs once at the end of the batch (or after each issue for single-issue processing).

**Jira I/O is per-issue, not per-batch (WEAP-241).** Each issue must receive its own:
- Analysis comment (Phase 1)
- Plan comment + `agent-fix-pending` label (Phase 2)
- Resolution comment + status transition (Phase 4)

The batch summary table on the epic/parent is **in addition to**, not a replacement for, per-issue Jira updates. Do not collapse per-issue Jira I/O into a single epic-level comment — this was the root cause of WEAP-241.

At batch end, output a summary table:

```
| Issue     | Result  | PR              | Notes            |
|-----------|---------|-----------------|------------------|
| WEAP-123  | Merged  | #42             |                  |
| WEAP-456  | Aborted | —               | Tests failed x3  |
```

### Load Board Context (Mandatory)

1. Read `.agent/.ai/BOOTSTRAP.md`, `.agent/.ai/MEMORY.md`, `.agent/.ai/AGENTS.md`.
2. Read `.agent/.mode` → set **cognitive mode** (`prototype` | `production`). If missing, default to **prototype**.
3. **Progressive loading:** Load each role spec only when that role activates (BOOTSTRAP §1.2):
   - ARCH → `.agent/.ai/ARCHITECT.md`
   - SEC → `.agent/.ai/SECURITY.md`
   - QA → `.agent/.ai/QA_VALIDATOR.md`
   - OPS → `.agent/.ai/DEVOPS.md`
   - LIB → `.agent/.ai/LIBRARIAN.md` (on Reflexion/error path)
4. **Domain memory on demand** (BOOTSTRAP §1.3): Load `MEMORY_SECURITY.md`, `MEMORY_UI.md`, `MEMORY_OPS.md`, or `MEMORY_ANTI_PATTERNS.md` when the task touches auth/client/deployment/code review.

### Resolve Toolchain & Branch

- **Coding standards:** Check `docs/CODING_STANDARDS.md`, `CODING_STANDARDS.md`, `.github/CODING_STANDARDS.md`, `CONTRIBUTING.md` in order; use if found.
- **Lint/Test:** From `package.json` scripts use `npm run lint`, `npm run test:unit` (or project equivalent); store as `LINT_CMD`, `TEST_CMD`.
- **Target branch:** `stage` is always the PR target branch. CI mode: use `target_branch` from JSON context (default: `stage`). Interactive mode: use `stage` directly — do NOT use `git remote show origin` (it returns `main`, which is the promotion target, not the PR target). Store as `DEFAULT_BRANCH=stage`.

### Initialization Status Report

Before starting Phase 1 for the first item, output:

- **Mode:** Interactive or CI
- **Active Epics:** (from Jira project WEAP — query open epics; CI mode: skip)
- **Cognitive Mode:** PROTOTYPE (Alpha) or PRODUCTION
- **Board Status:** Green / Active Vetoes
- **Memory Core:** Iron Laws count / Domain files available

---

## Phase 1 — Analyze (ARCH leads)

1. **Gather issue context:**
   - **Interactive mode:** Use Jira MCP: `getAccessibleAtlassianResources` for cloud ID; `getJiraIssue` for the issue (summary, description, acceptance criteria, comments, labels, status).
   - **CI mode:** Use the parsed JSON context (already loaded in Phase 0).
2. **Load** `.agent/.ai/ARCHITECT.md`.
3. **@ARCH** drafts analysis: root cause (2–3 sentences), affected files/components, acceptance criteria list. **Document sourcing:** Only use docs with **Status: Active** (SDLC §4.7.1); never cite Draft or archived.
4. **Capture analysis text** as `ANALYSIS_TEXT` (used in Phase 4 structured output).
5. **Interactive mode only:** Post to Jira with `addCommentToJiraIssue`:

```markdown
## Board Analysis (@ARCH)

**Root Cause:** <2-3 sentence summary>

**Affected Files/Components:**
- `path/to/file1.js` — <why>
- `path/to/file2.js` — <why>

**Acceptance Criteria Identified:**
- [ ] <criterion 1>
- [ ] <criterion 2>
```

---

## Phase 2 — Plan (ARCH → SEC → QA)

### ARCH: Fix Approach

- Propose 2–3 sentence approach; list files to modify/create and tests to add.
- **Doc Impact Scan:** For each file being modified, check whether it contains hardcoded constants (cookie opts, CORS config, rate limits, security headers, feature flags) or configuration values that should be documented. Cross-reference `docs/agent/technical/CONFIGURATION_REGISTER.md` and `docs/agent/technical/API_Reference.md`. If any constant is undocumented, add a **Docs to Update** line to the plan listing the doc and the missing entry. This catches omissions — not just drift.
- **SDLC §4.2:** Check `docs/agent/technical/LOW_RISK_WHITELIST.md`. If work **matches a whitelisted pattern**, ARCH self-authorizes, **skip @SEC**, proceed to QA. Only "Slow Lane" (Auth, Payments, Core Logic) summons @SEC.
- **SDLC §4.10 — Enforcement Gate:** If the ticket establishes a process, workflow, governance gate, or architectural constraint, ARCH must include an **Enforcement** section in the plan answering:
  1. What technically enforces this?
  2. Where is enforcement implemented?
  3. What happens if enforcement fails?
  4. How do we verify enforcement is active?
  If any answer is "convention" or "the agent follows the process," the plan is incomplete — do not proceed. **Method 3 rule:** For MEDIUM+ risk, Board self-review and policy documents do not count as enforcement (SDLC §4.10.2).

### SEC (when not whitelisted)

- **Load** `.agent/.ai/SECURITY.md`.
- Classify risk (LOW / MEDIUM / HIGH / CRITICAL) per `.agent/.ai/RISK_LEVELS.md`.
- **If HIGH or CRITICAL:** **Stop.** Present risk summary:
  - **Change:** <brief description>
  - **Risk:** <tier>
  - **Mitigation:** <what reduces risk>
  - **Approval:** [awaiting CEO]
  Do not proceed to Implement until CEO approves.
- Otherwise (LOW/MEDIUM): Delegated Approval; proceed to QA.

### QA: Validate Plan

- **Load** `.agent/.ai/QA_VALIDATOR.md`.
- Validate test cases per **SDLC §4.3** and quality gates per `.agent/workflows/quality-gates.md` §1–§24. If logic/security or Iron Laws violated, **VETO** with a clear "Path to Green."

### Post Plan & Branch

**Capture plan text** as `PLAN_TEXT` (used in Phase 4 structured output).
**Interactive mode only:** Post plan comment to Jira (include Board sign-off: ARCH plan, SEC risk or "whitelisted", QA ok/veto):

```markdown
## Board Plan

**Approach:** <2-3 sentence plan>
**Risk:** <LOW|MEDIUM|whitelisted>
**QA:** <OK | VETO: Path to Green>

**Files to Modify:** ...
**Tests to Add/Update:** ...
**Docs to Update:** <list docs needing updates, or "No doc-impacting changes">
**Branch:** `fix/<ISSUE_KEY>-<short-slug>`

<!-- Include Enforcement section ONLY for governance/process/workflow/constraint tickets (SDLC §4.10) -->
**Enforcement:**
1. **Enforced by:** <tooling mechanism>
2. **Implemented in:** <file path(s)>
3. **Failure mode:** <what happens if enforcement fails>
4. **Verification:** <how to confirm enforcement is active>
```

- **Interactive mode only:** Add label `agent-fix-pending` via `editJiraIssue`.
- Create branch: `git checkout <DEFAULT_BRANCH>` (or `target_branch` from CI context), `git pull`, `git checkout -b fix/<ISSUE_KEY>-<short-slug>`.

---

## Phase 3 — Implement (OPS executes)

### Gate

- **Interactive mode:** Verify the issue has label `agent-fix-pending`. If not, abort.
- **CI mode:** Verify Phase 2 completed successfully (risk LOW/MEDIUM, no QA veto).

### OPS: Apply Fix

- **Load** `.agent/.ai/DEVOPS.md`.
- Apply fix per ARCH plan and project CODING_STANDARDS; for UI/API changes apply `.agent/workflows/quality-gates.md`.
- **Mandates (BOOTSTRAP §2–3):**
  - **Chain-of-Thought:** Before generating code, output `<details><summary>Thinking...</summary> [Analysis] </details>`.
  - **Reflexion Loop:** Critique own code; in **prototype** mode check **Fatal Errors Only**.
  - **Flash Lesson:** If you catch an error during Reflexion or a test run, output: **"@LIB, record Flash Lesson: [The specific technical fix]."**
  - **Output economy:** Files < 200 lines → full-file update; files ≥ 200 lines → rewrite entire function/block.

### QA Requests Run; OPS Runs Lint & Tests

- Run `LINT_CMD`. If fail: use lint:fix if available, then re-run until clean.
- Run `TEST_CMD`. If tests fail: determine if fix-induced or pre-existing. If **fix-induced**, fix and re-run; after **3 attempts** still failing → post comment, leave branch intact, **ABORT**.
- Re-run lint after any test fixes.

### Per-Task Checklist

Complete only when: code standards, quality gates (§1–§21), tests per plan, TEST_REGISTRY updated, no new lint, tests pass, commit format satisfied.

### LIB Doc Audit (Mandatory — runs after every test pass)

After OPS tests pass and before `review-code` / PR creation, run the **LIB proactive doc audit** (`.agent/skills/lib/SKILL.md`):

1. **Load** `.agent/.ai/LIBRARIAN.md`.
2. **Run `npm run lint:doc-coverage`** — automated check for unregistered constants in changed files. If it reports gaps, add entries to `CONFIGURATION_REGISTER.md` before proceeding.
3. **Run the mandatory checklist below.** Each item must be answered with evidence (file checked, grep result, or "N/A — no X in this change"). Answering "no doc changes required" without completing this checklist is a process violation.
4. **Classify findings** by severity: HIGH (blocks PR), MED (creates linked ticket), LOW (comment only).
5. **Resolve HIGH findings** before proceeding. If unresolvable, create a linked Jira sub-task and **block PR creation**.
6. **Post audit report** as a Jira comment (interactive mode) in the structured format defined in `.agent/skills/lib/SKILL.md`.
7. **Capture audit report** for inclusion as a collapsible `<details>` section in the PR description.
8. If zero findings: post `LIB doc audit complete — no doc changes required.`

#### LIB Doc Audit Checklist (cannot be skipped)

| # | Check | How to verify | If missing |
|---|-------|--------------|------------|
| 1 | **Constants registered?** | `git diff` for new `const` at module scope with `UPPER_SNAKE_CASE`. Cross-reference each against `CONFIGURATION_REGISTER.md`. | MED — add entries |
| 2 | **API fields documented?** | If new fields were added to request/response bodies, check `API_Reference.md`. | MED — add entries |
| 3 | **DB schema documented?** | If new columns or tables were referenced, check `Database_Architecture.md`. | LOW — add note |
| 4 | **TEST_REGISTRY updated?** | If test files were added/modified, check `TEST_REGISTRY.md` for rows (AAR-004). | MED — add rows |
| 5 | **User docs current?** | If the feature is user-facing, check `Instructor_Guide.md` or relevant user doc for a section. | MED — add section or file ticket |
| 6 | **Design doc exists?** | If a new module/subsystem was created (new file > 200 lines), check for a design doc or architecture note. | LOW — note in PR |

> **Rationale (WEAP-49 AAR 2026-03-27):** The previous prose-based audit ("answer three questions") was rubber-stamped on a 1082-line new feature, missing 6 documentation gaps including 14 unregistered constants and missing API field documentation. This checklist makes each verification step explicit and auditable.

> **Note:** This proactive audit is separate from the on-error Flash Lesson mechanism during OPS, which remains unchanged. The proactive audit runs on **every** implementation, not just when errors occur.

---

## Phase 4 — Commit & Close (OPS only)

### Commit & Push

Stage only files that are part of the fix. Commit:
- `fix(<ISSUE_KEY>): <short description> [agent]` (or `feat`/`refactor` as appropriate).

Push branch.

### Create PR

- Create PR targeting `DEFAULT_BRANCH` (interactive) or `target_branch` from context (CI) with body: Summary, Root Cause, Changes, Test Plan, Closes <ISSUE_KEY>, "Board consensus (ARCH→SEC→QA→OPS)".
- Capture PR URL.

### Merge & Jira (Interactive mode only)

- **Merge strategy:** Try `gh pr merge --squash --auto`. Classify result:
  - Merged / Auto-merge queued → proceed
  - Reviews required / CI pending / Branch protection → add label `agent-ready-for-review`, post Jira comment "PR Awaiting Review", do **not** transition to Done
  - Merge failed → post "Merge Failed" comment, do not transition
- Post resolution comment with commit SHA, PR URL, files changed, fix summary.
- **Transition to Done** only if merge status is "merged" or "queued".
- **Remove** `agent-fix-pending` only if issue was transitioned to Done.

### Jira State Verification (Interactive mode — MANDATORY before JSON output, WEAP-241)

Before emitting the structured JSON, verify that all Jira I/O for this issue has been completed. Answer each question; if any is "no," go back and fix it before proceeding:

- [ ] **Analysis comment posted?** (Phase 1 `addCommentToJiraIssue`)
- [ ] **Plan comment posted?** (Phase 2 `addCommentToJiraIssue`)
- [ ] **`agent-fix-pending` label added?** (Phase 2 `editJiraIssue`)
- [ ] **Resolution comment posted?** (Phase 4 `addCommentToJiraIssue` — with PR URL, commit SHA, files changed)
- [ ] **Status transitioned?** (In Progress at minimum; Done only if merged)

This checklist is a cognitive speedbump — it cannot be skipped in batch mode.

### Structured JSON Output (Both modes — ALWAYS emit)

Your FINAL output must include a fenced JSON block. CI mode: this is parsed by the orchestrator. Interactive mode: this provides a machine-readable summary.

```json
{
  "status": "success|aborted|escalate",
  "issue_key": "WEAP-123",
  "phase_reached": 4,
  "risk_level": "LOW|MEDIUM|HIGH|CRITICAL",
  "analysis_comment": "## Board Analysis (@ARCH)\n...",
  "plan_comment": "## Board Plan\n...",
  "result_comment": "## Board Resolution\n...",
  "pr_url": "https://github.com/.../pull/42",
  "pr_number": 42,
  "branch": "fix/WEAP-123-short-slug",
  "commit_sha": "abc1234",
  "files_changed": ["path/to/file1.js", "path/to/file2.js"],
  "tests_passed": true,
  "lint_clean": true,
  "abort_reason": null,
  "flash_lessons": []
}
```

**Status values:**
- `success` — PR created (CI) or merged/queued (interactive), all tests pass, lint clean
- `aborted` — could not complete (test failures, insufficient info, QA veto)
- `escalate` — HIGH/CRITICAL risk, needs CEO review

**If aborting at any phase**, still output this JSON with `phase_reached` set to where it stopped and `abort_reason` populated.

---

## Phase 5 — After Action Review (AAR)

Run after Phase 4 completes. Scope scales with batch size:

### Single Issue — Checklist (~30 seconds)

- [ ] **Plan compliance:** Did we deliver the tests stated in Phase 2? If not, file a follow-up Jira issue (Anti-011).
- [ ] **Doc impact verification:** Did we update every doc listed in the "Docs to Update" line of the plan? Cross-check `API_Reference.md` if any API fields were added/changed (Anti-010).
- [ ] **Flash lessons:** Did any Reflexion loop or test failure reveal a reusable lesson? If yes, record it in the appropriate `MEMORY_*.md` file and update `MEMORY.md` index.

### Batch (2+ issues) — Mini-AAR (~2 minutes)

All Single Issue checks, plus:

- [ ] **Config register lint:** Run `npm run lint:config-register` — verify no undocumented hardcoded security constants.
- [ ] **Doc impact scan (cross-file):** For all files modified across the batch, check `CONFIGURATION_REGISTER.md`, `API_Reference.md`, and `Database_Architecture.md` for gaps.
- [ ] **Jira state:** Verify all processed issues are in the correct status. If any epics have all children Done, transition the epic.
- [ ] **TEST_REGISTRY:** If test files were added/modified, verify `npm run generate-registry` was run.

### Epic Close — Full AAR (~5 minutes)

All Batch checks, plus:

- [ ] **Acceptance criteria:** Cross-reference the epic's success criteria against delivered code. Every criterion must have evidence (test, code reference, or explicit "deferred" with Jira issue).
- [ ] **Process observations:** Note what went well, what could be improved, and any process violations that occurred.
- [ ] **Summary table:** Output a table of all issues processed with Result / PR / Notes.
- [ ] **Flash lesson consolidation:** Distribute any pending flash lessons to domain memory files.

> **Rationale (AAR 2026-03-14):** Every session over 4 consecutive sessions found significant gaps during AAR — undocumented security constants, dropped tests, stale docs, unclosed epics. Without Phase 5, these gaps ship silently. The AAR is where the process self-corrects and institutional memory grows.

---

## Close-as-Resolved Protocol

When an issue is verified as **already resolved in code** (no new changes needed), the Board must still complete a doc impact check before closing:

1. **Doc Impact Scan (mandatory):** For each file the issue targeted, check whether it contains hardcoded constants (cookie opts, CORS config, rate limits, security headers, JWT settings, feature flags) that are undocumented. Cross-reference `docs/agent/technical/CONFIGURATION_REGISTER.md`. If any constant is missing, add it before closing.
2. **Run `npm run lint:config-register`** to verify no hardcoded security constants are undocumented.
3. **Post Jira comment** with: status ("Already resolved"), evidence (file + line references), doc impact ("No doc gaps" or "Docs updated: [list]"), prior commit SHA.
4. **Transition to Done** only after doc scan passes.

> **Rationale (AAR 2026-03-14):** Closing issues as "already resolved" skips Phase 2 (Plan), which contains the doc impact scan. This caused HSTS, JWT algorithm, and cookie security constants to go undocumented despite being implemented.

---

## Abort Protocol

1. **Interactive mode only:** Post Jira comment: "## Agent Aborted — Phase <N>. **Reason:** <…>. **State:** <branch>. **Action Required:** Manual intervention."
2. Leave the branch intact (do not delete).
3. Do not transition the issue.
4. **Interactive mode only:** Remove `agent-fix-pending` only if it was added in Phase 2 and we are aborting.
5. **Both modes:** Output the structured JSON with abort details (status, phase_reached, abort_reason).

---

## References

- `.agent/.ai/BOOTSTRAP.md` — Board activation, cognitive mode, resolution sequence
- `.agent/.ai/AGENTS.md` — Roles, autonomy, veto, output economy
- `.agent/.ai/MEMORY.md` — Iron Laws; domain memory index
- `.agent/.ai/RISK_LEVELS.md` — Risk tiers, Human-in-the-Loop template
- `.agent/README.md` — Canonical paths
- `docs/agent/technical/SDLC.md` — §4.2 Whitelist/SEC, §4.3 Test-Informed Planning, §4.6 Quality Gates
- `docs/agent/technical/LOW_RISK_WHITELIST.md` — Patterns that bypass @SEC
- `.agent/workflows/quality-gates.md` — Pre-merge checklist §1–§25
- `docs/CODING_STANDARDS.md` — Project coding standards
