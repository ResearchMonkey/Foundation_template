---
name: implement
description: "Unified Board issue processor (ARCH → SEC → QA → OPS → LIB). Accepts Jira keys, URLs, or JSON context files. Auto-detects interactive vs CI mode. Works identically across Claude Code, Cursor, and Grok."
argument-hint: "<Jira key(s)/URL(s) OR path to JSON context file>"
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git checkout:*), Bash(git branch:*), Bash(git remote show origin:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git log:*), Bash(git diff:*), Bash(git stash:*), Bash(cat package.json *), Bash(npm run lint), Bash(npm run lint:fix), Bash(npm run test:unit), Bash(npm run -s test:unit), Bash(npx playwright test:*), Bash(node --test:*), Bash(python3:*), Bash(gh pr create:*), Bash(gh pr merge:*), Bash(gh pr view:*), Bash(gh pr edit:*)
---

# Implement — Unified Board Issue Processor

Canonical skill: **`.agent/skills/implement/SKILL.md`**

This is the single entry point for all Board work — interactive sessions and headless CI. It replaces `board-process`, `board-bootstrap-process`, and `board-bootstrap-ci`. See the canonical file for the full protocol.
