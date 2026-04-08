# Memory: Active Anti-Patterns (What NOT to Do)

> **Authority:** Project-specific coding standards (`CODING_STANDARDS.md`) take precedence over this file.

Loaded during code review, @QA validation, or when the relevant domain is active.

> **Project-Type Tags:** Each anti-pattern below is tagged with the project types it applies to.
> Tags use these abbreviations: `all`, `web-app`, `cli`, `library`, `automation`, `fullstack`, `tui`, `embedded`, `lambda`.
> **Important:** Tags indicate which types the pattern is RELEVANT to — not exclusive. Type-specific tags reduce
> noise but do not replace judgment. Every project should consider every anti-pattern; tags just indicate
> "this is commonly applicable here."

---

* **[Anti-001] "Ghost Features":** Documenting features that are not yet coded. `[all]`

* **[Anti-002] "Happy Path" Testing:** Writing tests that only check for success, ignoring failure modes. `[all]`

* **[Anti-003] "Silent Mutations":** Create/update/delete operations that don't refresh the affected view afterward. Every mutation MUST close modal → show feedback → refresh list → navigate to correct context. `[web-app, fullstack]` (N/A for read-only or CLI projects)

* **[Anti-004] "Inline Modals":** Rendering modals as hidden inline HTML instead of using the shared modal component. `[web-app, fullstack]` (N/A for non-UI projects)

* **[Anti-005] "Null-Blind Rendering":** Accessing chained properties without null guards. Any property access on external/API data MUST use optional chaining or explicit null checks. `[all]`

* **[Anti-006] "Swallowed Errors":** Catch blocks that only log without user feedback. Every catch for a user-initiated action MUST surface a meaningful error to the user. `[all]`

* **[Anti-007] "Context-Blind Navigation":** Save/create flows that always navigate to the same page regardless of origin. Multi-context features MUST track source context and return to the originating page. `[web-app, fullstack, tui]` (N/A for non-interactive projects)

* **[Anti-008] "ID Format Mismatch":** Frontend sending a slug/username where the API expects a numeric ID (or vice versa). API contracts MUST document parameter types. `[web-app, fullstack]` (Relevant when frontend and backend are separate)

* **[Anti-009] "Unusable Options in Dropdowns":** Showing options a user cannot successfully use. Dropdowns MUST only include choices valid for that action. `[web-app, fullstack, tui]` (N/A for non-interactive or batch projects)

* **[Anti-010] "Invisible API Changes":** Adding a new field to an API endpoint without updating the API documentation. A new API field is always doc-impacting. `[web-app, fullstack, cli, library, automation]` (N/A for purely local scripts with no consumers)

* **[Anti-011] "Dropped Planned Tests":** Committing code without implementing the tests stated in the implementation plan. If skipped due to time pressure, the plan must be updated and the gap filed as a follow-up issue. `[all]`

* **[Anti-012] "Retry-Masked Failures":** Using test retries to make flaky tests pass instead of fixing the root cause. Retries are only acceptable for post-deploy smoke tests, not for pre-merge quality gates. `[all]`

* **[Anti-013] "Environment-Blind Tests":** Writing tests that only work in one environment (e.g. direct DB access, hardcoded URLs) without documenting constraints or making them environment-aware. `[all]` (especially relevant for `web-app`, `fullstack`, `cli`, `automation`)

* **[Anti-014] "Batch Collapse":** When processing multiple issues in batch mode, collapsing all updates into a single comment instead of updating each issue individually. Each issue must receive its own updates. `[all]` (especially relevant for `cli`, `automation`)

* **[Anti-015] "Namespace-Blind References":** Hardcoding paths that assume a framework or library lives at a fixed location in the file tree (e.g., `.agent/.ai/BOOTSTRAP.md`). When the framework is embedded in another project (e.g., under `.foundation/`), every hardcoded path breaks. Solution: use a path resolution fallback chain — check local path first, fall back to the embedded prefix. This applies to any framework that gets embedded via git subtree, submodule, or similar. `[all]`

---

## Adding Project-Specific Anti-Patterns

Anti-001 through Anti-015 above are generic and portable across all projects. Fork projects may add their own project-specific anti-patterns below this line, using their own numbering scheme and project-type tags. When in doubt: keep project-specific patterns in the fork, don't push them upstream.

## Project-Type Quick Reference

| Tag | Project Type | Examples |
|-----|-------------|---------|
| `web-app` | Browser-based web application | React/Vue/Angular SPAs, server-rendered apps |
| `cli` | Command-line interface tool | Build tools, generators, utilities |
| `library` | Reusable library or package | npm packages, PyPI packages, Go modules |
| `automation` | Workflow/CI automation | CI runners, webhooks, cron jobs, bots |
| `fullstack` | Full-stack app with both frontend and backend | Monolith web apps with server-side rendering |
| `tui` | Terminal user interface | Interactive CLI tools with terminal UI |
| `embedded` | Embedded/IoT software | Firmware, microcontroller code |
| `lambda` | Serverless function | AWS Lambda, Cloudflare Workers, Vercel Functions |
| `other` | Doesn't fit above | (use freeform description) |
