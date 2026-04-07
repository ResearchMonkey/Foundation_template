# Approval Policy

<!-- TODO: Fork projects — define your approval workflow and escalation paths -->

## Risk-Based Approval Matrix

| Risk Tier | Approver | Human Required? | Turnaround |
|-----------|----------|-----------------|------------|
| LOW | ARCH self-authorizes | No | Immediate |
| MEDIUM | SEC review | No | Same session |
| HIGH | SEC review + human confirmation | Yes | Before merge |
| CRITICAL | SEC review + human confirmation + stakeholder | Yes | Immediate escalation |

## Escalation Path

1. **Agent disagreement** — ARCH and SEC disagree on risk tier → escalate to human.
2. **Human unavailable** — HIGH/CRITICAL work pauses; do not proceed without sign-off.
3. **Security incident** — Skip normal queue; follow `SECURITY_OPERATIONS.md` incident response.

## Sign-Off Format

For HIGH/CRITICAL approvals, document:

```
APPROVED: [risk tier]
REVIEWER: [human or agent role]
SCOPE: [what was reviewed]
CONDITIONS: [any caveats or follow-up required]
DATE: [ISO 8601]
```

## Override Policy

- No agent may override a human rejection.
- ARCH may override SEC for LOW-risk items only.
- QA veto cannot be overridden — find the "Path to Green."
