# Coding Standards

<!-- TODO: Fork projects — replace these with your team's actual standards -->

## 1. General Principles

- **Clarity over cleverness** — code is read more than written.
- **Consistency** — follow existing patterns in the file/module you're editing.
- **Small, focused changes** — one concern per commit.

## 2. Naming

- Use descriptive names that reveal intent.
- Prefer full words over abbreviations (`getUserById` not `getUsrById`).
- Constants: `UPPER_SNAKE_CASE`.
- Functions/variables: follow language convention (camelCase for JS/TS, snake_case for Python, etc.).

## 3. Error Handling

- Never swallow errors silently — always log or surface to the user.
- Use typed errors where the language supports them.
- Validate at system boundaries (user input, external APIs); trust internal code.

## 4. Testing

- Write the failing test first when fixing bugs.
- Test behavior, not implementation.
- Name tests to describe the scenario: `should return 404 when user not found`.

## 5. Security

- No secrets in source code — use environment variables or secret managers.
- Sanitize user input before use in queries, HTML, or shell commands.
- Use parameterized queries — never string-concatenate SQL.
- See `.agent/.ai/RISK_LEVELS.md` for risk classification.

## 6. Documentation

- Document "why", not "what" — the code shows what.
- Keep `CONFIGURATION_REGISTER.md` updated when adding constants.
- Keep `API_Reference.md` updated when adding/changing API fields.

## 7. Dependencies

- Justify new dependencies in the PR description.
- Prefer well-maintained packages with active security support.
- Pin versions in lock files.

## 8. Git Hygiene

- Conventional commit messages (or project-specific format).
- No merge commits on feature branches — rebase onto main.
- Reference issue/ticket keys in commit messages.
