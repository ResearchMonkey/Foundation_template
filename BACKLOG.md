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

### BL-032: Add project_type to PROJECT_INTAKE.md
**Source:** Experiment J (board-meeting)
**Problem:** Quality gates (validate-gates) and review skills are Weapons_Lore-optimized — WEAP-specific gates create noise for non-WEAP projects. Anti-patterns aren't tagged by project type. Skills recommend the same set regardless of project kind (web-app vs CLI vs library).
**Decision:** Add `project_type` field to PROJECT_INTAKE.md with suggested-values taxonomy. Anti-patterns tagged with applicable project types. Skills filter recommendations by type.
**Affected files:** `PROJECT_INTAKE.md` (template), `grill-me/SKILL.md`, `MEMORY_ANTI_PATTERNS.md`, `validate-gates/SKILL.md`, `review-security/SKILL.md`, `review-code/SKILL.md`
**Acceptance criteria:**
1. Intake interview adds question: "What kind of project is this?" with suggested values (web-app, cli, library, automation, fullstack, tui, embedded, lambda, other)
2. PROJECT_INTAKE.md template includes `project_type` field
3. Anti-patterns in MEMORY_ANTI_PATTERNS.md tagged with applicable project_type(s)
4. "Universal minimums always apply" documented — project_type filters noise, not replaces judgment
5. BL-002 (portability test) validates project_type tagging end-to-end
**Status:** PARTIAL — criteria 1-4 done. Criteria 5 (BL-002 end-to-end test) remains.