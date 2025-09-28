# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

resu:me is an AI Resume & Portfolio Generator with a FastAPI backend and Next.js frontend, designed for a 1-month MVP launch. It allows users to create, edit, and share web portfolios and PDF resumes through a form-based interface.

**Tech Stack:**

- Backend: Python/FastAPI, PostgreSQL (Neon in prod), Playwright for PDF generation
- Frontend: Next.js (App Router), TypeScript, React Hook Form, TanStack Query, Tailwind CSS, shadcn/ui
- Storage: Cloudflare R2 (prod) / MinIO (local)
- Deployment: Vercel (frontend) + Fly.io (backend/Playwright worker)

## Development Commands

### Local Development Stack

```bash
# Initial setup - copy environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.local

# Start full stack with Docker Compose
docker compose up --build

# Stop and clean volumes
docker compose down -v
```

**Service endpoints:**

- Backend API: <http://localhost:8000>
- Frontend App: <http://localhost:3000>
- PostgreSQL: localhost:5432 (user: resume, pw: resume)
- MinIO: <http://localhost:9000> (console: <http://localhost:9001>)

### Frontend Development

```bash
cd frontend
pnpm install                    # Install dependencies
pnpm dev                        # Start dev server (http://localhost:3000)
pnpm lint                       # Run Biome linter/formatter
pnpm test                       # Run Vitest tests
pnpm test --watch              # Run tests in watch mode
pnpm exec playwright test      # Run E2E tests
```

### Backend Development

```bash
cd backend
uv sync                                          # Install Python dependencies
uv run uvicorn app.main:app --reload           # Start dev server (http://localhost:8000)
uv run pytest                                   # Run all tests
uv run pytest --cov                            # Run tests with coverage report
uv run pytest tests/api/test_resumes.py -v    # Run specific test file
uv run ruff check                              # Lint code
uv run ruff format --check                     # Check formatting
uv run ruff format                             # Auto-format code
uv run mypy                                    # Type checking
uv run alembic upgrade head                    # Apply database migrations
uv run alembic revision --autogenerate -m "msg" # Create new migration
```

## Architecture Overview

### Backend Structure (FastAPI)

- **Routers** (`backend/app/api/`): REST endpoints organized by resource type
  - Auth endpoints: JWT-based authentication with access/refresh tokens
  - Resume CRUD: User can have max 1 resume on free plan
  - Section management: JSON data storage with type validation
  - Export pipeline: State machine (pending → processing → succeeded/failed)
  - AI endpoints (optional): Summary generation and translation

- **Services** (`backend/app/services/`): Business logic layer
  - Keep router functions thin, delegate to services
  - Handle Playwright PDF generation, S3 uploads, quota checks

- **Schemas** (`backend/app/schemas/`): Pydantic models for request/response validation
  - Section types: basic_info, summary, work, projects, skills, links
  - ULID format for all resource IDs (26 chars, uppercase+numbers)

- **Core** (`backend/app/core/`): Configuration, security, dependencies
  - All config prefixed with `RESUME_` in environment variables
  - JWT authentication with BCrypt password hashing

### Frontend Structure (Next.js App Router)

- **App Router** (`frontend/app/`): Server-first architecture
  - Default to server components, use `"use client"` only when needed
  - Public portfolio at `/u/{handle}/{resumeId}` (SSR for SEO)
  - Protected routes with JWT session management

- **Data Management**:
  - TanStack Query for server state and caching
  - React Hook Form + Zod for form validation
  - Minimal global state, prefer local component state

- **UI Components**:
  - shadcn/ui primitives in `frontend/components/ui/`
  - Tailwind CSS for styling, use `cn()` helper for conditional classes
  - Template preview shares SSR components with PDF export

### PDF Export Pipeline

1. Frontend triggers export request with optional template key
2. Backend creates export job (state: pending)
3. Playwright worker renders Next.js template to PDF
4. PDF uploaded to S3/R2, URL stored in database
5. Frontend polls status until succeeded/failed
6. Monthly quota enforced (5 PDFs on free plan)

## Critical Implementation Notes

### Authentication Flow

- Email/password registration with unique handle validation
- JWT with separate access (60min) and refresh (30 days) tokens
- Bearer token in Authorization header for all protected endpoints
- Handle must be unique across system for public portfolio URLs

### Database Conventions

- All IDs use ULID format (sortable, URL-safe)
- Timestamps in ISO-8601 UTC format
- snake_case for table/column names
- Use Alembic for all schema migrations

### API Conventions

- Base path: `/api`
- Error responses follow RFC 7807 Problem Details format
- kebab-case for URL paths, snake_case for JSON keys
- Return appropriate HTTP status codes with structured error details

### Testing Requirements

- Backend: ≥80% coverage on new code (`uv run pytest --cov`)
- Frontend: Component tests with Vitest + Testing Library
- E2E: Playwright for critical user journeys
- All tests must pass before merging PRs

### Environment Variables

Backend variables prefixed with `RESUME_`:

- Database: `RESUME_DATABASE_URL`
- Auth: `RESUME_JWT_SECRET`, `RESUME_JWT_ALGORITHM`
- Storage: `RESUME_STORAGE_*` for S3/MinIO config
- Quotas: `RESUME_PDF_MONTHLY_QUOTA`

Frontend public variables prefixed with `NEXT_PUBLIC_`:

- API: `NEXT_PUBLIC_API_BASE_URL`
- App: `NEXT_PUBLIC_APP_URL`
- Polling: `NEXT_PUBLIC_EXPORT_POLL_INTERVAL_MS`

## Naming Conventions & Code Style

### Python (Backend)

- **Toolchain**: Ruff + mypy
- **Files/Modules**: snake_case (e.g., `auth_service.py`)
- **Classes**: CamelCase Pydantic models (e.g., `ResumeResponse`)
- **Functions**: snake_case with explicit type hints on public APIs
- **Database**: snake_case for tables and columns
- **Config**: Prefix all with `RESUME_` (e.g., `RESUME_JWT_SECRET`)

### TypeScript/React (Frontend)

- **Components**: PascalCase (e.g., `ResumeEditor.tsx`)
- **Hooks/Utils**: camelCase (e.g., `useAuth`, `formatDate`)
- **Styles**: `Component.module.scss` when needed
- **Exports**: Prefer named exports over default

### API & Shared

- **URL Paths**: kebab-case (e.g., `/api/resume-export`)
- **JSON Keys**: snake_case (e.g., `user_id`, `created_at`)
- **IDs**: ULID format (26 chars, uppercase+numbers)

See `backend/CODING_STYLE.md` and `frontend/CODING_STYLE.md` for detailed conventions.

## Git Workflow & Commit Guidelines

### Branch Naming

- Format: `type/short-task` (e.g., `feat/resume-editor`, `fix/export-pdf`)
- Types: `feat`, `fix`, `docs`, `refactor`, `ci`, `test`
- Keep under 50 characters, lowercase with hyphens

### Commit Messages

- Use conventional prefixes: `feat:`, `fix:`, `docs:`, `ci:`, `refactor:`
- Imperative mood (e.g., "Add user authentication", not "Added")
- Reference issues: `feat: Add PDF export (#14)`
- Keep commits focused and atomic

### Pull Request Process

1. Describe scope and changes clearly
2. Include testing performed (unit, integration, manual)
3. Attach screenshots for UI changes
4. Link updated documentation
5. Request reviews from appropriate domain owners
6. Ensure CI passes before merge

See `docs/git_strategy.md` for complete workflow details.

## Common Development Tasks

### Adding a New Section Type

1. Define schema in `backend/app/schemas/sections.py`
2. Add validation logic in section service
3. Create frontend form component with React Hook Form
4. Add type to template renderer
5. Update API spec documentation

### Implementing a New PDF Template

1. Create template component in `frontend/app/templates/`
2. Register template key in backend config
3. Ensure SSR compatibility for Playwright rendering
4. Test visual consistency between preview and PDF output

### Running Database Migrations

```bash
# Create migration after model changes
cd backend
uv run alembic revision --autogenerate -m "Add user settings table"

# Apply migrations
uv run alembic upgrade head

# Rollback if needed
uv run alembic downgrade -1
```

### Debugging PDF Generation

1. Check Playwright timeout settings (`RESUME_PLAYWRIGHT_TIMEOUT_MS`)
2. Verify template URL accessibility from backend container
3. Review structlog output for render errors
4. Test template directly in browser for JS errors

## Performance Considerations

- Use async/await throughout FastAPI for non-blocking I/O
- Implement pagination for list endpoints when data grows
- Cache public portfolio pages with appropriate headers
- Optimize Playwright: reuse browser context, minimize viewport
- Consider background job queue for PDF generation at scale

## Security Checklist

- Never commit `.env` files or secrets
- Validate all user input with Pydantic schemas
- Implement rate limiting on auth and export endpoints
- Sanitize HTML in user-generated content
- Use prepared statements for all database queries
- Keep dependencies updated (`uv lock --upgrade`, `pnpm update`)

## Official Documentation References

When implementing features, consult these official docs for best practices:

### Frontend Libraries

- [Next.js](https://nextjs.org/docs) - App Router patterns, SSR/SSG, API routes
- [React](https://react.dev/learn) - Hooks, composition, server components
- [TypeScript](https://www.typescriptlang.org/docs/handbook/intro.html) - Type system, generics
- [TanStack Query](https://tanstack.com/query/latest) - Server state, caching, mutations
- [React Hook Form](https://react-hook-form.com) - Form state, validation
- [Zod](https://zod.dev) - Schema validation with RHF resolvers
- [shadcn/ui](https://ui.shadcn.com/docs) - Component patterns
- [Tailwind CSS](https://tailwindcss.com/docs) - Utility classes
- [Vitest](https://vitest.dev/guide/) - Testing framework
- [Testing Library](https://testing-library.com/docs/react-testing-library/intro/) - Component testing
- [Biome](https://biomejs.dev) - Linting and formatting
- [pnpm](https://pnpm.io) - Package management

### Backend Libraries

- [FastAPI](https://fastapi.tiangolo.com/) - Framework patterns
- [FastAPI Bigger Applications](https://fastapi.tiangolo.com/tutorial/bigger-applications/) - Project structure
- [Pydantic](https://docs.pydantic.dev) - Data validation
- [SQLAlchemy](https://docs.sqlalchemy.org/en/20/) - ORM patterns
- [Alembic](https://alembic.sqlalchemy.org) - Database migrations
- [PostgreSQL](https://www.postgresql.org/docs/current/) - Database features
- [Uvicorn](https://www.uvicorn.org/) - ASGI server
- [Playwright Python](https://playwright.dev/python) - Browser automation for PDF
- [structlog](https://www.structlog.org) - Structured logging
- [Passlib](https://passlib.readthedocs.io) - Password hashing
- [PyJWT](https://pyjwt.readthedocs.io) - JWT handling
- [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/) - S3/R2 storage
- [Pytest](https://docs.pytest.org) - Testing framework
- [Ruff](https://docs.astral.sh/ruff/) - Linting and formatting
- [mypy](https://mypy.readthedocs.io) - Type checking
- [uv](https://docs.astral.sh/uv/) - Python package management

### Infrastructure & DevOps

- [Docker](https://docs.docker.com) - Containerization
- [Docker Compose](https://docs.docker.com/compose/) - Local orchestration
- [GitHub Actions](https://docs.github.com/actions) - CI/CD pipelines
- [Playwright](https://playwright.dev) - E2E testing

### Community Resources

- [FastAPI Best Practices](https://github.com/zhanymkanov/fastapi-best-practices)
- [Full Stack FastAPI Template](https://github.com/fastapi/full-stack-fastapi-template)

## Project Documentation Structure

- `/docs/` - Canonical source of truth, always keep updated
  - `prd.md` - Product requirements
  - `api_spec.md` - API specifications
  - `db_schema.md` - Database design
  - `env_setup.md` - Environment variables guide
  - `mvp_checklist.md` - Development progress tracking
  - `open_questions.md` - Unresolved issues and risks
  - `git_strategy.md` - Complete git workflow
  - `/adr/` - Architecture Decision Records

Always update relevant docs in the same PR when behavior changes.

## Testing Strategy

### Backend Testing

- Location: `backend/tests/` mirroring router structure
- Fixtures: `backend/tests/conftest.py`
- Coverage: ≥80% on new code
- Commands:

  ```bash
  uv run pytest --cov              # Full suite with coverage
  uv run pytest tests/api/ -v      # API tests verbose
  uv run pytest -k "test_auth"     # Run specific tests
  ```

### Frontend Testing

- Unit/Component: Colocate as `*.test.tsx` files
- E2E: `frontend/e2e/` directory
- Use Testing Library patterns
- Commands:

  ```bash
  pnpm test                  # Run all tests
  pnpm test --watch         # Watch mode
  pnpm test ResumeEditor    # Specific component
  pnpm exec playwright test # E2E tests
  ```

### CI Requirements

- All tests must pass
- Linting and formatting checks required
- Type checking enforced (mypy, TypeScript)
- Coverage reports generated

Document manual verification steps in PR when automated testing isn't feasible.
