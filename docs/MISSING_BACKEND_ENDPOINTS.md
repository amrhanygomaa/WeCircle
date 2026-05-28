# Missing Backend Endpoints

Currently, there are no definitively known missing endpoints for the core MVP functionality.
However, as features scale, AI agents should note that:

- Mobile API endpoints (e.g. `mobile.transport.routes.ts`) may need further integration with the Supabase Realtime layer.
- Some edge cases in reporting (e.g., custom date-range queries) may require dedicated `GET` parameters that aren't fully optimized yet.

If you hit a 404 on the frontend:

1. Verify `ROUTES.md` to ensure you aren't calling a deprecated path.
2. Check `routes/index.ts` in the backend.
3. Build the missing route in the appropriate domain module following the `AI_AGENT_GUIDE.md`.
