# Architecture Standards

<!-- TODO: Fork projects — customize planning requirements, thresholds, and module boundaries for your stack -->

> **Owner:** This is a user-owned standards document. Edit this file to change the rules your AI agents follow when planning and designing changes.  
> **Consumer:** `@Architect` persona, `implement` skill.

## 1. Planning Checklist

Before handing off to SEC/OPS:

- [ ] Scope is clear — files, functions, and tests identified
- [ ] Risk tier assigned (LOW / MEDIUM / HIGH / CRITICAL) per `docs/SECURITY_STANDARDS.md`
- [ ] Breaking changes flagged (API, DB, config)
- [ ] "Docs to Update" line included if constants/API fields change
- [ ] Test plan sketched (happy path + failure cases)

## 2. When Planning Is Required

Produce a written plan (steps, files, risks) before generating code when:

- Change spans **3+ files**
- Change touches **auth, data, or payments**
- Change involves **database schema migrations**
- Change introduces a **new module or subsystem**

For smaller changes, inline reasoning is sufficient.

## 3. Design Doc Requirements

A design doc or architecture note is required when:

- A new module or subsystem is created (new file > 200 lines)
- A significant architectural pattern is introduced
- Multiple services or systems are affected

Design docs should include: problem statement, proposed approach, alternatives considered, and risks.

## 4. File Organization

- Files over **300 lines** should be evaluated for splitting
- Files over **500 lines** require justification for keeping as a single file
- Each module should have a **single clear responsibility**
- Cross-module dependencies must be documented

## 5. API Design

- Follow RESTful conventions (or project-specific conventions)
- Document all endpoints in `docs/agent/technical/API_Reference.md`
- Breaking changes require migration notes in the PR description
- Version APIs when backward compatibility cannot be maintained

## 6. Doc Impact Scan

For each file being modified, check for hardcoded constants or config values that should be documented:

- Cross-reference `docs/agent/technical/CONFIGURATION_REGISTER.md` for constants
- Cross-reference `docs/agent/technical/API_Reference.md` for API fields
- If any constant is undocumented, add a "Docs to Update" line to the plan
