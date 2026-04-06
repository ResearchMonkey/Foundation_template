# Foundation_template

Agent/skill/lesson foundation for new projects. Bidirectional sync with forks via `foundation-sync`.

## What's Here

```
.claude/skills/      — Canonical skills (Claude Code variant)
.agent/skills/       — Canonical skills (OpenClaw agent variant)
skills/              — Sync skill and contributed adaptations
skills/contributions/ — Fork contributions pushed back here
projects.json        — Registry of known forks
.agent/.ai/MEMORY_ANTI_PATTERNS.md — Generalized anti-patterns
```

## Canonical Skills

- **implement** — Unified Board issue processor
- **review-code** — Code review with impact analysis
- **review-security** — Full-project security sweep
- **review-tests** — Test quality and coverage review
- **test-runner** — Test execution and triage
- **write-a-skill** — Skill authoring
- **board-meeting** — Multi-persona brainstorm and interrogation
- **grill-me** — Design interrogation
- **foundation-sync** — Bidirectional sync engine

## Sync Contract

| Direction | Scope | Quality Gate |
|-----------|-------|--------------|
| Foundation → Fork | Skills, agents, anti-patterns | grill-me on copy step |
| Fork → Foundation | `contributions/` only | grill-me before push |

Only `contributions/` is ever read back from a fork. Everything else is project-local.

## Quick Start

```bash
# Pull canonical skills into your project
EDI, run foundation-sync pull

# Push contributions back
EDI, run foundation-sync push

# Check sync status
EDI, run foundation-sync status
```

## Adding Your Project to projects.json

```json
{
  "name": "Your_Project",
  "url": "https://github.com/YOUR_ORG/Your_Project",
  "lastSync": "2026-04-06"
}
```
