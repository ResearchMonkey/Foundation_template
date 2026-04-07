# Bootstrap: Board Activation & Resolution Sequence

<!-- TODO: Fork projects — fill in sections below to match your team's workflow -->

## 1. Board Activation

### 1.1 Cognitive Mode
Read `.agent/.mode` to determine current mode:
- **prototype** — speed-first; skip non-critical gates
- **production** — full zero-trust audit on every change

If `.agent/.mode` is missing, default to **prototype**.

### 1.2 Progressive Role Loading
Load role specs only when activated — not upfront. When a role activates, also load its standards doc:
| Trigger | Role | Spec | Standards Doc |
|---------|------|------|---------------|
| Always | ARCH | `.agent/.ai/Developer.md` | `docs/CODING_STANDARDS.md` |
| Non-whitelisted risk | SEC | `.agent/.ai/Security.md` | `docs/SECURITY_STANDARDS.md` |
| Test / quality gate | QA | `.agent/.ai/QA.md` | `docs/TESTING_STANDARDS.md` |
| Apply / deploy | OPS | `.agent/.ai/DevOps.md` | `docs/OPS_STANDARDS.md` |
| Reflexion / error | LIB | `.agent/.ai/Librarian.md` | `docs/DOCUMENTATION_STANDARDS.md` |

### 1.3 Domain Memory on Demand
Load domain-specific memory files only when the task touches their area:
- Code review / patterns → `MEMORY_ANTI_PATTERNS.md`
- Fork projects create additional domain memory files as needed (e.g., `MEMORY_SECURITY.md`, `MEMORY_OPS.md`)

## 2. Resolution Sequence
1. **ARCH** plans the work (§ see Developer.md)
2. **SEC** reviews risk (§ see Security.md / `docs/SECURITY_STANDARDS.md`)
3. **QA** validates quality (§ see QA.md)
4. **OPS** applies the fix and runs tests (§ see DevOps.md)
5. **LIB** audits docs (§ see Librarian.md)

## 3. Mandates
- Every mutation must refresh affected views
- Every catch block must show user-facing feedback
- Tests must pass before delivery
