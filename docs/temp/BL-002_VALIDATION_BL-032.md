# BL-002 Validation: project_type End-to-End (BL-032 Criterion 5)

**Date:** 2026-04-08
**Test repo:** rto-test (n8n-ci-autofix) — automation project
**Validating:** BL-032 criterion 5 — project_type tagging works end-to-end

## Test Steps

### Step 1 — Pull latest Foundation_template
```
cd rto-test
git fetch foundation main
git subtree pull --prefix=.foundation foundation main
```

**Result:** ✅ Pulled successfully. Latest anti-pattern tags, quality gates, and intake questions available.

### Step 2 — Verify anti-pattern project_type tags
```
grep "Anti-00" .foundation/.agent/.ai/MEMORY_ANTI_PATTERNS.md | grep '\['
```

**Result:** ✅ All 15 anti-patterns tagged. Examples:
- Anti-001 `[all]` — Ghost Features
- Anti-003 `[web-app, fullstack]` — Silent Mutations
- Anti-004 `[web-app, fullstack]` — Inline Modals
- Anti-005 `[all]` — Null-Blind Rendering
- Anti-007 `[web-app, fullstack, tui]` — Context-Blind Navigation
- Anti-014 `[all]` (especially relevant for `cli`, `automation`) — Batch Collapse

For n8n-ci-autofix (automation type), the most relevant anti-patterns are:
- Anti-005 `[all]` — Null-Blind Rendering
- Anti-006 `[all]` — Swallowed Errors
- Anti-010 `[web-app, fullstack, cli, library, automation]` — Invisible API Changes
- Anti-011 `[all]` — Dropped Planned Tests
- Anti-012 `[all]` — Retry-Masked Failures
- Anti-013 `[all]` — Environment-Blind Tests
- Anti-014 `[all]` (especially automation) — Batch Collapse
- Anti-015 `[all]` — Namespace-Blind References

Modal-specific patterns (Anti-003, Anti-004, Anti-007, Anti-009) correctly tagged as N/A for automation.

### Step 3 — Verify quality gate project_type tags
```
grep "^## §" .foundation/.agent/workflows/quality-gates.md
```

**Result:** ✅ All 25 gates tagged. Universal gates (§1-6, §8, §11-16, §18-21, §24-25) tagged `[all]`. Type-specific gates correctly tagged:
- §7 Mutation Refresh `[web-app, fullstack, tui]`
- §9 API Contract Match `[web-app, fullstack, cli, library, automation]`
- §10 Context-Aware Navigation `[web-app, fullstack, tui]`
- §17 Modal Compliance `[web-app, fullstack]`
- §22 Accessibility `[web-app, fullstack]`
- §23 Performance `[web-app, fullstack, cli, automation]`

For n8n-ci-autofix (automation type, no UI, no browser):
- §7, §10, §17, §22 correctly N/A
- §23 fires (Performance — unbounded file reads, process spawning)
- §9 fires (API Contract — CI runner makes HTTP calls to GitHub API)

Quick-reference table at top of quality-gates.md makes type filtering navigable without reading every gate.

### Step 4 — Verify intake question 9 (project_type)
```
grep -n "What kind of project" .foundation/.agent/skills/grill-me/SKILL.md
```

**Result:** ✅ Question 9 present at line 116:
> "What kind of project is this? (web-app, cli, library, automation, fullstack, tui, embedded, lambda, other — suggest based on tech stack, allow freeform)"

### Step 5 — Verify PROJECT_INTAKE.md template includes project_type
```
grep -A2 "Project type" .foundation/.agent/skills/grill-me/SKILL.md
```

**Result:** ✅ Template includes:
```markdown
**Project type:** web-app / cli / library / automation / fullstack / tui / embedded / lambda / other
```

Template also includes "Recommended Anti-patterns (by project type)" section.

### Step 6 — Verify "universal minimums" documentation
```
grep -n "ceiling\|noise reduction\|universal" .foundation/.agent/workflows/quality-gates.md
```

**Result:** ✅ Documented in quality-gates.md header:
> "Universal gates apply to all projects regardless of type. Type-specific gates are relevant for the listed types but still require judgment. Noise reduction, not ceiling."

And in MEMORY_ANTI_PATTERNS.md header:
> "Tags indicate which types the pattern is RELEVANT to — not exclusive. Type-specific tags reduce noise but do not replace judgment."

## Findings

### Finding BL-002-1: bootstrap.sh blocks piped curl (security feature)
During test setup, discovered that OpenClaw's exec approval blocks `curl URL | bash` patterns as obfuscated commands. bootstrap.sh uses this pattern for convenience install. Alternative: download bootstrap.sh first, then run it. This is a user education issue, not a Foundation_template bug.

**Severity:** LOW — documented, workaround exists

### Finding BL-002-2: foundation-sync init requires manual git fetch first
The `git subtree add` command fails on an empty repo ("ambiguous argument 'HEAD'") because there's no commit yet. bootstrap.sh handles this by fetching first then running subtree add. Manual testing required this same pattern.

**Severity:** LOW — bootstrap.sh handles this correctly

## BL-032 Criterion 5 Assessment

**CRITERION 5: BL-002 (portability test) validates project_type tagging end-to-end**

| Sub-criterion | Result |
|---------------|--------|
| Intake Q9 asks project_type | ✅ |
| PROJECT_INTAKE.md includes project_type field | ✅ |
| Anti-patterns tagged with project_type | ✅ |
| Quality gates tagged with project_type | ✅ |
| Universal minimums documented | ✅ |
| Quick-reference filter table navigable | ✅ |
| Anti-003, 004, 007, 009 correctly N/A for automation | ✅ |
| §23 Performance fires for automation (unbounded I/O) | ✅ |

**Conclusion:** BL-032 criterion 5 — **PASS**

## Recommendation

BL-032 is complete. All 5 acceptance criteria met. project_type taxonomy is implemented and validated end-to-end.
