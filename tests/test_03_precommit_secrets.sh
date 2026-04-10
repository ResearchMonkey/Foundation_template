#!/usr/bin/env bash
# Test: Pre-commit hook catches a planted secret
set -euo pipefail
REPO_ROOT="$1"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"
git init -q
git commit --allow-empty -m "init" -q

# Install the hook
cp "$REPO_ROOT/.agent/hooks/pre-commit" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Plant a file with a fake secret
echo 'export API_KEY="sk-fake-1234567890"' > config.sh
git add config.sh

# Attempt to commit — should fail
if git commit -m "add config" 2>&1; then
  echo "  FAIL: commit succeeded — hook did not catch the secret"
  exit 1
else
  echo "  PASS: pre-commit hook blocked commit with planted secret"
fi

# Verify a clean file commits fine
rm config.sh
echo 'echo "hello world"' > clean.sh
git add clean.sh
if git commit -m "add clean file" -q 2>&1; then
  echo "  PASS: clean file commits without hook blocking"
else
  echo "  FAIL: hook blocked a clean commit"
  exit 1
fi
