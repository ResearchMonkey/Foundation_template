# Foundation_template

A portable governance framework for AI-managed software development. It codifies agent roles, quality skills, and anti-patterns into a library that projects cherry-pick from based on their needs.

This is not an application template — there's no app code here. It's the well your projects draw from.

## Core Concepts

- **Board of Directors** — 5 agent roles (Developer, QA, Security, Librarian, DevOps) with constitutional mandates, veto powers, and a resolution sequence (ARCH → SEC → QA → OPS → LIB)
- **Skills** — reusable workflows that execute across any tech stack. Skills detect available tooling at runtime via `.agent/TOOLCHAIN_DISCOVERY.md`
- **Anti-patterns** — 14 portable patterns codified from real production failures
- **Bidirectional sync** — projects pull skills from here and push generalized lessons back

## What's Here

```
.agent/.ai/              — Board constitution and agent personas (5 roles)
.agent/skills/           — Canonical skill implementations (14 skills)
.agent/hooks/            — Generic pre-commit hook template
.agent/TOOLCHAIN_DISCOVERY.md — Runtime toolchain detection rules
.claude/skills/          — Claude Code wrappers (thin pointers to canonical skills)
skills/contributions/    — Lessons pushed back from fork projects (legacy; new forks use git subtree)
CATALOG.md               — Skill dependency map and recommended starting sets
BACKLOG.md               — Open items from project grilling sessions
projects.json            — Registry of known forks
SYNC_LOG.md              — Sync history
```

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

## Getting Started

### New project? Start here:

```
/grill-me intake
```

This interviews you about your project and recommends which skills, agents, and anti-patterns to pull. See [CATALOG.md](CATALOG.md) for the menu.

### Existing project? Sync:

```
/foundation-sync init    — first-time setup (adds git subtree remote + .foundation/ prefix)
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

## Known Forks

- **Weapons_Lore** — original upstream contributor; seeded this template
