# WeCircle — Project Context (CLAUDE.md)

> School attendance & transportation platform. Connects parents, students, teachers, and bus
> drivers. Three apps: a Flutter mobile app, an Express/Prisma backend, and a Next.js admin web
> dashboard. This file is the persistent context for every session — keep it accurate.

## ⚠️ Read this first (verified reality, 2026-05-29)

The README and the original takeover brief are **partly stale**. The previous developer already
began (and band-aid-deployed) a Supabase → AWS migration. The verified current state:

| Concern        | README / brief says            | **Actual reality in code**                                              |
|----------------|--------------------------------|-------------------------------------------------------------------------|
| Database       | Supabase Postgres              | **Postgres via Prisma** (`DATABASE_URL`). No Supabase SDK in code.      |
| Web auth       | Supabase Auth + JWT            | **AWS Cognito** (`aws-jwt-verify`) with a custom-JWT fallback.          |
| Mobile auth    | Firebase                       | **Custom backend-signed JWT** (`AppCredential` + device session store). |
| Mobile data    | Firebase/Firestore is "the DB" | **REST to the Express backend.** Firestore is used **only for chat.**   |
| Frontend build | Next.js                        | **Next.js 16 App Router** — but Vite/react-router deps still linger.    |
| Hosting        | (future) AWS                   | **Already on AWS, ad-hoc:** single EC2 + pm2 (backend **and** Next.js server), behind nginx + Certbot TLS for both `api.` and dashboard domains. |
| IaC            | infra/ (Terraform/CDK?)        | **No real IaC.** Ad-hoc shell/JSON + one Cognito Lambda.                |

Supabase removal is recorded in git (`31e2cc1`). Residual Supabase strings remain in env examples,
infra docs, and a `directUrl` in the Prisma schema.

## Repository layout

```
WeCircle/
├── mobile/                 # Flutter app (pubspec name: "wesal"). Roles: parent, student, teacher, driver.
│   └── lib/
│       ├── core/{api,config}   # api_service.dart, api_config.dart (REST base URL)
│       ├── services/           # chat_service.dart (Firestore), responsive_helper.dart
│       ├── screens/{parent,teacher,driver,student1-3,student4-6,student_shared}
│       └── main.dart           # Firebase.initializeApp (chat only)
├── dashboard/
│   ├── backend/            # Node + Express 5 + TypeScript + Prisma (Postgres)
│   │   ├── prisma/         # schema.prisma (~40 models), seed.ts — NO migrations/ dir
│   │   └── src/
│   │       ├── config/         # env.ts, prisma.ts, websocket.ts
│   │       ├── core/http/middlewares/  # auth, mobileAuth, roleGuard, tenantScope, errorHandler
│   │       ├── core/utils/     # AppError, asyncHandler, sessionStore, tenant
│   │       ├── controllers/    # ~45 controllers (legacy flat layout)
│   │       ├── routes/         # index.ts + routes/modules/*.routes.ts
│   │       ├── modules/student/ # the ONLY module migrated to the new layered style
│   │       ├── services/       # only notification.service.ts (services layer barely exists)
│   │       ├── cron/           # checkOverdueInvoices.ts
│   │       └── server.ts       # entry point (root route still says "EduControl")
│   └── frontend/          # Next.js 16 + React 19 admin dashboard
│       └── src/
│           ├── app/            # App Router pages (login, verify, dashboard/*)
│           ├── core/{api,auth,config,realtime,routing,i18n}  # cognito.ts, apiClient.ts, socketClient.ts
│           ├── modules/{auth,dashboard}/components
│           └── shared/{components,ui}
├── infra/
│   ├── aws/                # ad-hoc: ecs-task-definition.json, buildspec.yml, ec2-userdata.sh,
│   │                       #         s3-bucket-policy.json, budget*.json, ec2-assume-role.json
│   └── lambda/auto-confirm/ # Cognito post-signup auto-confirm Lambda (index.mjs + committed .zip)
├── .github/workflows/deploy.yml   # CI: build + SCP/SSH deploy to ONE EC2 box via pm2
├── docs/                   # MIGRATION_PLAN.md, PROGRESS.md (ours) + previous dev's docs (verify)
├── fix_*.js, restore_t.js  # ~22 one-off codemod band-aids (DO NOT add more; plan removal)
└── frontend_build.zip, dashboard/frontend/frontend.zip  # committed build artifacts (remove)
```

## Stack (verified)

- **Backend:** Node 24 / Express 5 / TypeScript (strict) / Prisma 6 / Postgres. Socket.IO for
  realtime (no Redis adapter yet → won't scale past one instance). Google Gemini for AI assistant.
  AWS SDKs present: Cognito, S3, S3 presigner, Bedrock. Zod for validation. Helmet, CORS, morgan.
- **Frontend:** Next.js 16 (App Router) / React 19 / TanStack Query / Tailwind v4 / framer-motion /
  recharts / amazon-cognito-identity-js. `NEXT_PUBLIC_*` env. **Stray Vite + react-router-dom deps.**
- **Mobile:** Flutter 3.41 / Dart 3.10. REST via `http` to the backend; `cloud_firestore` +
  `firebase_core` for chat only. Renders parent/student/teacher/driver UIs; gamified student screens.

## Auth model (two parallel systems — important)

- **`User`** rows ↔ **Cognito** identities → web dashboard. `requireAuth` verifies a Cognito *id*
  token, else falls back to a custom JWT.
- **`AppCredential`** rows ↔ backend-issued JWTs → mobile app. `requireMobileAuth` verifies the JWT
  and checks an in-memory/file device session store (`core/utils/sessionStore.ts`,
  `device_sessions.json`). Every Student/Teacher/Parent/Driver/Supervisor has BOTH a `User` and
  optional `AppCredential`s.
- Multi-tenancy: almost every model has `schoolId`; `tenantScope` middleware enforces it.

## Commands

```bash
# Backend (cd dashboard/backend)
npm install
npm run prisma:generate          # prisma generate
npm run dev                      # tsx watch src/server.ts  → http://localhost:5001
npm run build                    # tsc -p tsconfig.json     → dist/   (typechecks clean, strict)
npm start                        # node dist/server.js
# (no migrations dir yet — schema is synced with `prisma db push`, history is lost)

# Frontend (cd dashboard/frontend)
npm install
npm run dev                      # next dev  → http://localhost:3000
npm run build                    # next build (passes)

# Mobile (cd mobile)
flutter pub get
flutter analyze                  # 23 info-level lints (withOpacity deprecations), 0 errors
flutter run --dart-define=API_URL=http://10.0.2.2:5001/api   # needs Firebase config to boot
```

**Build baseline (2026-05-29): all three apps build/analyze cleanly.** "Builds" ≠ "runs end-to-end":
full runtime needs a live Postgres (`DATABASE_URL`), the Cognito pool, and Firebase config.

## Environment variables

- Backend `.env` (see `.env.example`): `PORT`, `NODE_ENV`, `FRONTEND_URL`, `JWT_SECRET`,
  `SUPER_ADMIN_EMAIL`, `DATABASE_URL`, `AWS_REGION`, `AWS_S3_BUCKET_NAME`, `COGNITO_USER_POOL_ID`,
  `COGNITO_CLIENT_ID`, `GOOGLE_AI_API_KEY`. Schema also reads `DIRECT_URL` (Supabase leftover).
- Frontend `.env.local`: `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_AWS_REGION`,
  `NEXT_PUBLIC_COGNITO_USER_POOL_ID`, `NEXT_PUBLIC_COGNITO_CLIENT_ID`, `NEXT_PUBLIC_APP_*`.
  (Still carries placeholder `NEXT_PUBLIC_SUPABASE_*` — unused.)
- Mobile: `--dart-define=API_URL=...` (default points at `api.wecircle.helpers-tech.com`).

## Conventions

- Backend response shape: `{ success: boolean, message?, ... }`. Errors via `AppError` +
  `errorHandler`. Wrap async handlers with `asyncHandler`.
- New backend code should follow the **layered module style** in `src/modules/student/`
  (routes → controller → service → repository), not the legacy flat `controllers/` layout.
- Validate input with **Zod**. Never hardcode secrets. Never add new `fix_*.js` band-aid scripts —
  fix root causes.

## Guardrails (from the takeover brief)

- Small, reviewable commits. Never force-push or rewrite shared history.
- Keep the app working at the end of every phase.
- **Ask before any destructive/irreversible action**: deleting files, dropping/altering data,
  provisioning paid AWS resources, decommissioning Supabase.
- Get explicit sign-off on the proposed schema and AWS architecture before implementing.

## Where we are

Phase 0 (stabilize & baseline) complete — see `docs/PROGRESS.md`. Phases, decisions, proposed schema
redesign, and the target AWS architecture live in `docs/MIGRATION_PLAN.md`. **At the start of every
session: re-read those two docs AND re-inspect the code to confirm reality before continuing.**
