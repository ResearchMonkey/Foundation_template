# Experiment C — foundation-sync Bidirectional Sync

**Date:** 2026-04-07
**Test repos:** `/tmp/fork-a`, `/tmp/fork-b`, `/tmp/subtree-test`
**Method:** Simulated git subtree bidirectional sync between cloned repos, tested init/pull/push contracts

---

## Method

1. Created 3 test repos from Foundation_template
2. Set up git subtree prefix in `subtree-test`
3. Simulated fork contributions and traced what `push` would transmit
4. Verified init, pull, and push contracts against actual git commands

---

## Init Test

`git subtree add --prefix=.foundation foundation/main --squash`

✅ Works correctly — subtree added at `.foundation/`, squashes Foundation history into a single merge commit.

---

## Pull Test

`git subtree pull --prefix=.foundation foundation main --squash`

✅ Works correctly — merges upstream changes into `.foundation/` directory. Merge conflicts surface as real git conflicts (not silently dropped like the old file-copy model).

---

## Push Test — CRITICAL FAILURE FINDING

### The Problem

The sync contract says Fork → Foundation_template pushes only `contributions/`.

But `git subtree push --prefix=.foundation` **only transmits content inside `.foundation/`**.

Contributions created at the **root level** (`skills/contributions/LESSONS.md`) are **never pushed**.

### Verification

```
git subtree push --prefix=.foundation foundation contrib/test
# Only pushes commits that modified .foundation/
# skills/contributions/ at root = NOT transmitted
```

### Origin of the Confusion

The original `skills/contributions/` was added to Foundation_template as a **root-level directory** (in the full repo). When a fork is created by cloning the repo normally (not via subtree), `skills/contributions/` is part of the fork and pushes work normally.

But when using the **git subtree model**:
- Fork clones don't have `.foundation/` — they have the full repo
- The subtree prefix (`--prefix=.foundation`) isolates Foundation content
- Only content inside `.foundation/` is ever pushed back

### Options

| Option | How it works | Pros | Cons |
|--------|-------------|------|-------|
| **A: Contributions inside `.foundation/`** | Edit `.foundation/skills/contributions/` | Pushes correctly | Merge conflicts on pull; fork edits live inside Foundation namespace |
| **B: Root-level `skills/contributions/`** | Edit `skills/contributions/` at root | Familiar location | git subtree push ignores root-level content |
| **C: Separate sync for contributions** | Sync `contributions/` via separate git push | Works with subtree model | Extra step, two sync mechanisms |
| **D: Accept full-repo push** | Don't use subtree — push the whole fork | Simple, full git history | Defeats the purpose of subtree isolation |

### Current Behavior

When a fork using git subtree creates a contribution at `skills/contributions/` (root level):
- The contribution is **never transmitted** to Foundation_template
- The `push` command silently reports success
- Foundation never receives the contribution

---

## Finding C-1: The git subtree model is incompatible with bidirectional contributions

The git subtree design works for **one-way** sync (Foundation → Fork). For **bidirectional** sync with contributions, the subtree prefix creates a hard boundary: `.foundation/` content flows downstream, but root-level contributions never flow upstream.

This is a **BLOCKER** for the bidirectional sync contract as designed.

**Recommended fix:** Option C — use `git push` for `skills/contributions/` (separate from subtree), or abandon subtree in favor of a custom sync script that handles both directories.

---

## Additional Findings

### Finding C-2: `bootstrap.sh` hardcodes ResearchMonkey org
```
REPO="https://github.com/ResearchMonkey/Foundation_template.git"
```
Foundation_template now lives at `Echo8Lore/Foundation_template`. The bootstrap script still points to the old org. Any new fork bootstrapped via `bootstrap.sh` would pull from the wrong repo.

**Severity:** HIGH — new projects would clone from wrong org
**Recommendation:** Update `bootstrap.sh` REMOTE URL

### Finding C-3: `projects.json` in Foundation_template root is empty `[]`
After BL-016 fix, `projects.json` was emptied to prevent template from containing another project's data. But the init command (Step 5) adds entries to this file, and with an empty array, new forks get no portability scan data.

**Severity:** MEDIUM — portability scan won't find any known forks (empty array), so it won't warn about leaked project-specific language
**Recommendation:** Keep `projects.json` empty in the template (correct for a template). Document that forks should populate it with their own name.

---

## Verdict

**Push: FAIL** — git subtree push only transmits `.foundation/` content. Root-level contributions are never pushed. This is a fundamental design conflict between the git subtree model and the bidirectional sync contract.

**BL-001 fix was incomplete:** Switching from file-copy to git subtree fixed silent-drop conflicts, but introduced a new failure mode: contributions at the root level are silently lost.

**Recommendation:** BL-001 needs a revisit. The fix should either:
1. Abandon git subtree and use a custom sync tool that handles two-way contributions, OR
2. Document that contributions must live inside `.foundation/` (inside the prefix) to be pushed, acknowledging the merge-conflict risk

---

## Next Steps

- Fix C-2 immediately (URL in bootstrap.sh)
- Decide on C-1 resolution (this affects the core sync architecture)
- Experiment D: validate-gates on real implement output
- Experiment E: Python project portability
