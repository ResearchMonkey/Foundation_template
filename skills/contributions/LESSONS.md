# Cross-Project Lessons — Generalized

**Source:** Weapons_Lore EDI-32 contributing back to Foundation_template
**Date:** 2026-04-06
**Purpose:** Standalone lessons extracted via grill-me from Weapons_Lore experience

> **Note (2026-04-06):** These lessons were pushed under the old file-copy sync model.
> New contributions flow through `.foundation/` commits via `git subtree push`
> (see `skills/foundation-sync/SKILL.md`). This directory is retained as historical
> content — the lessons themselves are still valid and referenced by agent roles.

---

## Lesson 1: Quality Gates Exist But Aren't Enforced

**Pattern:** Multiple defects trace back to a gate that was documented but not automated.

**Example from Weapons_Lore:** §21 (Mobile Responsiveness) existed in quality gates docs for 90 days. During periodic review, 6 of 27 bugs were mobile layout breaks — none were caught by automated tooling.

**Generalized lesson:** A quality gate that requires manual enforcement will eventually fail. Automate gate checks in CI, or they will be skipped under deadline pressure.

**Action for new projects:** Identify which gates CAN be automated (lint rules, test assertions) vs. which require human review. Automate what you can. Track the manual gates explicitly.

---

## Lesson 2: Tool-Specific Bugs Don't Generalize

**Pattern:** Weapons_Lore has recurring bugs from its manual HTML script-tag architecture (no bundler). This is specific to that project's tech stack.

**Generalized lesson:** Some "patterns" are actually tool-specific constraints, not general lessons. Before extracting a lesson, ask: "Is this true in any web project, or only in one with this specific architecture?"

**Rule for contributions:** Only push lessons that apply to a broad class of projects (e.g., "validate impossible state combinations"). Don't push tool-specific bugs upstream. With git subtree sync, contributions are commits to `.foundation/` pushed via `git subtree push` — the old `contributions/` directory is no longer the contribution path.

---

## Lesson 3: Memory Staleness Is a Process Failure

**Pattern:** Weapons_Lore had 3 memory files with 12+ days of staleness despite significant work happening in those domains.

**Generalized lesson:** Memory files that humans must manually update will eventually be forgotten. Use a periodic review to catch staleness. Automate where possible (e.g., a cron job that flags files not updated in 7 days).

**Action for new projects:** Set up a monthly periodic review that checks memory health across all domain files. Flag anything >7 days stale.

---

## Lesson 4: The Batch Collapse Anti-Pattern

**Pattern:** When processing multiple tickets in batch, it's tempting to collapse all updates into one summary comment. This hides individual issue state.

**Generalized lesson:** Each item in a batch must receive its own update. A batch summary is supplemental; individual issue state is required.

**Why it matters:** If you process 10 tickets and only update the parent epic, each ticket's timeline is opaque. When something goes wrong, you can't reconstruct what happened to ticket #7.

**Action for new projects:** When building batch processing, design for per-item state updates as first-class output, not an afterthought.

---

## Lesson 5: Anti-Pattern Lists Must Be Project-Agnostic

**Pattern:** Weapons_Lore's anti-patterns reference project-specific files (`CODING_STANDARDS.md §5.4`), ticket numbers (WEAP-XXX), and environment details.

**Generalized lesson:** An anti-pattern that says "don't do X because it violates our CODING_STANDARDS §5.4" is not portable — it requires the reader to have that document.

**Rule for Foundation_template:** Anti-patterns in this repo must be self-contained. If it references a project-specific path or ticket, it stays in that project — don't push it upstream.

---

## What Stays Local (Weapons_Lore-Specific)

These are NOT for upstream contribution — too project-specific:

- Mobile layout bugs (Weapons_Lore-specific CSS/HTML architecture)
- Script tag initialization bugs (manual HTML injection, no bundler)
- COF/Academy domain validation rules
- FBI scoring zone specifics
- Rate limit tuning for Weapons_Lore's specific API endpoints
