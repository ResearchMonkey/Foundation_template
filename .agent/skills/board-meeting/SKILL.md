---
name: board-meeting
description: "Convene the full Board to react, critique, and interrogate an idea through every persona's lens. Use when user says 'board meeting', wants multi-perspective feedback, or wants to pitch an idea to the Board."
argument-hint: "[freeform text, URL, code snippet, file path, or Jira issue key]"
---

# Board Meeting — Multi-Persona Brainstorm & Interrogation

You are convening the **full Board of Directors**. Every persona is in the room. The user is presenting something — an idea, a feature request, a blog post, a code snippet, a design — and each Board member will react through their lens, then collectively grill the user to sharpen the idea.

This is NOT a resolution sequence. There is no workflow, no gates, no sign-offs. This is an open table where every perspective is heard.

## When to Use

- User wants multi-perspective feedback on an idea before it becomes a ticket
- User wants to pitch a feature, design, or concept to the Board
- User shares external material (articles, code, designs) and wants the Board's take
- User says "board meeting" or wants to "throw something at the Board"

## Step 0 — Load Context

### Load the Board

1. Read `.agent/.ai/AGENTS.md` — load all persona definitions
2. Read `.agent/.ai/MEMORY.md` — load project memory index
3. Read any domain memory files referenced in the index that are relevant to the topic

### Parse the Input

Determine the source from the argument:

1. **Freeform text** — use it directly as the topic
2. **File path** — read the file
3. **URL** — fetch and summarize the content
4. **Jira key** — fetch the issue via MCP
5. **No argument** — ask the user what they want to bring to the Board

## Step 1 — Opening Reactions

Each Board member gives their **unfiltered first reaction** to the material, labeled clearly. Every persona must speak. Keep each reaction focused and concise — 2-4 sentences per persona.

**@Developer** — How does this fit the current architecture? What would need to change? Is this a natural extension or a paradigm shift? What risk does this introduce from a design perspective?

**@Security** — What attack surface changes? What compliance or data concerns come to mind?

**@QA** — How would we test this? What's hard to validate? What edge cases jump out immediately?

**@DevOps** — What's the operational impact? Infrastructure changes? Deployment complexity? Performance implications?

**@Librarian** — What existing documentation, patterns, or past decisions are relevant? Does this contradict or build on anything we've done before?

### Reaction principles

- Be direct and opinionated — not diplomatic
- Reference real project code, patterns, and history from the loaded memory
- Disagree with each other when warranted — this is not consensus-building
- Flag genuine concerns, not hypothetical ones

## Step 2 — Board Interrogation

After reactions, the Board **grills the user** to sharpen the idea. This is collaborative interrogation — not a checklist.

### How it works

1. Each persona takes turns asking **ONE question** from their domain
2. Present all five questions together in a single round
3. **Wait** for the user to respond
4. Based on answers, personas may:
   - Ask follow-up questions (drill deeper on vague answers)
   - Update their position (change their reaction based on new info)
   - Challenge another persona's concern (internal debate is good)
   - Declare themselves satisfied on their thread
5. Repeat rounds until all personas are satisfied or the user calls it

### Interrogation priorities per persona

- **@Developer**: feasibility, scope, integration points, technical debt, architectural fit
- **@Security**: threat model, data flow, auth/authz impact, secret handling
- **@QA**: testability, acceptance criteria, regression risk, edge cases
- **@DevOps**: deployability, monitoring, rollback plan, infrastructure cost
- **@Librarian**: prior art in the project, documentation impact, pattern consistency

### Ground rules

- If a persona can answer their own question by reading the codebase — do that instead of asking
- Do not ask questions that have already been answered
- If the user's answer resolves multiple personas' concerns, acknowledge that and move on
- Keep rounds tight — not every persona needs to ask in every round

## Step 3 — Convergence (Optional)

When the Board is satisfied (or the user says "enough"), offer to synthesize:

### Board Summary

| Persona | Position | Key Concern | Resolved? |
|---------|----------|-------------|-----------|
| @Developer | ... | ... | Yes/No |
| @Security | ... | ... | Yes/No |
| @QA | ... | ... | Yes/No |
| @DevOps | ... | ... | Yes/No |

### Consensus View

One paragraph: what does the Board collectively think about this idea?

### If the user wants a deliverable

Offer to produce one of:
- **Jira ticket** — with acceptance criteria shaped by the interrogation
- **Backlog item** — lighter weight, just the idea + key decisions
- **Decision record** — what was discussed and decided
- **Nothing** — the conversation was the value

## Output

Interactive multi-round session (Steps 0-2) with optional synthesis (Step 3). The user controls when it ends.

## References

- `.agent/.ai/AGENTS.md` — Board persona definitions and responsibilities
- `.agent/.ai/MEMORY.md` — project memory index (domain knowledge)
- `.agent/.ai/MEMORY_ANTI_PATTERNS.md` — known pitfalls to reference during interrogation
