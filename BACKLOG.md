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

---

## RTO Portability Test — Session 2026-04-07

### BL-020: Bootstrap is incomplete and Claude Code-only
**Source:** RTO_Toolkit portability test — bootstrap succeeded but `/grill-me` was "unknown skill"
**Problem:** `bootstrap.sh` adds the `foundation` remote and pulls `.foundation/` via git subtree, but does NOT create `.claude/skills/` symlinks. After bootstrap, all skill files exist in `.foundation/.claude/skills/` but Claude Code can't discover them. The bootstrap output tells users to "Run: /grill-me intake" — which is impossible because grill-me isn't linked yet.

Additionally, bootstrap assumes Claude Code. Cursor uses `.cursor/rules/` (or Cursor Agents), not `.claude/skills/`. The canonical skill layer (`.agent/skills/`) is IDE-agnostic by design, but bootstrap only generates Claude Code wrappers — and doesn't even do that correctly.

**Fix (three parts):**
1. `bootstrap.sh` must auto-link at minimum `grill-me` and `foundation-sync` into `.claude/skills/` so the entry-point skills work immediately
2. Bootstrap should detect or ask which IDE the user is using and generate appropriate wrappers (`.claude/skills/` for Claude Code, `.cursor/rules/` for Cursor)
3. `grill-me intake` Step 3 install instructions should cover multiple IDEs, not just Claude Code symlinks
**Status:** DONE — bootstrap.sh now detects/asks IDE (Claude Code, Cursor, or skip), auto-links grill-me + foundation-sync as entry-point skills in the correct format. grill-me intake Step 3 updated with multi-IDE install instructions.

---

## Onboarding Experiment Findings — Session 2026-04-07

### BL-021: Canonical skills use hardcoded paths that don't resolve in fork projects
**Source:** Onboarding experiment — Finding 1 (BLOCKER)
**Problem:** Every canonical skill references `.agent/.ai/BOOTSTRAP.md`, `docs/CODING_STANDARDS.md`, etc. In fork projects these files live under `.foundation/`. 11 skill files reference `.agent/` paths, 7 reference `docs/` paths. Skills run without their constitutional documents, risk rubrics, or quality gates loaded.
**Decision (Board Meeting 2026-04-07):** Implement a fallback chain — skills check local path first (`.agent/`, `docs/`), fall back to `.foundation/.agent/`, `.foundation/docs/` if not found. No symlinks (fork projects need their own directories). grill-me intake handles collision detection: asks user to keep theirs or use Foundation's, offers wrapper pointer if they keep theirs.
**Affected files (11 canonical skills):** `implement`, `review-code`, `review-security`, `review-tests`, `test-runner`, `aar`, `board-meeting`, `validate-gates`, `grill-me`, `developer`, `security` — all in `.agent/skills/*/SKILL.md`
**Acceptance criteria:**
1. Each canonical skill that references `.agent/` or `docs/` includes a path resolution preamble: "Check local path first, fall back to `.foundation/` prefix"
2. A fork project with only `.foundation/` (no local `.agent/` or `docs/`) can run `implement` in local mode and load all Board context
3. A fork project with its own `docs/CODING_STANDARDS.md` uses the local version, not `.foundation/docs/CODING_STANDARDS.md`
4. grill-me intake detects when both local and Foundation versions of a file exist and asks user how to resolve
**Status:** OPEN

### BL-022: grill-me intake and bootstrap.sh give contradictory skill linking instructions
**Source:** Onboarding experiment — Finding 2
**Problem:** bootstrap.sh links wrappers to `.claude/skills/` (correct for Claude Code). grill-me intake recommends linking canonicals to `.agent/skills/`. These are different directories with different content. A user following grill-me's advice bypasses the wrappers entirely.
**Decision:** Reconcile to one authoritative path per IDE. bootstrap.sh is correct for Claude Code; grill-me intake instructions must match.
**Affected files:** `.agent/skills/grill-me/SKILL.md` (intake Step 3 install instructions)
**Acceptance criteria:**
1. grill-me intake install instructions match bootstrap.sh: Claude Code → `.claude/skills/` wrappers, Cursor → `.cursor/rules/`
2. No skill references `.agent/skills/` as a user-facing install target (that's the canonical location, not the IDE integration point)
**Status:** OPEN

### BL-023: allowed-tools whitelists are project-specific, block toolchain discovery
**Source:** Onboarding experiment — Finding 3
**Problem:** Wrapper skills hardcode `Bash(npm run test:unit)` in allowed-tools, but toolchain discovery says to adapt to the project. A project using `npm test` instead of `npm run test:unit` gets blocked. The rigid whitelist was designed for a single project (WEAP) and doesn't generalize.
**Decision (Board Meeting 2026-04-07):** Broaden allowed-tools to permissive patterns (e.g., `Bash(npm *)`, `Bash(node *)`) so toolchain discovery can actually adapt.
**Affected files:** All `.claude/skills/*/SKILL.md` wrappers (11 files)
**Acceptance criteria:**
1. Every wrapper's `allowed-tools` includes broad patterns: `Bash(npm *)`, `Bash(node *)`, `Bash(python3 *)`, `Bash(make *)`, `Bash(cargo *)`, `Bash(go *)` as appropriate per skill
2. Specific commands (e.g., `Bash(npm run test:unit)`) removed in favor of broad patterns
3. Git commands remain specific (e.g., `Bash(git push:*)`) — those are safety-critical
**Status:** OPEN

### BL-024: No .agent/.mode file created by bootstrap; no mode promotion path
**Source:** Onboarding experiment — Finding 4
**Problem:** Skills check `.agent/.mode` for prototype vs production. No file exists after bootstrap. Default is prototype (correct for new projects), but there's no documentation or mechanism for promoting to production.
**Decision (Board Meeting 2026-04-07):** Default stays prototype. grill-me intake should ask the user about mode and create the file. Document mode promotion in README or a dedicated guide.
**Affected files:** `.agent/skills/grill-me/SKILL.md` (add mode question to intake), `README.md` (document mode), `bootstrap.sh` (optional: create default file)
**Acceptance criteria:**
1. grill-me intake asks "Is this a prototype or production project?" and creates `.agent/.mode` with the answer
2. README explains what `.agent/.mode` does and how to change it
3. Skills continue to default to `prototype` when file is missing (no breaking change)
**Status:** OPEN

### BL-025: Project-specific references remain in canonical skills (WEAP-*, stage branch, doc paths)
**Source:** Onboarding experiment — Finding 5
**Problem:** `implement` references WEAP-123, WEAP-241, WEAP-49 as Jira keys in examples/rationale (acceptable). But operational instructions hardcode `stage` as PR target branch and assume `docs/agent/technical/SDLC.md`, `LOW_RISK_WHITELIST.md` exist (not acceptable — these are project-specific docs, not Foundation templates). Branch naming assumes Jira key format.
**Decision:** WEAP references in rationale blocks are fine (they explain _why_ a rule exists). Operational defaults (target branch, doc paths, branch naming) should be configurable or detected from project state at runtime.
**Affected files:** `.agent/skills/implement/SKILL.md` (primary), plus any skill referencing `docs/agent/technical/SDLC.md` or `LOW_RISK_WHITELIST.md`
**Acceptance criteria:**
1. Target branch detected from `git remote show origin` default branch, not hardcoded to `stage`
2. Branch naming supports non-Jira patterns (e.g., `fix/LOCAL-short-slug` for local mode, not just `fix/WEAP-123-slug`)
3. References to `docs/agent/technical/SDLC.md`, `LOW_RISK_WHITELIST.md` guarded with "if exists" — these are optional project-specific docs, not Foundation requirements
4. WEAP-* references in `> **Rationale**` blocks left as-is (historical context)
**Status:** OPEN

### BL-026: review-security produces empty results on fresh projects
**Source:** Onboarding experiment — Finding 6
**Problem:** review-security expects `npm audit` (needs node_modules), `node scripts/security/*` (project-specific), `npm run lint:config-register` (project-specific). A fresh project with no deps gets mostly "skipped" results. Toolchain discovery handles this gracefully (WARN) but the review is nearly useless.
**Decision:** Add a "code-level scan" fallback mode that focuses on source code patterns (hardcoded secrets, SQL injection, XSS) when no dependency tooling is available. The skill should always produce _some_ value.
**Affected files:** `.agent/skills/review-security/SKILL.md`
**Acceptance criteria:**
1. When no dependency audit tool is available, skill falls back to grep-based source scan: secrets patterns, SQL string concatenation, unescaped user input in HTML, hardcoded credentials
2. Skill always produces at least a secrets scan result (regex-based, no tooling required)
3. Skipped sections clearly state what tooling would enable them (e.g., "Install dependencies and run `npm audit` for CVE scanning")
**Status:** OPEN

### BL-027: No CLAUDE.md generated by bootstrap
**Source:** Onboarding experiment — Finding 7
**Problem:** Claude Code auto-loads `CLAUDE.md` as conversation context. Without one, the agent starts every session with no awareness of Foundation, skills, or the `.foundation/` prefix. Foundation is invisible unless a skill is explicitly invoked.
**Decision:** bootstrap.sh should generate a minimal `CLAUDE.md` pointing to `.foundation/`, listing available skills, and explaining the project's relationship to Foundation_template.
**Affected files:** `bootstrap.sh`
**Acceptance criteria:**
1. bootstrap.sh generates a `CLAUDE.md` in the project root (only if one doesn't already exist)
2. Generated CLAUDE.md includes: pointer to `.foundation/` directory, list of activated skills, note about `foundation-sync pull` for updates
3. Content is minimal (~10-20 lines) — just enough for Claude Code to know Foundation exists
4. Does not overwrite an existing CLAUDE.md

### BL-028: AAR flash lesson — subtree model creates path namespace problem (candidate Anti-015)
**Source:** AAR session 2026-04-07 — flash lesson from onboarding experiment
**Problem:** When Foundation moved from "I am the project" (paths at root) to "I live inside the project" (paths under `.foundation/`), every hardcoded path in every skill broke. This is the same class of bug as a library hardcoding absolute paths instead of relative ones. The BL-001 migration changed deployment topology but didn't update consumers.
**Decision:** After BL-021 is implemented, codify as Anti-015: "Namespace-Blind References" — skill protocols must not assume their files live at a fixed path. Test future Foundation changes in a fork context, not just in-repo.
**Affected files:** `.agent/.ai/MEMORY_ANTI_PATTERNS.md`
**Acceptance criteria:**
1. Anti-015 added after BL-021 lands (so it describes the solution, not just the problem)
2. Wording is generic/portable (applies to any framework that gets embedded in another project)
**Status:** OPEN — blocked by BL-021
