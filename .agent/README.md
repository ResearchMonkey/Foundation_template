# Agent Directory

<!-- TODO: Fork projects — update this index as you add or remove skills -->

## Overview

This directory contains the AI agent framework: role personas, skills, workflows, and memory files.

## Structure

```
.agent/
├── .ai/                    # Role personas and memory
│   ├── AGENTS.md           # Role definitions and authority
│   ├── ARCHITECT.md        # @ARCH persona
│   ├── BOOTSTRAP.md        # Board activation sequence
│   ├── Developer.md        # @DEV persona
│   ├── DevOps.md           # @OPS persona
│   ├── Librarian.md        # @LIB persona
│   ├── MEMORY.md           # Iron Laws and domain index
│   ├── MEMORY_ANTI_PATTERNS.md
│   ├── MEMORY_OPS.md
│   ├── MEMORY_SECURITY.md
│   ├── MEMORY_UI.md
│   ├── QA.md               # @QA persona + validation rules
│   ├── RISK_LEVELS.md      # → redirect to docs/SECURITY_STANDARDS.md
│   ├── Security.md         # @SEC persona
│   └── TEST_QUALITY_RULES.md  # → redirect to docs/TESTING_STANDARDS.md
├── skills/                 # Canonical skill definitions
│   ├── aar/                # After Action Review
│   ├── board-meeting/      # Multi-perspective review
│   ├── developer/          # Dev implementation
│   ├── devops/             # Ops / deployment
│   ├── foundation-sync/    # Template sync
│   ├── grill-me/           # Ticket interrogation
│   ├── implement/          # Unified Board processor
│   ├── lib/                # Librarian doc audit
│   ├── librarian/          # Librarian persona skill
│   ├── qa/                 # QA validation
│   ├── review-code/        # Code review
│   ├── review-security/    # Security sweep
│   ├── review-tests/       # Test quality review
│   ├── security/           # Security persona skill
│   ├── test-runner/        # Test execution
│   ├── validate-gates/     # Gate validation
│   └── write-a-skill/      # Skill scaffolding
├── templates/              # Scaffolding templates
│   └── SKILL.template.md
├── workflows/              # Process definitions
│   └── quality-gates.md
└── README.md               # This file
```

## Skills Index

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `aar` | After Action Review | Post-session, hotfix, epic close |
| `board-meeting` | Multi-perspective Board review | "board meeting", pitch |
| `foundation-sync` | Bidirectional template sync | "foundation-sync pull/push" |
| `grill-me` | Ticket interrogation | "grill", "review ticket" |
| `implement` | Unified Board issue processor | Jira key, URL, or JSON |
| `lib` | Librarian proactive doc audit | Auto — post-implement |
| `review-code` | Code review with impact analysis | PR review, branch diff |
| `review-security` | Full security sweep | Periodic security audit |
| `review-tests` | Test quality and coverage review | Periodic test health |
| `test-runner` | Run, triage, improve tests | Test execution, CI fails |
| `validate-gates` | Quality gate validator | Post-implement |
| `write-a-skill` | Scaffold a new skill | "write a skill" |

## Standards Docs (User-Owned)

Agent personas define **authority and workflow**. The rules they follow live in `docs/`:

| Standards Doc | Consumer Agent | What It Controls |
|--------------|----------------|------------------|
| `docs/CODING_STANDARDS.md` | @Developer | Implementation checklist, anti-patterns, quality scoring |
| `docs/TESTING_STANDARDS.md` | @QA | Pre-merge review, test strategy, coverage requirements |
| `docs/SECURITY_STANDARDS.md` | @Security | Risk classification, security checklists, approval policy |
| `docs/ARCHITECTURE_STANDARDS.md` | @Architect | Planning checklist, design doc requirements, file organization |
| `docs/OPS_STANDARDS.md` | @DevOps | Failure classification, deployment rules, CI/CD conventions |
| `docs/DOCUMENTATION_STANDARDS.md` | @Librarian | SSOT rules, doc lifecycle, doc-code sync |

To change a rule, edit the standards doc — agents pick it up automatically.
