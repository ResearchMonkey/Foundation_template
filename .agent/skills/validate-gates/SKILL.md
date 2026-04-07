---
name: validate-gates
description: "Second-pass validator that audits the quality_gates output from implement. Catches skipped gates, missing evidence, and self-reported passes without proof. Use after implement completes, or as a CI post-check."
argument-hint: "[path to implement JSON output, or 'last' to use most recent]"
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*), Bash(npm *), Bash(npx *), Bash(node *), Bash(python3 *), Bash(make *), Bash(cargo *), Bash(go *)
---

# Validate Gates — Second-Pass Quality Audit

You are an **independent auditor**. Your job is to verify that the `quality_gates` array emitted by the `implement` skill reflects reality — not just what the implementing agent claimed.

> **Core principle:** You are a DIFFERENT agent reviewing ANOTHER agent's work. Do not trust self-reported results. Verify with evidence.

## Path Resolution (Fork Support)

This skill references files under `.agent/`. In fork projects using Foundation via git subtree, these files live under `.foundation/`. For every path referenced in this skill:
1. Check the **local path** first (e.g., `.agent/TOOLCHAIN_DISCOVERY.md`)
2. If not found, check with `.foundation/` prefix (e.g., `.foundation/.agent/TOOLCHAIN_DISCOVERY.md`)
3. If both exist, prefer the **local** version (fork override)
4. If neither exists, WARN and continue — do not fail silently

## Step 0 — Load Gate Output

Determine input source:

1. **File path** → read the JSON file, extract `quality_gates` array
2. **`last`** → find the most recent implement output in the conversation or git log
3. **No argument** → search for the latest JSON block containing `quality_gates` in the conversation

If no gate output is found, STOP with: "No implement output found. Run `implement` first."

Extract: `issue_key`, `status`, `phase_reached`, `quality_gates`, `files_changed`, `branch`, `commit_sha`.

## Step 1 — Structural Check

Verify the `quality_gates` array is complete:

### Required gates (all must be present)

| Gate | Required when |
|------|--------------|
| `ARCH_ANALYSIS` | Always |
| `SEC_RISK_CLASSIFICATION` | Always (may be `skipped` if whitelisted) |
| `QA_PLAN_VALIDATION` | Always |
| `ENFORCEMENT_CHECK` | Always (may be `n/a`) |
| `LINT_CLEAN` | phase_reached >= 3 |
| `TESTS_PASS` | phase_reached >= 3 |
| `LIB_DOC_AUDIT` | phase_reached >= 3 |
| `CONSTANTS_REGISTERED` | phase_reached >= 3 |
| `API_FIELDS_DOCUMENTED` | phase_reached >= 3 |
| `TEST_REGISTRY_UPDATED` | phase_reached >= 3 |
| `ANTI_PATTERN_SWEEP` | phase_reached >= 3 |
| `JIRA_STATE_VERIFIED` | phase_reached >= 4 |
| `AAR_COMPLETE` | phase_reached >= 5 |

**Finding:** Any missing gate = **HIGH** — "Gate X omitted from output."

## Step 2 — Evidence Audit

For each gate, evaluate the `evidence` field:

### Unacceptable evidence (flag as MEDIUM)
- Empty or null
- Generic phrases: "looks good", "checked", "verified", "no issues"
- Self-referential: "I confirmed this", "agent reviewed"

### Acceptable evidence
- Command output: "npm run lint exit 0", "12/12 tests passed"
- File references: "checked API_Reference.md — no new fields"
- Grep results: "grep for UPPER_SNAKE_CASE const — 0 new matches"
- Explicit N/A with reason: "no new API fields in this change"

**Finding:** Weak evidence on a `pass` result = **MEDIUM** — "Gate X claims pass but evidence is not verifiable."

## Step 3 — Spot-Check Verification

For gates where you CAN independently verify, do so:

### LINT_CLEAN
- If `files_changed` is available, check if lint command exists (per `.agent/TOOLCHAIN_DISCOVERY.md`)
- If available, re-run lint on the branch

### TESTS_PASS
- Check git log for the commit — did CI pass?
- If test command is available, re-run tests

### CONSTANTS_REGISTERED
- Run `git diff` on the branch's changed files
- Grep for new `const` declarations with `UPPER_SNAKE_CASE`
- Cross-reference against `CONFIGURATION_REGISTER.md` (if it exists)

### TEST_REGISTRY_UPDATED
- Check if test files were added/modified in `files_changed`
- If yes, verify `TEST_REGISTRY.md` was also modified

### ANTI_PATTERN_SWEEP
- Read `.agent/.ai/MEMORY_ANTI_PATTERNS.md`
- Spot-check 2-3 relevant anti-patterns against `files_changed`

If a spot-check contradicts the claimed result: **HIGH** finding.

## Step 4 — Report

Output a validation report:

```markdown
## Gate Validation Report

**Issue:** <issue_key>
**Implement status:** <status>
**Phase reached:** <phase_reached>

### Gate Summary

| Gate | Claimed | Validated | Finding |
|------|---------|-----------|---------|
| ARCH_ANALYSIS | pass | confirmed | — |
| LINT_CLEAN | pass | CONTRADICTED | lint errors found in file.js |
| ... | ... | ... | ... |

### Findings

| # | Severity | Gate | Finding |
|---|----------|------|---------|
| 1 | HIGH | LINT_CLEAN | Claimed pass but re-run found 2 errors |
| 2 | MEDIUM | LIB_DOC_AUDIT | Evidence is "checked" — not verifiable |
| 3 | HIGH | TESTS_PASS | Gate omitted from output |

### Verdict

**PASS** — All gates verified, no HIGH findings.
**WARN** — MEDIUM findings only; implement output is usable but evidence should be strengthened.
**FAIL** — HIGH findings; implement output cannot be trusted. Re-run affected phases.
```

### Structured JSON (sub-agent mode)

If argument contains `sub-agent`, output JSON only:

```json
{
  "issue_key": "PROJ-123",
  "verdict": "pass|warn|fail",
  "gates_total": 13,
  "gates_verified": 10,
  "gates_contradicted": 1,
  "gates_weak_evidence": 2,
  "findings": [
    {"severity": "HIGH", "gate": "LINT_CLEAN", "finding": "..."}
  ]
}
```

## References

- `.agent/skills/implement/SKILL.md` — gate definitions and JSON schema
- `.agent/TOOLCHAIN_DISCOVERY.md` — command resolution for spot-checks
- `.agent/.ai/MEMORY_ANTI_PATTERNS.md` — anti-pattern list for sweep verification
