# Foundation_template Backlog

Items discovered during project grilling sessions. Implement after each round.

---

## Round 1

### BL-001: Replace file-copy sync with git subtree
**Source:** Grill question — sync contract has no conflict resolution
**Problem:** Current `foundation-sync` drops conflicts silently ("drop, log, continue"). Customized skills in forks get overwritten.
**Decision:** Use git subtree. Sync skill becomes a thin wrapper around `git subtree pull/push`.
**Status:** DONE — Rewrote foundation-sync to use `git subtree` with `.foundation/` prefix. Pull uses 3-way merge (conflicts surface for manual resolution, never auto-dropped). Push goes to `contrib/<project>` branch for review. Added `init` command for first-time setup. Migration path documented for existing file-copy forks. Portability check (BL-013) integrated into push workflow.

### BL-002: Define success criteria for RTO portability test
**Source:** Grill question — how to validate the template is portable
**Acceptance Criteria (defined in board meeting 2026-04-07):**
1. `foundation-sync init` completes without error on a fresh repo
2. `grill-me intake` runs, classifies the project, and recommends a skill set appropriate to the project's stack and risk profile
3. At least one skill from each category (workflow, review, standalone) executes without project-specific errors or missing references
4. `implement` processes a real ticket end-to-end (ARCH → SEC → QA → OPS → LIB) with no template-origin references in output
5. `aar` runs against the session and produces actionable findings (not empty/boilerplate)
**Status:** Criteria defined — pending RTO integration test

### BL-003: Implement skill emits machine-readable gate checklist
**Source:** Grill question — no automation on quality gates
**Problem:** 25+ gates are agent-enforced with no verification. Skipped gates go unnoticed.
**Decision:** `implement` skill outputs a structured pass/fail checklist (JSON or markdown table) for every gate. Missing entries are flagged as gaps.
**Status:** DONE — quality_gates array added to implement JSON output with 13 gates, evidence requirements, and no-omission rule

### BL-004: Ship generic pre-commit hook template
**Source:** Grill question — zero automation
**Problem:** No structural checks at commit time.
**Decision:** Provide a `.husky/pre-commit` template with stack-agnostic checks: secrets regex, TODO without ticket ID, skipped tests. Forks opt in via husky install.
**Status:** DONE — .agent/hooks/pre-commit created. Checks: secrets detection (blocks), TODO without ticket ID (warns), skipped tests (warns), large files (warns), auto-detects and runs linter. Install instructions in file header.

### BL-005: Create validate-gates skill (post-run second-pass validator)
**Source:** Grill question — who catches skipped gates
**Problem:** Single agent self-reporting compliance has no verification.
**Decision:** New skill that reads the last `implement` output and verifies: Security sign-off present, QA confirmed tests, Librarian updated docs. A second agent checking the first.
**Status:** DONE — canonical (.agent/skills/validate-gates/) and wrapper (.claude/skills/validate-gates/) created. Checks structural completeness, evidence quality, and spot-checks with independent verification.

### BL-010: Add project intake mode to grill-me skill
**Source:** Grill question — no onboarding path for new forks
**Problem:** `grill-me` only interrogates Jira tickets. New projects need a "what do you need from Foundation_template?" intake flow — identify tech stack, risk profile, which skills/agents to pull, what gates matter.
**Decision:** Add a second mode to `grill-me` (or a new `project-intake` skill) that interviews the user about their project and recommends a starting set of skills, agents, and anti-patterns from the catalog (BL-009).
**Status:** DONE — intake mode added to grill-me (canonical + wrapper). Interviews project, classifies risk profile (Lightweight/Standard/Full), recommends skills/agents/anti-patterns, offers to copy them in.

### BL-009: Create skill catalog with dependency map
**Source:** Grill question — template is a library but no guide for cherry-picking
**Problem:** New forks must read every skill to know what to pull. No visibility into which skills are standalone vs. which depend on others (e.g., `implement` assumes `validate-gates`, agent mandates assume board constitution).
**Decision:** Add a CATALOG.md or section in README listing each skill with: one-line purpose, prerequisites/dependencies, which agent roles it requires.
**Status:** DONE — see CATALOG.md

### BL-008: Create or adopt a risk classification rubric for Security agent
**Source:** Grill question — risk tiers have no calibration
**Problem:** LOW/MEDIUM/HIGH/CRITICAL tiers control agent autonomy but classification is undefined. Results vary across sessions.
**Decision:** Research existing security risk rubrics (OWASP Risk Rating, STRIDE, DREAD) for fit. If none map cleanly, build a project-specific rubric with concrete criteria (e.g., touches auth = HIGH, UI-only = LOW). Embed in Security.md.
**Status:** DONE — Expanded Security.md §5 with concrete criteria per tier, boolean rules, and tie-breaking logic

### BL-007: Deduplicate MEMORY_ANTI_PATTERNS.md — single source in .agent/.ai/
**Source:** Grill question — SSOT violation
**Problem:** `MEMORY_ANTI_PATTERNS.md` exists at root AND `.agent/.ai/`. Edits to one don't propagate to the other.
**Decision:** Canonical location is `.agent/.ai/MEMORY_ANTI_PATTERNS.md`. Delete root copy, update all references.
**Status:** DONE

### BL-006: Skills gracefully detect available tooling
**Source:** Grill question — skills reference npm scripts/tools that don't exist in template
**Problem:** Skills call `npm run lint`, `npm run test:unit`, `npm run generate-registry`, Husky hooks — forks without these fail silently or produce misleading output.
**Decision:** Skills discover what's available (package.json scripts, Makefile targets, test runners in PATH) and adapt. Missing tooling produces a clear warning, not a silent pass or silent failure.
**Status:** DONE — .agent/TOOLCHAIN_DISCOVERY.md created; implement, test-runner, review-tests, review-security updated to reference it

---

## AAR Findings — Session 2026-04-06

### BL-011: Scrub remaining Weapons_Lore references from canonical skills
**Source:** AAR session review — finding #1
**Problem:** review-code, review-tests, review-security hardcoded "Weapons Lore project" in their persona lines. Template skills must be project-agnostic.
**Status:** DONE — changed to "this project"

### BL-012: Stand up AAR skill early in new frameworks
**Source:** AAR session review — process observation
**Problem:** AAR was the last skill built but it's the one that catches everything. Should be among the first skills established in any new framework.
**Why:** Running AAR on the session that created the framework itself found 3 real gaps immediately.
**How to apply:** When onboarding a new project (grill-me intake), recommend AAR in the Minimal set and call it out as a day-one skill.
**Status:** DONE — added aar to Lightweight recommended set in grill-me intake. CATALOG.md already had it.

### BL-013: Audit all canonical skills for project-specific language before promoting to template
**Source:** AAR session review — process observation
**Problem:** "Weapons Lore" hardcoding in 3 skills was a pre-existing issue that survived the seed-to-template transition. No step in the sync process checks for project-specific language.
**Why:** foundation-sync copies files wholesale — it doesn't scan for project-specific references.
**How to apply:** Add a portability check to foundation-sync pull: grep for known fork project names and warn if found.
**Status:** DONE — Post-pull portability scan added (Step 5). Loads fork names from projects.json, greps .foundation/ for matches. Warns but doesn't block (fork needs the update; leaked names should be fixed upstream). Push already had a blocking check; top-level Portability Check section updated to cover both directions.

### BL-014: LIB doc audit missed stale references on behavioral changes
**Source:** BL-001 AAR — LIB passed but 3 files still described old file-copy sync
**Problem:** The LIB Doc Audit checklist (items 1–6) only catches *additions* (new constants, new API fields). When a skill's contract changes (replacement, not addition), references to the old behavior in other files go undetected.
**Why:** README, grill-me intake, and AGENTS.md all described the old file-copy model after BL-001 shipped. The checklist passed because there were no new constants or API fields — it never asked "did anything *change* that other files still describe the old way?"
**How to apply:** Added checklist item #7: "Stale references to old behavior?" — grep for old command names, workflow descriptions, and contract terms when a skill or interface changes behavior. Severity: HIGH (blocks merge).
**Status:** DONE — item #7 added to LIB Doc Audit checklist, STALE_REFS_CHECKED gate added to quality_gates JSON

---

## Board Meeting Findings — Session 2026-04-07

### BL-015: CATALOG.md and AGENTS.md missing skills added after initial catalog
**Source:** Board meeting — release readiness review
**Problem:** `board-meeting` was missing from CATALOG.md. `validate-gates` and `aar` were missing from AGENTS.md skill list. These skills were added after the catalog/constitution were written, and no step in the skill-creation workflow updates those indexes.
**Why:** `write-a-skill` scaffolds the canonical + wrapper skill files but does not update CATALOG.md or AGENTS.md. The LIB doc audit checklist catches *changes* to existing skills but not *additions* of new ones.
**How to apply:** `write-a-skill` should include a step to add the new skill to CATALOG.md and AGENTS.md, or at minimum warn if the skill isn't listed in either.
**Status:** DONE — indexes fixed manually. Process gap noted for write-a-skill improvement.

### BL-016: Template shipped with project-specific data in projects.json and MEMORY_ANTI_PATTERNS.md
**Source:** Board meeting — release readiness review
**Problem:** `projects.json` contained a Weapons_Lore entry. `MEMORY_ANTI_PATTERNS.md` referenced Weapons_Lore by name. A template should not contain another project's real data.
**Status:** DONE — projects.json emptied to `[]`. MEMORY_ANTI_PATTERNS.md rewritten to generic guidance.

### BL-017: No LICENSE file
**Source:** Board meeting — @Security flagged as release blocker
**Problem:** No license file means no legal clarity for users. Hard blocker for any public or shared use.
**Status:** DONE — MIT LICENSE added.

### BL-018: Pre-commit hook security risk not documented
**Source:** Board meeting — @Security noted opt-in hook with no warning
**Problem:** The pre-commit hook (secrets scanning) is opt-in but the README didn't explain the security implications of skipping it. New users who skip setup have no automated secrets protection.
**Status:** DONE — README updated with explicit security warning and install instructions.

### BL-019: No .agent/.ai/MEMORY.md index file
**Source:** Board meeting — @Librarian found 404 on skill load target
**Problem:** Multiple skills reference `.agent/.ai/MEMORY.md` as a load target during Step 0, but the file doesn't exist. Skills silently skip it.
**Status:** DONE — created with references to all persona files, active decisions index, and domain memory section for forks.
