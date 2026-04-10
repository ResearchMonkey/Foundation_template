#!/usr/bin/env bash
# Foundation_template — contract & portability tests
# Run from repo root: bash tests/run_tests.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
ERRORS=()

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); ERRORS+=("$1"); }

run_test() {
  local test_file="$1"
  local test_name
  test_name="$(basename "$test_file" .sh)"
  echo ""
  echo "── $test_name ──"
  if bash "$test_file" "$REPO_ROOT"; then
    : # individual pass/fail handled inside each test
  else
    fail "$test_name (script exited non-zero)"
  fi
}

echo "Foundation_template contract tests"
echo "==================================="

for t in "$REPO_ROOT"/tests/test_*.sh; do
  [ -f "$t" ] && run_test "$t"
done

echo ""
echo "==================================="
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  echo "Failures:"
  for e in "${ERRORS[@]}"; do echo "  - $e"; done
  exit 1
fi
