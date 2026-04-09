# Foundation_template Backlog

Items discovered during project grilling sessions. Implement after each round.

---

### BL-036: Foundation_template missing canonical skills in skills/
**Source:** EDI-32 close-out (BL-002 Criteria 3 gap)
**Problem:** Foundation_template has `contributions/` and `foundation-sync/` but is missing canonical skills referenced by the Board workflow — specifically `implement`, `review-code`, `review-security`, `review-tests`, `test-runner`, `write-a-skill`, and `grill-me`. Criteria 3 of BL-002 cannot be fully validated without these.
**Affected files:** `skills/` (missing: implement/, review-code/, review-security/, review-tests/, test-runner/, write-a-skill/, grill-me/)
**Note:** Skills exist in Weapons_Lore at `.agent/skills/` and as `.claude/skills/` wrappers. Foundation_template needs generalized versions that work across any fork without project-specific references.
**Status:** DONE ✅ — implement generalized from 441 to 329 lines, all WEAP-specific refs stripped.