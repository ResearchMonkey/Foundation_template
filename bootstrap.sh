#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/ResearchMonkey/Foundation_template.git"
PREFIX=".foundation"
REMOTE="foundation"

# Entry-point skills that must be available immediately after bootstrap
ENTRY_SKILLS=(grill-me foundation-sync)

# Must be inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a git repository. Run 'git init' first."
  exit 1
fi

# Check if already bootstrapped
if git remote get-url "$REMOTE" >/dev/null 2>&1; then
  echo "Remote '$REMOTE' already exists. You may already be bootstrapped."
  echo "Run '/foundation-sync status' inside your AI coding tool to check."
  exit 1
fi

if [ -d "$PREFIX" ]; then
  echo "Error: directory '$PREFIX' already exists."
  exit 1
fi

# ── Detect or ask which IDE ─────────────────────────────
detect_ide() {
  # Check for IDE-specific directories in the project
  if [ -d ".cursor" ]; then
    echo "cursor"
  elif [ -d ".claude" ]; then
    echo "claude"
  else
    echo ""
  fi
}

IDE="${1:-}"
if [ -z "$IDE" ]; then
  IDE=$(detect_ide)
fi

if [ -z "$IDE" ]; then
  echo ""
  echo "Which AI coding tool are you using?"
  echo "  1) Claude Code  (.claude/skills/)"
  echo "  2) Cursor       (.cursor/rules/)"
  echo "  3) Skip         (I'll set up wrappers manually)"
  echo ""
  read -rp "Enter 1, 2, or 3 [1]: " choice
  case "${choice:-1}" in
    1) IDE="claude" ;;
    2) IDE="cursor" ;;
    3) IDE="skip"   ;;
    *) echo "Invalid choice. Defaulting to Claude Code."; IDE="claude" ;;
  esac
fi

# ── Pull the subtree ────────────────────────────────────
echo "Adding Foundation_template as git subtree..."
git remote add "$REMOTE" "$REPO"
git subtree add --prefix="$PREFIX" "$REMOTE" main

# ── Generate IDE-specific wrappers ──────────────────────
link_claude_skills() {
  echo "Setting up Claude Code skills..."
  mkdir -p .claude/skills
  for skill in "${ENTRY_SKILLS[@]}"; do
    if [ -d "$PREFIX/.claude/skills/$skill" ] && [ ! -e ".claude/skills/$skill" ]; then
      ln -s "../../$PREFIX/.claude/skills/$skill" ".claude/skills/$skill"
      echo "  Linked: .claude/skills/$skill"
    fi
  done
}

generate_cursor_rules() {
  echo "Generating Cursor rules..."
  mkdir -p .cursor/rules
  for skill in "${ENTRY_SKILLS[@]}"; do
    canonical="$PREFIX/.agent/skills/$skill/SKILL.md"
    if [ -f "$canonical" ] && [ ! -e ".cursor/rules/$skill.md" ]; then
      cat > ".cursor/rules/$skill.md" <<RULE
---
name: $skill
description: "Foundation skill — see .foundation/.agent/skills/$skill/SKILL.md for full protocol"
---

# $skill

This is a Foundation_template skill. The canonical implementation is at:

\`.foundation/.agent/skills/$skill/SKILL.md\`

When the user asks to run \`$skill\`, read and follow the full protocol in that file.
RULE
      echo "  Created: .cursor/rules/$skill.md"
    fi
  done
}

case "$IDE" in
  claude)
    link_claude_skills
    ;;
  cursor)
    generate_cursor_rules
    ;;
  skip)
    echo "Skipping wrapper setup. Skills are available in $PREFIX/.agent/skills/"
    echo "See $PREFIX/CATALOG.md for the full list."
    ;;
  *)
    echo "Unknown IDE '$IDE'. Skipping wrapper setup."
    echo "Skills are available in $PREFIX/.agent/skills/"
    ;;
esac

echo ""
echo "Done. Foundation_template is now at $PREFIX/"
echo ""
echo "Next steps:"
case "$IDE" in
  claude)
    echo "  1. Open this project in Claude Code"
    echo "  2. Run: /grill-me intake"
    echo "  3. Follow the recommendations to activate more skills"
    ;;
  cursor)
    echo "  1. Open this project in Cursor"
    echo "  2. Ask the agent to run 'grill-me intake'"
    echo "  3. Follow the recommendations to activate more skills"
    ;;
  *)
    echo "  1. Set up skill wrappers for your IDE (see $PREFIX/CATALOG.md)"
    echo "  2. Run the grill-me intake process to get recommendations"
    ;;
esac
echo ""
echo "To sync future updates: /foundation-sync pull"
