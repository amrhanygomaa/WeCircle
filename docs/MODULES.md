# WeCircle Domain Modules

This project follows Domain-Driven Design (DDD) to keep the codebase modular, scalable, and friendly to AI agents.

## What is a Module?

A module represents a specific business domain. It encapsulates everything related to that domain.

### Backend Module Structure (`dashboard/backend/src/modules/`)

```
src/modules/student/
  ├── student.controller.ts  (Express handlers)
  ├── student.service.ts     (Business logic & DB queries - optional)
  ├── student.routes.ts      (Express router definitions)
  └── index.ts               (Public exports for the module)
```

### Frontend Module Structure (`dashboard/frontend/src/modules/`)

```
src/modules/student/
  ├── components/            (UI components specific to students)
  ├── hooks/                 (React hooks specific to students)
  ├── services/              (API client calls using React Query)
  └── types/                 (TypeScript definitions)
```

## Migration Guide for AI Agents

If you need to add a new feature (e.g. `Library`):

1. Create `dashboard/backend/src/modules/library/`.
2. Define the schema in `prisma/schema.prisma` and run `npx prisma generate`.
3. Create `library.routes.ts` and `library.controller.ts`.
4. Register the route in `dashboard/backend/src/routes/index.ts`.
5. Create `dashboard/frontend/src/modules/library/`.
6. Add the navigation route to `dashboard/frontend/src/core/routing/routes.ts`.
7. Consume the API in frontend components.
