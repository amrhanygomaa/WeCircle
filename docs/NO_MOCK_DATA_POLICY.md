# No Mock Data Policy

**WARNING: AI Agents working on this project MUST adhere strictly to this policy.**

## The Golden Rule

**Under NO circumstances should fake, hardcoded, dummy, or placeholder business data be used.**

- Do not invent static records in React components.
- Do not create "mock" backend routes.
- Do not return hardcoded logic inside controllers.
- All real application data MUST be sourced from the AWS backend/API (PostgreSQL).

## Acceptable Fallbacks

If a route or feature is incomplete, do NOT fake the data to make the UI look good. Instead:

1. Return `null` or `[]` from the API.
2. Render an "Empty State" component (e.g. `ModulePlaceholder`).
3. Render a Loading state while querying.

## Handling Missing Endpoints

If the frontend requires an endpoint that does not exist on the backend yet:

1. Implement the endpoint fully using Prisma.
2. If unable to implement immediately, leave the frontend in an empty/error state.

**Do not break this policy.**
