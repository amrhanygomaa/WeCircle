# WeCircle API Endpoints

The API is structured in a standard RESTful convention.

## Base URL

- Frontend context: `ENV.API_URL`
- Mobile context: `ApiConfig.baseUrl`
- Production value: `http://44.201.109.24:5001/api`

## Security

- Almost all endpoints require an `Authorization: Bearer <token>` header.
- The token is retrieved from the Supabase session (`supabase.auth.getSession()`).
- The backend `requireAuth` middleware verifies the JWT against `SUPABASE_JWT_SECRET`.

## Standard CRUD Pattern

Most modules follow a strict pattern:

- `GET /api/<module>?limit=10&page=1` -> Fetch paginated list
- `GET /api/<module>/:id` -> Fetch single entity
- `POST /api/<module>` -> Create new entity
- `PUT/PATCH /api/<module>/:id` -> Update entity
- `DELETE /api/<module>/:id` -> Archive/Delete entity

## Avoiding Mock Data

When implementing new frontend features, NEVER hardcode UI fallback values in the components.
Use React Query's `isLoading` states or Empty states from the UI library (`<ModulePlaceholder />`).
If an API endpoint does not exist yet, build it in the backend first.
