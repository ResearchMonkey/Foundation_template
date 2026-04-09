---
name: implement
description: "Unified Board issue processor — analyze, plan, implement, and close. Accepts issue keys/URLs, JSON context files, or freeform text. Auto-detects CI vs interactive vs local mode. Generic version suitable for any project."
argument-hint: "<issue key(s)/URL(s) OR path to JSON context file OR freeform description>"
---

# Implement — Unified Board Issue Processor

You are the **@Board agent** executing a full analyze-plan-implement-close cycle.

---

## Phase 0 — Parse Input & Initialize

### Mode Detection (CRITICAL — do this first)

Examine the argument to determine **execution mode**:

| Argument pattern | Mode | External I/O | Merge | Example |
|---|---|---|---|---|
| Path ending in `.json` | **CI** | None (capture for JSON output) | PR only, no merge | `/implement /tmp/ctx/ISSUE-123.json` |
| Issue key (e.g. `PROJ-123`) or URL | **Interactive** | Direct issue tracker tools | Try auto-merge | `/implement PROJ-123` |
| Backlog ID (`BL-###`) | **Local** | None | Commit to `main` | `/implement BL-001` |
| Anything else (freeform text) | **Local** | None | Commit to `main` | `/implement add path resolution` |

**Match order:** JSON path → Issue key/URL → BL-### → freeform. First match wins.

**CI mode rules:**
1. Read the JSON context file. Required fields: `issue_key`, `summary`. Validate before proceeding.
2. **Do NOT call any external I/O tools** (Jira, GitHub Issues, Linear, etc.). All I/O is captured in the structured JSON output (Phase 4).
3. All tracker-bound text (analysis, plan, result) must be captured in the structured JSON output.

**Interactive mode rules:**
1. Use the project's issue tracker tools normally for reads, writes, comments, and transitions.
2. Conversational output is shown to the user in real-time.

**Local mode rules:**
1. **Context source:**
   - `BL-###`: Read `BACKLOG.md`, find the matching entry. Extract: Problem, Decision, Status. If Status is already `DONE` → warn and confirm before proceeding.
   - Freeform text: The argument **is** the task description.
2. **Do NOT call any issue tracker tools.** Context comes from BACKLOG.md or the freeform argument.
3. Commit directly to `main`.
4. On completion:
   - `BL-###`: Update `BACKLOG.md` status to `DONE` with implementation summary.
   - Freeform: No backlog update.
5. Structured JSON output emitted (Phase 4) with `issue_key` set to the `BL-###` ID or a slug.

**All three modes** execute the identical Board resolution sequence: ARCH → SEC → QA → OPS → LIB.

### Batch Support (Interactive mode only)

Space-separated issue keys/URLs are processed sequentially. CI mode processes one item per invocation.

**Batch limit:** If more than 5 items, complete the first 5, run a doc-sync pass, then continue.

**Per-issue I/O:** Each issue must receive its own analysis comment, plan comment, and resolution comment. Do not collapse per-issue I/O into a single batch-level comment.

At batch end, output a summary table:
```
| Issue       | Result  | PR              | Notes            |
|-------------|---------|-----------------|------------------|
| PROJ-123    | Merged  | #42             |                  |
| PROJ-456    | Aborted | —               | Tests failed x3  |
```

### Path Resolution (Fork Support)

This skill references files under `.agent/` and `docs/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/.ai/BOOTSTRAP.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/.ai/BOOTSTRAP.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

### Load Board Context (Mandatory)

1. Read `.agent/.ai/BOOTSTRAP.md`, `.agent/.ai/MEMORY.md`, `.agent/.ai/AGENTS.md` if they exist.
2. Read `.agent/.mode` → set **cognitive mode** (`prototype` | `production`). If missing, default to **prototype**.
3. **Progressive loading:** Load each role spec only when that role activates:
   - ARCH → `.agent/.ai/Developer.md` + `docs/CODING_STANDARDS.md` (if exists)
   - SEC → `.agent/.ai/Security.md` + `docs/SECURITY_STANDARDS.md` (if exists)
   - QA → `.agent/.ai/QA.md` + `docs/TESTING_STANDARDS.md` (if exists)
   - OPS → `.agent/.ai/DevOps.md` + `docs/OPS_STANDARDS.md` (if exists)
   - LIB → `.agent/.ai/Librarian.md` + `docs/DOCUMENTATION_STANDARDS.md` (if exists)
4. **Domain memory on demand:** Load `.agent/.ai/MEMORY_ANTI_PATTERNS.md` when the task touches code review/patterns. Load additional domain memory files if they exist.

### Resolve Toolchain & Branch

- **Coding standards:** Check `docs/CODING_STANDARDS.md`, `CODING_STANDARDS.md`, `.github/CODING_STANDARDS.md`, `CONTRIBUTING.md` in order; use if found.
- **Lint/Test:** Follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect available lint/test commands. Store as `LINT_CMD`, `TEST_CMD`. If no test runner found, WARN and mark test gates as `"skipped"`.
- **Target branch:** CI mode uses `target_branch` from JSON context. Interactive/Local mode detects default branch via `git remote show origin | grep 'HEAD branch'`. If the project uses a staging branch (e.g., `stage`, `develop`), prefer it. Store as `DEFAULT_BRANCH`.

### Initialization Status Report

Before starting Phase 1, output:
- **Mode:** Interactive / CI / Local
- **Cognitive Mode:** PROTOTYPE or PRODUCTION
- **Board Status:** Green / Active Vetoes
- **Memory Core:** Domain files available count

---

## Phase 1 — Analyze (ARCH leads)

1. **Gather issue context:**
   - **Interactive mode:** Use issue tracker tools to fetch issue details (summary, description, acceptance criteria, comments, labels, status).
   - **CI mode:** Use the parsed JSON context (already loaded in Phase 0).
   - **Local mode:** Context from BACKLOG.md entry or freeform argument.
2. **Load** `.agent/.ai/Developer.md` if it exists.
3. **@ARCH** drafts analysis: root cause (2–3 sentences), affected files/components, acceptance criteria.
4. **Document sourcing:** Only use docs with **Status: Active**; never cite Draft or archived.
5. **Capture analysis text** as `ANALYSIS_TEXT`.
6. **Interactive mode only:** Post analysis to issue tracker.

---

## Phase 2 — Plan (ARCH → SEC → QA)

### ARCH: Fix Approach

- Propose 2–3 sentence approach; list files to modify/create and tests to add.
- **Doc Impact Scan:** For each file being modified, check for hardcoded constants (cookie opts, CORS config, rate limits, security headers, feature flags) that should be documented. Cross-reference `docs/CONFIGURATION_REGISTER.md` and `docs/API_Reference.md` if they exist. If any constant is undocumented, add a **Docs to Update** line to the plan.
- **Low-risk whitelist:** If `docs/LOW_RISK_WHITELIST.md` exists and work matches a whitelisted pattern, ARCH self-authorizes, **skip @SEC**, proceed to QA. If no whitelist file exists, always route to @SEC for non-trivial changes.
- **Enforcement Gate:** If the ticket establishes a process, workflow, governance gate, or architectural constraint, ARCH must include an **Enforcement** section in the plan:
  1. What technically enforces this?
  2. Where is enforcement implemented?
  3. What happens if enforcement fails?
  4. How do we verify enforcement is active?
  If any answer is "convention" or "the agent follows the process," the plan is incomplete — do not proceed.

### SEC (when not whitelisted)

- **Load** `.agent/.ai/Security.md` if it exists.
- Classify risk (LOW / MEDIUM / HIGH / CRITICAL) per `docs/SECURITY_STANDARDS.md` if it exists, otherwise per Security.md.
- **If HIGH or CRITICAL:** **Stop.** Present risk summary and await approval before proceeding.
- Otherwise (LOW/MEDIUM): proceed to QA.

### QA: Validate Plan

- **Load** `.agent/.ai/QA.md` if it exists.
- Validate test cases and quality gates per `.agent/workflows/quality-gates.md` if it exists. If logic/security or Iron Laws are violated, **VETO** with a clear "Path to Green."

### Post Plan & Branch

**Capture plan text** as `PLAN_TEXT`.
**Interactive mode only:** Post plan comment to issue tracker.
**Interactive mode only:** Create branch: `git checkout <DEFAULT_BRANCH>`, `git pull`, `git checkout -b fix/<ISSUE_KEY>-<short-slug>`. For Local mode without an issue key, use `fix/LOCAL-<short-slug>`.

---

## Phase 3 — Implement (OPS executes)

### Gate

- **Interactive mode:** Verify the issue has appropriate tracking label (e.g. `agent-fix-pending` or equivalent). If not, abort.
- **CI mode:** Verify Phase 2 completed successfully (risk LOW/MEDIUM, no QA veto).

### OPS: Apply Fix

- **Load** `.agent/.ai/DevOps.md` if it exists.
- Apply fix per ARCH plan and project CODING_STANDARDS; apply `.agent/workflows/quality-gates.md` if it exists.
- **Mandates:**
  - **Chain-of-Thought:** Before generating code, output `<details><summary>Thinking...</summary> [Analysis] </details>`.
  - **Reflexion Loop:** Critique own code; in **prototype** mode check **Fatal Errors Only**.
  - **Flash Lesson:** If you catch an error during Reflexion or a test run, output: **"@LIB, record Flash Lesson: [The specific technical fix]."**
  - **Output economy:** Files < 200 lines → full-file update; files ≥ 200 lines → rewrite entire function/block.

### QA Requests Run; OPS Runs Lint & Tests

- Run `LINT_CMD` if found. If fail: use lint:fix if available, then re-run until clean.
- Run `TEST_CMD` if found. If tests fail: determine if fix-induced or pre-existing. If **fix-induced**, fix and re-run; after **3 attempts** still failing → post comment, leave branch intact, **ABORT**.
- Re-run lint after any test fixes.

### LIB Doc Audit (Mandatory — runs after every test pass)

After OPS tests pass and before PR creation, run the **LIB proactive doc audit**:

1. **Load** `.agent/.ai/Librarian.md` if it exists.
2. **Run `npm run lint:doc-coverage`** if available — automated check for unregistered constants. If it reports gaps, add entries to `docs/CONFIGURATION_REGISTER.md` before proceeding.
3. **Run the mandatory checklist below.** Each item must be answered with evidence (file checked, grep result, or "N/A — no X in this change").
4. **Classify findings** by severity: HIGH (blocks PR), MED (create linked ticket), LOW (comment only).
5. **Resolve HIGH findings** before proceeding. If unresolvable, block PR creation.
6. **Post audit report** as a tracker comment (interactive mode).
7. If zero findings: post `LIB doc audit complete — no doc changes required.`

#### LIB Doc Audit Checklist

| # | Check | How to verify | If missing |
|---|-------|--------------|------------|
| 1 | **Constants registered?** | `git diff` for new `const` at module scope with `UPPER_SNAKE_CASE`. Cross-reference against `docs/CONFIGURATION_REGISTER.md`. | MED — add entries |
| 2 | **API fields documented?** | If new fields in request/response bodies, check `docs/API_Reference.md`. | MED — add entries |
| 3 | **DB schema documented?** | If new columns/tables, check `docs/Database_Architecture.md`. | LOW — add note |
| 4 | **TEST_REGISTRY updated?** | If test files added/modified, check `docs/TEST_REGISTRY.md`. | MED — add rows |
| 5 | **User docs current?** | If feature is user-facing, check relevant user doc. | MED — add section or file ticket |
| 6 | **Design doc exists?** | If new module > 200 lines created, check for design doc. | LOW — note in PR |
| 7 | **Stale references?** | If a skill, contract, or interface changed behavior, grep project for old references. Update or acknowledge all. | HIGH — update before merge |

---

## Phase 4 — Commit & Close (OPS only)

### Commit & Push

Stage only files that are part of the fix. Commit:
- `fix(<ISSUE_KEY>): <short description> [agent]`

Push branch.

### Create PR

Create PR targeting `DEFAULT_BRANCH` with body: Summary, Root Cause, Changes, Test Plan, Closes <ISSUE_KEY>, "Board consensus (ARCH→SEC→QA→OPS)".

### Merge & Tracker (Interactive mode only)

- **Merge strategy:** Try `gh pr merge --squash --auto`. Classify result:
  - Merged / Auto-merge queued → proceed
  - Reviews required / CI pending / Branch protection → add label `agent-ready-for-review`, post tracker comment, do **not** transition to Done
  - Merge failed → post "Merge Failed" comment, do not transition
- Post resolution comment with commit SHA, PR URL, files changed, fix summary.
- **Transition** only if merge status is "merged" or "queued".

### Tracker State Verification (Interactive mode only — MANDATORY before JSON output)

Before emitting the structured JSON, verify all tracker I/O is complete:
- [ ] **Analysis comment posted?**
- [ ] **Plan comment posted?**
- [ ] **Appropriate tracking label added?**
- [ ] **Resolution comment posted?**
- [ ] **Status transitioned?**

### Structured JSON Output (All modes — ALWAYS emit)

```json
{
  "status": "success|aborted|escalate",
  "issue_key": "PROJ-123",
  "phase_reached": 4,
  "risk_level": "LOW|MEDIUM|HIGH|CRITICAL",
  "pr_url": "https://github.com/.../pull/42",
  "pr_number": 42,
  "branch": "fix/PROJ-123-short-slug",
  "commit_sha": "abc1234",
  "files_changed": ["path/to/file1.js"],
  "tests_passed": true,
  "lint_clean": true,
  "abort_reason": null,
  "flash_lessons": [],
  "quality_gates": [
    {"gate": "ARCH_ANALYSIS", "phase": 1, "result": "pass|fail|skipped", "evidence": "..."},
    {"gate": "SEC_RISK_CLASSIFICATION", "phase": 2, "result": "pass|skipped", "evidence": "LOW — whitelisted"},
    {"gate": "QA_PLAN_VALIDATION", "phase": 2, "result": "pass|fail|veto", "evidence": "..."},
    {"gate": "ENFORCEMENT_CHECK", "phase": 2, "result": "pass|n/a", "evidence": "not a governance ticket"},
    {"gate": "LINT_CLEAN", "phase": 3, "result": "pass|fail", "evidence": "exit 0"},
    {"gate": "TESTS_PASS", "phase": 3, "result": "pass|fail", "evidence": "N/N tests passed"},
    {"gate": "LIB_DOC_AUDIT", "phase": 3, "result": "pass|fail", "evidence": "checklist verified"},
    {"gate": "STALE_REFS_CHECKED", "phase": 3, "result": "pass|n/a", "evidence": "0 stale refs or all updated"}
  ]
}
```

**Rules:**
- Every gate MUST have a `result` — no gate may be omitted.
- `evidence` must be concrete (command output, file checked, grep result), not a self-assertion.
- If a gate was not reached due to abort, set `result` to `"skipped"` with explanation.
- `validate-gates` skill consumes this array for second-pass verification.

---

## Phase 5 — After Action Review (AAR)

Run after Phase 4 completes. Scope scales with batch size:

### Single Issue — Checklist

- [ ] **Plan compliance:** Did we deliver the tests stated in Phase 2?
- [ ] **Doc impact verification:** Did we update every doc listed in the plan?
- [ ] **Flash lessons:** Did any Reflexion loop or test failure reveal a reusable lesson? If yes, record in the appropriate `MEMORY_*.md` file.

### Batch (2+ issues) — Mini-AAR

All Single Issue checks, plus:
- [ ] **Config register lint** if available
- [ ] **Doc impact scan** across all modified files
- [ ] **Tracker state:** All processed issues in correct status

### Epic Close — Full AAR

All Batch checks, plus:
- [ ] **Acceptance criteria:** Cross-reference epic success criteria against delivered code
- [ ] **Summary table:** All issues with Result / PR / Notes
- [ ] **Flash lesson consolidation**

---

## Close-as-Resolved Protocol

When an issue is verified as **already resolved** (no new changes needed):

1. **Doc Impact Scan:** Check files for undocumented hardcoded constants. Cross-reference `docs/CONFIGURATION_REGISTER.md`.
2. **Run `npm run lint:config-register`** if available.
3. **Post tracker comment:** status, evidence, doc impact.
4. **Transition** only after doc scan passes.

---

## Abort Protocol

1. **Interactive mode only:** Post tracker comment: "## Agent Aborted — Phase <N>. **Reason:** <…>. **State:** <branch>. **Action Required:** Manual intervention."
2. Leave the branch intact.
3. Do not transition the issue.
4. **Both modes:** Output the structured JSON with abort details.

---

## References

- `.agent/.ai/BOOTSTRAP.md` — Board activation, cognitive mode, resolution sequence
- `.agent/.ai/AGENTS.md` — Roles, autonomy, veto, output economy
- `.agent/.ai/MEMORY.md` — Iron Laws; domain memory index
- `.agent/.ai/Developer.md` — ARCH role spec
- `.agent/.ai/Security.md` — SEC role spec
- `.agent/.ai/QA.md` — QA role spec
- `.agent/.ai/DevOps.md` — OPS role spec
- `.agent/.ai/Librarian.md` — LIB role spec
- `.agent/workflows/quality-gates.md` — Pre-merge checklist
- `docs/CODING_STANDARDS.md` — Coding standards (if exists)
- `docs/SECURITY_STANDARDS.md` — Security standards (if exists)
- `docs/TESTING_STANDARDS.md` — Testing standards (if exists)
- `docs/OPS_STANDARDS.md` — Ops standards (if exists)
- `docs/DOCUMENTATION_STANDARDS.md` — Doc standards (if exists)
- `docs/LOW_RISK_WHITELIST.md` — Patterns that bypass @SEC (if exists)