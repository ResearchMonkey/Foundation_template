#!/usr/bin/env bash
# Test: Skills resolve paths correctly under .foundation/ prefix (fork mode)
set -euo pipefail
REPO_ROOT="$1"

ERRORS=0

# Simulate fork mode: all canonical skills should exist under .foundation/ after subtree add.
# We test this by verifying that every .agent/skills/*/SKILL.md exists in the repo root,
# which is the content that would land at .foundation/.agent/skills/ in a fork.
for skill_dir in "$REPO_ROOT"/.agent/skills/*/; do
  skill_name=$(basename "$skill_dir")
  # lib is a shared module, not a standalone skill — skip
  [ "$skill_name" = "lib" ] && continue

  if [ -f "$skill_dir/SKILL.md" ]; then
    echo "  PASS: $skill_name has SKILL.md"
  else
    echo "  FAIL: $skill_name missing SKILL.md"
    ERRORS=$((ERRORS + 1))
  fi
done

# Verify wrapper references use relative paths that work under .foundation/ prefix
for wrapper in "$REPO_ROOT"/.claude/skills/*/SKILL.md; do
  [ -f "$wrapper" ] || continue
  wrapper_name=$(basename "$(dirname "$wrapper")")

  # Extract the canonical path reference from the wrapper
  canonical_ref=$(grep -oP '\.agent/skills/[^/]+' "$wrapper" | head -1 || true)
  if [ -n "$canonical_ref" ] && [ -d "$REPO_ROOT/$canonical_ref" ]; then
    echo "  PASS: wrapper $wrapper_name → $canonical_ref exists"
  elif [ -n "$canonical_ref" ]; then
    echo "  FAIL: wrapper $wrapper_name → $canonical_ref not found"
    ERRORS=$((ERRORS + 1))
  fi
done

exit "$ERRORS"
