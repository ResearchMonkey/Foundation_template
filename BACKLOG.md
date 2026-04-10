# Foundation_template Backlog

Items discovered during project grilling sessions. Implement after each round.

---

### BL-038: Plan and re-add CRITICAL-tier enforcement mechanism
**Source:** Board meeting critical review (2026-04-09), @Security
**Problem:** SECURITY_STANDARDS.md defines a CRITICAL risk tier requiring "human review," but no mechanism enforces it. The pre-commit hook only catches secrets via regex — it doesn't classify risk tiers or block CRITICAL changes. Enforcement may have existed in the original project and been stripped during generalization.
**Action:** Investigate what enforcement existed in the original project. Design a portable mechanism (pre-commit gate, implement skill gate, or CI check) that blocks or escalates when a CRITICAL-tier change is detected. Must work across tech stacks without project-specific assumptions.
**Status:** OPEN

---

### BL-040: Add `foundation-sync doctor` health check subcommand
**Source:** Board meeting critical review (2026-04-09), @DevOps
**Problem:** Git subtree sync has limited real-world usage. When corruption or misconfiguration happens, there's no diagnostic tool — users discover problems mid-sync when recovery is harder.
**Action:** Add a `doctor` subcommand to foundation-sync that validates: remote `foundation` exists, `.foundation/` prefix directory is intact, no orphaned merge state, subtree split history is consistent, `projects.json` entry matches actual git config.
**Goal:** Catch subtree health issues early before they become messy recovery situations.
**Status:** OPEN

---

### BL-042: Selective intake — let users choose full suite or cherry-picked subset
**Source:** Board meeting critical review (2026-04-09), @Librarian
**Problem:** Bootstrap pulls the entire template into `.foundation/`. For a solo dev, 5 standards docs + 17 skills + full governance may be overkill. Users should choose between pulling everything or only what they need.
**Action:** Extend `grill-me intake` to ask "full governance suite or just the skills/standards relevant to your project?" Based on the answer, selectively activate only the chosen pieces. CATALOG.md already has recommended skill sets by project type — use that as the menu.
**Status:** OPEN

---

### BL-043: Purge WEAP/Weapons_Lore from historical files
**Source:** Deep dive scan 2026-04-10
**Problem:** 68 WEAP/Weapons_Lore references found across the repo. Active files cleaned (implement, test-runner, LESSONS, PERIODIC_REVIEW, TEST_LESSONS, BACKLOG). Remaining historical files still contain WEAP references.
**Remaining targets:**
1. `foundation_backlog_done.md` — historical decision records with WEAP references (WEAP-241, WEAP-49, WEAP-specific gate descriptions, BL-011/BL-025 entries)
2. `docs/temp/EXPERIMENT_*.md` (7 files) — experiment docs with WEAP references in findings
3. `docs/temp/EXPERIMENT_RESULTS.md` — summary doc referencing WEAP-123, WEAP-specific findings
4. `SYNC_LOG.md` — sync log with Weapons_Lore as source/destination
**Redaction rule:** Replace WEAP-### → [ISSUE-###], Weapons_Lore → [PROJECT], keep rationale blocks intact as historical context
**Note:** git history will still contain original content — file-level redaction is cosmetic only. Full history purge requires `git filter-repo`.
**Status:** OPEN
