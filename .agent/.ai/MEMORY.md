# Project Memory Index

Domain knowledge and active decisions. Skills load this file during Step 0 to pick up relevant context.

## References

- [AGENTS.md](AGENTS.md) — Board constitution and agent roles
- [MEMORY_ANTI_PATTERNS.md](MEMORY_ANTI_PATTERNS.md) — Portable anti-patterns (14 entries)
- [Developer.md](Developer.md) — Developer agent persona (includes ARCH role)
- [Security.md](Security.md) — Security agent persona and risk classification rubric
- [QA.md](QA.md) — QA agent persona
- [DevOps.md](DevOps.md) — DevOps agent persona
- [Librarian.md](Librarian.md) — Librarian agent persona

## Active Decisions

- Sync mechanism: git subtree with `.foundation/` prefix (BL-001)
- Quality gates: machine-readable JSON output from implement (BL-003)
- Risk classification: concrete criteria per tier in Security.md §5 (BL-008)
- Portability: post-pull scan for project-specific references (BL-013)
- Stale reference detection: LIB doc audit item #7 (BL-014)

## Domain Memory

Fork projects add domain-specific memory files here. Template ships with agent personas only.
