#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/ResearchMonkey/Foundation_template.git"
PREFIX=".foundation"
REMOTE="foundation"

# Must be inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a git repository. Run 'git init' first."
  exit 1
fi

# Check if already bootstrapped
if git remote get-url "$REMOTE" >/dev/null 2>&1; then
  echo "Remote '$REMOTE' already exists. You may already be bootstrapped."
  echo "Run '/foundation-sync status' inside Claude Code to check."
  exit 1
fi

if [ -d "$PREFIX" ]; then
  echo "Error: directory '$PREFIX' already exists."
  exit 1
fi

echo "Adding Foundation_template as git subtree..."
git remote add "$REMOTE" "$REPO"
git subtree add --prefix="$PREFIX" "$REMOTE" main

echo ""
echo "Done. Foundation_template is now at .foundation/"
echo ""
echo "Next steps:"
echo "  1. Open this project in Claude Code"
echo "  2. Run: /grill-me intake"
echo "  3. Follow the recommendations to activate skills"
echo ""
echo "To sync future updates: /foundation-sync pull"
