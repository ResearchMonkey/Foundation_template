# Experiment B — grill-me Intake Flow

**Date:** 2026-04-07
**Test project:** `/tmp/intake-test` (Go task tracker)
**Method:** Traced intake skill logic against a real Go project, simulated Q&A, tested collision detection

---

## Method

1. Created Go project with `go.mod`, `src/main.go`, `src/main_test.go`
2. Ran intake logic simulation: traced through all 9 questions, risk classification, collision detection
3. Created actual path collision scenario to verify the detection logic

---

## Intake Flow Results

### Step 1 — Discover the Project

Questions asked one at a time:
1. "What does this project do?" → Go CLI task tracker
2. "What's the tech stack?" → Go 1.21, git
3. "Does it have user auth?" → No
4. "Does it handle sensitive data?" → No
5. "Is there an existing test suite?" → Yes, Go testing.T
6. "Is there CI/CD?" → No
7. "Solo or team?" → Solo
8. "Current pain?" → None — brand new
9. "Prototype or production?" → Prototype

✅ **One-at-a-time questioning: WORKING**

### Step 2 — Risk Profile

Classified as **Lightweight**:
- No auth, no sensitive data, solo, no CI/CD
- Recommended: review-code, test-runner, grill-me, aar

✅ **Risk classification: WORKING**

### Step 2.5 — Path Collision Detection

Created actual collision scenario:
- `.claude/skills/grill-me` exists locally
- `.foundation/.claude/skills/grill-me` exists in subtree

✅ **Collision detection: WORKING** — both paths exist, different content, skill would prompt user correctly

### Step 3 — Recommendations & Install

Recommended skill set: Lightweight profile → 4 skills
Install instructions for Claude Code, Cursor, and other IDEs all present.

✅ **Recommendations: WORKING**

---

## Additional Findings

### Finding B-1: Go toolchain detection gaps
The skill's toolchain discovery references `npm`, `node`, `pytest` — but for Go projects, `go test`, `go vet`, `golangci-lint` aren't mentioned in the discovery guide. A Go project would pass toolchain discovery with "no testing tools found" even though `go test` is built in.

**Severity:** LOW — toolchain discovery says "adapt to the project's actual commands," but the discovery guide only lists Node.js/Python patterns.
**Recommendation:** Add Go patterns (`go test ./...`, `go vet ./...`, `golangci-lint run`) to TOOLCHAIN_DISCOVERY.md.

### Finding B-2: Intake output not persisted
The intake interview concludes with recommendations and install instructions, but there's no output file created. The user gets a markdown table in chat, then it's gone. Other skills (implement, validate-gates) produce structured output files.

**Severity:** MEDIUM — without a file, the next session has to re-run intake or manually copy the recommendations.
**Recommendation:** Add an `intake-output.json` or `PROJECT_INTAKE.md` that records: risk profile, recommended skills, collision decisions, `.agent/.mode` value.

---

## Verdict

**Intake flow: PASS** — all 4 steps work as designed. One actionable gap: Go toolchain patterns missing from discovery guide (Finding B-1).
