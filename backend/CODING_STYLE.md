# Backend Coding Style

## Project Layout

- Organize FastAPI routers under `backend/app/api/` mirroring REST paths; place business logic in `backend/app/services/` and data access in `backend/app/repositories/` (create the directory when needed).
- Keep Pydantic schemas in `backend/app/schemas/`; distinguish request/response models and DTOs.
- Store background tasks, workers, or Playwright PDF helpers under `backend/app/workers/` or `backend/app/export/` as appropriate.
- Consolidate configuration in `backend/app/core/config.py`; load secrets via environment variables or `.env` managed by uv.

## Async & Concurrency

- Declare router handlers as `async def`; use `fastapi.concurrency.run_in_threadpool` when calling synchronous libraries (e.g., boto3) from async contexts.
- Prefer async-capable libraries when available (e.g., `aioboto3`) but document the choice in ADR if diverging from standard boto3.
- Offload long-running tasks (Playwright PDF generation) to background workers or Celery/RQ if response latency is critical.

## Typing & Linting

- Annotate all public functions, service methods, and dependencies with explicit types. Avoid `Any` except at integration boundaries.
- Run `uv run ruff check`, `uv run ruff format`, and `uv run mypy` before committing; configure these in CI.
- Use module-level docstrings to describe routers/services and reference relevant sections in `/docs`.

## Database & Persistence

- Use SQLAlchemy declarative models with snake_case table names; access the session via dependency injection.
- Apply Alembic migrations for schema changes; keep upgrade/downgrade scripts idempotent and reference ADRs when altering critical tables.
- Interact with S3-compatible storage via boto3 (or aioboto3 if asynchronous usage is chosen). Wrap upload logic in dedicated service modules for reuse.

## PDF Rendering & Export

- Render PDFs with Playwright (Chromium). Provide helper utilities that accept a public/internal URL for the Next.js template and return the stored file key/URL.
- Ensure Playwright dependencies are installed in the container image and share launch options (headless, viewport, wait strategies) via configuration.

## Testing

- Place tests under `backend/tests/` mirroring router/service structure (e.g., `tests/api/test_resumes.py`).
- Maintain reusable fixtures in `backend/tests/conftest.py`; include database setup/teardown, storage mocks, and Playwright stubs where needed.
- Run `uv run pytest --cov` locally; strive for ≥80% coverage on new modules and document gaps in PRs.

## API Conventions

- Use kebab-case for REST paths and snake_case for JSON keys unless camelCase is required by the client.
- Return `pydantic` response models; surface validation errors via FastAPI's standard problem details.
- Centralize error handling in custom exception handlers when business logic requires consistent messaging.

## Logging & Observability

- Use `structlog` on top of the standard logging module. Configure JSON output, include request IDs/trace IDs, and bind contextual data (user, resume_id) at the entry points.
- Emit metrics/events for export processing, storage failures, and quota checks. Wire health checks under `/health`.

## General Guidelines

- Avoid business logic inside router functions; delegate to services and repositories for testability.
- Keep modules focused; split files when they exceed ~400 lines or handle multiple resource types.
- Reference ADRs for significant architectural decisions (PDF pipeline, storage choice, async strategy) and keep `/docs` synchronized.
