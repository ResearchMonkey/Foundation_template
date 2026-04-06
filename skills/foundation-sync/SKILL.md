---
name: foundation-sync
description: "Bidirectional sync between a fork project and Foundation_template. Pull canonical skills/agents/lessons into the fork, or push contributions back. Use when Caleb says 'run foundation-sync pull/push/status'."
argument-hint: "<pull-from-foundation|push-to-foundation|status> [local-project-path]"
allowed-tools: Read, Write, Glob, Bash(git checkout:*), Bash(git branch:*), Bash(git remote show origin:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git log:*), Bash(git diff:*), Bash(git stash:*), Bash(git pull:*), Bash(git fetch:*), Bash(git clone:*), Bash(gh api:*), Bash(node:*), Bash(cat:*), Bash(ls:*), Bash(mkdir:*), Bash(cp:*), Bash(find:*), Bash(tree:*), Bash(rm:*)
---

# Foundation Sync

Bidirectional sync between a fork project and Foundation_template.

## Usage

```
EDI, run foundation-sync pull [local-project-path]
EDI, run foundation-sync push [local-project-path]
EDI, run foundation-sync status [local-project-path]
```

## Concepts

- **Foundation_template:** The upstream template repo (this repo)
- **Fork (local project):** A project that cloned from Foundation_template
- **Pull:** Copy Foundation_template → local fork (import canonical skills)
- **Push:** Copy fork contributions → Foundation_template (contributions/ only)

## Sync Contract

| Direction | What syncs | Quality gate |
|-----------|-----------|---------------|
| Foundation → Fork | `.claude/skills/`, `.agent/skills/`, `skills/`, `.agent/.ai/MEMORY_ANTI_PATTERNS.md` | grill-me on EDI's copy step before committing |
| Fork → Foundation | `contributions/` only | grill-me before anything goes into contributions/ |

**Conflict resolution:** Drop unresolvable pieces, log them, continue.

---

## pull-from-foundation

Copy canonical material from Foundation_template into the local project.

### Step 0 — Resolve project path

```
if [local-project-path not provided]:
  use current directory
else if [path exists locally]:
  cd to that path
else:
  ERROR: Project path not found
  STOP
```

### Step 1 — Determine source

```
if [Foundation_template repo exists locally at ~/.openclaw/workspace/Foundation_template]:
  cd there
  git pull origin main  (warn if dirty)
else:
  clone Foundation_template to temp dir
  SOURCE = temp clone
```

### Step 2 — Scan what changed in Foundation

```
# Find canonical directories in Foundation_template
foundation_items = find SOURCE/{.claude/skills,.agent/skills,skills,.agent/.ai/MEMORY_ANTI_PATTERNS.md}

For each item:
  check if it exists in LOCAL_PROJECT
  if exists:
    diff them (show what changed)
  else:
    flag as NEW
```

### Step 3 — Present diff to user via grill-me

```
Show user:
  - List of NEW items (will be added)
  - List of CHANGED items (will be updated)
  - List of UNCHANGED items (no action)

Ask: "Proceed with applying these N changes to [project]? Say 'yes' to continue, 'skip X' to exclude specific items, or 'abort'."
```

Wait for answer.

### Step 4 — Apply changes

For each item approved:
```
if [item is directory]:
  copy directory to LOCAL_PROJECT
  git add the directory
else if [item is file]:
  copy file to LOCAL_PROJECT
  git add the file
```

### Step 5 — Commit

```
git status
git commit -m "chore: sync from Foundation_template $(date -u +%Y-%m-%d)"

if commit succeeds:
  echo "Synced. Run 'git push' when ready."
else:
  echo "Nothing to sync or commit failed."
```

---

## push-to-foundation

Push contributions from local fork back to Foundation_template.

**Rule:** Only `contributions/` directory is read back. Everything else in the fork is project-local and not synced.

### Step 0 — Resolve project path

Same as pull-from-foundation Step 0.

### Step 1 — Check for contributions/

```
if [contributions/ does not exist in LOCAL_PROJECT]:
  ERROR: No contributions/ found. Create it first.
  STOP
```

### Step 2 — Scan contributions/

```
contribution_items = find LOCAL_PROJECT/contributions/

For each item:
  flag as TO_PUSH
  show what it is (lesson, skill adaptation, anti-pattern)
```

### Step 3 — Present to user via grill-me

```
Show user:
  - List of items in contributions/ ready to push
  - Remind them: only contributions/ is pushed; rest of fork stays local

Ask: "Push these contributions to Foundation_template? Say 'yes' to continue or 'abort'."
```

Wait for answer.

### Step 4 — Determine Foundation_template target

```
if [Foundation_template repo exists locally at ~/.openclaw/workspace/Foundation_template]:
  cd there
  git pull origin main  (warn if dirty)
  DEST = local
else:
  ERROR: Foundation_template must exist locally for push
  STOP
```

### Step 5 — Apply contributions to Foundation_template

```
For each approved contribution item:
  dest = "DEST/skills/contributions/ITEM_NAME/"
  copy LOCAL_PROJECT/contributions/ITEM_NAME to dest
  git add dest
```

### Step 6 — Commit and push

```
git commit -m "chore: contributions from [PROJECT_NAME] $(date -u +%Y-%m-%d)"
git push origin main
echo "Pushed to Foundation_template."
```

---

## status

Show current sync state without making changes.

### Step 0 — Resolve project path

Same as pull-from-foundation Step 0.

### Step 1 — Check Foundation_template

```
foundation_local = ~/.openclaw/workspace/Foundation_template

if [Foundation_template exists locally]:
  last_sync = git log -1 --format=%ci in Foundation_template
  echo "Foundation_template: local (last pulled: LAST_SYNC)"
else:
  echo "Foundation_template: not checked out locally"
  echo "Run 'pull-from-foundation' to sync."
```

### Step 2 — Scan local project

```
for dir in [.claude/skills, .agent/skills, skills, contributions]:
  if [dir exists in LOCAL_PROJECT]:
    count = number of items in dir
    echo "LOCAL_PROJECT/DIR: count items"
  else:
    echo "LOCAL_PROJECT/DIR: not present"
```

### Step 3 — Show contributions pending push

```
if [contributions/ exists in LOCAL_PROJECT]:
  pending = find contributions/ -type f
  if [pending is empty]:
    echo "No pending contributions to push."
  else:
    echo "contributions/ pending push:"
    for item in pending: echo "  - item"
else:
  echo "No contributions/ directory — nothing to push."
```

---

## Error Handling

- **API failure (GitHub):** Alert user, move on (do not block)
- **Git conflict:** Drop the conflicting piece, log to `SYNC_LOG.md`, continue
- **Dirty working tree (Foundation_template):** Warn user, offer to stash or abort
- **Empty contributions push:** Skip commit, report "nothing to push"
- **Permission denied:** Report and stop (do not force)

---

## Sync Log

All sync events are appended to `SYNC_LOG.md` in the local project:

```
## YYYY-MM-DD HH:MM UTC — [pull|push]
- Direction: ...
- Items synced: ...
- Conflicts dropped: ...
- Notes: ...
```
