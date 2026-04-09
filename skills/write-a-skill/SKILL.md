---
name: write-a-skill
description: "Scaffold a new canonical + wrapper skill following project conventions. Use when creating a new skill or when user says 'write a skill'."
argument-hint: "[skill-name or description of what the skill should do]"
---

# Write a Skill

You are a **skill author**. Your job is to scaffold a new skill that follows this project's two-layer convention: a canonical implementation in `.agent/skills/` and an IDE wrapper in `.claude/skills/`.

## Path Resolution (Fork Support)

This skill references files under `.agent/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/skills/`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/skills/`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

**Important:** In fork projects, new skills go in the fork's own `.agent/skills/` (NOT `.foundation/.agent/skills/`). The `.foundation/` prefix is only for reading Foundation's canonical files.

## When to Use

- Creating a new skill for the project
- User describes a repeatable workflow they want to codify
- User says "write a skill" or "make a skill"

## Step 0 — Gather Requirements

Ask the user (or infer from the argument):

1. **Name** — lowercase kebab-case identifier (e.g., `review-perf`)
2. **Purpose** — what does this skill do? One sentence.
3. **Trigger** — when should someone use it? ("Use when...")
4. **Arguments** — what input does it expect? (Jira key, file path, description, none)
5. **Tools needed** — does it read only, or does it edit/write/run commands?

## Step 1 — Check for Overlap

Before creating, scan for existing skills that already cover this:

- Read `.agent/README.md` skills table for the full inventory
- Grep `.agent/skills/*/SKILL.md` descriptions for related keywords
- If overlap exists, tell the user and ask whether to extend the existing skill or proceed with a new one

## Step 2 — Write Canonical Skill

Create `.agent/skills/<name>/SKILL.md` following the template at `.agent/templates/SKILL.template.md`:

```
---
name: <name>
description: "<purpose>. Use when <trigger>."
argument-hint: "<expected arguments>"
---
```

### Structure guidelines

- **When to Use** — 2-4 bullet points describing trigger conditions
- **Steps** — numbered steps (Step 0, Step 1, ...) with clear actions
- **Output** — describe the expected output format (table, summary, specs, etc.)
- **References** — cite authority docs the skill depends on

### Quality checks

- Each step should be actionable, not vague ("Analyze X" → "Read `path/to/file` and check for Y")
- Reference real project paths and patterns, not generic advice
- Keep it under 150 lines — if longer, the skill is doing too much; split it

## Step 3 — Write Claude Code Wrapper

Create `.claude/skills/<name>/SKILL.md`:

```
---
name: <name>
description: "<shorter description>. Use when <trigger>."
argument-hint: "<expected arguments>"
allowed-tools: <comma-separated list>
---

# <Skill Title>

Canonical skill: **`.agent/skills/<name>/SKILL.md`**

<1-2 sentence summary of what the skill does.>
```

### allowed-tools guidance

- **Read-only skills** (reviews, audits, analysis): `Read, Grep, Glob`
- **Git-aware skills** (reviews with history): add `Bash(git log:*), Bash(git diff:*)`
- **Implementation skills** (write code): add `Edit, Write, Bash(npm run lint), Bash(npm run test:unit)`
- **Jira-aware skills**: MCP tools are granted globally; no need to list them

## Step 4 — Update README Index

Edit `.agent/README.md`:

1. Increment the skill count in `## Skills (N Canonical)` and the directory structure comment
2. Add a new row to the skills table: `| \`<name>\` | <purpose> | — |`
3. Place the row alphabetically in the table

## Output

- Two new files created (canonical + wrapper)
- README updated with new skill entry
- Summary of what was created

## References

- `.agent/templates/SKILL.template.md` — canonical skill template
- `.agent/README.md` — skill index to update
- `.claude/skills/review-code/SKILL.md` — wrapper pattern reference
