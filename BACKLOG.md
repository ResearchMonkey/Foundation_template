# Foundation_template Backlog

Items discovered during project grilling sessions. Implement after each round.

---

### BL-036: Foundation_template missing canonical skills in skills/
**Source:** EDI-32 close-out (BL-002 Criteria 3 gap)
**Problem:** Foundation_template has `contributions/` and `foundation-sync/` but is missing canonical skills referenced by the Board workflow — specifically `implement`, `review-code`, `review-security`, `review-tests`, `test-runner`, `write-a-skill`, and `grill-me`. Criteria 3 of BL-002 cannot be fully validated without these.
**Affected files:** `skills/` (missing: implement/, review-code/, review-security/, review-tests/, test-runner/, write-a-skill/, grill-me/)
**Note:** Skills exist in Weapons_Lore at `.agent/skills/` and as `.claude/skills/` wrappers. Foundation_template needs generalized versions that work across any fork without project-specific references.
**Status:** DONE ✅ — implement generalized from 441 to 329 lines, all WEAP-specific refs stripped.

---

### BL-037: Consolidate duplicate skills from top-level `skills/` into `.agent/skills/`
**Source:** Board meeting critical review (2026-04-09)
**Problem:** 11 skill directories in `skills/` (aar, board-meeting, foundation-sync, grill-me, implement, review-code, review-security, review-tests, test-runner, validate-gates, write-a-skill) duplicate `.agent/skills/` with no documented rationale. `.agent/skills/` is the canonical source; `.claude/skills/` holds wrappers. The top-level copies add confusion and maintenance burden.
**Keep:** `skills/contributions/` — it's a separate git subtree channel for fork sync (documented in foundation-sync skill and Experiment C).
**Action:** Remove the 11 duplicated skill directories from `skills/`. Update README "What's Here" tree to reflect the change. Update any references that point to `skills/<name>` instead of `.agent/skills/<name>`.
**Status:** OPEN

---

### BL-042: Selective intake — let users choose full suite or cherry-picked subset
**Source:** Board meeting critical review (2026-04-09), @Librarian
**Problem:** Bootstrap pulls the entire template into `.foundation/`. For a solo dev, 5 standards docs + 17 skills + full governance may be overkill. Users should choose between pulling everything or only what they need.
**Action:** Extend `grill-me intake` to ask "full governance suite or just the skills/standards relevant to your project?" Based on the answer, selectively activate only the chosen pieces. CATALOG.md already has recommended skill sets by project type — use that as the menu.
**Status:** OPEN

---

### BL-041: Refresh README for clarity, accuracy, and audience
**Source:** Board meeting critical review (2026-04-09), @Librarian
**Problem:** README has several gaps that would confuse new users:
1. **Stale info** — says "14 skills" but actual count is 17
2. **No target audience** — should state: solo developers using an AI coding agent as primary/sole developer
3. **Appears Claude-only** — `.claude/skills/` wrappers are everywhere but README never says the framework is AI-tool-agnostic. Should clarify that `.claude/skills/` is one integration and users can write wrappers for Cursor, Codex, etc.
4. **No practical example** — no "what does this look like in practice" section showing sample output from `/implement` or a board meeting
5. **Prerequisites unclear** — Getting Started should state: have your AI coding agent of choice installed
**Status:** OPEN

---

### BL-040: Add `foundation-sync doctor` health check subcommand
**Source:** Board meeting critical review (2026-04-09), @DevOps
**Problem:** Git subtree sync has limited real-world usage. When corruption or misconfiguration happens, there's no diagnostic tool — users discover problems mid-sync when recovery is harder.
**Action:** Add a `doctor` subcommand to foundation-sync that validates: remote `foundation` exists, `.foundation/` prefix directory is intact, no orphaned merge state, subtree split history is consistent, `projects.json` entry matches actual git config.
**Goal:** Catch subtree health issues early before they become messy recovery situations.
**Status:** OPEN

---

### BL-039: Add portability and contract tests for Foundation_template
**Source:** Board meeting critical review (2026-04-09), @QA
**Problem:** The template has zero automated tests. As a governance library, its tests should validate the consumer experience — not internal logic in isolation.
**Tests to implement:**
1. `bootstrap.sh` runs clean on an empty git repo
2. Skills resolve paths correctly under `.foundation/` prefix (fork mode)
3. Pre-commit hook catches a planted secret in a test file
4. README skill count matches actual skill count in `.agent/skills/`
5. All `.claude/skills/` wrappers point to existing canonical skills in `.agent/skills/`
**Goal:** Prove the template delivers what it promises before onboarding the next fork project.
**Status:** OPEN

---

### BL-038: Plan and re-add CRITICAL-tier enforcement mechanism
**Source:** Board meeting critical review (2026-04-09), @Security
**Problem:** SECURITY_STANDARDS.md defines a CRITICAL risk tier requiring "human review," but no mechanism enforces it. The pre-commit hook only catches secrets via regex — it doesn't classify risk tiers or block CRITICAL changes. Enforcement may have existed in the original project and been stripped during generalization.
**Action:** Investigate what enforcement existed in the original project. Design a portable mechanism (pre-commit gate, implement skill gate, or CI check) that blocks or escalates when a CRITICAL-tier change is detected. Must work across tech stacks without project-specific assumptions.
**Status:** OPEN