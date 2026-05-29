# WeCircle — Migration Plan (living document)

Owner: lead engineer (takeover). Last updated: **2026-05-29**. Keep decisions + rationale here.

---

## 0. Context

WeCircle = school attendance & transport platform (Flutter mobile + Express/Prisma backend +
Next.js admin web). Inherited mid–Supabase→AWS migration with significant band-aid debt. This plan
follows the phased order from the takeover brief. **No Phase 2 schema changes or AWS provisioning
until signed off.**

---

## 1. Phase status

| Phase | Goal | Status |
|------|------|--------|
| 0 | Stabilize & baseline (map, verify stack, build locally, set up docs) | ✅ Done (2026-05-29) |
| 1 | Resolve ambiguities (single DB, single FE build tool, single auth) | 🔜 Proposed below — needs sign-off |
| 2 | Schema redesign (Prisma migrations) | ⏸ Proposed below — **needs sign-off, not applied** |
| 3 | Logic & structure refactor (layered arch, Zod, error handling, mobile alignment) | ⏳ Pending |
| 4 | AWS + IaC (Terraform/CDK) | ⏸ Target below — **needs sign-off before provisioning** |
| 5 | Cutover (migrate data, switch endpoints, decommission Supabase) | ⏳ Pending |

---

## 2. Decisions & rationale

### D1 — Database: **PostgreSQL via Prisma** (confirm)
Code already targets plain Postgres through `DATABASE_URL`; Supabase SDK is gone. Keep Prisma.
→ AWS target: **RDS for PostgreSQL** (or Aurora Serverless v2). Mostly a connection-string change.
Remove the Supabase-era `directUrl` from the datasource (was for pgBouncer pooling).

### D2 — Frontend build tool: **Next.js 16 (App Router)** — remove Vite/react-router ✅ LOCKED
It already builds as Next and deploys as a Next server. The leftover `vite`, `@vitejs/plugin-react`,
`@tailwindcss/vite`, and `react-router-dom` deps + `src/core/routing/*` + `vite.svg`/`react.svg` are
dead weight from the original Vite SPA. Decision: commit to Next, delete the Vite/react-router
remnants in Phase 1.
→ AWS target: **S3 + CloudFront (static export)**. The app is a client dashboard hitting a REST API —
SSR is not required, so `next export` → S3 + CloudFront is cheaper and simpler than Amplify/OpenNext.
This also matches the current S3-static deployment pattern.

### D3 — Auth: **Cognito for web, custom JWT (`AppCredential`) for mobile** (confirm, then harden)
This split already exists and is coherent (staff use email/Cognito; mobile users get
dashboard-generated login IDs). Keep both but:
- Remove the hardcoded JWT fallback secret and the `SUPABASE_JWT_SECRET` fallback in `config/env.ts`.
- Replace the in-memory/file `device_sessions.json` session store with a real store (DB or Redis).
- **Delete the `GET /api/auth/temp-make-admin` backdoor immediately** (see risk R1).

### D4 — Realtime: keep Socket.IO, add a Redis adapter before horizontal scaling
Single-instance today. For ECS multi-task, add `@socket.io/redis-adapter` + ElastiCache and sticky
sessions at the ALB.

### D5 — Chat: **consolidate on Postgres + Socket.IO** ✅ LOCKED
The Postgres `Conversation`/`Message` models already exist with backend chat/conversation controllers.
The mobile `chat_service.dart` (Firestore) is dead weight. Decision: drop Firestore from the mobile
app; update `chat_service.dart` to call the existing REST/Socket.IO endpoints. This eliminates the
Firebase dependency entirely (Firebase is currently only wired for chat — see `main.dart:71`). Phase 3 work.

### D6 — AI: keep Gemini for now, keep Bedrock as an option
`@google/generative-ai` is wired; `@aws-sdk/client-bedrock-runtime` is also present. Defer the
Gemini→Bedrock decision to Phase 4; abstract the AI call behind a service so it's swappable.

---

## 3. Proposed schema redesign (Phase 2 — FOR REVIEW, NOT APPLIED)

The current schema (~40 models in `dashboard/backend/prisma/schema.prisma`) is **already mature and
well-normalized** for the domain (School, User, AppCredential, AcademicYear, Grade, SchoolClass,
Subject, full Application/admissions tree, Student, Teacher, TeacherSubject, Parent, Timetable,
Homework(+Submission), Exam(+Result), Attendance, FeeStructure, Invoice, Payment, Bus, Driver,
BusRoute, StudentBus, Announcement, Notification, ActivityLog, SchoolSettings, SchoolResult,
Conversation/Message, Archive, LeaveRequest, AiChatMessage, BusSupervisor, BusAttendance,
BehaviorReport, DailyReport, StudentTask, StudentTaskCompletion).

So Phase 2 is **cleanup, normalization, and migration hygiene** — not a greenfield rebuild.

### 3.1 Migration hygiene (highest priority)
- **Introduce Prisma migrations.** There is no `prisma/migrations/` dir today — the DB is synced with
  `prisma db push`, so there is no history and no safe path to evolve production. Baseline the current
  schema as the first migration (`prisma migrate diff` against the live DB → initial migration), then
  use `prisma migrate` going forward. **No destructive migration without explicit approval.**

### 3.2 Concrete model changes proposed
1. **Roles:** drop the legacy `ADMIN` value from `enum Role` (kept "for backward compatibility");
   migrate any existing `ADMIN` rows to `SCHOOL_ADMIN` first.
2. **Money precision:** type all `Decimal` money fields explicitly, e.g. `@db.Decimal(12,2)`
   (Student fees, Invoice amounts, Payment, ApplicationFee, FeeStructure, Expense, salaries).
3. **`Parent.schoolId`:** make required (`String`) for tenant consistency — every other entity is.
4. **`Conversation` uniqueness:** `@@unique([participant1Id, participant2Id])` is order-sensitive and
   allows duplicate (A,B)/(B,A) pairs. Normalize (store sorted pair, or a derived `pairKey`).
5. **`Message.senderId` / `Notification.recipientId`:** these are bare `String`s with no FK. Add real
   relations to `User` (or a polymorphic participant) so integrity and joins work.
6. **Gamification:** replace the flat `Student.points` + `game1Lvl…game5Lvl` columns with the
   brief's **`Assignment`/game-gating table** (per-student, per-game unlock + progress rows). This is
   the one genuinely missing model the brief calls for.
7. **Naming consistency:** several relations on `School` use PascalCase field names
   (`BusSupervisor`, `BusAttendance`, `BehaviorReport`, `DailyReport`, `StudentTask`) — normalize to
   camelCase plural to match the rest.
8. **`Teacher.subject` / `Driver.idCopy`:** remove fields explicitly marked "legacy / backward
   compatibility" once data is migrated to the normalized relations.
9. **`directUrl`:** remove from datasource (Supabase pooling leftover).
10. **Indexing review:** add composite indexes for the hottest queries (e.g.
    `Attendance(schoolId, classId, date)`, `Invoice(schoolId, status, dueDate)`).

A full proposed `schema.prisma` will be produced as a separate reviewable file once the above
direction is approved (kept separate so it is never mistaken for "applied").

---

## 4. Target AWS architecture (Phase 4 — FOR SIGN-OFF, NOTHING PROVISIONED)

Replace the current ad-hoc single-EC2 + pm2 + SCP deployment with a managed, reproducible stack
defined as **Infrastructure as Code (Terraform or AWS CDK — decision pending; CDK fits the TS team)**.

```
                Route 53
                   │
         ┌─────────┴───────────┐
         │                     │
   CloudFront (web)     CloudFront/ALB (api.*)
         │                     │
   S3 static  OR        Application Load Balancer (sticky sessions for Socket.IO)
   Amplify/OpenNext            │
                         ECS Fargate service (backend, autoscaling)
                               │
            ┌──────────────┬───┴────────┬───────────────┐
            │              │            │               │
   RDS PostgreSQL   ElastiCache     S3 (assets:    Secrets Manager / SSM
   (Multi-AZ)       Redis           cards, scans,  (DB URL, JWT, Cognito,
                    (Socket.IO      report PDFs)    Gemini key)
                     adapter)            │
                                    CloudFront (asset CDN)

   Auth: Amazon Cognito (existing pool us-east-1_IvG7IexJJ) + post-signup auto-confirm Lambda
   Cron: EventBridge Scheduler  →  replaces the in-process node cron (checkOverdueInvoices)
   Push: SNS / Pinpoint (FCM/APNs) for mobile notifications
   AI:   Gemini (external) now; optional swap to Amazon Bedrock
   CI/CD: GitHub Actions with an OIDC role (no long-lived keys) → ECR images → ECS deploy
   Observability: CloudWatch logs/metrics/alarms; budgets already drafted in infra/aws/budget.json
```

**Highest-risk piece:** Cognito (already partially live — pool `us-east-1_IvG7IexJJ`). Treat the
auth path as the most fragile during cutover. Second-riskiest: data migration from the current
Postgres to RDS (Phase 5).

**Cutover (Phase 5):** stand up RDS + ECS in parallel, run a dump/restore + Prisma migrate, smoke
test against a staging domain, flip DNS, then decommission the EC2 box and any Supabase remnants
(with approval).

---

## 5. Owner decisions (locked 2026-05-29)

| # | Question | Answer | Impact |
|---|----------|--------|--------|
| 1 | Is the live EC2 production with real user data? | **YES** | Phase 5 migration must be zero-data-loss; no destructive change without explicit approval |
| 2 | Is there Supabase data to migrate? | **NO** — current Postgres is source of truth | No Supabase data migration needed; just remove Supabase config remnants |
| 3 | Firestore chat: keep or consolidate? | **Consolidate to Postgres** | Phase 3: rewrite mobile chat_service.dart to use REST/Socket.IO; remove Firebase |
| 4 | IaC tool? | **Terraform** | Phase 4: write `.tf` modules for RDS, ECS, ALB, CloudFront, Cognito, S3, ElastiCache, EventBridge |
| 5 | Frontend on AWS? | **S3 + CloudFront (static export)** | Phase 4: `next export` → S3 bucket + CloudFront distribution via Terraform |
