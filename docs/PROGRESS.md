# WeCircle — Progress Log

Last updated: **2026-05-29**. Update at the end of every session. Re-verify against code at the start.

---

## ✅ Done

### Phase 0 — Stabilize & baseline (2026-05-29)
- Mapped the full repo (mobile / dashboard.backend / dashboard.frontend / infra / .github / docs).
- Resolved the stack ambiguities (see "Verified stack" below).
- Documented the current Prisma data model (~40 models) and migration-hygiene gap.
- Assessed all ~22 `fix_*.js` band-aid scripts and the committed build zips.
- Inventoried `infra/` (ad-hoc shell/JSON + one Cognito Lambda; no Terraform/CDK).
- **Build baseline — all green:**
  - Backend: `prisma validate` ✓, `prisma generate` ✓, `tsc -p tsconfig.json --noEmit` (strict) → 0 errors.
  - Frontend: `next build` → success (full App Router route tree).
  - Mobile: `flutter pub get` ✓, `flutter analyze` → 0 errors, 23 info lints (`withOpacity`).
- Created `CLAUDE.md`, `docs/MIGRATION_PLAN.md`, `docs/PROGRESS.md`.

### Verified stack (resolves the README/brief conflicts)
- **DB:** Postgres via Prisma (`DATABASE_URL`). No Supabase SDK in code.
- **Web auth:** AWS Cognito id-token (`aws-jwt-verify`) + custom-JWT fallback.
- **Mobile auth:** backend-signed JWT (`AppCredential`) + device session store.
- **Mobile data:** REST to the Express backend. Firestore used **only for chat**.
- **Frontend:** Next.js 16 App Router (Vite/react-router deps are dead leftovers).
- **Hosting:** already on AWS, ad-hoc — single EC2 + pm2 (backend & frontend) + S3 static + Cognito.

---

## 🔜 In progress / Next (awaiting sign-off)
- **BLOCKED ON SIGN-OFF:** Phase 1 ambiguity decisions (D1–D6 in MIGRATION_PLAN.md).
- **BLOCKED ON SIGN-OFF:** Phase 2 schema redesign + introducing Prisma migrations.
- **BLOCKED ON SIGN-OFF / APPROVAL:** Phase 4 AWS provisioning; any file deletions; any data changes.
- Answer the 5 open questions in MIGRATION_PLAN.md §5.

---

## 🐞 Prioritized risks / bugs / tech debt

### 🔴 Critical (security / data)
- **R1 — Auth backdoor.** `GET /api/auth/temp-make-admin` (`routes/modules/auth.routes.ts:10`) is
  **unauthenticated** and elevates a hardcoded account (`amuhamad@helpers-tech.com`) to `SUPER_ADMIN`,
  auto-creating a school. Anyone who hits the URL gains super-admin. **Remove ASAP.**
- **R2 — Hardcoded fallback JWT secret.** `config/env.ts` falls back to
  `"default-fallback-jwt-secret-key-wecircle"` (and to `SUPABASE_JWT_SECRET`). If `JWT_SECRET` is
  unset, all mobile JWTs are forgeable. `requireEnv` also only throws when `NODE_ENV !== development`.
- **R3 — `aws_config.txt` committed.** Exposes Cognito pool/client IDs + S3 bucket name (infra
  topology). `env.ts` `allowedOrigins` hardcodes a leaked AWS account id (`035611741710`) and public
  EC2 IPs. Not credentials, but should not be in git.
- **R4 — `/auth/cognito-sync`** was added "to bypass failing requireAuth middleware" — auto-creates a
  DB user from a Cognito token. Review for account-takeover / unverified-email issues.

### 🟠 High (stability / architecture)
- **R5 — No DB migrations.** Schema is synced via `prisma db push`; no `prisma/migrations/` history.
  No safe way to evolve a production DB. (Phase 2 priority.)
- **R6 — Half-done backend refactor.** Only `src/modules/student/` uses the target layered style;
  everything else is the legacy flat `controllers/`. `controllers/student.controller.ts` is **dead
  code** (nothing imports it; `/students` uses the module version). Services layer is essentially
  empty (only `notification.service.ts`) → controllers talk to Prisma directly.
- **R7 — Socket.IO won't scale.** No Redis adapter; in-process state. Breaks on >1 instance / ECS.
- **R8 — Device session store is a JSON file** (`device_sessions.json` + `core/utils/sessionStore.ts`).
  Not durable, not multi-instance safe.
- **R9 — Duplicated chat systems** (Postgres `Conversation`/`Message` vs Firestore). Pick one (D5).
- **R10 — In-process cron** (`startOverdueChecker`) runs per-instance → duplicate work when scaled.
  Move to EventBridge Scheduler.

### 🟡 Medium (cleanliness / migration debt)
- **R11 — ~22 `fix_*.js` band-aid codemods** at repo root + in `backend/` + `mobile/` (Supabase
  removal, Vite→Next conversion, i18n key restoration via `git show`, TS-error patches). Some contain
  self-doubt comments. Plan removal **after** confirming their effects are baked in (don't delete yet).
- **R12 — Committed build artifacts:** `frontend_build.zip` (17 MB), `dashboard/frontend/frontend.zip`
  (8 MB), `infra/lambda/auto-confirm/auto-confirm.zip`. Remove from git; add to `.gitignore`.
- **R13 — Vite/react-router leftovers** in the frontend (`vite`, `@vitejs/plugin-react`,
  `react-router-dom`, `src/core/routing/*`, `vite.svg`). Dead since the Next conversion.
- **R14 — Stale config drift:** infra `README.md` still diagrams "Supabase (DB/Auth)" and references
  `VITE_*` GitHub secrets; frontend `.env.local` still carries placeholder `NEXT_PUBLIC_SUPABASE_*`;
  two different EC2 IPs appear across files; root API route still self-identifies as "EduControl".
- **R15 — Name drift:** Flutter `pubspec` name is `wesal`; backend self-describes as "EduControl";
  product is "WeCircle". Unify branding.
- **R16 — CI/CD weaknesses:** `deploy.yml` SCPs a zip and `sed`/`echo`s secrets into `.env` on the
  box; no OIDC; no tests/typecheck/lint gate before deploy.

### 🟢 Low (polish)
- **R17 — 23 Flutter `withOpacity` deprecation lints.** Mechanical fix → `.withValues()`.
- **R18 — `express.json({ limit: "50mb" })`** is very large; tighten or scope to upload routes.

---

## 📌 Known unknowns (need owner input — see MIGRATION_PLAN.md §5)
- Is the live EC2 environment production-with-real-data or a dev box?
- Does a Supabase project still hold authoritative data to migrate, or is current Postgres the source?
- Firestore chat: keep or consolidate?
- IaC: Terraform vs CDK. Frontend: SSR vs static export.
