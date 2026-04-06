# Skill & Agent Catalog

Pick what your project needs. Skills marked **Standalone** work independently. Others require prerequisites.

## Workflow Skills

| Skill | Purpose | Standalone | Prerequisites |
|-------|---------|:----------:|---------------|
| **implement** | Unified board issue processor (ARCH → SEC → QA → OPS → LIB) | No | All agent roles, review-code, review-security, review-tests, test-runner, grill-me |
| **foundation-sync** | Bidirectional sync with Foundation_template | Partial | grill-me (validation gate) |
| **write-a-skill** | Scaffold new canonical + wrapper skill | Yes | None |

## Review & Analysis Skills

| Skill | Purpose | Standalone | Prerequisites |
|-------|---------|:----------:|---------------|
| **review-code** | Code review with inline findings against quality gates | Yes | None |
| **review-security** | Full-project security sweep (OWASP, CVE, auth, secrets) | Yes | None |
| **review-tests** | Test quality, coverage metrics, gap analysis | Yes | None |
| **test-runner** | Execute tests, triage failures, drive coverage | Yes | None |
| **grill-me** | Design interrogation and stress testing | Yes | None |
| **validate-gates** | Second-pass audit of implement's quality gate output | Yes | Requires implement output to validate |
| **aar** | After Action Review — catches dropped tests, missing docs, process gaps | Yes | None |

## Agent Roles

Roles activated within `implement`. Pull these if you're using the full board.

| Role | Purpose | Works with |
|------|---------|------------|
| **Developer** | Feature implementation, TDD flow | QA, Security, DevOps |
| **QA** | Testing strategy, quality gate enforcement | Developer, review-tests, test-runner |
| **Security** | Risk classification, auth review, secrets scanning | Developer, review-security |
| **Librarian** | Doc-code sync, SSOT enforcement, memory health | All (post-implementation audit) |
| **DevOps** | Terminal execution, CI/CD, deployment safety | Developer, test-runner |

## Dependency Graph

```
implement (master orchestrator)
├── All 5 agent roles
├── review-code
├── review-security
├── review-tests
├── test-runner
└── grill-me (complex decisions)

validate-gates (post-implement verifier)
└── implement output (quality_gates JSON)

foundation-sync
└── grill-me (validation gate)

All others: standalone
```

## Recommended Starting Sets

**Minimal (solo project, no Jira):**
- review-code, test-runner, grill-me, validate-gates, aar

**Standard (project with issue tracking):**
- implement, all agent roles, all review skills, test-runner, grill-me

**Full:**
- Everything, including foundation-sync and write-a-skill
