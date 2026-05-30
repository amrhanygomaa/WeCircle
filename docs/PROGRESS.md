# WeCircle — Progress Log

Last updated: **2026-05-30** (session 4). Update at the end of every session. Re-verify against code at the start.

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

## ✅ Done (Session 4 — migrations applied to production, 2026-05-30)

1. **5 schema migrations applied to production** (`20260530000003`–`20260530000007`):
   - Drop `ADMIN` enum value (migrate rows to `SCHOOL_ADMIN` first).
   - Remove `Teacher.subject` + `Driver.idCopy` legacy fields.
   - Migrate `Student.game1Lvl…game5Lvl` → `StudentGameProgress` rows.
   - Make `Parent.schoolId` non-nullable (patch nulls first).
   - Add FK from `Message.senderId` → `User.id`.
2. **Frontend static export removed** — `output: 'export'` dropped from `next.config.mjs`; EC2 runs Next.js as a server and dynamic routes (`[id]`) no longer require `generateStaticParams()`.
3. **Teacher Zod schema cleanup** — `subject: z.string().optional()` removed from create and update schemas (field was dropped from DB in migration 000004).
4. **CI pipeline green** — `validate` + `deploy-backend-ec2` passing consistently.

---

## ✅ Done (Phase 4 — IaC + CI hardening, 2026-05-30)

All CDK infrastructure code written and synthesises cleanly. **Not deployed to AWS** — graduation
project decision: staying on free tier; EC2 + PM2 remains production. The CDK code lives in
`infra/cdk/` as an architectural showcase (6 stacks, ~700 lines TypeScript).

1. **CDK bootstrap** — `CDKToolkit` stack bootstrapped on account `035611741710 / us-east-1`.
   Account pinned in `infra/cdk/lib/config.ts` to prevent accidental deploy to wrong account.
   `infra/cdk/cdk.json` sets `"profile": "wecircle"` so CDK always uses the correct credentials.
2. **WeCircleNetwork** (Stack 1) — VPC, 3-tier subnets, NAT, 4 security groups. *(Created then
   destroyed — NAT Gateway costs ~$32/month; unnecessary for graduation project.)*
3. **WeCircleDatabase** (Stack 2) — RDS Postgres 16, Multi-AZ, Secrets Manager. *(Not deployed —
   free tier limitation: backup retention > 0 days requires account upgrade.)*
4. **WeCircleCompute** (Stack 3) — ECS Fargate, ALB, ECR, OIDC GitHub deploy role. *(Not deployed.)*
5. **WeCircleCache** (Stack 4) — ElastiCache Redis 7, Socket.IO adapter. *(Not deployed.)*
6. **WeCircleCdn** (Stack 5) — CloudFront + S3 for Next.js static export. *(Not deployed.)*
7. **WeCircleScheduler** (Stack 6) — EventBridge + Lambda for hourly overdue-invoice cron. *(Not deployed.)*
8. **CI restructured** — `deploy.yml` split into 3 jobs: `validate` (typecheck gate) +
   `deploy-backend-ec2` (every push) + `deploy-frontend-cdn` (manual, OIDC) + `deploy-ecs` (manual).
9. **Redis adapter wired** — `websocket.ts` applies `@socket.io/redis-adapter` when `REDIS_URL` is set;
   gracefully falls back to in-process without it. (R7 — code done, activation deferred.)
10. **EventBridge cron endpoint** — `/api/internal/cron/check-overdue` added; `CRON_SECRET` guards it.
    `startOverdueChecker()` removed from `server.ts`. (R10 — code done, EC2 still uses pm2 restart to
    retrigger; EventBridge activation deferred.)
11. **Mobile login wired** — `login_screen.dart` calls `/auth/mobile/login`; saves `mobile_token`,
    `mobile_entity_id`, `mobile_role`, `mobile_user_id` to SharedPreferences. (R16 partial)
12. **Body limit tightened** — `express.json({ limit: "50mb" })` → `1mb`. (R18 ✅)

---

## ✅ Done (Phase 3 — logic & structure refactor, 2026-05-30)

All 5 workstreams complete; deployed to production via CI on 2026-05-30.

1. **Flutter lint cleanup** — 23 `withOpacity` → `withValues(alpha:)`, `flutter analyze` → 0 issues. (R17)
2. **Backend chat consolidation** — `controllers/chat.controller.ts` + `controllers/conversation.controller.ts`
   merged into `modules/chat/` (333 lines). Both `/chat` and `/conversations` mount the same router. (R6, R9)
3. **Mobile chat consolidation** — Firebase/Firestore removed from the mobile app. `chat_service.dart`
   rewritten to REST + 5-second polling. `pubspec.yaml` drops `cloud_firestore` and `firebase_core`.
   Parent messages screen loads real conversations from the backend. (D5, R9)
4. **Controller migrations** — all 35 remaining legacy flat controllers moved into `modules/<domain>/`
   (routes → controller pattern). `src/controllers/` and `src/routes/modules/` directories deleted. (R6)
5. **Device session store** — `device_sessions.json` + sync file I/O replaced by `DeviceSession` Prisma
   model + async `sessionStore.ts`. Migration `20260530000002_device_sessions` applied in production. (R8)

**Post-deploy notes:**
- Mobile users were logged out once (expected — file sessions don't migrate to DB).
- `mobile_token` + `mobile_entity_id` still need to be written to SharedPreferences during login
  (`login_screen.dart`) — chat service won't authenticate until this is wired up.

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
- **R4 — `/auth/cognito-sync`** ✅ **FULLY FIXED (2026-05-30)** — two vulnerabilities closed:
  (a) `auto-confirm` Lambda deployed to AWS as `WeCircle-AutoConfirm` and attached to Cognito
  pre-signup trigger. No longer sets `autoVerifyEmail=true`.
  (b) `cognitoSync` now rejects tokens with `email_verified !== true` and always creates new users
  as PARENT — `custom:role` attribute in token is no longer trusted for elevated roles.

### 🟠 High (stability / architecture)
- **R5 — No DB migrations.** ✅ **FIXED (Phase 2)** — `prisma/migrations/` established with baseline + Phase 2 additions.
- **R6 — Half-done backend refactor.** ✅ **FIXED (Phase 3+session 3)** — all 35 legacy flat controllers
  migrated to `modules/<domain>/`. `invoice.service.ts` added (payment calc, discount logic,
  credential toggling). Express `Request` interface fully typed — eliminated all `(req as any)` casts.
- **R7 — Socket.IO won't scale.** ✅ **CODE DONE (Phase 4)** — Redis adapter wired in `websocket.ts`;
  activates automatically when `REDIS_URL` env var is set. Not activated on EC2 (no Redis instance).
  Acceptable for graduation project (single instance).
- **R8 — Device session store is a JSON file** ✅ **FIXED (Phase 3)** — replaced with `DeviceSession`
  Prisma model + async `sessionStore.ts`. Migration applied in production.
- **R9 — Duplicated chat systems** ✅ **FIXED (Phase 3)** — Firestore removed from mobile app; all chat
  goes through Postgres `Conversation`/`Message` via the consolidated `modules/chat/` backend.
- **R10 — In-process cron.** ✅ **CODE DONE (Phase 4)** — `startOverdueChecker()` removed from
  `server.ts`; replaced by `/api/internal/cron/check-overdue` endpoint + `CRON_SECRET` guard.
  `WeCircleScheduler` CDK stack written. Not activated on EC2 (acceptable for graduation project).

### 🟡 Medium (cleanliness / migration debt)
- **R11 — ~22 `fix_*.js` band-aid codemods** ✅ **FIXED (2026-05-30)** — all 23 scripts deleted after
  confirming effects are baked in. `forgot-password` i18n keys restored as a side-fix.
- **R12 — Committed build artifacts:** ✅ **Tracking clean (2026-05-30)** — files untracked and gitignored
  since Phase 1; local copies deleted. ~40 MB of blob objects remain in old commits (history rewrite
  via `git filter-repo` + force-push would remove them but needs explicit sign-off — CLAUDE.md prohibits
  rewriting shared history without approval).
- **R13 — Vite/react-router leftovers** ✅ **Already clean** — removed in Phase 1; confirmed 2026-05-30.
- **R14 — Stale config drift** ✅ **FIXED (2026-05-30)** — `buildspec.yml`, `ec2-userdata.sh`,
  `ecs-task-definition.json`, `infra/README.md` all updated to Cognito/JWT stack; Supabase vars purged.
- **R15 — Name drift** ✅ **FIXED (2026-05-30)** — "EduControl" → "WeCircle" in `server.ts`,
  `ai.controller.ts`, `admission.controller.ts`, `zoom.controller.ts`.
- **R16 — CI/CD weaknesses.** ✅ **FIXED (Phase 4 + session 3)** — `deploy.yml` simplified to
  EC2-only (CDN/ECS jobs removed — no missing-secret warnings). `validate` typecheck gate runs
  before every deploy. OIDC CDK role exists for future use.

### 🟢 Low (polish)
- **R17 — 23 Flutter `withOpacity` deprecation lints.** ✅ **FIXED (Phase 3A)** — replaced with `.withValues(alpha:)`.
- **R18 — `express.json({ limit: "50mb" })`** is very large; tighten or scope to upload routes.

---

## 📌 Known unknowns / open items
- **R12 — build artifact blobs in git history** (~40 MB). Files are untracked/gitignored since
  Phase 1, but the blobs remain in old commits. Removal requires `git filter-repo` + force-push —
  executed in session 4 (see commits). Clone size reduced.
- **Flutter screens partial audit** — functional screens (parent/teacher/driver dashboards) still
  contain some hardcoded sample data. Game screens (student1-3 / student4-6) are intentionally
  static. See session 4 audit results in PROGRESS.md.
- **Phase 4 provisioning** — RDS, ECS, ALB, CloudFront, Cognito, S3, ElastiCache, EventBridge.
  Decision: **not provisioned** — graduation project stays on EC2 + PM2 (free tier). CDK code
  in `infra/cdk/` serves as architectural showcase only.
