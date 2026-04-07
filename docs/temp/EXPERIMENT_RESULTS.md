# Foundation Template — New Project Onboarding Experiment

**Date:** 2026-04-07
**Test project:** `/tmp/foundation-test-project` (Node.js task tracker API)
**Method:** Bootstrap → scaffold code → add features → attempt review skills → document findings

---

## Timeline & What Happened

### Bootstrap (2 minutes)
- Created Node.js project with `git init`
- Added Foundation as local git remote, ran `git subtree add --prefix=.foundation`
- Symlinked entry skills (`grill-me`, `foundation-sync`) to `.claude/skills/`
- Committed bootstrap

**Verdict:** Smooth. The subtree approach is clean — one commit, everything lands in `.foundation/`.

### Iteration 1: Scaffold Project Code (5 minutes)
- Created a task tracker API: `src/index.js`, `src/router.js`, `src/store.js`, `src/store.test.js`
- Package.json with `npm test` → `node --test`
- 7 tests, all passing
- Foundation was not involved at this stage — just normal coding

**Verdict:** Foundation doesn't help or hinder at this stage. Expected.

### Iteration 2: Activate Skills & Add Feature (5 minutes)
- Symlinked all 11 wrapper skills from `.foundation/.claude/skills/`
- Added task filtering (by status and search term) with 3 new tests
- 10 tests, all passing

**Question tested:** Would Foundation guide the feature work?
**Answer:** Not yet. The skills need to be explicitly invoked — they don't passively guide coding. Foundation becomes useful when you _run_ a skill.

### Iteration 3: Attempt Review Skills (the interesting part)

Traced through what `review-code`, `review-security`, `review-tests`, and `implement` would do when invoked on this project. This is where the findings live.

---

## Critical Findings

### FINDING 1: Path Resolution Gap (BLOCKER)

**Severity:** High — skills are non-functional in fork projects without workaround

Every canonical skill references files at paths like:
- `.agent/.ai/BOOTSTRAP.md`
- `.agent/workflows/quality-gates.md`
- `docs/CODING_STANDARDS.md`
- `docs/SECURITY_STANDARDS.md`

But in a fork project, these files live at:
- `.foundation/.agent/.ai/BOOTSTRAP.md`
- `.foundation/.agent/workflows/quality-gates.md`
- `.foundation/docs/CODING_STANDARDS.md`
- `.foundation/docs/SECURITY_STANDARDS.md`

**Scope:** 11 skill files reference `.agent/` paths, 7 reference `docs/` paths. Every single file referenced by `implement` (17 files checked) is missing at the expected path.

**The wrapper skills don't help** — they just say "See the canonical file for the full protocol" without remapping paths.

**Impact:** An AI agent following the implement protocol would try to `Read .agent/.ai/BOOTSTRAP.md`, get a file-not-found, and either fail or skip context loading. The Board resolution sequence would run without its constitutional documents.

**Possible fixes:**
1. **Wrapper rewrite:** Wrappers could include path remapping instructions ("in fork projects, replace `.agent/` with `.foundation/.agent/` and `docs/` with `.foundation/docs/`")
2. **Symlink approach:** Bootstrap could create top-level symlinks: `.agent/ → .foundation/.agent/`, `docs/ → .foundation/docs/`
3. **Canonical skill rewrite:** Use a path variable or detection logic ("check `.agent/` first, fall back to `.foundation/.agent/`")
4. **grill-me intake already hints at this:** The intake skill mentions `cp .foundation/.agent/TOOLCHAIN_DISCOVERY.md .agent/` — suggesting skills expect a local `.agent/` directory. But this isn't part of bootstrap.sh.

### FINDING 2: Mixed Path Conventions in grill-me

grill-me intake recommends:
```
ln -s .foundation/.agent/skills/{skill} .agent/skills/{skill}
```

But bootstrap.sh creates:
```
ln -s ../../.foundation/.claude/skills/{skill} .claude/skills/{skill}
```

These are different skill directories (`.agent/skills/` vs `.claude/skills/`). The canonical skills live in `.agent/skills/`, the wrappers live in `.claude/skills/`. A new user following grill-me's instructions would create a different layout than bootstrap.sh creates.

### FINDING 3: allowed-tools Whitelist vs Toolchain Discovery Mismatch

The `implement` wrapper's `allowed-tools` includes:
- `Bash(npm run test:unit)` — specific to projects with a `test:unit` script
- `Bash(npm run lint)` — fine
- `Bash(node --test:*)` — fine

But `TOOLCHAIN_DISCOVERY.md` says to adapt to the project's actual commands. Our test project uses `npm test` (which maps to `node --test`), not `npm run test:unit`. The allowed-tools whitelist would block `npm test` even though the skill protocol says to discover and use it.

Similarly:
- `review-tests` allows `Bash(npm run test:unit*)` but not `Bash(npm test)`
- `review-security` allows `Bash(npm audit*)` but if the project has no `node_modules/`, `npm audit` fails immediately

**Tension:** Toolchain discovery is flexible, but allowed-tools are rigid. The rigid list was designed for a specific project (WEAP/Weapons Lore) and doesn't generalize.

### FINDING 4: Missing `.agent/.mode` File

Skills check `.agent/.mode` for prototype vs production mode. No file exists after bootstrap, and no default is created. The skill says "default to prototype if missing" — so this works, but there's no documentation telling the user they can create this file.

### FINDING 5: Project-Specific References in Skills

Several skills contain references to a specific project:
- `implement` references `WEAP-123`, `WEAP-241`, `WEAP-49` (Jira keys from the original project)
- Branch naming uses `fix/<ISSUE_KEY>-<short-slug>` pattern hardcoded for Jira
- `implement` assumes a `stage` branch exists as PR target
- Skills reference `docs/agent/technical/SDLC.md`, `LOW_RISK_WHITELIST.md`, etc. — these are project-specific docs, not Foundation templates

These references are fine as examples/rationale, but the operational instructions (branch naming, target branch, doc paths) assume a specific project structure.

### FINDING 6: review-security Assumes Tooling That Doesn't Exist

The security review skill expects:
- `npm audit` (requires `node_modules/` — our project has none)
- `node scripts/security/*` (project-specific scripts)
- `npm run lint:config-register` (project-specific script)

For a fresh project, the security review would produce mostly "skipped" results. The toolchain discovery handles this gracefully (WARN and skip), but the review would be almost empty.

### FINDING 7: No CLAUDE.md Generated

After bootstrap, there's no `CLAUDE.md` in the project root. Claude Code loads `CLAUDE.md` automatically as context. Without one, the agent doesn't know Foundation exists unless a skill is explicitly invoked. A bootstrap-generated `CLAUDE.md` pointing to `.foundation/` would make skills discoverable.

---

## When Do Foundation Elements Become Useful?

| Stage | Useful Foundation Elements | Not Yet Useful |
|-------|---------------------------|----------------|
| **Bootstrap** | Git subtree structure, CATALOG.md for skill selection | Everything else (can't use skills yet) |
| **First code** | Nothing — Foundation doesn't guide initial coding | All skills (no code to review yet) |
| **First feature** | review-code could review diff IF path resolution worked | implement (too heavy), review-security (no deps to audit) |
| **Multiple features** | review-code, review-tests, test-runner, aar | review-security (still minimal deps) |
| **Team/CI stage** | implement (full board), validate-gates, foundation-sync | — |

**Bottom line:** Foundation skills become useful at the "first feature review" stage (~15 minutes into a project), but only if the path resolution gap (Finding 1) is fixed.

---

## What Works Well

1. **Subtree sync model** is elegant — one prefix, clean git history, 3-way merge on pull
2. **CATALOG.md** is an excellent quick reference for what to activate
3. **Toolchain discovery** protocol is well-designed and genuinely portable
4. **Quality gates** are thorough and well-documented
5. **Wrapper/canonical split** is a good architecture — thin wrappers per IDE, one canonical source
6. **bootstrap.sh** is clean and handles multiple IDEs
7. **Skill allowed-tools lists** provide good sandboxing (when they match the project)

## What Needs Work

1. **Path resolution** is the #1 blocker for fork usability
2. **allowed-tools** need to be more generic (support `npm test`, not just `npm run test:unit`)
3. **grill-me intake** and **bootstrap.sh** give contradictory skill linking instructions
4. **No CLAUDE.md generated** — Foundation is invisible without explicit skill invocation
5. **Project-specific references** (WEAP-*, stage branch, specific doc paths) reduce portability
6. **.agent/.mode** should be created by bootstrap with a sensible default
7. **review-security** has almost nothing to do on a fresh project — could have a "minimal scan" mode

---

## Recommendations

### Quick Wins
1. Have `bootstrap.sh` generate a minimal `CLAUDE.md` that points to `.foundation/`
2. Have `bootstrap.sh` create `.agent/.mode` with `prototype` default
3. Add path fallback instructions to wrapper skills ("if `.agent/` not found, check `.foundation/.agent/`")

### Medium Effort
4. Generalize `allowed-tools` in wrappers (add `Bash(npm test)`, `Bash(npm run test)` alongside `Bash(npm run test:unit)`)
5. Reconcile grill-me intake and bootstrap.sh skill linking instructions
6. Add a "fresh project" mode to review-security that focuses on code-level scanning when no deps exist

### Larger Effort
7. Consider making canonical skills use a path variable or auto-detection for the `.foundation/` prefix
8. Abstract project-specific references (branch naming, target branch, doc paths) into a config file

---

## Experiment Artifacts

- Test project: `/tmp/foundation-test-project`
- 4 commits: init → bootstrap → scaffold → feature
- 10 passing tests
- No Foundation skills were actually _executed_ (only traced/simulated) because the path resolution gap would cause them to load without context
