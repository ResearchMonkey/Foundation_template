# Periodic Review — 5-Pillar Monthly Audit Process

**Source:** Weapons_Lore Periodic Review 2026-03-11 + Agent Effectiveness Scorecard
**Status:** Active
**Purpose:** Generalized monthly audit process for agent-driven development systems

---

## Overview

A **periodic review** is a structured monthly audit of the development system's health across 5 pillars. It identifies systemic patterns, not individual bugs — root causes that escape quality gates repeatedly, agent blind spots, and memory staleness.

Run once per month (or after major milestones). Use `implement` skill with the review output as input.

---

## The 5 Pillars

| Pillar | Focus | Key Questions |
|--------|-------|--------------|
| **1. Bug Root Cause** | What caused recent bugs? | Are the same root causes repeating? Which gates are failing? |
| **2. Agent Effectiveness** | Are agents doing their jobs? | Which agent has the most bugs escaped? Which has stale memory? |
| **3. Quality Gate Completeness** | Are gates current and enforced? | Have gates drifted from actual code? Are references accurate? |
| **4. Memory Health** | Is long-term memory accurate? | Which memory files are stale? What lessons were missed? |
| **5. Process Compliance** | Are processes being followed? | Are PR checklists being completed? Are retrospective actions tracked? |

---

## Pillar 1 — Bug Root Cause Analysis

### Collect Recent Defects

Pull all bugs from the last 30 days (or the sprint window). Classify each by:

| Root Cause | Description |
|------------|-------------|
| **Spec Gap** | Requirement was ambiguous or missing |
| **Missing Gate** | A quality gate existed but wasn't applied |
| **Test Gap** | A test was missing or insufficient |
| **Process Gap** | A required step was skipped |
| **Agent Blind Spot** | No gate exists for this class of defect |

### Output: Root Cause Distribution Table

```
| Category | Count | % |
|----------|-------|---|
| Spec Gap | X | X% |
| Missing Gate | X | X% |
| Test Gap | X | X% |
| Process Gap | X | X% |
| Agent Blind Spot | X | X% |
```

### Output: Systemic Patterns

Group related defects. Ask: "Is this one problem manifesting in multiple tickets?"

Example pattern: *6 of 27 defects were mobile layout breaks — gate §21 (mobile responsiveness) exists on paper but was never enforced at CI.*

---

## Pillar 2 — Agent Effectiveness Scorecard

Rate each agent on:

| Dimension | What to Check |
|-----------|--------------|
| **Mandate Coverage** | Does the agent's mandate actually cover what it's supposed to do? |
| **Bugs Escaped** | How many bugs slipped past this agent's gates? |
| **Blind Spots** | What class of defect can this agent not catch? |
| **Memory Staleness** | Are the agent's memory files current? |

### Scorecard Template

```
| Agent | Mandate Coverage | Bugs Escaped | Blind Spots | Memory Staleness | Grade |
|-------|-----------------|-------------|-------------|------------------|-------|
| @ARCH | Strong/Adequate/Weak | N | X, Y | N days stale | A/B/C |
| @QA | Strong/... | N | X, Y | N days stale | A/B/C |
| @SEC | Strong/... | N | X, Y | N days stale | A/B/C |
| @OPS | Strong/... | N | X, Y | N days stale | A/B/C |
| @LIB | Strong/... | N | X, Y | N days stale | A/B/C |
```

---

## Pillar 3 — Quality Gate Completeness

### Gate Count Drift Check

Count the gates referenced in governance documents vs. the actual canonical list. Report discrepancies.

**Example:** Quality gates §1-§21 defined in the SKILL.md, but 3 different documents reference 17, 19, or 21 gates — all different. Auto-fix references and standardize.

### Gate Coverage Matrix

For each defect, ask: "Which gate SHOULD have caught this?" Build a coverage matrix:

```
| WEAP-# | Root Cause | Gate Should Catch | Agent |
|--------|-----------|-------------------|-------|
| XXX | Missing Gate | §21 Mobile | @QA |
| XXX | Spec Gap | §6 API Contract | @QA |
```

---

## Pillar 4 — Memory Health

| File | Last Updated | Days Stale | Pending Items | Action Needed |
|------|-------------|-----------|---------------|---------------|
| MEMORY.md | YYYY-MM-DD | N | X items | Do consolidation |
| MEMORY_ANTI_PATTERNS.md | YYYY-MM-DD | N | — | OK or needs update |
| [Domain Memory] | YYYY-MM-DD | N | X items | Update with lessons |

Flag any domain with >7 days staleness.

---

## Pillar 5 — Process Compliance

| Process | What to Check |
|---------|--------------|
| **PR Checklist** | Are feature completeness, test coverage, and anti-pattern reviews actually done? |
| **Retrospective Actions** | Are post-mortem action items tracked and completed? |
| **AAR Policy** | Are After-Action Reviews being held for significant events? |

---

## Output: Executive Summary

One paragraph distilling the most important finding. Then:

### Top 3 Systemic Risks
1. [Risk] — [Description] — [Recommended Action]
2. ...
3. ...

### Recommended Next Steps
Prioritized list of process or tooling changes to address the root causes found.

---

## Review Cadence

- **Monthly:** Full 5-pillar review
- **On-demand:** After a major incident or significant architectural change

## Source Files (Weapons_Lore Reference)

- `WEAPONS_LORE/docs/agent/quality/PERIODIC_REVIEW_YYYY-MM-DD.md` — completed reviews
- `WEAPONS_LORE/.agent/.ai/quality-gates.md` — current gate definitions
- `WEAPONS_LORE/docs/agent/quality/QA_LESSONS_LEARNED.md` — accumulated lessons
