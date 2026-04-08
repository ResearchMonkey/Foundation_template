# Foundation_template Backlog

Items discovered during project grilling sessions. Implement after each round.

---

### BL-002: Define success criteria for RTO portability test
**Source:** Grill question — how to validate the template is portable
**Acceptance Criteria (defined in board meeting 2026-04-07):**
1. `foundation-sync init` completes without error on a fresh repo
2. `grill-me intake` runs, classifies the project, and recommends a skill set appropriate to the project's stack and risk profile
3. At least one skill from each category (workflow, review, standalone) executes without project-specific errors or missing references
4. `implement` processes a real ticket end-to-end (ARCH → SEC → QA → OPS → LIB) with no template-origin references in output
5. `aar` runs against the session and produces actionable findings (not empty/boilerplate)
**Status:** Criteria defined — pending RTO integration test

Five structured experiments run against Foundation_template (Experiments A–E).

### BL-031: projects.json in Foundation_template root is empty `[]`
**Source:** Experiment C (sync)
**Problem:** After BL-016 (template must not contain project-specific data), `projects.json` was emptied to `[]`. The portability scan (BL-013) reads fork names from `projects.json` — an empty array means no portability warnings ever fire on pull.
**Affected files:** `projects.json`, `skills/foundation-sync/SKILL.md`
**Decision:** Keep `projects.json` empty in the template (correct — template should not hardcode fork names). Document that forks must populate it with their own name after init.
**Status:** OPEN — decision made, documentation update needed
