# Software Development Lifecycle (SDLC)

<!-- TODO: Fork projects — customize workflow stages for your team -->

## §1 — Issue Intake
- Ticket arrives (Jira, GitHub Issue, or ad-hoc request).
- ARCH triages: assigns risk tier per `docs/SECURITY_STANDARDS.md`, identifies affected files.

## §2 — Planning
- ARCH produces a plan: scope, files, risks, test strategy.
- For MEDIUM+ risk: plan is reviewed before implementation begins.

## §3 — Implementation
- OPS (Developer) implements per ARCH plan.
- Follow `docs/CODING_STANDARDS.md`.
- TDD: write failing test first, then code to pass it.

## §4 — Review Gates

### §4.1 — Progressive Role Activation
Roles activate per BOOTSTRAP §1.2 — only when needed, not upfront.

### §4.2 — Whitelist / SEC Bypass
If the change matches a pattern in `docs/agent/technical/LOW_RISK_WHITELIST.md`, ARCH self-authorizes and skips SEC. Only "Slow Lane" work (auth, payments, core logic) requires SEC review.

### §4.3 — Test-Informed Planning
Tests are part of the plan, not an afterthought. ARCH specifies expected test cases; QA validates coverage.

### §4.4 — Quality Gates
All applicable gates from `.agent/workflows/quality-gates.md` must pass before merge.

### §4.5 — Security Review
HIGH/CRITICAL risk tasks require SEC sign-off with the Human-in-the-Loop template from `docs/SECURITY_STANDARDS.md`.

### §4.6 — Quality Gates (Detail)
See `.agent/workflows/quality-gates.md` §1–§25 for the full pre-merge checklist.

## §5 — Documentation
- LIB audits doc impact: `CONFIGURATION_REGISTER.md`, `API_Reference.md`, `TEST_REGISTRY.md`.
- Flash Lessons recorded if implementation revealed non-obvious patterns.

## §6 — Delivery
- QA grants "Green" status.
- PR created with structured description.
- Merge to main after approval.

## §7 — Post-Delivery
- AAR (After Action Review) for non-trivial work.
- Memory updated if lessons apply to future work.
