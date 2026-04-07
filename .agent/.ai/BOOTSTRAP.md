# Bootstrap: Board Activation & Resolution Sequence

<!-- TODO: Fork projects — fill in sections below to match your team's workflow -->

## 1. Board Activation

### 1.1 Cognitive Mode
Read `.agent/.mode` to determine current mode:
- **prototype** — speed-first; skip non-critical gates
- **production** — full zero-trust audit on every change

If `.agent/.mode` is missing, default to **prototype**.

### 1.2 Progressive Role Loading
Load role specs only when activated — not upfront:
| Trigger | Role | Spec |
|---------|------|------|
| Always | ARCH | `.agent/.ai/ARCHITECT.md` |
| Non-whitelisted risk | SEC | `.agent/.ai/Security.md` |
| Test / quality gate | QA | `.agent/.ai/QA_VALIDATOR.md` |
| Apply / deploy | OPS | `.agent/.ai/DevOps.md` |
| Reflexion / error | LIB | `.agent/.ai/Librarian.md` |

### 1.3 Domain Memory on Demand
Load domain-specific memory files only when the task touches their area:
- Auth / data security → `MEMORY_SECURITY.md`
- Client / UI → `MEMORY_UI.md`
- Deployment / infra → `MEMORY_OPS.md`
- Code review / patterns → `MEMORY_ANTI_PATTERNS.md`

## 2. Resolution Sequence
1. **ARCH** plans the work (§ see ARCHITECT.md)
2. **SEC** reviews risk (§ see Security.md / RISK_LEVELS.md)
3. **QA** validates quality (§ see QA_VALIDATOR.md)
4. **OPS** applies the fix and runs tests (§ see DevOps.md)
5. **LIB** audits docs (§ see Librarian.md)

## 3. Mandates
- Every mutation must refresh affected views
- Every catch block must show user-facing feedback
- Tests must pass before delivery
