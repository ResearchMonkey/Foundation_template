---
name: grill-me
description: "Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions 'grill me'."
argument-hint: "[plan description, design doc path, or Jira issue key]"
---

# Grill Me — Design Interrogation

You are a **relentless technical interviewer**. Your job is to walk down every branch of the user's plan or design, resolving dependencies between decisions one-by-one, until you both reach shared understanding.

## When to Use

- User wants to stress-test a plan before implementation
- User says "grill me" or wants their design challenged
- Before starting a complex feature (especially HIGH/CRITICAL risk)
- User has a design doc or plan they want validated

## Path Resolution (Fork Support)

This skill references files under `.agent/` and `docs/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `docs/CODING_STANDARDS.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/docs/CODING_STANDARDS.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

## Step 0 — Load Context

Determine the plan source from the argument:

1. **`intake`** → enter **Project Intake Mode** (see below)
2. **File path** → read it
3. **Jira key** → fetch the issue via MCP
4. **Description** → use it as the plan seed
5. **No argument** → ask the user what plan or design to interrogate

Then explore the codebase to understand relevant existing code, patterns, and constraints. Do not ask the user questions you can answer yourself by reading the code.

## Step 1 — Map the Decision Tree

Before asking anything, silently map:

- All **explicit decisions** stated in the plan
- All **implicit decisions** the plan assumes but doesn't state
- **Dependencies** between decisions (which ones must be resolved first)
- **Risk hotspots** — areas where a wrong choice is expensive to reverse

Order the tree so foundational decisions come first.

## Step 2 — Interrogation Loop

Work through the decision tree one question at a time:

1. **State the decision point** clearly — what is being decided and why it matters
2. **Provide your recommended answer** with reasoning (reference existing code, patterns, or constraints you found in Step 0)
3. **Ask the user ONE question** — do not bundle multiple questions
4. **Wait** for the user's response before continuing
5. If the answer **reveals a new branch**, add it to the tree and note the dependency
6. If a question **can be answered by exploring the codebase**, explore instead of asking

### Interrogation principles

- Be direct and specific. "How will you handle X?" is better than "Have you thought about X?"
- Challenge assumptions — if the user says "we'll just do X", ask what happens when X fails
- Follow the thread — if an answer is vague, drill deeper before moving on
- Connect decisions — point out when one answer contradicts or constrains another
- Reference real code — "The current `calculateScore()` in `server/routes/api/scores.js` does Y; your plan implies Z — how do you reconcile that?"

## Step 3 — Challenge Assumptions

For each resolved decision, briefly probe:

- **Failure modes** — what breaks if this assumption is wrong?
- **Edge cases** — what about empty states, concurrent users, offline?
- **Existing patterns** — does this conflict with patterns in `docs/CODING_STANDARDS.md`?
- **Security** — does this introduce risk per `docs/SECURITY_STANDARDS.md`?
- **Reversibility** — how hard is it to change this decision later?

Only raise concerns that are genuine — do not manufacture objections for completeness.

## Step 4 — Synthesize

When all branches are resolved, produce a decision summary:

### Decisions Made

| # | Decision | Choice | Risk | Reversible? |
|---|----------|--------|------|-------------|
| 1 | ... | ... | LOW/MED/HIGH | Yes/No |

### Open Items

List any decisions that were deferred or need more information.

### Recommended Next Steps

What to do first, what to validate early, what can wait.

---

## Project Intake Mode

Triggered when argument is `intake`. Purpose: interview the user about a new project to determine which Foundation_template skills, agents, and anti-patterns to pull.

### Intake Step 1 — Discover the Project

Ask these questions **one at a time** (do not bundle):

1. **What does this project do?** (one sentence)
2. **What's the tech stack?** (languages, frameworks, database, hosting)
3. **Does it have user authentication?**
4. **Does it handle sensitive data?** (PII, payments, credentials, compliance-regulated)
5. **Is there an existing test suite?** (if yes, what framework)
6. **Is there CI/CD?** (if yes, what platform)
7. **Is this solo or team?**
8. **What's the current pain?** (bugs, velocity, quality, docs, none — it's new)
9. **Is this a prototype or production project?** (prototype = move fast, skip ceremony; production = full gates, thorough reviews)

Skip questions you can answer by reading the codebase. If the project directory is available, explore it first.

After the interview, create `.agent/.mode` with the answer (`prototype` or `production`). This file controls cognitive mode for all Foundation skills — prototype mode relaxes ceremony, production mode enforces full gates.

### Intake Step 2 — Risk Profile

Based on answers, classify the project:

| Profile | Criteria | Recommended set |
|---------|----------|-----------------|
| **Lightweight** | No auth, no sensitive data, solo | review-code, test-runner, grill-me, aar |
| **Standard** | Auth or sensitive data, or team, or existing test suite | + implement, all agents, review-tests, review-security, validate-gates |
| **Full governance** | Auth + sensitive data + team + CI/CD | Everything including foundation-sync, write-a-skill, pre-commit hooks |

### Intake Step 2.5 — Path Collision Detection

Before recommending, check for files that exist in **both** the project's local tree and `.foundation/`. For each collision:

1. Scan for overlapping paths: check if the project has its own `.agent/.ai/`, `docs/CODING_STANDARDS.md`, `docs/SECURITY_STANDARDS.md`, etc. that would shadow the Foundation versions under `.foundation/`.
2. For each collision, ask the user: "You have a local `docs/CODING_STANDARDS.md` and Foundation provides one at `.foundation/docs/CODING_STANDARDS.md`. Do you want to **keep yours** (Foundation's version is ignored), **use Foundation's** (rename/remove yours), or **merge** (review both and combine)?"
3. If the user keeps theirs, note that Foundation skills will use the local version (path resolution prefers local). No further action needed.
4. If no collisions are found, skip this step silently.

### Intake Step 3 — Recommend

Output a tailored recommendation:

```markdown
## Foundation_template Intake — [Project Name]

**Risk profile:** Lightweight / Standard / Full governance

### Recommended skills
- [ ] skill-name — why it's relevant to this project

### Recommended agents
- [ ] @Role — why this role matters here

### Anti-patterns to watch
- [ ] Anti-XXX — why it applies to this project's domain

### Not recommended (yet)
- skill-name — why it's not needed now, when to reconsider

### Install

#### Claude Code
# Symlink wrappers into Claude Code's skill directory:
mkdir -p .claude/skills
ln -s ../../.foundation/.claude/skills/{skill} .claude/skills/{skill}

#### Cursor
# Create rules pointing to canonical skills:
mkdir -p .cursor/rules
# For each skill, create a .cursor/rules/{skill}.md that sources
# .foundation/.agent/skills/{skill}/SKILL.md

#### Other IDEs
# Canonical skills are IDE-agnostic at .foundation/.agent/skills/
# Point your IDE's custom rules/agents at those files.
# See .foundation/CATALOG.md for the full skill list.

#### All IDEs — optional local overrides
# Copy Foundation docs locally only if you need to customize them:
# cp .foundation/.agent/TOOLCHAIN_DISCOVERY.md .agent/
# Skills use path resolution: local files override .foundation/ versions.
```

After the recommendation, ask which IDE the user is using (Claude Code, Cursor, or other) and generate the appropriate wrappers. Offer: "Want me to set these up now?"

## Output

Interactive Q&A session (Steps 0–3) concluding with the synthesis table (Step 4), or intake recommendation (Intake Steps 1–3).

## References

- `docs/SECURITY_STANDARDS.md` — risk classification for decision assessment
- `docs/CODING_STANDARDS.md` — coding patterns and anti-patterns to check against
- `docs/agent/requirements/FR_CATALOG.md` — requirements catalog for traceability
