#!/usr/bin/env bash
# Test: README skill count matches actual skill count in .agent/skills/
set -euo pipefail
REPO_ROOT="$1"

# Count actual skill directories (exclude lib — it's a shared module, not a skill)
actual_skills=0
actual_roles=0
for dir in "$REPO_ROOT"/.agent/skills/*/; do
  name=$(basename "$dir")
  [ "$name" = "lib" ] && continue
  # Agent roles are: developer, qa, security, librarian, devops
  case "$name" in
    developer|qa|security|librarian|devops)
      actual_roles=$((actual_roles + 1))
      ;;
    *)
      actual_skills=$((actual_skills + 1))
      ;;
  esac
done

# README says: "11 canonical skills + 5 agent roles + shared lib"
readme_skills=$(grep -oP '(\d+) canonical skills' "$REPO_ROOT/README.md" | grep -oP '^\d+')
readme_roles=$(grep -oP '(\d+) agent roles' "$REPO_ROOT/README.md" | grep -oP '^\d+')

ERRORS=0

if [ "$readme_skills" = "$actual_skills" ]; then
  echo "  PASS: README skill count ($readme_skills) matches actual ($actual_skills)"
else
  echo "  FAIL: README says $readme_skills skills but found $actual_skills"
  ERRORS=$((ERRORS + 1))
fi

if [ "$readme_roles" = "$actual_roles" ]; then
  echo "  PASS: README role count ($readme_roles) matches actual ($actual_roles)"
else
  echo "  FAIL: README says $readme_roles roles but found $actual_roles"
  ERRORS=$((ERRORS + 1))
fi

exit "$ERRORS"
