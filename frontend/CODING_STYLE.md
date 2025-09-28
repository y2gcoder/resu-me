# Frontend Coding Style

## Project Structure

```
frontend/
├── src/
│   ├── app/           # Next.js App Router
│   ├── components/    # Shared components
│   │   └── ui/       # shadcn/ui components
│   ├── hooks/        # Custom hooks
│   ├── lib/          # Utilities and helpers
│   └── types/        # TypeScript definitions
├── public/           # Static assets
└── e2e/             # E2E tests
```

## Next.js Best Practices

- **Server Components by default** - Add `"use client"` only when needed
- **Colocate route files** - Keep `page.tsx`, `layout.tsx`, `loading.tsx` together
- **App Router conventions** - Follow Next.js 15 naming patterns

## TypeScript & Components

- **Named exports** - Prefer over default exports
- **PascalCase** - Components (`ResumeEditor.tsx`)
- **camelCase** - Hooks, utilities (`useAuth.ts`, `formatDate.ts`)
- **Type safety** - Leverage TypeScript, avoid `any`

## Forms & Validation

- **React Hook Form + Zod** - Standard form handling
- **shadcn/ui components** - Use provided form primitives
- **Validation schemas** - Colocate with forms or share from `lib/`

## Styling

- **Tailwind CSS** - Primary styling method
- **cn() helper** - Conditional classes from `lib/utils`
- **No inline styles** - Use Tailwind classes instead

## State Management

- **Local state first** - useState for component state
- **React Hook Form** - Form state management
- **TanStack Query** - Server state (when needed)
- **Minimal global state** - Only if absolutely necessary

## Code Quality

- **Biome** - Linting and formatting (`pnpm lint`)
- **TypeScript strict** - Maintain type safety
- **Clean imports** - Let Biome organize them
- **Environment variables** - `NEXT_PUBLIC_` prefix for client-side

## Testing

- **Vitest** - Unit/component tests
- **Testing Library** - Component testing
- **Playwright** - E2E tests in `e2e/`

Keep it simple, follow Next.js conventions, and let the tooling handle formatting.
