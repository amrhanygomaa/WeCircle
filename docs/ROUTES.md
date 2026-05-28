# WeCircle Routing Architecture

## Frontend Routing (Next.js App Router)
The frontend relies heavily on the App Router `src/app/` structure.
To prevent hardcoded paths scattering the application, all navigation is registered in `src/core/routing/routes.ts`.

Example:
```typescript
import { ROUTES } from "@/core/routing/routes";
import Link from "next/link";

<Link href={ROUTES.DASHBOARD.STUDENTS}>Manage Students</Link>
```

### Adding a new route
1. Create the page under `src/app/dashboard/<feature>/page.tsx`.
2. Add the path to `ROUTES.DASHBOARD.<FEATURE>` in `src/core/routing/routes.ts`.
3. Add a navigation entry to `src/core/routing/navigation.ts` to expose it on the sidebar.

## Backend Routing (Express)
All API requests flow through `dashboard/backend/src/routes/index.ts`.
Each module mounts its own sub-router.

Example:
```typescript
// src/routes/index.ts
import studentRoutes from "../modules/student/student.routes";
router.use("/students", studentRoutes);
```
