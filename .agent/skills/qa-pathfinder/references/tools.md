# qa-pathfinder Methodology

No AI required. Use these techniques to map applications systematically.

## Source Analysis

### Frontend Routes (React)

```bash
grep -rn "Route\|Routes\|useRoute\|Link\|href\|navigate\|push" src/ \
  --include="*.jsx" --include="*.tsx" | grep -v "css\|style\|aria"
```

Look for: `Route path=`, `Link to=`, `useNavigate()`, `useRouter()`

### Frontend State (React)

```bash
grep -rn "useState\|onClick\|handle\|submit\|fetch\|axios\|useEffect" src/ \
  --include="*.jsx" --include="*.tsx"
```

Identifies: interactive elements, API calls, component state

### Backend Routes (FastAPI)

```bash
grep -rn "@router\|@app\.get\|@app\.post\|@get\|@post\|@put\|@delete" backend/ \
  --include="*.py" | grep -v __pycache__
```

### Backend Models

```bash
grep -rn "class.*BaseModel\|class.*Model\|pydantic" backend/ \
  --include="*.py" | grep -v __pycache__
```

## HTTP Tracing

Always verify with real requests:

```bash
# Basic health
curl -s http://HOST:PORT/health | python3 -m json.tool

# All API routes
curl -s http://HOST:PORT/api | python3 -m json.tool

# Endpoint with JSON body
curl -s -X POST http://HOST:PORT/api/endpoint \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}' | python3 -m json.tool

# Form data
curl -s -X POST http://HOST:PORT/api/endpoint \
  -F "file=@test.csv"
```

## UI State Tracing

For each button/interactive element:
1. Read the handler function
2. Identify state mutations
3. Identify API calls made
4. Identify navigation (route changes)
5. Document the full sequence as a User Path

## Framework Patterns

### React + Vite
```
src/App.jsx        — root, routing, tab state
src/main.jsx       — entry point
src/components/    — UI components
```

### FastAPI
```
backend/main.py         — app creation, route registration
backend/api/routes/     — route handlers
backend/core/           — business logic
backend/config.py       — settings
```

### Next.js
```
app/               — App Router pages
pages/             — Pages Router
app/api/            — API routes
```

## Coverage Checklist

| Check | How |
|-------|-----|
| All routes discovered | Read every .jsx/.py file |
| All endpoints respond | `curl` each one |
| State changes mapped | Trace `useState` + handlers |
| Error paths covered | 4xx, 5xx responses |
| Auth flows | Login, session, token storage |
| Realistic sequences | User Path = trigger → state → API → response → render |

## Output Format

Always produce:
1. `PATHS.md` — route table + user path descriptions
2. Test stubs — pytest functions per user path
3. Coverage assessment — tested vs untested paths
