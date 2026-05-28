# AI Agent Guide for WeCircle

This codebase is specifically engineered to be safe, modular, and easy for AI agents to traverse and modify.
When operating on this codebase, adhere to the following rules:

## 1. No Blind Deletions
Never execute `rm` or `Remove-Item` without first verifying references using ripgrep or `grep_search`.
If a file appears unused, rename it to `*.deprecated` or move it to a `_legacy` folder first if you are uncertain.

## 2. No Mock Data
The system is built on a strictly "AWS-First" methodology.
- Do not create mock objects or arrays to satisfy frontend UI states.
- If the UI needs data, ensure the backend route provides it dynamically via Prisma from the PostgreSQL database.
- Use `null`, `0`, or `[]` for fallback states. Show a loading or empty state.

## 3. Strict Module Boundaries
If building a new feature:
- Put Backend code in `dashboard/backend/src/modules/<feature>/`.
- Put Frontend code in `dashboard/frontend/src/modules/<feature>/`.
- Put Mobile code in `mobile/lib/features/<feature>/`.
- Never dump logic into `app/page.tsx` or `main.dart`. Keep routing layer files thin.

## 4. Environment Variables
- Never hardcode URLs.
- Always use `ENV.API_URL` (Frontend) or `ApiConfig.getBaseUrl()` (Mobile).
- Backend should fail loudly if critical variables (`DATABASE_URL`, `SUPABASE_JWT_SECRET`) are missing in production.

## 5. Follow the AWS Free Tier Guidelines
- Refer to `docs/AWS_INTEGRATION.md` before doing any DevOps.
