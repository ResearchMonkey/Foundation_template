---
name: qa-pathfinder
description: Map all user paths in a web application by reading its source code and API routes, then generate a PATHS.md coverage map and test stubs. Use when asked to discover, map, or test all user paths in a web application. Triggers: "map user paths", "QA all routes", "find all pages", "crawl application", "find navigation paths", "test all flows". No external AI API keys required — works by reading source code and tracing actual HTTP endpoints with curl/exec.
---

# qa-pathfinder

Map all user paths in a web application through source code analysis, then generate test stubs.

## Core Principle

**No external AI required.** You have exec, file read, and HTTP access. Read the actual code, trace the actual routes, hit the actual endpoints. The application is the ground truth — not an AI's interpretation of screenshots.

## Workflow

### Phase 1 — Source Discovery

1. **Find the frontend entry point**
   ```
   Read App.jsx or main.jsx → identify routing library (React Router, Next.js, etc.)
   ```

2. **Map all routes**
   ```bash
   grep -rn "Route\|Routes\|useRoute\|Link\|href\|navigate\|push\|path" src/ --include="*.jsx" --include="*.tsx" | grep -v "css\|className\|style"
   ```

3. **Find ALL API endpoints** — check every main.py/app.py in backend/
   ```bash
   grep -rn "@router\|@app\|@get\|@post\|@put\|@delete" backend/ --include="*.py" | grep -v __pycache__
   ```
   ⚠️ Multiple apps may exist — `backend/main.py` AND `backend/app/main.py` are separate apps

4. **Identify UI states and interactions**
   ```bash
   grep -rn "useState\|onClick\|handle\|submit\|fetch\|axios\|useEffect" src/ --include="*.jsx" --include="*.tsx"
   ```

### Phase 2 — Active Path Discovery

Hit real endpoints to confirm they work:

```bash
# Health check
curl -s http://localhost:PORT/health

# List all routes
curl -s http://localhost:PORT/api

# Trace each endpoint
curl -s http://localhost:PORT/api/TARGET/ENDPOINT
```

### Phase 3 — Build PATHS.md

```markdown
# Discovered Paths — PROJECT_NAME

Generated: YYYY-MM-DD by qa-pathfinder

## Frontend Routes

| Route | Component | Params | Notes |
|-------|-----------|--------|-------|
| /app | App.jsx | — | Root, two-tab layout |
| /app → Presets tab | PresetsTab.jsx | — | Channel list + GO |
| /app → Scan tab | ScanTab.jsx | — | Waterfall + activity log |

## API Endpoints

| Method | Path | Handler | Params | Response |
|--------|------|---------|--------|----------|
| GET | /health | health_check | — | {status, app, version} |
| GET | /api/sdr/status | get_status | — | SDRStatus |
| POST | /api/sdr/config | configure_sdr | SDRConfig | {message, config} |

## User Paths

### Path 1: Monitor a channel
1. GET /api/gmrs/channels → view channel list
2. Click channel row → set selectedChannel state
3. Tap GO button
4. POST /api/sdr/config {frequency, gain, sample_rate, squelch_level}
5. POST /api/sdr/start
→ Monitor starts, signal strength streams

### Path 2: Wideband scan
1. Click "Wideband Scan" tab
2. Tap "Start Scan" → POST /api/sdr/start
3. GET /api/sdr/spectrum (polls every 250ms)
4. Activity log fills with detected signals
5. Tap waterfall → POST /api/sdr/config with tapped frequency
6. Tap "Stop Scan" → POST /api/sdr/stop

## Coverage Assessment

| Path | Status | Notes |
|------|--------|-------|
| Presets → GO | ✅ Tested | Works |
| Scan → Start Scan | ✅ Tested | Works |
| Scan → tap waterfall | ❌ Untested | — |
| Sunlight toggle | ❌ Untested | — |

## Test Stubs

```python
# tests/test_user_paths.py
import pytest

class TestPresetsTab:
    def test_channel_list_loads(self, client):
        res = client.get("/api/gmrs/channels")
        assert res.status_code == 200
        assert len(res.json()["channels"]) > 0

    def test_go_starts_monitoring(self, client):
        res = client.post("/api/sdr/config", json={
            "frequency": 462.5625e6, "gain": 30, "sample_rate": 2400000, "squelch_level": -60
        })
        assert res.status_code == 200
        res = client.post("/api/sdr/start")
        assert res.status_code == 200

class TestScanTab:
    def test_spectrum_returns_256_bins(self, client):
        res = client.get("/api/sdr/spectrum")
        assert res.status_code == 200
        assert len(res.json()["data"]) == 256
```

## Checklist Before Marking Done

- [ ] All frontend routes identified
- [ ] ALL backend app files found (check `backend/app/main.py` separately)
- [ ] All API endpoints identified per app
- [ ] Real HTTP requests made to confirm each endpoint
- [ ] User paths documented from state tracing
- [ ] PATHS.md created
- [ ] Test stubs generated
- [ ] Coverage: tested vs untested paths flagged

## Key Files to Read

| Project | What to read |
|---------|--------------|
| React/Vite | `src/App.jsx`, `src/components/*.jsx` |
| FastAPI app 1 | `backend/main.py`, `backend/api/routes/*.py` |
| FastAPI app 2 | `backend/app/main.py` (separate app) |
| Next.js | `pages/`, `app/` |
| Express | `routes/`, `app.js` |

## Path Resolution

```bash
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
```
