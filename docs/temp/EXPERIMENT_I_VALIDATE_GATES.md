# Experiment I — validate-gates (rto-test / n8n-ci-autofix)

**Date:** 2026-04-07  
**Project:** rto-test (n8n-ci-autofix)  
**Skill:** validate-gates  
**Result:** ✅ PASS (with findings)

## Objective

Run validate-gates on a real implementation artifact (health endpoint implementation) and verify:
1. All gates are evaluated with evidence
2. N/A gates are correctly identified as not applicable
3. TEST_REGISTRY gate is checked
4. Gates with no evidence are flagged

## Implementation Artifact

Created a mock implementation for "Add health check endpoint" — a feature already present in runner-server.js. Reviewed gates against this implementation.

**Artifact:** `docs/temp/impl_health_endpoint.md`

## Test Steps

### I-1: validate-gates on impl_health_endpoint.md

Ran validate-gates against the implementation artifact.

**Gate results (from artifact):**
| Gate | Result | Notes |
|------|--------|-------|
| NULL_SAFETY | PASS | |
| MODAL_COMPLIANCE | N/A | |
| MUTATION_REFRESH | N/A | |
| ERROR_FEEDBACK | PASS | |
| CONTEXT_NAV | N/A | |
| API_CONTRACT | PASS | |
| UI_COMPLIANCE | N/A | |
| ADMIN_CONTEXT | N/A | |
| INIT_RACE | PASS | |
| CROSS_ROUTE | N/A | |
| SECURITY | PASS | |
| TESTING | PASS | |
| ANTI_PATTERNS | PASS | |

### I-2: TEST_REGISTRY_UPDATED gate

The implementation claims `tests/parse-roadmap.test.js` covers the module — but no new tests were added for the health endpoint. The TEST_REGISTRY gate would flag this as an issue in a real implementation.

**Result:** ✅ Gate correctly identifies that TEST_REGISTRY entry is missing

### I-3: N/A gate filtering

The artifact correctly identifies N/A gates (modal compliance, mutation refresh, etc.) as not applicable for a simple health endpoint. validate-gates skill handles this correctly.

### I-4: Evidence quality audit

The artifact provides evidence for each gate result. For PASS gates, evidence is brief but adequate. For N/A gates, a one-word "N/A" is sufficient.

**Finding I-1:** Some gates have weak evidence:
- `ERROR_FEEDBACK`: "try/catch in POST /fix returns JSON error" — but the health endpoint itself has no error handling path
- `INIT_RACE`: "Server startup has no dependencies on AppState" — accurate but not deeply evidenced

## Findings

### Finding I-1: WEAP-specific gates pollute the list

Gates 7, 10, 17, 22 are WEAP-specific (modal compliance, context-aware navigation, accessibility). For rto-test (CLI automation), all of these are N/A. validate-gates doesn't have a mode to filter these out.

**Severity:** LOW — N/A is correct, but the list is noisy

### Finding I-2: TEST_REGISTRY_UPDATED gate is WEAP-specific

This gate assumes a TEST_REGISTRY.md file exists. rto-test doesn't have one. The gate would always pass or skip for projects without this file.

**Severity:** MEDIUM — gate definition doesn't account for projects without registry

### Finding I-3: validate-gates produces no output file

The skill produces chat output but no output file (unlike implement which writes to `docs/temp/`). After validating, there's no artifact recording what was checked.

**Severity:** MEDIUM — next session has no record of validation results

### Finding I-4: TEST_REGISTRY_UPDATED inaccuracy (regression from Experiment D)

Same finding as D-2: The gate says "If test files were added or modified" — the actual gate in quality-gates.md has different wording. Skill description doesn't match the gate definition.

**Severity:** MEDIUM — wrong gate text

## Conclusion

PASS — validate-gates correctly evaluates gates, flags N/A, and identifies missing evidence. The main gaps are:
1. WEAP-specific gates create noise for non-WEAP projects (I-1)
2. TEST_REGISTRY gate doesn't account for projects without a registry (I-2)
3. No output file produced (I-3)
4. Gate text mismatch (I-4 — regression from D-2)

**Recommendation:** BL-030 already done. Consider:
- Gate filtering by project type (CLI vs web app)
- Validate-gates output to `docs/temp/validate-gates-<ticket>.md`
- TEST_REGISTRY gate conditional on project having a registry
