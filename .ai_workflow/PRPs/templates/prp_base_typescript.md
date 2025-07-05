name: "Base PRP Template v2 - Context-Rich with Validation Loops"
description: |

## Purpose

Template optimized for AI agents to implement features with sufficient context and self-validation capabilities to achieve working code through iterative refinement.

## Core Principles

1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance

---

## Goal

[One sentence: What needs to be built - be specific about the end state]

## Why

- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves]

## What

[User-visible behavior and technical requirements]

### Success Criteria

- [ ] [Specific measurable outcome]
- [ ] [Performance requirement if applicable]
- [ ] [Integration requirement]

## Critical Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://nextjs.org/docs/app/building-your-application/routing
  why: App Router fundamentals and file conventions

- file: app/layout.tsx
  why: Root layout pattern, metadata configuration

- doc: https://react.dev/reference/rsc/server-components
  section: Server Component constraints and patterns
  critical: No useState, useEffect, or event handlers in RSC

- file: components/ui/button.tsx
  why: Shadcn UI component patterns, styling conventions
```

### Known Gotchas & Library Quirks

```typescript
// CRITICAL: Next.js 15 App Router specifics
// Example: Route handlers must export named functions (GET, POST, etc.)
// Example: Dynamic routes use [param] folders, catch-all uses [...param]
// Example: Metadata must be exported from page.tsx, not components
// Example: 'use client' directive must be at top of file, affects entire component tree
// Example: Server Components can't use browser APIs or event handlers
// Example: Client Components can't directly import server-only code
```

## Implementation Blueprint

### Critical data models and structure

```typescript
// CRITICAL: Next.js App Router conventions
// Server Component (default - no directive needed)
export default async function Page() {
  const data = await fetchData() // Can use async/await directly
  return <div>{data}</div>
}

// Client Component (needs interactivity)
'use client'
import { useState } from 'react'

export function InteractiveComponent() {
  const [state, setState] = useState()
  return <button onClick={() => setState()}>Click</button>
}

// Route Handler pattern
export async function GET(request: NextRequest) {
  return NextResponse.json({ data })
}
```

### Critical data types and schemas

```typescript
// Example with Zod (matches project pattern):
import { z } from "zod";

export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(["user", "admin"]),
  createdAt: z.date(),
});

export type User = z.infer<typeof userSchema>;

// Validation in route handlers
export async function POST(request: NextRequest) {
  const body = await request.json();
  const validated = userSchema.parse(body); // throws on error
  // ... rest of implementation
}
```

### Task List, Use information dense keywords and patterns from the codebase

** Use keywords like: MODIFY, CREATE, UPDATE, DELETE, MIRROR, etc.**

** Use patterns from the codebase, like: Export default function, typed children prop, Suspense boundaries for loading states, etc.**

** Use the codebase and documentation as a reference.**

** Use details about what and where to modify, create, update, delete, mirror, etc.**

```
MODIFY app/layout.tsx: (what and where)
  - FIND pattern: "export default function RootLayout" (implementation details)
  - INJECT in metadata object (implementation details)
  - PRESERVE children prop typing (implementation details)
  - ...

CREATE app/(dashboard)/layout.tsx: (what and where)
  - PATTERN: Route group with shared layout (implementation details)
  - MUST: Export default function, typed children prop (implementation details)
  - INCLUDE: Suspense boundaries for loading states (implementation details)
  - ...

CREATE app/api/users/route.ts: (what and where)
  - MIRROR pattern from: app/api/example/route.ts (implementation details)
  - EXPORT: Named HTTP method functions (GET, POST) (implementation details)
  - USE: NextRequest, NextResponse from 'next/server' (implementation details)
  - ...

```

### Core Implementation

```typescript
// Pseudocode with CRITICAL Next.js 15 details
// app/(dashboard)/users/page.tsx - Server Component

// pseudocode for critical implemntation details, integration points, USE REAL CODEBASE AS REFERENCE, NEVER GUESS

// ...
```

### Integration Points

```yaml
DATABASE:
  - client: "@/lib/supabase/client"
  - pattern: "createClient() for client components"
  - pattern: "createServerClient() for server components"

CONFIG:
  - add to: .env.local
  - pattern: "NEXT_PUBLIC_* for client-side env vars"

ROUTES:
  - file structure: app/feature-name/page.tsx
  - api routes: app/api/feature-name/route.ts
  - middleware: middleware.ts (root level)
```

## Validation Loop

### Level 1: Syntax & Type Checking

```bash
# Run these FIRST - fix any errors before proceeding
npm run lint                    # ESLint checks
npx tsc --noEmit               # TypeScript type checking

# prettier
npx prettier --write .

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Component Tests / Unit Tests

```typescript
// Follow existing testing patterns
// Each component should have a corresponding test file
// Use existing test patterns as a reference
// Never guess, always read the codebase
// Each unit should be self-contained and independent and testable
```

```bash
# Run and iterate until passing:
npm test new-feature.test.tsx
# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Tests

```bash
# Start the dev server
npm run dev

# Test the page loads
curl http://localhost:3000/dashboard/users
# Expected: HTML response with user table

# Test the API endpoint
curl -X GET http://localhost:3000/api/users \
  -H "Content-Type: application/json"

# Expected: {"users": [...], "total": n}
# If error: Check console for Next.js error messages
```

### Level 4: Build Validation

```bash
# Production build check
npm run build

# Expected: Successful build with no errors
# Common issues:
# - "Module not found" → Check import paths
# - "Hydration mismatch" → Ensure server/client render same content
# - Type errors → Run tsc to identify

# Test production build
npm run start
```

## Progressive Enhancement

### Phase 1: Core Functionality (Do First)

- [ ] Basic page/route working
- [ ] Data fetching implemented
- [ ] Error boundaries in place

### Phase 2: Robustness (Do Second)

- [ ] Loading states with Suspense
- [ ] Error handling with error.tsx
- [ ] Form validation (client + server)

### Phase 3: Production Ready (Do Third)

- [ ] Optimize images with next/image
- [ ] Add metadata for SEO
- [ ] Implement caching strategies

## Debugging Aids

```typescript
// Add these temporarily for debugging:
// In Server Components
console.log("Server render:", { data });

// In Client Components
("use client");
useEffect(() => {
  console.log("Client hydration:", { state });
}, []);

// In Route Handlers
export async function GET(request: NextRequest) {
  console.log("API called:", request.url);
  // ... rest of handler
}

// Remove before final commit
```

## Final Checklist

- [ ] All TypeScript errors resolved: `npx tsc --noEmit`
- [ ] No linting errors: `npm run lint`
- [ ] Dev server runs without errors: `npm run dev`
- [ ] Production build succeeds: `npm run build`
- [ ] No hydration warnings in browser console
- [ ] API routes return proper status codes
- [ ] Loading states implemented with Suspense
- [ ] Error boundaries handle failures gracefully

---

## Anti-Patterns to Avoid

- ❌ Don't use 'use client' unnecessarily - embrace Server Components
- ❌ Don't fetch data in useEffect - use Server Components or SWR/React Query
- ❌ Don't mix server and client code in same component
- ❌ Don't ignore TypeScript errors - they prevent runtime issues
- ❌ Don't hardcode URLs - use environment variables
- ❌ Don't skip error boundaries - every page needs error handling
