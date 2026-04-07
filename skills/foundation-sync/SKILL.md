---
name: foundation-sync
description: "Bidirectional sync between a fork project and Foundation_template using git subtree. Pull canonical skills/agents/lessons into the fork, or push contributions back. Use when Caleb says 'run foundation-sync pull/push/status'."
argument-hint: "<pull|push|status|init> [local-project-path]"
allowed-tools: Read, Write, Glob, Bash(git checkout:*), Bash(git branch:*), Bash(git remote show origin:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git log:*), Bash(git diff:*), Bash(git stash:*), Bash(git pull:*), Bash(git fetch:*), Bash(git subtree:*), Bash(git remote add:*), Bash(git remote -v:*), Bash(gh api:*), Bash(cat:*), Bash(ls:*), Bash(tree:*), Bash(diff:*)
---

# Foundation Sync (git subtree)

Bidirectional sync between a fork project and Foundation_template using `git subtree`.

## Why git subtree (not file-copy)

The previous file-copy approach silently overwrote fork customizations on every pull ("drop, log, continue"). Git subtree uses real 3-way merge — fork edits and upstream changes merge automatically when they don't conflict, and surface as standard git merge conflicts when they do. No more silent data loss.

## Usage

```
EDI, run foundation-sync init [local-project-path]   # first-time setup
EDI, run foundation-sync pull [local-project-path]    # pull upstream changes
EDI, run foundation-sync push [local-project-path]    # push contributions back
EDI, run foundation-sync status [local-project-path]  # show sync state
```

## Concepts

- **Foundation_template:** The upstream template repo (`https://github.com/Echo8Lore/Foundation_template.git`)
- **Fork (local project):** A project that uses Foundation_template's skills/agents
- **Subtree prefix:** `.foundation/` — a directory in the fork containing synced Foundation_template content
- **Pull:** `git subtree pull` — merges upstream changes into `.foundation/`, preserving fork edits
- **Push:** `git subtree push` — extracts `.foundation/` commits back to Foundation_template

## Sync Contract

| Direction | Mechanism | What syncs | Conflict handling |
|-----------|-----------|-----------|-------------------|
| Foundation → Fork | `git subtree pull` | Everything under `.foundation/` | Git 3-way merge; conflicts surface for manual resolution |
| Fork → Foundation | `git subtree push` | Commits touching `.foundation/` | Pushed to `contrib/<project>` branch for review |

## Portability Check (BL-013)

Foundation_template content must be project-agnostic. Both directions scan for project-specific language.

**On push (blocks):** Before pushing, scan `.foundation/` for the fork's project name. If found, STOP — fix before pushing.

**On pull (warns):** After pulling, scan `.foundation/` for all known fork project names from `projects.json`. If found, WARN — this means Foundation_template has leaked project-specific language upstream. Report it but don't block (the fork still needs the update).

```
# Build list of known fork names from projects.json
fork_names = [entry.name for entry in projects.json]

grep -ri "<fork-name-1>\|<fork-name-2>\|..." .foundation/
```

---

## init — First-Time Setup

Run this once per fork to establish the subtree relationship.

### Step 0 — Resolve project path

```
if [local-project-path not provided]:
  use current directory
else if [path exists]:
  cd to that path
else:
  ERROR: Project path not found
  STOP
```

### Step 1 — Check preconditions

```
# Must be a git repo
if [not a git repo]:
  ERROR: Not a git repository
  STOP

# Must not already have .foundation/
if [.foundation/ exists]:
  ERROR: .foundation/ already exists — subtree already initialized.
  Hint: Use 'pull' to update, not 'init'.
  STOP

# Must have clean working tree
if [git status shows uncommitted changes]:
  WARN: Dirty working tree. Stash or commit first.
  STOP
```

### Step 2 — Add Foundation remote

```
# Check if remote already exists
existing = git remote -v | grep Foundation_template

if [not exists]:
  git remote add foundation https://github.com/Echo8Lore/Foundation_template.git
  git fetch foundation
else:
  echo "Remote 'foundation' already configured."
  git fetch foundation
```

### Step 3 — Add subtree

```
git subtree add --prefix=.foundation foundation main --squash \
  -m "chore: init foundation subtree from Foundation_template"
```

`--squash` collapses Foundation_template history into a single merge commit, keeping fork history clean.

### Step 4 — Set up local references

After the subtree is added, `.foundation/` contains the full Foundation_template content:
```
.foundation/
├── .agent/          # agent roles, skills, AI config
├── .claude/         # Claude Code wrappers
├── skills/          # canonical skill implementations
├── CATALOG.md
├── README.md
└── ...
```

The fork can now:
1. **Symlink** from `.foundation/.claude/skills/` into its own `.claude/skills/` for skills it wants
2. **Copy and customize** specific skills (edits persist across pulls via merge)
3. **Reference directly** — point tool configs at `.foundation/` paths

### Step 5 — Update projects.json

If `projects.json` exists in Foundation_template, add an entry for this fork:
```json
{
  "name": "<project-name>",
  "url": "<fork-repo-url>",
  "prefix": ".foundation",
  "remote": "foundation",
  "lastSync": "<today's date>"
}
```

### Step 6 — Log and commit

Append to `SYNC_LOG.md`:
```
## YYYY-MM-DD HH:MM UTC — init
- Direction: init (git subtree add)
- Prefix: .foundation
- Remote: foundation (Foundation_template main)
- Notes: First-time subtree setup
```

Report: "Foundation subtree initialized at `.foundation/`. Use `pull` to get future updates."

---

## pull — Pull Upstream Changes

Merge Foundation_template updates into the fork's `.foundation/` directory.

### Step 0 — Resolve project path

Same as init Step 0.

### Step 1 — Check preconditions

```
# .foundation/ must exist
if [.foundation/ does not exist]:
  ERROR: No .foundation/ directory. Run 'init' first.
  STOP

# 'foundation' remote must exist
if [git remote -v does not show 'foundation']:
  ERROR: No 'foundation' remote. Run 'init' first.
  STOP

# Clean working tree required
if [git status shows uncommitted changes]:
  WARN: Dirty working tree. Stash or commit first.
  STOP
```

### Step 2 — Fetch and show what changed

```
git fetch foundation

# Show what's new upstream
git log --oneline HEAD..foundation/main -- .foundation/
```

If no new commits: "Already up to date." STOP.

Show user the summary of incoming changes.

### Step 3 — Subtree pull

```
git subtree pull --prefix=.foundation foundation main --squash \
  -m "chore: sync from Foundation_template $(date -u +%Y-%m-%d)"
```

**If merge succeeds:** Report files changed, continue to Step 4.

**If merge conflicts:**
```
echo "Merge conflicts detected in .foundation/:"
git diff --name-only --diff-filter=U

echo "Resolve conflicts, then run: git add <files> && git commit"
echo "After resolving, re-run 'foundation-sync pull' to verify."
STOP (do not auto-resolve — user must decide)
```

This is the key improvement over file-copy: conflicts are visible and user-resolved, not silently dropped.

### Step 4 — Post-pull report

```
# Show what changed
git diff --stat HEAD~1..HEAD -- .foundation/

# Check for new skills added upstream
new_skills = diff between .foundation/skills/ listing before and after
if [new skills found]:
  echo "New skills available from Foundation_template:"
  for skill in new_skills:
    echo "  - skill (see .foundation/skills/skill/SKILL.md)"
```

### Step 5 — Post-pull portability check (BL-013)

```
# Load known fork project names from projects.json (in .foundation/ or local)
fork_names = [entry.name for entry in projects.json]

# Scan pulled content for project-specific language
for name in fork_names:
  matches = grep -ri "$name" .foundation/
  if [matches found]:
    WARN: "Found references to fork project '$name' in upstream content:"
    show matches
    echo "Foundation_template may contain project-specific language."
    echo "Consider filing an issue or fixing upstream."
```

This is a **warning**, not a blocker. The fork needs the update regardless — but leaked project names in the template should be reported and fixed upstream.

### Step 6 — Update sync log

Append to `SYNC_LOG.md`:
```
## YYYY-MM-DD HH:MM UTC — pull
- Direction: pull (git subtree pull)
- Prefix: .foundation
- Files changed: <count>
- New skills: <list or "none">
- Conflicts: <count or "none">
- Portability warnings: <count or "none">
- Notes: ...
```

Update `lastSync` in `projects.json`.

---

## push — Push Contributions Back

Extract commits from `.foundation/` and push to Foundation_template for review.

### Step 0 — Resolve project path

Same as init Step 0.

### Step 1 — Check preconditions

```
# .foundation/ must exist
if [.foundation/ does not exist]:
  ERROR: No .foundation/ directory. Run 'init' first.
  STOP

# 'foundation' remote must exist and user must have push access
if [git remote -v does not show 'foundation']:
  ERROR: No 'foundation' remote. Run 'init' first.
  STOP

# Clean working tree
if [git status shows uncommitted changes]:
  WARN: Dirty working tree. Stash or commit first.
  STOP
```

### Step 2 — Portability check (BL-013)

```
# Get project name from git remote or directory name
project_name = basename of fork repo

# Scan for project-specific language
matches = grep -ri "$project_name" .foundation/
matches += grep -ri "hardcoded project references" .foundation/

if [matches found]:
  WARN: "Found project-specific references in .foundation/:"
  show matches
  echo "Foundation_template content must be project-agnostic."
  echo "Fix these before pushing. Aborting."
  STOP
```

### Step 3 — Show what will be pushed

```
# Show commits that touched .foundation/ since last sync
git log --oneline foundation/main..HEAD -- .foundation/
```

If no commits touch `.foundation/`: "Nothing to push." STOP.

Present the commit list to user:
```
echo "These commits will be pushed to Foundation_template:"
<commit list>
echo "They will land on branch 'contrib/<project-name>' for review."
echo "Proceed? (yes/abort)"
```

Wait for confirmation.

### Step 4 — Subtree push

```
# Push to a contribution branch, not main
git subtree push --prefix=.foundation foundation contrib/<project-name>
```

This extracts all commits that modified `.foundation/` and replays them on the `contrib/<project-name>` branch of Foundation_template.

**If push succeeds:** Continue to Step 5.
**If push fails (permission, conflict):** Report error, suggest user create a PR manually.

### Step 5 — Create PR (optional)

```
echo "Contribution branch pushed. Create a PR on Foundation_template?"
echo "(yes/no)"

if yes:
  # Switch context to Foundation_template or use gh CLI
  gh pr create \
    --repo Echo8Lore/Foundation_template \
    --base main \
    --head "contrib/<project-name>" \
    --title "contrib: changes from <project-name>" \
    --body "Contributions pushed via foundation-sync from <project-name>."
```

### Step 6 — Update sync log

Append to `SYNC_LOG.md`:
```
## YYYY-MM-DD HH:MM UTC — push
- Direction: push (git subtree push)
- Branch: contrib/<project-name>
- Commits pushed: <count>
- PR: <url or "skipped">
- Notes: ...
```

---

## status — Show Sync State

### Step 0 — Resolve project path

Same as init Step 0.

### Step 1 — Check subtree setup

```
if [.foundation/ does not exist]:
  echo "Not initialized. Run 'foundation-sync init' first."
  STOP

if [git remote -v does not show 'foundation']:
  echo "Remote 'foundation' not configured. Run 'foundation-sync init'."
  STOP
```

### Step 2 — Fetch and compare

```
git fetch foundation

# Commits upstream that we don't have
incoming = git log --oneline HEAD..foundation/main -- (count)

# Commits we have that upstream doesn't
outgoing = git log --oneline foundation/main..HEAD -- .foundation/ (count)
```

### Step 3 — Report

```
Foundation Sync Status
──────────────────────
Remote:     foundation (https://github.com/Echo8Lore/Foundation_template.git)
Prefix:     .foundation/
Last sync:  <from SYNC_LOG.md or git log>

Incoming:   <N> commits available (run 'pull' to merge)
Outgoing:   <N> commits to push (run 'push' to contribute)

Skills in .foundation/:
  - <list skills with counts>

Local customizations (files in .foundation/ modified since last pull):
  - <list or "none">
```

---

## Migration from File-Copy

For forks currently using the old file-copy sync:

1. **Commit all pending changes** in the fork
2. **Run `foundation-sync init`** — this adds `.foundation/` via subtree
3. **Compare** old skill locations (`.claude/skills/`, `.agent/skills/`) with `.foundation/` equivalents
4. **Decide per-skill:**
   - **Unmodified:** Delete local copy, symlink to `.foundation/` equivalent
   - **Customized:** Keep local copy; `.foundation/` serves as reference for future upstream changes
5. **Update `.gitignore`** if needed (`.foundation/` should be tracked)
6. **Commit** the migration

The old `contributions/` directory workflow is replaced by commits to `.foundation/` + `push`.

---

## Error Handling

| Scenario | Action |
|----------|--------|
| **Merge conflict on pull** | Surface conflict, user resolves manually — never auto-drop |
| **Push rejected (no access)** | Report error, suggest fork + PR workflow |
| **Push rejected (diverged)** | Suggest `pull` first, then retry push |
| **Dirty working tree** | Warn, suggest stash or commit, stop |
| **.foundation/ missing** | Direct to `init` |
| **Remote missing** | Direct to `init` |
| **Network failure** | Report and stop (do not proceed with stale data) |

---

## Sync Log

All sync events are appended to `SYNC_LOG.md` in the local project:

```
## YYYY-MM-DD HH:MM UTC — [init|pull|push]
- Direction: ...
- Prefix: .foundation
- Files changed: ...
- Conflicts: ...
- Notes: ...
```
