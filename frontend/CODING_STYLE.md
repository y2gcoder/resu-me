# Frontend Coding Style

## Project Layout

- Use Next.js App Router under `frontend/app/`; keep `page.tsx`, `layout.tsx`, `loading.tsx`, and `error.tsx` colocated within each route segment.
- Place shared components and hooks under `frontend/components/` and `frontend/hooks/`; use PascalCase for components and camelCase for hooks/utilities.
- Keep route-specific UI under the corresponding segment directory; colocate test files as `*.test.tsx` next to implementation files.
- Store shared helpers/types in `frontend/lib/`; prefer named exports.

## Client vs Server Components

- Default to server components (`"use client"` omitted). Convert to client components only when browser APIs, interactive state, or event handlers are required.
- Use server actions and Route Handlers for data mutations where possible, and fall back to TanStack Query mutations for client-driven updates.

## Data Fetching & State

- Perform server-side fetching within async `page`/`layout` functions or `generateMetadata` when data is required before render.
- Manage client-side async state with TanStack Query (`useQuery`, `useMutation`) and keep cache keys scoped to the user/resume.
- Keep global state minimal; prefer local component state or React Hook Form for managed forms.

## Forms & Validation

- Build forms with React Hook Form + Zod resolvers. Colocate schema definitions near the form component and export shared schemas from `frontend/lib/validation` when reused.
- Use controlled components from shadcn/ui where possible, wiring them to RHF with `Controller` when needed.

## Styling & Components

- Use Tailwind classes for layout and utility styles; compose conditional classes with the shared `cn` helper.
- Maintain design primitives under `frontend/components/ui` (shadcn/ui). Extend components via wrappers rather than editing generated files directly.
- Keep SCSS modules only when scoped styles cannot be expressed in Tailwind. Name files `Component.module.scss` and avoid global selectors.

## Testing

- Write component/unit tests with Vitest + Testing Library colocated as `Component.test.tsx`.
- Use Playwright for end-to-end coverage under `frontend/e2e/`; prefer data-testid attributes for selectors.

## Tooling

- Run Biome (`pnpm lint`) to enforce linting and formatting. Avoid manual Prettier/ESLint configs.
- Use `pnpm test --watch` during development; keep snapshot usage minimal.
- Name environment variables with `NEXT_PUBLIC_` prefix when exposed to the browser.

## General Guidelines

- Prefer named exports; avoid default exports for components/hooks.
- Document complex flows via JSDoc comments or reference `/docs` entries; keep inline comments minimal.
- Decompose components into smaller units when JSX exceeds ~150 lines or mixes multiple responsibilities.
