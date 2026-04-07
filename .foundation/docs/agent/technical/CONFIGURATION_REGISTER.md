# Configuration Register

<!-- TODO: Fork projects — document all hardcoded constants here as you add them -->

This file tracks hardcoded constants, configuration values, and magic numbers across the project. Every module-scope `UPPER_SNAKE_CASE` constant should have an entry here.

## How to Use

When adding or modifying a constant:
1. Add a row to the appropriate category below.
2. Include the file path, constant name, current value, and purpose.
3. Flag whether it's safe to change without coordination.

## Security Constants

| Constant | File | Value | Safe to Change? | Purpose |
|----------|------|-------|-----------------|---------|
| <!-- e.g. SESSION_TTL --> | <!-- e.g. src/auth/config.ts --> | <!-- e.g. 3600 --> | <!-- No — coordinate with SEC --> | <!-- Session timeout in seconds --> |

## API Constants

| Constant | File | Value | Safe to Change? | Purpose |
|----------|------|-------|-----------------|---------|
| <!-- e.g. MAX_PAGE_SIZE --> | <!-- e.g. src/api/pagination.ts --> | <!-- e.g. 100 --> | <!-- Yes --> | <!-- Maximum items per page --> |

## Feature Flags

| Flag | File | Default | Purpose |
|------|------|---------|---------|
| <!-- e.g. ENABLE_DARK_MODE --> | <!-- e.g. src/config/features.ts --> | <!-- false --> | <!-- Dark mode toggle --> |

## Infrastructure Constants

| Constant | File | Value | Safe to Change? | Purpose |
|----------|------|-------|-----------------|---------|
| <!-- e.g. MAX_RETRIES --> | <!-- e.g. src/http/client.ts --> | <!-- e.g. 3 --> | <!-- Yes --> | <!-- HTTP retry limit --> |
