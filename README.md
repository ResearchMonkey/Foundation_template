# Foundation_template

A portable governance framework for AI-managed software development. It codifies agent roles, quality skills, and anti-patterns into a library that projects cherry-pick from based on their needs.

**Target audience:** Solo developers using an AI coding agent (Claude Code, Cursor, Codex, or similar) as their primary developer. If you ship code through an AI agent and want structured quality gates without a large team, this is for you.

This is not an application template — there's no app code here. It's the well your projects draw from.

## Core Concepts

- **Board of Directors** — 5 agent roles (Developer, QA, Security, Librarian, DevOps) with constitutional mandates, veto powers, and a resolution sequence (ARCH → SEC → QA → OPS → LIB)
- **Skills** — reusable workflows that execute across any tech stack. Skills detect available tooling at runtime via `.agent/TOOLCHAIN_DISCOVERY.md`
- **Anti-patterns** — 15 portable patterns codified from real production failures
- **Bidirectional sync** — projects pull skills from here and push generalized lessons back

## What's Here

```
.agent/.ai/              — Board constitution and agent personas (5 roles)
.agent/skills/           — 11 canonical skills + 5 agent roles + shared lib
.agent/hooks/            — Generic pre-commit hook template
.agent/TOOLCHAIN_DISCOVERY.md — Runtime toolchain detection rules
.claude/skills/          — Claude Code wrappers (one example integration; see note below)
skills/contributions/    — Lessons pushed back from fork projects (legacy; new forks use git subtree)
CATALOG.md               — Skill dependency map and recommended starting sets
BACKLOG.md               — Open items from project grilling sessions
projects.json            — Registry of known forks
SYNC_LOG.md              — Sync history
```

### AI tool compatibility

The canonical skills in `.agent/skills/` are tool-agnostic — they contain markdown prompts and logic that any AI coding agent can execute. The `.claude/skills/` directory contains thin wrappers for Claude Code as a reference integration. If you use a different tool (Cursor, Codex, Windsurf, etc.), write equivalent wrappers that point to the same canonical skills. The wrapper pattern is simple: each wrapper just sources the canonical skill and passes context.

## Skills

See [CATALOG.md](CATALOG.md) for the full dependency map and recommended sets.

| Skill | Purpose | Standalone |
|-------|---------|:----------:|
| **implement** | Unified board issue processor (full ARCH → SEC → QA → OPS → LIB cycle) | No |
| **validate-gates** | Second-pass audit of implement's quality gate output | Yes |
| **aar** | After Action Review — catches dropped tests, missing docs, process gaps | Yes |
| **board-meeting** | Multi-persona brainstorm and interrogation | Yes |
| **review-code** | Code review with inline findings against quality gates | Yes |
| **review-security** | Full-project security sweep (OWASP, CVE, auth, secrets) | Yes |
| **review-tests** | Test quality, coverage metrics, gap analysis | Yes |
| **test-runner** | Execute tests, triage failures, drive coverage | Yes |
| **grill-me** | Design interrogation + project intake for new forks | Yes |
| **write-a-skill** | Scaffold new canonical + wrapper skill | Yes |
| **foundation-sync** | Bidirectional sync with fork projects (git subtree) | Partial |

## What This Looks Like in Practice

A typical workflow with Foundation in a fork project:

1. **You create a Jira ticket** (or describe a feature/bug in your agent chat)
2. **Run `/implement PROJ-42`** — the Board picks it up:
   - Developer designs the approach and writes code
   - Security reviews for OWASP issues and risk classification
   - QA enforces test coverage gates and runs the test suite
   - DevOps validates the build and deployment safety
   - Librarian checks that docs match the code changes
3. **Run `/validate-gates`** — a second-pass audit confirms no gates were self-reported or skipped
4. **Run `/aar`** — catches anything the Board missed: dropped tests, stale docs, process gaps

Each skill outputs structured findings. No step requires human intervention unless a CRITICAL-tier issue is flagged.

## Getting Started

**Prerequisites:** Git and an AI coding agent of your choice (Claude Code, Cursor, Codex, etc.).

### First-time setup (bootstrap)

From your project's root directory:

```bash
curl -s https://raw.githubusercontent.com/ResearchMonkey/Foundation_template/main/bootstrap.sh | bash
```

Or manually:

```bash
git remote add foundation https://github.com/ResearchMonkey/Foundation_template.git
git subtree add --prefix=.foundation foundation main
```

This pulls the full template into `.foundation/` in your project.

### Then, open your project in your AI coding agent and run the intake:

```
/grill-me intake
```

This interviews you about your project and recommends which skills, agents, and anti-patterns to activate. See [CATALOG.md](CATALOG.md) for the menu. (The `/` syntax is Claude Code; other tools may invoke skills differently.)

### Ongoing sync:

```
/foundation-sync pull    — merge upstream changes into .foundation/ (git subtree pull)
/foundation-sync push    — push .foundation/ commits to contrib/<project> branch for review
/foundation-sync status  — check sync state and divergence
```

## Sync Contract

Uses `git subtree` with prefix `.foundation/` in each fork.

| Direction | Mechanism | Scope | Conflict handling |
|-----------|-----------|-------|-------------------|
| Foundation → Fork | `git subtree pull` | Full template content in `.foundation/` | Git 3-way merge; conflicts surface for manual resolution |
| Fork → Foundation | `git subtree push` | Commits touching `.foundation/` | Pushed to `contrib/<project>` branch for review |

## Adding Your Project

1. Run `/foundation-sync init` in your project to set up the subtree
2. Add an entry to `projects.json`:

```json
{
  "name": "Your_Project",
  "url": "https://github.com/YOUR_ORG/Your_Project",
  "prefix": ".foundation",
  "remote": "foundation",
  "lastSync": "2026-04-06"
}
```

## Cognitive Mode (`.agent/.mode`)

Foundation skills operate in one of two modes:

| Mode | Behavior |
|------|----------|
| `prototype` | Move fast — relaxed ceremony, shorter reviews, skip non-critical gates |
| `production` | Full governance — all gates enforced, thorough reviews, complete documentation |

The mode is set in `.agent/.mode` (a single-line file containing `prototype` or `production`). If the file is missing, skills default to **prototype**.

**Setting mode:**
- `grill-me intake` asks about mode and creates the file automatically
- Or create it manually: `echo "production" > .agent/.mode`
- Change it any time — the switch is immediate

## Pre-commit Hook (Recommended)

The template includes a generic pre-commit hook at `.agent/hooks/pre-commit` with secrets detection, TODO-without-ticket warnings, and skipped-test warnings.

**Security note:** Without this hook, there is no automated check preventing secrets (API keys, tokens, credentials) from being committed. Install it early:

```bash
cp .agent/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## CI/CD (Optional)

This template does not ship with a CI pipeline — forks define their own based on their stack. If you want automated checks on PRs, consider a GitHub Actions workflow that runs:

- Markdown linting (e.g., `markdownlint`)
- Secrets scanning (e.g., `trufflehog`, `gitleaks`)
- Portability check (grep for project-specific references in `.foundation/`)

## Known Forks

See `projects.json` for registered forks.
