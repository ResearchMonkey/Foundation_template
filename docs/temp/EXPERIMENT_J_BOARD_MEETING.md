# Experiment J — board-meeting (rto-test / n8n-ci-autofix)

**Date:** 2026-04-07  
**Project:** rto-test (n8n-ci-autofix)  
**Skill:** board-meeting  
**Result:** ✅ PASS (with findings)

## Objective

Run board-meeting on the question: **"Should we add a project_type field to PROJECT_INTAKE.md to drive skill and gate filtering?"**

This emerged from Experiments G and I — WEAP-specific gates create noise for non-WEAP projects. The Board was asked to evaluate whether project_type filtering is the right solution.

## Topic

> Should PROJECT_INTAKE.md include a `project_type` field (web-app / cli / library / automation) to drive which quality gates fire and which skills are recommended?

## Opening Reactions

### @Developer
This is a natural extension of what we already have. PROJECT_INTAKE.md already classifies risk profile — adding project_type is just one more field. It solves the gate noise problem cleanly. Validate-gates would check project_type first and skip irrelevant gates. The intake interview would just add one more question: 'What kind of project is this?' with options: web-app, cli, library, automation, fullstack.

Implementation cost is low. We'd add project_type to the intake Step 1 questions, store it in PROJECT_INTAKE.md, and read it in skills that need to filter. The hard part is getting the taxonomy right — does 'automation' include CI runners? Is a TUI a CLI?

### @Security
From a security perspective, project_type changes the threat model significantly. A CLI tool has different attack surfaces than a web app — no XSS, no SQL injection, but potentially command injection, path traversal, privilege escalation. If we tag projects correctly, review-security can skip web-app checks on CLI tools and vice versa. That said, most security gates are universal: no hardcoded secrets, input validation, safe defaults. project_type helps prioritize, not replace.

### @QA
Testability varies wildly by project type. Web apps need E2E tests, CI runners need integration tests against real APIs. If we know the project type, test-runner can suggest the right test strategy automatically. Right now it falls back to 'find package.json scripts' which works but isn't proactive. project_type would let us say 'this is a CLI tool — suggest shell-based integration tests, not Jest unit tests.'

### @DevOps
Deployability patterns are completely different. Web app needs a server, reverse proxy, possibly a database migration step. CLI tool is just 'copy binary to PATH'. Automation scripts like n8n-ci-autofix need a cloudflared tunnel and a webhook receiver. Knowing the project type upfront means we can give better bootstrap advice. Right now grill-me recommends skills but doesn't advise on operational setup.

### @Librarian
Looking at MEMORY_ANTI_PATTERNS.md — many anti-patterns are type-specific. Anti-004 (Modal Compliance) is web-app only. Anti-009 (Init Race Safety) is more relevant to long-running services. If we tag with project_type, we can surface only relevant anti-patterns during intake. The pattern library becomes more actionable — instead of a flat list of 28 anti-patterns, filtered by project type it's 4-6 relevant ones.

## Board Interrogation — Round 1

### @Developer asks
The taxonomy question — 'is a TUI a CLI?' — is actually important. A TUI has interactive user input, which changes testing strategy. How do we handle ambiguous cases?
- (a) Fixed enum — simple but excludes edge cases
- (b) Freeform with suggested values — flexible, needs fuzzy matching
- (c) Multi-select — most accurate but adds complexity

**Verdict:** Suggested values (option b) — allows TUI, embedded, lambda functions, etc. without hardcoding every type.

### @Security asks
Does project_type filtering create false confidence? A developer might skip SQL injection checks on a CLI that still does file-based data processing with injection potential. How do we prevent the filter from being a ceiling rather than a baseline?

**Verdict:** The answer is universal minimums — project_type filters WHAT to prioritize, not WHAT to ignore entirely. Must be documented as "relevant + universal" not "relevant = complete."

### @QA asks
Do we want test-runner to actively recommend a test strategy, or just filter existing recommendations?

**Verdict:** Filter existing + add proactive recommendations. Not full reasoning — a lookup table based on project_type and detected stack.

### @DevOps asks
Should bootstrap.sh ask project_type, or is that too much friction for first-run?

**Verdict:** Bootstrap should be zero-friction. project_type capture belongs in grill-me intake, not bootstrap. Bootstrap is "get the template." Intake is "understand your project."

### @Librarian asks
Every new anti-pattern needs a project_type tag. Who owns keeping that current?

**Verdict:** Template maintainers (Echo8Lore). Tags are required fields for new anti-patterns in BACKLOG. Onboarding experiment (BL-002) should test the tagging.

## Convergence

### Board Summary

| Persona | Position | Key Concern | Resolved? |
|---------|----------|-------------|-----------|
| @Developer | ✅ Yes, with suggested values taxonomy | Taxonomy edge cases | Partial — suggested values approach |
| @Security | ✅ Yes, but universal minimums required | False confidence ceiling | Yes — "relevant + universal" framing |
| @QA | ✅ Yes, filter + proactive recommendations | Scope creep in test-runner | Yes — lookup table, not full reasoning |
| @DevOps | ✅ Yes, in grill-me intake not bootstrap | Bootstrap friction | Yes — intake not bootstrap |
| @Librarian | ✅ Yes, with required tagging governance | Maintenance burden | Yes — maintainers own tags |

### Consensus View

**Yes — add project_type to PROJECT_INTAKE.md.** The value is clear: gate noise reduction, targeted recommendations, actionable anti-patterns. The risks are manageable: suggested-values taxonomy (not fixed enum), universal minimum framing (not ceiling), maintainer-owned tagging governance. The right place to capture it is grill-me intake, not bootstrap. A lookup table approach keeps test-runner in scope without full reasoning.

## Findings

### Finding J-1: Taxonomy decision deferred
The board agreed on "suggested values" approach but didn't nail down the actual taxonomy. n8n-ci-autofix would be "automation" — but "CI runner" and "workflow automation" might be distinct types. Needs a follow-up taxonomy session.

**Severity:** LOW — discovery, not blocker

### Finding J-2: Security ceiling prevention needs documentation
The "universal minimums always apply" principle needs explicit documentation so it doesn't get lost. Every skill that filters by project_type must document that project_type reduces noise, not replaces judgment.

**Severity:** MEDIUM — if not documented, future developers may misuse the filter

### Finding J-3: board-meeting skill is WEAP-optimized
The board personas (@Developer, @Security, @QA, @DevOps, @Librarian) reflect Weapons_Lore's concerns (modals, API contracts, CI/CD). For non-WEAP projects, the interrogation priorities are different. n8n-ci-autofix doesn't have @Developer-style architecture concerns — it has "does the shell script handle edge cases."

**Severity:** LOW — still useful, but the framing is noisy

## New Backlog Item

### BL-032: Add project_type to PROJECT_INTAKE.md

**Source:** Experiment J (board-meeting)  
**Decision:** Add project_type field to intake with suggested-values taxonomy (web-app, cli, library, automation, fullstack, tui, embedded, lambda, other)  
**Acceptance criteria:**
1. Intake interview adds question: "What kind of project is this?" with suggested values
2. PROJECT_INTAKE.md includes project_type field
3. Anti-patterns in MEMORY_ANTI_PATTERNS.md tagged with applicable project_type(s)
4. Quality gates and skills document filtering behavior (noise reduction, not ceiling)
5. BL-002 (portability test) validates project_type tagging works end-to-end

**Status:** OPEN

## Conclusion

PASS — board-meeting worked correctly. All 5 personas responded with relevant domain perspectives, interrogation rounds surfaced important edge cases, and the board reached clear consensus: yes with conditions.

**Recommendation:** BL-032 is the next backlog item. Start with a taxonomy definition session, then update grill-me intake, anti-pattern tags, and skill filtering logic.
