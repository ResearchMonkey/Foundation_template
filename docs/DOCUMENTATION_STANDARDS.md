# Documentation Standards

<!-- TODO: Fork projects — customize doc lifecycle, SSOT rules, and sync triggers for your team -->

> **Owner:** This is a user-owned standards document. Edit this file to change the rules your AI agents follow for documentation and knowledge management.  
> **Consumer:** `@Librarian` persona, `lib` skill, `aar` skill.

## 1. Single Source of Truth (SSOT)

- Every domain has exactly **one authoritative source**. When multiple documents describe the same thing, flag the conflict and consolidate.
- **Classification Check:** Verify every document under `docs/` has a `**Status:** Draft|Active|Historic` line. Draft documents cannot be cited as authority.
- **Directory Classification:**
  - Living reference documents → `docs/agent/technical/`
  - Point-in-time decision records → `docs/agent/decisions/`
  - Flag misplacements.

## 2. Documentation Lifecycle

- **New Documents:** Every new document must include `**Status:** Draft|Active|Historic` frontmatter.
- **Artifact Lifecycle:** Draft → Active → Historic. Active documents must be maintained. Historic documents must be archived.
- **Superseded Documents:** Move to archive immediately when replaced by an active specification.

## 3. Doc-Code Synchronization

When code changes, documentation must stay in sync:

- New API routes → `docs/agent/technical/API_Reference.md` updated
- New patterns → `docs/CODING_STANDARDS.md` updated
- New anti-patterns encountered → `docs/CODING_STANDARDS.md` §6 updated
- Architectural decisions → architecture decision records updated
- **Verified-Against Markers:** Documented values must be verified against implementation and include a marker noting the source file and commit.

## 4. Memory Health

- Monitor memory files for staleness (> 7 days without updates = stale)
- Domain memory files:
  - `MEMORY.md` — Iron Laws and domain index
  - `MEMORY_ANTI_PATTERNS.md` — code smells and process anti-patterns (defers to `docs/CODING_STANDARDS.md`)
  - `MEMORY_SECURITY.md` — auth, data security
  - `MEMORY_OPS.md` — CI/CD, deployment, infrastructure

## 5. What Must Be Documented

When adding or modifying code, check whether documentation is needed for:

- **API fields** → `docs/agent/technical/API_Reference.md`
- **Configuration constants** → `docs/agent/technical/CONFIGURATION_REGISTER.md`
- **Database schema changes** → project-specific architecture doc
- **New test files** → `docs/agent/quality/TEST_REGISTRY.md`
- **User-facing features** → user-facing documentation or ticket for follow-up

## 6. Document Structure Conventions

- Include a `<!-- TODO: Fork projects — ... -->` marker in template docs
- Include a `> **Owner:**` / `> **Consumer:**` header in standards docs
- Include a `## References` section at the bottom of skill and persona files
- Keep documents focused — one topic per file
