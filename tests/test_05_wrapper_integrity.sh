#!/usr/bin/env bash
# Test: All .claude/skills/ wrappers point to existing canonical skills in .agent/skills/
set -euo pipefail
REPO_ROOT="$1"

ERRORS=0

for wrapper_dir in "$REPO_ROOT"/.claude/skills/*/; do
  [ -d "$wrapper_dir" ] || continue
  wrapper_name=$(basename "$wrapper_dir")

  # Corresponding canonical skill must exist
  canonical="$REPO_ROOT/.agent/skills/$wrapper_name"
  if [ -d "$canonical" ]; then
    echo "  PASS: .claude/skills/$wrapper_name → .agent/skills/$wrapper_name exists"
  else
    echo "  FAIL: .claude/skills/$wrapper_name has no matching canonical skill"
    ERRORS=$((ERRORS + 1))
  fi

  # Wrapper SKILL.md must reference the canonical skill
  wrapper_skill="$wrapper_dir/SKILL.md"
  if [ -f "$wrapper_skill" ]; then
    if grep -q "\.agent/skills/$wrapper_name" "$wrapper_skill"; then
      echo "  PASS: .claude/skills/$wrapper_name/SKILL.md references canonical path"
    else
      echo "  FAIL: .claude/skills/$wrapper_name/SKILL.md does not reference .agent/skills/$wrapper_name"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "  FAIL: .claude/skills/$wrapper_name missing SKILL.md"
    ERRORS=$((ERRORS + 1))
  fi
done

exit "$ERRORS"
