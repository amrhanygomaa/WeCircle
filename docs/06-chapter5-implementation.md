<!-- ============================================================
     CHAPTER 5 — IMPLEMENTATION
     ============================================================ -->

# Chapter 5 — Implementation

This chapter describes how the design of Chapter 4 was realized in code. It covers the development
environment, the structure of each component, and the concrete implementation of the backend,
database layer, web dashboard, mobile application, and security, with representative annotated
excerpts taken directly from the source.

## 5.1 Development Environment & Tools

### Table 5.1 — Technology Stack & Versions

| Component | Key technologies (declared versions) |
|-----------|---------------------------------------|
| **Backend** | Node.js (24), TypeScript `^5.9.3`, Express `^5.1.0`, Prisma `^6.17.1`, PostgreSQL, Socket.IO `^4.8.3` (+ Redis adapter `^8.3.0`), `aws-jwt-verify ^5.1.1`, `jsonwebtoken ^9.0.2`, AWS SDK v3 (`bedrock-runtime`, `cognito-identity-provider`, `s3`, `s3-request-presigner` `^3.1056.0`), `firebase-admin ^12.7.0`, `zod ^4.1.12`, `helmet ^8.1.0`, `cors ^2.8.5`, `morgan ^1.10.1` |
| **Frontend** | Next.js `^16.2.4`, React `^19.2.4`, TanStack Query `^5.90.3`, `axios ^1.12.2`, `amazon-cognito-identity-js ^6.3.16`, Tailwind CSS `^4.1.14`, `framer-motion ^12.38.0`, `recharts ^3.2.1`, `react-hook-form ^7.65.0`, `socket.io-client ^4.8.3`, `jspdf ^4.2.1` |
| **Mobile** | Flutter / Dart (`sdk ^3.10.7`), `http ^1.6.0`, `shared_preferences ^2.5.2`, `firebase_core ^3.8.0`, `firebase_messaging ^15.1.5`, `flutter_screenutil ^5.9.3`, `lottie ^3.3.2`, `image_picker ^1.2.1`, `pdf ^3.12.0`, `intl ^0.20.2` |
| **Tooling / Ops** | Git + GitHub Actions (CI/CD), AWS (EC2, Cognito, S3, Bedrock), pm2, nginx, Certbot, Prisma Migrate |

Local development uses `npm run dev` for the backend (`tsx watch`, port 5001), `next dev` for the
frontend (port 3000), and `flutter run --dart-define=API_URL=...` for the mobile app. All three
components build and type-check cleanly under strict settings.

## 5.2 Project Structure

The repository is a monorepo with three top-level components: `mobile/` (Flutter), `dashboard/
backend/` (Express/Prisma), and `dashboard/frontend/` (Next.js). The verified folder layouts are
presented in Chapter 4 of the analysis; the backend's feature-module structure is the defining
organizational pattern and is detailed in §5.3.

## 5.3 Backend Implementation

### 5.3.1 Application bootstrap

The Express application is assembled in `server.ts`: it installs security and logging middleware,
mounts all feature routes under `/api`, initializes the Socket.IO server, starts the overdue-invoice
cron, and registers the global error handler last.

```ts
// dashboard/backend/src/server.ts (excerpt)
const app = express();
const httpServer = createServer(app);
initWebSocket(httpServer);                 // Socket.IO with per-school rooms

app.use(helmet());                          // security headers
app.use(cors({ origin: env.allowedOrigins, credentials: true }));
app.use(express.json({ limit: "1mb" }));    // body-size cap
app.use(express.urlencoded({ limit: "1mb", extended: true }));
app.use(morgan("dev"));

app.use("/api", routes);                     // all 37 feature modules
app.use(errorHandler);                       // centralized error handling (last)
```

### 5.3.2 Modular routing

Each feature is a self-contained module (`routes → controller → service`). The route index mounts
every module under a stable path prefix:

```ts
// dashboard/backend/src/routes/index.ts (excerpt)
router.use("/students",   studentRoutes);
router.use("/attendance", attendanceRoutes);
router.use("/invoices",   invoiceRoutes);
router.use("/transport",  transportRoutes);
router.use("/ai",         aiRoutes);
// ... 37 modules total, plus an internal cron endpoint protected by X-Cron-Secret
```

A representative route file demonstrates the middleware pipeline (authenticate → tenant-scope →
role-guard → controller) and the co-existence of web and mobile surfaces in one module:

```ts
// dashboard/backend/src/modules/student/student.routes.ts (excerpt)
// Mobile (AppCredential JWT)
router.get("/mobile/game-state",  requireMobileAuth, getMobileStudentGameState);
router.post("/mobile/ai-chat",    requireMobileAuth, studentMobileAiChat);

// Web dashboard (Cognito) — writes restricted by role
router.get("/",      requireAuth, tenantScope, getStudents);
router.post("/",     requireAuth, tenantScope, roleGuard([Role.SCHOOL_ADMIN, Role.SUPER_ADMIN]), createStudent);
router.delete("/:id",requireAuth, tenantScope, roleGuard([Role.SCHOOL_ADMIN, Role.SUPER_ADMIN]), deleteStudent);
```

### 5.3.3 Error handling and validation

Controllers are wrapped with `asyncHandler` so that any thrown error is routed to the central
`errorHandler`. Domain errors are expressed as typed `AppError` subclasses (`ValidationError`,
`AuthenticationError`, `ForbiddenError`, `NotFoundError`, `ConflictError`). Input is validated at the
controller boundary with **Zod** schemas, e.g.:

```ts
// dashboard/backend/src/modules/auth/auth.controller.ts (excerpt)
const mobileLoginSchema = z.object({
  loginId:  z.string().min(1, "Login ID or Email is required"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});
const { loginId, password } = mobileLoginSchema.parse(req.body);
```

### 5.3.4 Real-time layer

`config/websocket.ts` initializes Socket.IO and places each connection into a room based on its
school, so that broadcasts reach only that school's users. A Redis adapter is attached *only* when
`REDIS_URL` is configured, enabling multi-instance scaling without changing application code:

```ts
// dashboard/backend/src/config/websocket.ts (excerpt)
io.on("connection", (socket) => {
  const schoolId = socket.handshake.query.schoolId as string | undefined;
  if (userRole === "SUPER_ADMIN") socket.join("super_admin");
  else if (schoolId) socket.join(`school:${schoolId}`);   // per-tenant isolation
  // ...resolve the real User.id and join `user:<id>` for targeted events
});
```

## 5.4 Authentication & Role-Based Access Control

WeCircle implements **two parallel authentication systems** reconciled behind a uniform `req.user`.

**Web (Cognito).** `requireAuth` accepts a Bearer token, first attempting to verify it as a
backend-signed custom JWT and otherwise verifying it as a Cognito *id* token; on success it loads the
local user and attaches role-specific profile IDs:

```ts
// dashboard/backend/src/core/http/middlewares/auth.ts (excerpt)
const verifier = CognitoJwtVerifier.create({
  userPoolId: env.cognitoUserPoolId, tokenUse: "id", clientId: env.cognitoClientId,
});
// 1) try custom JWT (jwt.verify with JWT_SECRET) → 2) fallback to Cognito verify
const cognitoPayload = await verifier.verify(token);
const dbUser = await prisma.user.findUnique({ where: { email }, include: { teacher:true, parent:true, student:true, driver:true, supervisor:true }});
req.user = { id: dbUser.id, cognitoId: cognitoPayload.sub, email, role: dbUser.role, schoolId: dbUser.schoolId };
```

The `cognito-sync` controller hardens first sign-in: it **requires `email_verified === true`** and
**never** elevates a user's role from token attributes—new users are always created as `PARENT` and
must be promoted by a Super Admin through the admin UI.

**Mobile (JWT + device sessions).** `requireMobileAuth` verifies the backend JWT and, for Parent and
Teacher roles, additionally confirms that the device session is still active (enabling remote
logout):

```ts
// dashboard/backend/src/core/http/middlewares/mobileAuth.ts (excerpt)
const decoded = jwt.verify(token, env.jwtSecret) as MobileRequestUser;
if ((decoded.role === "PARENT" && decoded.parentId) ||
    (decoded.role === "TEACHER" && decoded.teacherId)) {
  if (!(await isSessionActive(token))) {
    res.status(401).json({ success:false, message:"Session has been terminated or revoked" });
    return;
  }
}
req.user = { id: decoded.id, email: decoded.loginId, role: decoded.role, schoolId: decoded.schoolId, cognitoId: decoded.id };
```

**Tenant scoping and role guarding.** After authentication, `tenantScope` derives `req.schoolId`
(Super Admin may target any school via header/query; other users are bound to their own school), and
`roleGuard` restricts specific operations:

```ts
// tenantScope.ts (excerpt)
if (user.role === "SUPER_ADMIN") { req.schoolId = headerSchoolId || querySchoolId || user.schoolId || null; return next(); }
if (!user.schoolId) throw new ForbiddenError("Your account is not associated with any school.");
req.schoolId = user.schoolId;

// roleGuard.ts (excerpt)
export function roleGuard(roles: Role[]) {
  return (req, res, next) => {
    if (!req.user?.role || !roles.includes(req.user.role)) {
      res.status(403).json({ success:false, message:"Forbidden" }); return;
    }
    next();
  };
}
```

## 5.5 Database Layer

Persistence is implemented with Prisma over PostgreSQL. The schema (`prisma/schema.prisma`) declares
roughly forty-five models and twenty-four enumerations; the Prisma client is a singleton
(`config/prisma.ts`) injected into controllers. Schema evolution is managed by **versioned
migrations** under `prisma/migrations/` (ten migrations from `20260529000000_init` to
`20260530000009_device_tokens`), applied in production with `prisma migrate deploy`.

Two patterns are pervasive:

- **Multi-tenant columns.** Almost every model carries `schoolId` with an index, and queries always
  filter by the request's school, e.g. `prisma.student.findMany({ where: { schoolId } })`.
- **Money as decimals.** Financial fields use `Decimal(12,2)` to avoid floating-point error, and
  invoice balances (`paid`, `remaining`, `status`) are maintained as payments are recorded.

## 5.6 Web Dashboard Implementation

The dashboard is a Next.js 16 App-Router application. Server state is managed with TanStack Query;
HTTP is performed by an axios instance whose request interceptor attaches the current Cognito ID
token and disables caching:

```ts
// dashboard/frontend/src/core/api/apiClient.ts (excerpt)
api.interceptors.request.use(async (config) => {
  const cognitoUser = userPool.getCurrentUser();
  if (cognitoUser) {
    const token = await getValidIdToken(cognitoUser);   // session.getIdToken().getJwtToken()
    if (token) config.headers.Authorization = "Bearer " + token;
  }
  return config;
});

// Direct-to-S3 upload via a presigned URL obtained from the backend
export async function uploadToS3(file: File, folder = "uploads"): Promise<string> {
  const { data } = await api.get('/storage/presign', { params: { fileName: file.name, fileType: file.type, folder }});
  await axios.put(data.presignedUrl, file, { headers: { 'Content-Type': file.type }});
  return data.publicUrl;
}
```

Pages under `src/app/dashboard/*` implement each module (students, teachers, parents, attendance,
admissions with a multi-step wizard, payments/invoices, timetable, exams, transport, announcements,
messages, reports, settings, credentials), and an embedded **AI Chat Assistant** component calls the
`/ai/chat` endpoint. Real-time updates are received through a Socket.IO client. Localization
(`core/i18n`) provides Arabic (RTL) and English.

## 5.7 Mobile Application Implementation

The Flutter app (`mobile/`, package `wesal`) communicates with the backend over REST using the
`http` package, storing the JWT and identity in `shared_preferences`. A representative service call:

```dart
// mobile/lib/core/api/api_service.dart (excerpt)
final token = prefs.getString('mobile_token') ?? '';
final res = await http.get(
  Uri.parse('${ApiConfig.getBaseUrl()}/parents/mobile/dashboard'),
  headers: {'Authorization': 'Bearer $token'},
).timeout(const Duration(seconds: 15));
```

The base URL is environment-driven (defaulting to the production API), and **chat is served by the
backend** (`/chat/mobile`) rather than a third-party database:

```dart
// mobile/lib/core/config/api_config.dart
static const String baseUrl = String.fromEnvironment(
  'API_URL', defaultValue: 'https://api.wecircle.helpers-tech.com/api');

// mobile/lib/services/chat_service.dart
static String get _base => '${ApiConfig.getBaseUrl()}/chat/mobile';
```

`main.dart` defines the route table and initializes push notifications. Screens are organized by
role (`parent/`, `teacher/`, `driver/`, `student1-3/`, `student4-6/`, `student_shared/`), with the
two student bands receiving distinct gamified themes. Push notifications use `firebase_messaging`;
Firebase is used **only** for FCM (there is no Firestore dependency).

## 5.8 Key Modules (Deep Dives)

- **Admissions.** An `Application` aggregate with eight child tables captures child, parents,
  guardian, residence, documents, interview, fees, and a status log. A status workflow
  (`NEW → UNDER_REVIEW → … → FINAL_ACCEPTED`) is recorded in `ApplicationStatusLog`, and a `convert`
  endpoint promotes an accepted application into a `Student` with the linked `convertedStudentId`.

- **Finance.** Invoices maintain `totalAmount`, `discount`, `paid`, and `remaining`, with status
  transitions driven by payments. An hourly job (`cron/checkOverdueInvoices.ts`) marks past-due
  unpaid/partial invoices as `OVERDUE`; it can run in-process or be triggered externally via the
  `X-Cron-Secret`-protected `/internal/cron/check-overdue` endpoint (e.g., from AWS EventBridge).

- **Transport & live tracking.** Drivers post coordinates to `/transport/mobile/location`; the
  backend updates the bus's last position and broadcasts a `bus:location` event to the school room,
  which parent apps consume in real time:

  ```ts
  // dashboard/backend/src/modules/transport/transport.routes.ts (excerpt)
  await prisma.bus.updateMany({
    where: { schoolId, driver: { id: driverId } },
    data: { lastLat: lat, lastLng: lng, locationUpdatedAt: new Date() },
  });
  getIO().to(`school:${schoolId}`).emit("bus:location", { driverId, lat, lng, updatedAt: new Date() });
  ```

- **AI assistant.** The `/ai/chat` controller invokes Amazon Bedrock's `Converse` API with four
  database tools (`query/create/update/delete_school_data`) and a system prompt that **locks the
  assistant to the caller's `schoolId`**. The controller loops up to five tool iterations, executing
  each tool against Prisma scoped to the school, then returns the model's Arabic answer and persists
  the exchange.

## 5.9 Security Implementation

The implemented controls include: HTTPS/TLS termination at nginx; Helmet security headers; a CORS
allow-list; a 1 MB request-body cap; Cognito token verification with a verified-email requirement and
no role elevation from tokens; backend-signed mobile JWTs with server-side, revocable device
sessions; multi-tenant isolation via `tenantScope`; role checks via `roleGuard`; a secret-guarded
internal cron endpoint; audit logging (`ActivityLog`); and soft-delete/restore via `Archive`.

For an honest account, the following weaknesses are present in the current build and are revisited in
Chapters 6 and 7: mobile passwords are hashed with **unsalted SHA-256**; a temporary **plaintext**
password copy (`plainTextPw`) is retained for admin sharing; and the per-school AI password and Zoom
client secret are stored in plaintext. The AI assistant is intentionally granted broad CRUD over the
tenant's data, which is powerful but widens the impact of a prompt-injection attack. These are
documented limitations with concrete remediations proposed in §7.4.

## 5.10 Representative Annotated Code Snippets

Beyond the excerpts above, the following are referenced by file for the committee's inspection:

1. `core/http/middlewares/auth.ts` — dual custom-JWT/Cognito verification and profile-ID attachment.
2. `core/http/middlewares/mobileAuth.ts` — JWT verification with device-session revocation.
3. `core/http/middlewares/tenantScope.ts` — Super-Admin bypass and per-school binding.
4. `modules/auth/auth.controller.ts` — `mobileLogin` (hashing, JWT issuance, device session,
   geolocated session labeling).
5. `config/websocket.ts` — per-school room isolation and optional Redis adapter.
6. `modules/transport/transport.routes.ts` — GPS update and real-time broadcast.
7. `modules/ai/ai.controller.ts` — Bedrock Converse loop with school-scoped tool execution.
8. `modules/storage/storage.controller.ts` — S3 presigned-URL generation.

## 5.11 Challenges & Solutions

| Challenge | Solution adopted |
|-----------|------------------|
| **Two user populations with different identity needs** (staff vs. parents/students/drivers) | Two authentication systems reconciled behind a uniform `req.user`: Cognito for staff, backend JWT + device sessions for mobile. |
| **Strict multi-tenant isolation** across ~45 tables | A `schoolId` column on nearly every model plus a `tenantScope` middleware that derives and enforces the school on every request. |
| **Real-time bus tracking** that must scale | Socket.IO rooms per school, with an optional Redis adapter activated purely by configuration to allow horizontal scaling. |
| **Evolving the schema safely** in production | Migration from ad-hoc `db push` to versioned Prisma migrations applied deterministically by the deploy pipeline. |
| **Platform migration** (a prior Supabase setup → AWS) | Consolidation onto Prisma/PostgreSQL with AWS Cognito/S3/Bedrock, removing the Supabase SDK and residual configuration. |
| **Keeping three apps continuously buildable** | A CI gate that type-checks and builds the backend and frontend on every push before deployment. |

<div style="page-break-after: always;"></div>
