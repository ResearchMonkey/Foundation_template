# Foundation_template Backlog

Items discovered during project grilling sessions. Implement after each round.

---

### BL-002: Define success criteria for RTO portability test
**Source:** Grill question — how to validate the template is portable
**Acceptance Criteria:**
1. `foundation-sync init` completes without error on a fresh repo — **UNTESTED**
2. `grill-me intake` runs and classifies correctly — **UNTESTED**
3. At least one skill from each category executes without project-specific errors — **PARTIAL** (foundation-sync exists; implement/review-code/skills absent from Foundation_template/skills/)
4. `implement` processes a real ticket end-to-end with no template-origin refs — **VALIDATED** ✅ (EDI-32 close-out PR #1)
5. `aar` runs and produces actionable findings — **UNTESTED**
**Status:** CRITERIA 4 VALIDATED. Criteria 1, 2, 3, 5 remain untested.

### BL-031: projects.json in Foundation_template root is empty `[]`
**Source:** Experiment C (sync)
**Problem:** After BL-016 (template must not contain project-specific data), `projects.json` was emptied to `[]`. The portability scan (BL-013) reads fork names from `projects.json` — an empty array means no portability warnings ever fire on pull.
**Affected files:** `projects.json`, `skills/foundation-sync/SKILL.md`
**Decision:** Keep `projects.json` empty in the template (correct — template should not hardcode fork names). Document that forks must populate it with their own name after init.
**Status:** OPEN — decision made, documentation update needed

---

### BL-036: Foundation_template missing canonical skills in skills/
**Source:** EDI-32 close-out (BL-002 Criteria 3 gap)
**Problem:** Foundation_template has `contributions/` and `foundation-sync/` but is missing canonical skills referenced by the Board workflow — specifically `implement`, `review-code`, `review-security`, `review-tests`, `test-runner`, `write-a-skill`, and `grill-me`. Criteria 3 of BL-002 cannot be fully validated without these.
**Affected files:** `skills/` (missing: implement/, review-code/, review-security/, review-tests/, test-runner/, write-a-skill/, grill-me/)
**Note:** Skills exist in Weapons_Lore at `.agent/skills/` and as `.claude/skills/` wrappers. Foundation_template needs generalized versions that work across any fork without project-specific references.
**Status:** OPEN

### BL-031: projects.json in Foundation_template root is empty `[]`
**Source:** Experiment C (sync)
**Problem:** After BL-016 (template must not contain project-specific data), `projects.json` was emptied to `[]`. The portability scan (BL-013) reads fork names from `projects.json` — an empty array means no portability warnings ever fire on pull.
**Affected files:** `projects.json`, `skills/foundation-sync/SKILL.md`
**Decision:** Keep `projects.json` empty in the template (correct — template should not hardcode fork names). Document that forks must populate it with their own name after init.
**Status:** OPEN — decision made, documentation update needed

### BL-035: Resolve EDI-32 deferred open questions (CLOSED — tracked as Jira sub-tasks)
**Source:** EDI-32 close-out
**Decision:** File 4 sub-tasks in Jira to track deferred open questions rather than leaving them in the backlog doc.
**Sub-tasks filed:**
- EDI-34: Define periodic pull cadence for foundation-sync
- EDI-35: Define skill evolution ownership model
- EDI-36: Automate fork discovery for projects.json
- EDI-37: Define conflict resolution UX
**Status:** CLOSED (tracked in Jira)
