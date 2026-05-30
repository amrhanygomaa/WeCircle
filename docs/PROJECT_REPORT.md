# WeCircle — Project Technical Report

**Project:** WeCircle — School Attendance & Transportation Platform  
**Date:** 2026-05-30  
**Status:** Production-ready on EC2; CDK IaC designed and committed

---

## 1. Project Overview

WeCircle is a multi-role school management platform connecting **parents, students, teachers, bus
drivers, and school administrators**. It comprises three applications:

| App | Technology | Purpose |
|-----|-----------|---------|
| Mobile | Flutter 3.41 / Dart 3.10 | Parent, student, teacher, driver roles |
| Backend | Node 24 / Express 5 / TypeScript / Prisma 6 | REST API + WebSocket + AI assistant |
| Dashboard | Next.js 16 (App Router) / React 19 / Tailwind v4 | Admin web interface |

**Production URL:** `https://wecircle.helpers-tech.com` / `https://api.wecircle.helpers-tech.com`  
**Repository:** `github.com/amrhanygomaa/WeCircle`  
**AWS Account:** `035611741710 / us-east-1`

---

## 2. Technology Stack (Verified)

### Backend
- **Runtime:** Node.js 24 + Express 5 + TypeScript (strict mode)
- **ORM / Database:** Prisma 6 → PostgreSQL (40+ models, full school domain)
- **Auth:** AWS Cognito (web dashboard) + custom backend-signed JWT (mobile app)
- **Realtime:** Socket.IO 4.x (Redis adapter wired, activates via `REDIS_URL`)
- **AI:** Google Gemini (`@google/generative-ai`); AWS Bedrock SDK also present
- **Storage:** AWS S3 + presigned URLs
- **Validation:** Zod
- **Security:** Helmet, CORS with `ALLOWED_ORIGINS`, rate-limit ready

### Frontend (Dashboard)
- **Framework:** Next.js 16 App Router + React 19
- **Auth:** Amazon Cognito via `amazon-cognito-identity-js`
- **Data fetching:** TanStack Query
- **UI:** Tailwind v4 + Framer Motion + Recharts
- **i18n:** Custom AR/EN implementation

### Mobile
- **Framework:** Flutter 3.41 / Dart 3.10
- **Auth:** Backend-signed JWT stored in SharedPreferences
- **Data:** REST via `http` package to backend API
- **Chat:** Firestore removed; now via REST polling to backend (consolidated in Phase 3)

### Infrastructure
- **Hosting:** AWS EC2 (t3.micro) + pm2 process manager
- **CI/CD:** GitHub Actions (typecheck gate → SSH deploy → pm2 restart)
- **DB:** PostgreSQL (on EC2, managed by pm2)
- **IaC:** AWS CDK v2 TypeScript (6 stacks designed, not deployed — see Section 6)

---

## 3. Architecture Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **PostgreSQL via Prisma** as sole database | Supabase SDK already removed by previous dev; clean Prisma setup was already working |
| D2 | **Next.js App Router** as sole frontend build tool | Vite/react-router deps were dead leftovers from original SPA; removed entirely |
| D3 | **Dual auth** — Cognito for web, custom JWT for mobile | Staff use email/Cognito; students/parents use school-generated login IDs (by design) |
| D4 | **Socket.IO** for realtime | Already wired; Redis adapter added for future horizontal scaling |
| D5 | **Consolidate chat on Postgres + REST** | Firestore was only used for chat — eliminated Firebase dependency from mobile |
| D6 | **Google Gemini** AI assistant (Bedrock optional) | Already wired and working; Bedrock SDK present for future swap |

---

## 4. Work Completed by Phase

### Phase 0 — Stabilize & Baseline (2026-05-29)
- Full repo mapping across all 3 apps + infra + CI
- Resolved README/brief contradictions (DB, auth, hosting all differed from docs)
- Established build baseline: backend TypeScript + frontend Next.js build + Flutter analyze all clean
- Created `CLAUDE.md` (persistent context), `MIGRATION_PLAN.md`, `PROGRESS.md`

### Phase 1 — Resolve Ambiguities (2026-05-29)
- Removed Supabase `directUrl` from Prisma schema
- Removed Vite, react-router-dom, dead routing code from frontend
- **Security: deleted `GET /api/auth/temp-make-admin` backdoor** (account takeover vector)
- Hardened env config: `requireEnv()` strict — app fails fast if secrets missing
- Added `ALLOWED_ORIGINS` env var; removed hardcoded CORS origins
- Untracked and gitignored committed build artifacts (`frontend_build.zip` etc.)

### Phase 2 — Schema & Migrations (2026-05-29)
- Introduced `prisma/migrations/` (was missing — DB was only ever `db push`'d)
- `20260529000000_init`: 1674-line baseline SQL capturing existing production schema
- `20260529000001_phase2_additions`: non-destructive additions:
  - `@db.Decimal(12,2)` on 9 money fields
  - Composite indexes: `Attendance(schoolId,classId,date)`, `Invoice(schoolId,status,dueDate)`
  - `StudentGameProgress` model (replaces flat `game1Lvl…game5Lvl` columns)
  - `Conversation.pairKey` unique field (prevents duplicate A↔B chat pairs)
  - `Notification.recipient → User` FK (enforces referential integrity)

### Phase 3 — Logic & Structure Refactor (2026-05-30)
- **Flutter lint cleanup:** 23 `withOpacity` → `withValues(alpha:)` deprecations fixed; `flutter analyze` → 0 issues
- **Backend architecture:** all 35 legacy flat controllers migrated from `src/controllers/` to layered `src/modules/<domain>/` (routes → controller pattern)
- **Chat consolidation:** Firestore removed from mobile app; `chat_service.dart` rewritten to REST + polling; `cloud_firestore` and `firebase_core` removed from `pubspec.yaml`
- **Device session store:** `device_sessions.json` + sync file I/O replaced by `DeviceSession` Prisma model + async `sessionStore.ts` (migration `20260530000002_device_sessions` applied in production)
- **Mobile login:** `login_screen.dart` wired to real `/auth/mobile/login` API; saves `mobile_token`, `mobile_entity_id`, `mobile_role` to SharedPreferences

### Phase 4 — Security Hardening + IaC (2026-05-30)

#### Security Fixes
- **R4 — Account-takeover in `/auth/cognito-sync` (CRITICAL):**
  - `auto-confirm` Lambda: removed `autoVerifyEmail: true` — Cognito now sends real email verification
  - `cognitoSync` endpoint: added `email_verified !== true` guard
  - Auto-created users always get `Role.PARENT` — `custom:role` attribute from token no longer trusted
- **R11 — Deleted 23 `fix_*.js` band-aid codemods** after verifying effects are baked in
- **R14 — Purged Supabase config drift** from `buildspec.yml`, `ec2-userdata.sh`, `ecs-task-definition.json`
- **R15 — Fixed "EduControl" → "WeCircle" branding** in `server.ts`, `ai.controller.ts`, `admission.controller.ts`
- **R18 — Body limit tightened:** `express.json({ limit: "50mb" })` → `1mb`

#### CI/CD Improvements
- `deploy.yml` restructured: `validate` job (TypeScript typecheck gate) runs before any deploy
- Split into 3 independent jobs: `deploy-backend-ec2` (auto, every push) + `deploy-frontend-cdn` (manual) + `deploy-ecs` (manual)
- DB migration steps added to EC2 deploy: `prisma migrate resolve` + `prisma migrate deploy`

#### Backend Wiring
- **Redis adapter:** `websocket.ts` applies `@socket.io/redis-adapter` when `REDIS_URL` is present; graceful fallback to in-process when not set
- **Cron endpoint:** `/api/internal/cron/check-overdue` added with `CRON_SECRET` header guard; `startOverdueChecker()` removed from `server.ts`

#### CDK Infrastructure (Designed, Not Deployed)
See Section 6.

---

## 5. Security Improvements Summary

| Risk | Severity | Status |
|------|----------|--------|
| Auth backdoor (`/temp-make-admin`) | 🔴 Critical | ✅ Fixed — endpoint deleted |
| Hardcoded JWT fallback secret | 🔴 Critical | ✅ Fixed — `requireEnv()` strict |
| `aws_config.txt` committed | 🔴 Critical | ✅ Fixed — gitignored; `ALLOWED_ORIGINS` env var |
| Account-takeover in `/auth/cognito-sync` | 🔴 Critical | ✅ Fixed — email verification + role guard |
| Body limit `50mb` | 🟡 Medium | ✅ Fixed → `1mb` |
| No DB migration history | 🟠 High | ✅ Fixed — `prisma/migrations/` established |
| Device sessions in a JSON file | 🟠 High | ✅ Fixed — `DeviceSession` Prisma model |
| In-process cron (duplicate on scale) | 🟠 High | ✅ Code done — endpoint ready for EventBridge |
| Socket.IO won't scale beyond 1 instance | 🟠 High | ✅ Code done — Redis adapter wired |
| 23 band-aid codemods | 🟡 Medium | ✅ Fixed — all deleted |
| Stale Supabase/EduControl config | 🟡 Medium | ✅ Fixed — all purged |
| CI: no typecheck gate before deploy | 🟡 Medium | ✅ Fixed — `validate` job added |

---

## 6. AWS CDK Infrastructure Design

Six CDK stacks in `infra/cdk/lib/stacks/` — all synthesise cleanly via `cdk synth`.  
Account pinned to `035611741710` in `lib/config.ts` to prevent accidental cross-account deploy.

```
internet
    │
Route 53 / DNS
    ├── wecircle.helpers-tech.com  →  CloudFront → S3 (Next.js static export)
    └── api.wecircle.helpers-tech.com  →  ALB → ECS Fargate (backend)

VPC 10.0.0.0/16 (2 AZs, us-east-1)
├── Public subnets    — ALB, NAT Gateway
├── Private subnets   — ECS Fargate tasks (egress via NAT)
└── Isolated subnets  — RDS PostgreSQL 16, ElastiCache Redis 7
```

| Stack | Resources | Purpose |
|-------|-----------|---------|
| `WeCircleNetwork` | VPC, 6 subnets, NAT, 4 Security Groups | Networking layer |
| `WeCircleDatabase` | RDS PostgreSQL 16 Multi-AZ, Secrets Manager | Managed database |
| `WeCircleCompute` | ECR, ECS Fargate, ALB (lb_cookie sticky), OIDC role | Backend compute |
| `WeCircleCache` | ElastiCache Redis 7 (2 nodes, TLS), SSM `/wecircle/REDIS_URL` | Socket.IO adapter |
| `WeCircleCdn` | S3 (private) + CloudFront OAC, 403/404→index.html | Frontend hosting |
| `WeCircleScheduler` | EventBridge CfnSchedule (`cron(0 * * * ? *)`), Lambda → ALB | Hourly cron job |

**Key design decisions in the CDK:**
- `deletionProtection: true` + `RemovalPolicy.RETAIN` on RDS — database survives stack deletion
- `cacheDeployed` context flag — Compute stack reads `REDIS_URL` from SSM only after Cache stack is live
- OIDC GitHub Actions role — no long-lived AWS keys in CI (R16)
- ECS autoscaling 1→3 tasks on CPU 70%
- ALB `lb_cookie` stickiness — required for Socket.IO connections to stay on the same task

---

## 7. Data Model Overview

~40 Prisma models covering the full school domain:

```
School (multi-tenant root — schoolId on every model)
├── Users & Auth
│   ├── User (Cognito ↔ web dashboard)
│   ├── AppCredential (backend JWT ↔ mobile)
│   ├── DeviceSession (mobile session store)
│   └── ActivityLog
├── Academic
│   ├── AcademicYear, Grade, SchoolClass, Subject
│   ├── Student, Teacher, TeacherSubject, Parent
│   ├── Timetable, Homework (+Submission), Exam (+Result)
│   ├── Attendance, LeaveRequest, BehaviorReport, DailyReport
│   └── StudentGameProgress (gamification)
├── Finance
│   ├── FeeStructure, Invoice, Payment
│   └── ApplicationFee
├── Transport
│   ├── Bus, Driver, BusRoute, BusSupervisor
│   ├── StudentBus, BusAttendance
│   └── BusTrackingEvent
├── Communication
│   ├── Conversation (+pairKey dedup), Message
│   ├── Announcement, Notification
│   └── AiChatMessage (Gemini history)
└── Settings
    ├── SchoolSettings, SchoolResult
    └── Archive
```

---

## 8. API Structure

Backend follows layered module pattern (`routes → controller → service → repository`):

```
src/
├── modules/
│   ├── auth/          — Cognito sync, mobile login, logout
│   ├── student/       — CRUD + game progress (fully layered reference impl)
│   ├── teacher/       — CRUD + subjects
│   ├── parent/        — CRUD + children
│   ├── driver/        — CRUD + bus assignment
│   ├── chat/          — conversations + messages (consolidated)
│   ├── attendance/    — daily attendance records
│   ├── homework/      — assignments + submissions
│   ├── exam/          — exams + results
│   ├── invoice/       — fee structure + billing
│   ├── bus/           — routes + tracking
│   ├── notification/  — push notifications
│   └── ai/            — Gemini AI assistant
├── core/
│   ├── http/middlewares/  — requireAuth, requireMobileAuth, roleGuard, tenantScope
│   └── utils/             — AppError, asyncHandler, sessionStore
└── config/                — env, prisma, websocket (Redis adapter)
```

**Response shape:** `{ success: boolean, message?, data? }` — consistent across all endpoints.

---

## 9. Mobile App Structure

```
mobile/lib/
├── core/
│   ├── api/         — ApiService (HTTP client), ApiConfig (base URL)
│   └── config/
├── services/
│   └── responsive_helper.dart
├── screens/
│   ├── login_screen.dart     — wired to /auth/mobile/login
│   ├── parent/               — home, children, attendance, messages, payments
│   ├── teacher/              — home, class, homework, exams
│   ├── driver/               — route, students, tracking
│   ├── student1-3/           — gamified (grades 1-3)
│   ├── student4-6/           — gamified (grades 4-6)
│   └── student_shared/       — shared student screens
└── main.dart
```

**Auth flow:** login → backend returns `mobile_token` + role-specific entity ID → stored in
SharedPreferences → every subsequent request includes `Authorization: Bearer <token>`.

---

## 10. CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
on: push (main) | workflow_dispatch

jobs:
  validate:          # TypeScript typecheck — blocks deploy if types fail
    - npm ci + prisma generate + tsc (backend)
    - npm ci + next build (frontend)

  deploy-backend-ec2:   # every push to main
    - SSH to EC2
    - git pull + npm ci + prisma generate
    - prisma migrate resolve (baseline) + prisma migrate deploy
    - npm run build + pm2 restart

  deploy-frontend-cdn:  # manual only (workflow_dispatch: cdn/both)
    - next build (static export → out/)
    - AWS OIDC → S3 sync + CloudFront invalidation

  deploy-ecs:           # manual only (workflow_dispatch: ecs/both)
    - AWS OIDC → ECR login → docker build + push
    - ECS force-new-deployment
```

---

## 11. Current Production State

| Component | Where | Status |
|-----------|-------|--------|
| Backend API | EC2 `api.wecircle.helpers-tech.com` | ✅ Running (pm2) |
| Admin Dashboard | EC2 static files | ✅ Running |
| PostgreSQL | EC2 local | ✅ Running |
| Mobile App | Flutter (Android/iOS) | ✅ Built, auth wired |
| Cognito User Pool | `us-east-1_IvG7IexJJ` | ✅ Active |
| Redis / ElastiCache | — | ⏸ Not deployed (free tier) |
| RDS | — | ⏸ Not deployed (free tier) |
| CloudFront CDN | — | ⏸ Not deployed |

---

## 12. Remaining Open Items

1. **R4 Lambda redeployment** — `infra/lambda/auto-confirm/index.mjs` was fixed in code but the
   Lambda running on AWS still has the old `autoVerifyEmail: true` logic. Redeploy before any
   Cognito-based user registration in production.

2. **Deferred schema migrations** (need data migration before applying):
   - Drop `ADMIN` enum value (migrate rows to `SCHOOL_ADMIN` first)
   - Remove `Teacher.subject`, `Driver.idCopy` legacy fields
   - Remove `Student.game1Lvl…game5Lvl` flat columns (after backfilling `StudentGameProgress`)
   - Make `Parent.schoolId` non-nullable (patch null rows first)
   - Type `Message.senderId` as FK (needs chat identity consolidation)

3. **CDK stacks ready for deployment** if free tier constraint is lifted:
   - Bootstrap already complete on account `035611741710`
   - Sequence: `WeCircleNetwork → WeCircleDatabase → WeCircleCompute → WeCircleCache → WeCircleCdn → WeCircleScheduler`
   - After Cache deploy: set `cacheDeployed: true` in `cdk.json` and redeploy Compute

---

*Report generated 2026-05-30. See `docs/PROGRESS.md` for per-phase detail and `docs/MIGRATION_PLAN.md` for architectural decisions.*
