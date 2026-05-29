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

## 🔄 In progress — Phase 3 (logic & structure refactor)

Started 2026-05-29. Workstreams:

1. **Flutter lint cleanup** ✅ — 23 `withOpacity` → `withValues(alpha:)`, `flutter analyze` → 0 issues.
2. **Backend chat consolidation** — merge duplicate `chat.controller.ts` + `conversation.controller.ts`
   into a single `modules/chat/` module.
3. **Mobile chat consolidation** — rewrite `chat_service.dart` to use REST + Socket.IO; remove Firebase.
4. **Controller migrations** — move remaining 37 legacy flat controllers into `modules/<domain>/`.
5. **Device session store** — replace file-based `device_sessions.json` with DB/Redis.

## ✅ Done (Phase 1 + Phase 2)

### Phase 1 — Resolve ambiguities (2026-05-29)
- D1: Supabase removed; Postgres via Prisma confirmed; `directUrl` (pgBouncer) removed from schema.
- D2: Vite/react-router removed from frontend; `next build` still clean; static export confirmed.
- D3: Auth hardened — backdoor removed, `requireEnv` strict, `ALLOWED_ORIGINS` env var.
- D4–D6: Socket.IO kept; Firestore chat to consolidate; Gemini kept (Phase 3+4).
- Dead code deleted: `controllers/student.controller.ts` (451 lines), `src/core/routing/*`,
  `src/assets/{react,vite}.svg`. Build artifacts untracked from git.

### Phase 2 — Schema redesign / Prisma migrations (2026-05-29)
- Created `prisma/migrations/` with `migration_lock.toml`.
- `20260529000000_init`: 1674-line baseline SQL (production already applied via `db push`).
  Deploy with `prisma migrate resolve --applied "20260529000000_init"`.
- `20260529000001_phase2_additions`: non-destructive additions (80 lines):
  - `@db.Decimal(12,2)` on 9 money fields.
  - Composite indexes: `Attendance(schoolId,classId,date)`, `Invoice(schoolId,status,dueDate)`.
  - `StudentGameProgress` model (replaces flat `game1Lvl…game5Lvl` in Phase 3).
  - `Conversation.pairKey String? @unique` (deterministic pair deduplication).
  - `Notification.recipient → User` FK.
  - Chat controllers updated to use `pairKey` on upsert/create.

---

## 🐞 Prioritized risks / bugs / tech debt

### 🔴 Critical (security / data)
- **R1 — Auth backdoor.** ✅ **FIXED (Phase 1)** — endpoint removed.
- **R2 — Hardcoded fallback JWT secret.** ✅ **FIXED (Phase 1)** — `requireEnv` strict, no fallback.
- **R3 — `aws_config.txt` committed.** ✅ **FIXED (Phase 1)** — untracked + gitignored; `ALLOWED_ORIGINS` env var.
- **R4 — `/auth/cognito-sync`** — still needs review for account-takeover / unverified-email issues.

### 🟠 High (stability / architecture)
- **R5 — No DB migrations.** ✅ **FIXED (Phase 2)** — `prisma/migrations/` established with baseline + Phase 2 additions.
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
- **R17 — 23 Flutter `withOpacity` deprecation lints.** ✅ **FIXED (Phase 3A)** — replaced with `.withValues(alpha:)`.
- **R18 — `express.json({ limit: "50mb" })`** is very large; tighten or scope to upload routes.

---

## 📌 Known unknowns / open items
- **R4 `/auth/cognito-sync`** — auto-creates DB user from Cognito token; review for account-takeover risk.
- **Deferred schema changes** (need data migration before applying):
  - Drop `ADMIN` enum value (migrate rows first).
  - Remove `Teacher.subject`, `Driver.idCopy` legacy fields.
  - Remove `Student.game1Lvl…game5Lvl` flat cols (after backfilling `StudentGameProgress`).
  - Make `Parent.schoolId` non-nullable (patch null rows first).
  - Type `Message.senderId` as FK (needs chat identity consolidation).
- **Phase 4 provisioning** — RDS, ECS, ALB, CloudFront, Cognito, S3, ElastiCache, EventBridge.
  Needs sign-off before any paid AWS resources are created.
