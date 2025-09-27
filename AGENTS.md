# Repository Guidelines

## Official References

### Frontend

- **Framework & Language**
  - [Next.js docs](https://nextjs.org/docs): Use the official patterns when deciding UI routing and directory layout.
  - [React docs](https://react.dev/learn): Ground component composition, hooks, and state management in the current best practices.
  - [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html): Align shared types, utilities, and generics with the official guidance applied in `frontend/`.

- **State & Data**
  - [TanStack Query docs](https://tanstack.com/query/latest/docs/react/overview): Manage server state, caching, and optimistic updates in the resume and section flows.

- **Forms & Validation**
  - [React Hook Form docs](https://react-hook-form.com/get-started): Base form state management and validation flows on the official hook patterns.
  - [Zod docs](https://zod.dev/?id=basic-usage): Define and refine schema validation paired with React Hook Form resolvers.

- **UI & Styling**
  - [shadcn/ui docs](https://ui.shadcn.com/docs): Reference the component primitives and composition patterns we mirror in our UI layer.
  - [Tailwind CSS docs](https://tailwindcss.com/docs): Ground utility class usage and configuration overrides in the official guidance.

- **Testing**
  - [Testing Library docs](https://testing-library.com/docs/react-testing-library/intro/): Follow the canonical approach for component-level tests alongside Vitest.
  - [Vitest docs](https://vitest.dev/guide/): Use the de facto standard runner for Next.js component, hook, and integration tests.

- **Tooling**
  - [Biome docs](https://biomejs.dev/guides/getting-started/): Rely on the unified linter/formatter for Next.js projects using the ESLint compatibility layer.
  - [pnpm docs](https://pnpm.io/motivation): Follow the recommended workflow for dependency management and workspaces.

### Backend

- **Framework & Architecture**
  - [FastAPI docs](https://fastapi.tiangolo.com/): Follow best practices for routers, dependency injection, and configuration organization.
  - [FastAPI bigger applications](https://fastapi.tiangolo.com/tutorial/bigger-applications/): Mirror the recommended project layout when splitting routers, services, and dependencies.

- **Runtime & Deployment**
  - [Gunicorn docs](https://docs.gunicorn.org/en/stable/): Combine with Uvicorn workers when deploying on traditional process managers.
  - [Uvicorn docs](https://www.uvicorn.org/): Configure the ASGI server for local development and production tuning.

- **Data & Persistence**
  - [Alembic docs](https://alembic.sqlalchemy.org/en/latest/): Mirror the recommended migration scripts and upgrade patterns.
  - [PostgreSQL docs](https://www.postgresql.org/docs/current/): Validate SQL features, migrations, and operational guidelines for the primary datastore.
  - [Pydantic docs](https://docs.pydantic.dev/latest/usage/models/): Reference canonical patterns for schema validation and settings management.
  - [SQLAlchemy docs](https://docs.sqlalchemy.org/en/20/): Align ORM usage, session management, and migrations with the current best practices.
  - [SQLite docs](https://www.sqlite.org/docs.html): Reference in-memory database behavior for test fixtures and lightweight prototyping.
  - [boto3 docs](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html): Interact with S3-compatible storage (AWS S3, Cloudflare R2) for export uploads.

- **Tooling & Quality**
  - [mypy docs](https://mypy.readthedocs.io/en/stable/): Enforce static type checking for FastAPI services and shared libraries.
  - [Pytest docs](https://docs.pytest.org/en/stable/): Double-check fixtures, parametrization, and plugin usage when shaping backend tests.
  - [Ruff docs](https://docs.astral.sh/ruff/): Apply the combined linting and formatting tooling with project-specific rules.
  - [uv docs](https://docs.astral.sh/uv/): Use the official guidance for managing Python tooling and dependency workflows.

- **Rendering & Export**
  - [Playwright for Python docs](https://playwright.dev/python/docs/intro): Use headless Chromium to render Next.js templates and export PDFs that match the SSR preview.

- **Logging & Observability**
  - [structlog docs](https://www.structlog.org/en/stable/): Produce structured JSON logs and bind contextual data for FastAPI services.

- **Auth & Security**
  - [Passlib docs](https://passlib.readthedocs.io/en/stable/): Apply password hashing algorithms recommended by FastAPI security guidance.
  - [PyJWT docs](https://pyjwt.readthedocs.io/en/stable/): Implement token issuance and validation aligned with the JWT spec.

### Cross-cutting

- **Testing & QA**
  - [Playwright docs](https://playwright.dev/docs/test-intro): Model end-to-end specs after the supported helpers and testing conventions that span frontend and backend flows.

- **Platform & Automation**
  - [Docker docs](https://docs.docker.com/get-started/): Standardize containerized development for local and CI environments.
  - [Docker Compose docs](https://docs.docker.com/compose/): Orchestrate the multi-service stack used for local development.
  - [GitHub Actions docs](https://docs.github.com/actions): Run CI pipelines for linting, tests, and container builds.

### Community Guides

- [fastapi-best-practices](https://github.com/zhanymkanov/fastapi-best-practices/blob/master/README.md): Scan pragmatic do's and don'ts that complement the official FastAPI guidance.
- [full-stack-fastapi-template](https://github.com/fastapi/full-stack-fastapi-template/tree/master): Reference a maintained scaffold when evaluating full-stack project organization.

## Project Structure & Module Organization

- `frontend/`: Next.js + TypeScript app. Co-locate route handlers and UI under `app/` (or `src/` if adopted), mirror API paths inside `app/api`, and keep shared utilities in `frontend/lib/`. Co-locate component tests as `*.test.tsx` beside the source, and e2e specs under `frontend/e2e/`. Add a short README for any sub-module that spans more than one screen of context.
- `backend/`: FastAPI service. Keep routers in `backend/app/api/`, schemas in `backend/app/schemas/`, and services in `backend/app/services/`. Centralize settings in `backend/app/core/config.py`, load secrets via environment variables or `.env` (never commit secrets), and group tests under `backend/tests/` with fixtures in `backend/tests/conftest.py`.
- `docs/`: Product and technical source of truth (PRD, API spec, glossary). Update the relevant doc in the same PR whenever behavior changes, and cross-link from your PR description.

## Build, Test, and Development Commands

- `docker compose up`: Bring up the application stack (frontend, backend, databases, supporting services) for end-to-end validation.
- Frontend:
  - `cd frontend && pnpm install && pnpm dev`: Install dependencies and run the Next.js dev server.
  - `cd frontend && pnpm lint`: Run Biome in lint + format-check mode.
  - `cd frontend && pnpm test`: Execute the Vitest suite (consider `--watch` during development).
  - `cd frontend && pnpm exec playwright test`: Run Playwright end-to-end specs when they exist.
- Backend:
  - `cd backend && uv sync`: Install Python dependencies using uv (use `uv venv` if a virtualenv is needed).
  - `cd backend && uv run uvicorn app.main:app --reload`: Start the FastAPI dev server with auto-reload.
  - `cd backend && uv run pytest --cov`: Execute the Pytest suite with coverage enabled.
  - `cd backend && uv run ruff check` / `uv run ruff format --check`: Lint and ensure formatting with Ruff.
  - `cd backend && uv run mypy`: Perform static type checking.
- `make format` and `make check`: Provide composite entry points that wrap the commands above (keep them in sync with the tooling choices).

## Coding Style & Naming Conventions

- Python: Ruff + mypy as the canonical toolchain; 4-space indentation, snake_case modules, CamelCase Pydantic models, and explicit type hints on public APIs. See `backend/CODING_STYLE.md` for detailed conventions (async patterns, router/service structure, Playwright workflow, S3 uploads).
- TypeScript/React: Biome with `next/core-web-vitals`; components in PascalCase, hooks/utilities in camelCase, styles as `Component.module.scss`, and named exports. See `frontend/CODING_STYLE.md` for App Router structure, client/server component rules, TanStack Query patterns, and Tailwind/shadcn usage.
- Shared: Keep API routes kebab-case (e.g., `/resume-builder`), database tables snake_case, and prefix feature flags/configuration keys with `RESUME_*`. Document non-trivial behaviour in `/docs` or the per-project coding style guides.

## Testing Guidelines

- Backend: Organise tests under `backend/tests/`, mirroring router paths (`test_api_resume.py`). Maintain fixtures in `backend/tests/conftest.py`, target ≥80% coverage on new code, and run `uv run pytest --cov` before opening a PR. Add Ruff/mypy to CI to prevent regressions.
- Frontend: Colocate Vitest specs as `Component.test.tsx` beside components and run them with `pnpm test`. Use Testing Library patterns, and introduce Playwright specs under `frontend/e2e/` for multi-step flows (`pnpm exec playwright test`).
- Document any manual verification steps in the PR checklist whenever automated coverage is not feasible.

## Commit & Pull Request Guidelines

- Follow the existing conventional prefix pattern (`docs:`, `feature/`, `ci:`). Use imperative mood and include the GitHub issue or PR number in parentheses when applicable (`feature/api spec (#14)`).
- Keep commits focused; squash fixups before pushing.
- Pull requests must describe scope, testing performed, and affected docs. Attach screenshots or curl examples for new endpoints/UI. Request reviews from domain owners (backend, frontend, docs) and link relevant doc updates.

## Documentation & Knowledge Base

- Treat `/docs` as canonical. When behavior changes, update the relevant doc in the same PR.
- Capture architecture decisions in `docs/adr/` (create the directory if absent) to keep rationales searchable for future agents.
