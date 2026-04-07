---
name: review-tests
description: "Test quality and coverage review — coverage metrics, gap analysis, flaky test identification, test quality audit, registry completeness. Use for periodic test health assessments."
argument-hint: "[sub-agent]"
---

# Test Quality Review

You are the **@QA Test Auditor** for this project. Assess the overall health of the test suite: coverage metrics, quality compliance, registry completeness, flaky test patterns, and gap analysis.

> **Scope distinction:** This skill **reviews** test quality across the project. For **running** tests, triaging failures, or driving coverage increase, use `test-runner` instead.

## Step 0 — Determine mode

- **Default mode:** Full interactive output with findings and recommendations.
- **Sub-agent mode** (argument contains `sub-agent`): Output structured JSON only (see Output section).

## Step 0.5 — Toolchain Discovery (Mandatory)

Follow `.agent/TOOLCHAIN_DISCOVERY.md` to detect available coverage tools, test runners, and registry generators. Adapt all commands in this skill to the project's actual toolchain. If a tool is unavailable, WARN and mark that section's findings as "skipped — tool not available."

## Step 1 — Load context

Read these files:

- `docs/TESTING_STANDARDS.md` — test quality rules, coverage requirements, anti-patterns
- `.agent/.ai/QA_VALIDATOR.md` — @QA mandates
- `docs/CODING_STANDARDS.md` — Anti-002 (happy-path-only), Anti-011 (dropped planned tests)
- `docs/agent/quality/TEST_REGISTRY.md` — test inventory
- `.agent/workflows/quality-gates.md` — pre-merge gates §8 (testing verification)

## Step 2 — Coverage metrics

Run coverage report:

```bash
npm run test:unit:cov 2>&1 | tail -20
```

Record current metrics:
- **Lines:** X%
- **Statements:** X%
- **Functions:** X%
- **Branches:** X%

Compare against thresholds:
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Lines | >= 80% | X% | PASS/FAIL |
| Statements | >= 80% | X% | PASS/FAIL |
| Functions | >= 60% | X% | PASS/FAIL |
| Branches | >= 40% | X% | PASS/FAIL |

## Step 3 — Coverage gap analysis

Identify the least-covered modules:

```bash
npx nyc -r text npm run -s test:unit 2>&1 | sort -t'|' -k2 -n | head -20
```

For each module under threshold:
- Classify as critical path (auth, API routes, scoring) or non-critical
- Critical paths below threshold = HIGH finding
- Non-critical paths below threshold = MEDIUM finding

## Step 4 — Test registry completeness

```bash
npm run generate-registry 2>&1
```

Cross-reference:
- [ ] Every test file in `tests/` has a TEST_REGISTRY entry
- [ ] Every entry has a valid FR-XXX or NONE requirement link
- [ ] No orphaned registry entries (test file deleted but entry remains)
- [ ] Registry generation produces no warnings

## Step 5 — Test quality rules audit

Check compliance with `docs/TESTING_STANDARDS.md`:

1. **TQR-001 Observable assertions:** Tests assert observable behavior (response status/body, DB state), not mock internals
2. **TQR-002 Environment parity:** Tests can run against both SQLite and PostgreSQL
3. **TQR-003 Fixture isolation:** Each test creates its own data; no shared mutable state
4. **TQR-004 Negative paths:** Critical endpoints have negative-path tests (401, 403, 404, 422)
5. **TQR-005 Null/empty user:** At least one test per domain uses a minimal/new user
6. **TQR-006 Mutation verification:** CUD operations verify the side effect occurred
7. **TQR-007 No sleep:** Tests use `waitFor*` patterns, not fixed `setTimeout`/`sleep`

Sample 5-10 test files and audit against these rules.

## Step 6 — Flaky test identification

```bash
# Check for known flaky patterns
grep -rn "test\.skip\|test\.todo\|\.skip(" tests/ --include="*.js" --include="*.ts" | head -20

# Check for timing-dependent patterns
grep -rn "setTimeout\|sleep\|\.slow()" tests/ --include="*.js" --include="*.ts" | head -20

# Check for order-dependent patterns (shared state)
grep -rn "beforeAll.*insert\|beforeAll.*create" tests/ --include="*.js" --include="*.ts" | head -10
```

## Step 7 — Anti-pattern sweep

Check for documented test anti-patterns:
- **Anti-002 (happy-path-only):** Endpoints with only 200/201 tests, no error paths
- **Anti-011 (dropped planned tests):** Tests promised in Board plans but never implemented

```bash
# Find API routes and check for corresponding negative tests
grep -rn "router\.\(get\|post\|put\|patch\|delete\)" server/routes/api/ --include="*.js" | wc -l
grep -rn "expect.*status.*4\|expect.*status.*5" tests/ --include="*.js" | wc -l
```

## Output

### Default mode

```markdown
## Test Quality Review

**Date:** YYYY-MM-DD
**Overall Health:** [CRITICAL|HIGH|MEDIUM|LOW|CLEAN]

### Coverage Summary
| Metric | Target | Current | Delta | Status |
|--------|--------|---------|-------|--------|

### Gap Analysis
| Module | Coverage | Critical Path | Priority |
|--------|----------|---------------|----------|

### TQR Compliance
| Rule | Compliant | Sample Violations |
|------|-----------|-------------------|

### Flaky Tests
| Test | Pattern | Recommendation |
|------|---------|----------------|

### Registry Health
- Total entries: X
- Missing entries: X
- Orphaned entries: X

### Findings
**[SEVERITY]** Description — Rule: TQR-XXX / Anti-XXX / Gate §N
> Details and recommended fix

### Verdict
One of: CLEAN (all green), PASS (LOW/MEDIUM only), FAIL (HIGH/CRITICAL present)
```

### Sub-agent mode (JSON)

When invoked with `sub-agent` argument, output ONLY this JSON:

```json
{
  "domain": "tests",
  "timestamp": "YYYY-MM-DDTHH:MM:SSZ",
  "overall_health": "CRITICAL|HIGH|MEDIUM|LOW|CLEAN",
  "coverage": {
    "lines": { "target": 80, "current": 0, "status": "PASS|FAIL" },
    "statements": { "target": 80, "current": 0, "status": "PASS|FAIL" },
    "functions": { "target": 60, "current": 0, "status": "PASS|FAIL" },
    "branches": { "target": 40, "current": 0, "status": "PASS|FAIL" }
  },
  "gap_analysis": [
    {
      "module": "path/to/module.js",
      "coverage_pct": 0,
      "critical_path": true,
      "priority": "HIGH|MEDIUM|LOW"
    }
  ],
  "tqr_compliance": {
    "TQR-001": { "compliant": true, "violations": [] },
    "TQR-002": { "compliant": true, "violations": [] },
    "TQR-003": { "compliant": true, "violations": [] },
    "TQR-004": { "compliant": true, "violations": [] },
    "TQR-005": { "compliant": true, "violations": [] },
    "TQR-006": { "compliant": true, "violations": [] },
    "TQR-007": { "compliant": true, "violations": [] }
  },
  "registry": {
    "total_entries": 0,
    "missing_entries": 0,
    "orphaned_entries": 0
  },
  "flaky_tests": [],
  "findings": [
    {
      "id": "TEST-AUDIT-001",
      "severity": "CRITICAL|HIGH|MEDIUM|LOW",
      "category": "coverage|quality|registry|flaky|anti-pattern",
      "title": "Short description",
      "file": "path/to/file.js",
      "description": "Detailed description",
      "fix": "Recommended fix",
      "auto_fixable": false,
      "existing_jira": null
    }
  ],
  "verdict": "CLEAN|PASS|FAIL"
}
```

## References

- `docs/TESTING_STANDARDS.md` — test quality rules, coverage, anti-patterns
- `.agent/.ai/QA_VALIDATOR.md` — @QA mandates
- `docs/CODING_STANDARDS.md` — Anti-002, Anti-011
- `docs/agent/quality/TEST_REGISTRY.md` — test inventory
- `.agent/workflows/quality-gates.md` — §8 testing verification
- `.agent/skills/test-runner/SKILL.md` — test execution (complementary skill)
