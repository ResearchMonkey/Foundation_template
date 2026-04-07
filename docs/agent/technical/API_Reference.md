# API Reference

<!-- TODO: Fork projects — document your API endpoints and field definitions here -->

This file tracks API endpoints, request/response fields, and contract details. Keep it updated when adding or changing API fields to prevent frontend/backend drift.

## How to Use

When adding or modifying an API endpoint:
1. Add or update the entry in the appropriate section below.
2. Include method, path, request fields, response fields, and auth requirements.
3. Flag breaking changes with a `BREAKING` label.

## Endpoints

<!-- Example format — replace with your actual endpoints:

### `GET /api/users/:id`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| **Request** | | | |
| `id` | string (UUID) | Yes | User identifier |
| **Response** | | | |
| `id` | string | — | User UUID |
| `email` | string | — | User email |
| `created_at` | ISO 8601 | — | Account creation timestamp |

**Auth:** Bearer token required
**Risk:** MEDIUM — returns PII

-->

## Field Naming Conventions

- Use `snake_case` for all API field names.
- Dates: ISO 8601 format (`2024-01-15T09:30:00Z`).
- IDs: document the type (UUID, integer, slug) to prevent ID format mismatch (Anti-008).
- Booleans: prefix with `is_`, `has_`, or `can_` for clarity.

## Breaking Change Log

| Date | Endpoint | Change | Migration Notes |
|------|----------|--------|-----------------|
| <!-- e.g. 2024-03-15 --> | <!-- e.g. GET /api/users --> | <!-- e.g. removed `name` field, split into `first_name` + `last_name` --> | <!-- e.g. clients must update to use new fields --> |
