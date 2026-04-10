#!/usr/bin/env bash
# Test: bootstrap.sh runs clean on an empty git repo
set -euo pipefail
REPO_ROOT="$1"
source "$REPO_ROOT/tests/run_tests.sh" 2>/dev/null || true

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"
git init -q
git commit --allow-empty -m "init" -q

# Run bootstrap with "skip" IDE to avoid interactive prompt
bash "$REPO_ROOT/bootstrap.sh" skip

# Verify .foundation/ was created with key content
if [ -d ".foundation/.agent/skills" ]; then
  echo "  PASS: .foundation/.agent/skills/ exists after bootstrap"
else
  echo "  FAIL: .foundation/.agent/skills/ missing after bootstrap"
  exit 1
fi

if [ -f ".foundation/CATALOG.md" ]; then
  echo "  PASS: .foundation/CATALOG.md exists"
else
  echo "  FAIL: .foundation/CATALOG.md missing"
  exit 1
fi

if [ -f "CLAUDE.md" ]; then
  echo "  PASS: CLAUDE.md generated"
else
  echo "  FAIL: CLAUDE.md not generated"
  exit 1
fi

if git remote get-url foundation >/dev/null 2>&1; then
  echo "  PASS: foundation remote configured"
else
  echo "  FAIL: foundation remote not configured"
  exit 1
fi
