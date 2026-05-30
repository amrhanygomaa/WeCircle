<!-- ============================================================
     BACK MATTER — REFERENCES & APPENDICES
     ============================================================ -->

# References

> Formatted in IEEE style. Online sources are official product/standard documentation; access dates
> should be set to the date of final submission (`[Accessed: 2026]`).

[1] OpenJS Foundation, *Node.js Documentation*. [Online]. Available: https://nodejs.org/en/docs

[2] OpenJS Foundation, *Express — Fast, unopinionated, minimalist web framework for Node.js*.
[Online]. Available: https://expressjs.com

[3] Microsoft, *TypeScript Documentation*. [Online]. Available: https://www.typescriptlang.org/docs

[4] Prisma Data, Inc., *Prisma ORM Documentation*. [Online]. Available: https://www.prisma.io/docs

[5] The PostgreSQL Global Development Group, *PostgreSQL 16 Documentation*. [Online]. Available:
https://www.postgresql.org/docs

[6] Vercel, Inc., *Next.js Documentation (App Router)*. [Online]. Available: https://nextjs.org/docs

[7] Meta Open Source, *React Documentation*. [Online]. Available: https://react.dev

[8] Google LLC, *Flutter Documentation*. [Online]. Available: https://docs.flutter.dev

[9] Google LLC, *Dart Programming Language*. [Online]. Available: https://dart.dev/guides

[10] Amazon Web Services, *Amazon Cognito Developer Guide*. [Online]. Available:
https://docs.aws.amazon.com/cognito

[11] Amazon Web Services, *Amazon Simple Storage Service (S3) User Guide*. [Online]. Available:
https://docs.aws.amazon.com/s3

[12] Amazon Web Services, *Amazon Bedrock User Guide — Converse API and Tool Use*. [Online].
Available: https://docs.aws.amazon.com/bedrock

[13] Google LLC, *Firebase Cloud Messaging Documentation*. [Online]. Available:
https://firebase.google.com/docs/cloud-messaging

[14] Socket.IO, *Socket.IO Documentation*. [Online]. Available: https://socket.io/docs/v4

[15] M. Jones, J. Bradley, and N. Sakimura, *JSON Web Token (JWT)*, RFC 7519, IETF, May 2015.
[Online]. Available: https://datatracker.ietf.org/doc/html/rfc7519

[16] R. T. Fielding, *Architectural Styles and the Design of Network-based Software Architectures*,
Ph.D. dissertation, University of California, Irvine, 2000.

[17] C. Colyer et al., *Zod — TypeScript-first schema validation*. [Online]. Available:
https://zod.dev

[18] Tailwind Labs, *Tailwind CSS Documentation*. [Online]. Available: https://tailwindcss.com/docs

[19] TanStack, *TanStack Query Documentation*. [Online]. Available: https://tanstack.com/query

[20] OWASP Foundation, *OWASP Top Ten Web Application Security Risks*. [Online]. Available:
https://owasp.org/www-project-top-ten

[21] OWASP Foundation, *OWASP Password Storage Cheat Sheet*. [Online]. Available:
https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html

[22] Classera, *Classera Learning & School Management Platform*. [Online]. Available:
https://www.classera.com

[23] Fedena, *Fedena School & College ERP*. [Online]. Available: https://fedena.com

[24] ClassDojo, Inc., *ClassDojo — Classroom Communication*. [Online]. Available:
https://www.classdojo.com

[25] GitHub, Inc., *GitHub Actions Documentation*. [Online]. Available: https://docs.github.com/actions

`[Placeholder: add any additional sources cited in the final text, e.g., specific Egyptian
school-management products or academic papers introduced during revision.]`

<div style="page-break-after: always;"></div>

# Appendices

## Appendix A — Screenshots

> Insert captured screenshots in place of each placeholder before submission. Suggested figures:

- **A.1** Web dashboard — Login (AWS Cognito). `[Figure: screenshot placeholder]`
- **A.2** Web dashboard — Analytics home (KPI cards & charts). `[Figure: screenshot placeholder]`
- **A.3** Web dashboard — Students list & student detail. `[Figure: screenshot placeholder]`
- **A.4** Web dashboard — Admissions wizard. `[Figure: screenshot placeholder]`
- **A.5** Web dashboard — Payments & invoices. `[Figure: screenshot placeholder]`
- **A.6** Web dashboard — Transport (buses/drivers). `[Figure: screenshot placeholder]`
- **A.7** Web dashboard — AI Chat Assistant. `[Figure: screenshot placeholder]`
- **A.8** Mobile (Parent) — Children dashboard & bus tracker. `[Figure: screenshot placeholder]`
- **A.9** Mobile (Teacher) — Attendance & grade entry. `[Figure: screenshot placeholder]`
- **A.10** Mobile (Student) — Gamified dashboard & a learning game. `[Figure: screenshot placeholder]`
- **A.11** Mobile (Driver) — Live location sharing. `[Figure: screenshot placeholder]`

## Appendix B — Full API Reference

All endpoints are served under the base URL `https://api.wecircle.helpers-tech.com/api`
(locally `http://localhost:5001/api`). Authentication legend: **Cognito** = `requireAuth`;
**+Tenant** = also tenant-scoped; **Role(...)** = role-restricted; **Mobile** = `requireMobileAuth`;
**Public** = none; **Secret** = shared-header secret.

### Table B.1 — Full API Endpoint Reference

**System & Auth**

| Method | Path | Auth |
|--------|------|------|
| GET | `/health` | Public |
| GET | `/` | Public |
| POST | `/internal/cron/check-overdue` | Secret |
| POST | `/auth/login` (disabled) | Public |
| POST | `/auth/register` | Public |
| POST | `/auth/cognito-sync` | Public (token) |
| POST | `/auth/webhook` | Public |
| GET | `/auth/check-school-id/:code` | Public |
| GET | `/auth/check-school-name/:name` | Public |
| GET | `/auth/check-school-email/:email` | Public |
| GET | `/auth/me` | Cognito |
| POST | `/auth/mobile/login` | Public |
| POST | `/auth/mobile/social-login` | Public |
| POST | `/auth/mobile/change-password` | Mobile |

**Students / Teachers / Parents / Users**

| Method | Path | Auth |
|--------|------|------|
| GET / POST | `/students` | +Tenant / +Role(SCHOOL_ADMIN,SUPER_ADMIN) |
| GET / PUT / DELETE | `/students/:id` | +Tenant (+Role on write) |
| GET / POST | `/students/mobile/game-state` | Mobile |
| POST | `/students/mobile/ai-chat` | Mobile |
| GET | `/teachers` | +Tenant |
| POST / PUT / DELETE | `/teachers` , `/teachers/:id` | +Role(SUPER_ADMIN) |
| GET / POST / DELETE | `/teachers/:id/assignments[/:assignmentId]` | +Tenant (+Role on write) |
| GET/PUT/POST | `/teachers/mobile/{dashboard,reports,classes,profile,change-password,devices,devices/logout,devices/logout-all,social/status,social/link,social/unlink}` | Mobile |
| GET | `/parents` | +Tenant |
| PATCH | `/parents/:id` | +Tenant |
| POST | `/parents/students/:studentId/attach` | +Tenant |
| GET/PUT/POST | `/parents/mobile/{dashboard,profile,change-password,devices,devices/logout,devices/logout-all,social/status,social/link,social/unlink}` | Mobile |
| GET | `/users` | +Tenant |
| PATCH | `/users/:id/role` | +Tenant |

**Academic Structure & School**

| Method | Path | Auth |
|--------|------|------|
| GET / POST / DELETE | `/classes` , `/classes/:id` | +Tenant (+Role(SUPER_ADMIN) on write) |
| GET / POST / POST / DELETE | `/subjects` , `/subjects/bulk` , `/subjects/:id` | +Tenant |
| GET/POST/PUT/DELETE | `/academic/years[/:id]` | +Tenant |
| GET/POST/PUT/DELETE | `/academic/grades[/:id]` , `/academic/grades/seed` | +Tenant |
| GET / PATCH | `/school/me` | +Tenant |
| GET / PATCH | `/settings` | +Tenant |
| GET | `/dashboard/overview` | +Tenant |
| GET | `/reports/overview` | +Tenant |
| GET | `/storage/presign` | Cognito |

**Admissions**

| Method | Path | Auth |
|--------|------|------|
| GET | `/admissions` , `/admissions/stats` , `/admissions/:id` | Cognito |
| POST | `/admissions` , `/admissions/:id/convert` , `/admissions/:id/contact` | Cognito |
| PUT / PATCH / DELETE | `/admissions/:id` , `/admissions/:id/status` | Cognito |

**Attendance / Homework / Exams / Timetable**

| Method | Path | Auth |
|--------|------|------|
| GET / POST / POST | `/attendance` , `/attendance/bulk` | +Tenant |
| GET / POST | `/attendance/mobile` , `/attendance/mobile/bulk` | Mobile |
| GET/POST/PATCH/DELETE | `/homework[/:id]` , `/homework/:id/submit` , `/homework/:id/submissions` | +Tenant |
| GET | `/homework/mobile/student/:studentId` | Mobile |
| GET/POST/PATCH/DELETE | `/exams[/:id]` , `/exams/:id/results` , `/exams/student/:studentId` | +Tenant |
| GET/POST/GET | `/exams/mobile/{teacher-classes,:id/results,student/:studentId}` | Mobile |
| GET/POST/DELETE | `/timetable` , `/timetable/auto-generate` , `/timetable/:id` | +Tenant |
| GET | `/timetable/mobile/student` , `/timetable/mobile/my-schedule` | Mobile |

**Finance**

| Method | Path | Auth |
|--------|------|------|
| GET / POST | `/payments` | +Tenant (+Role(SUPER_ADMIN) on create) |
| GET/POST/POST | `/invoices` , `/invoices/bulk` | Cognito |
| PATCH | `/invoices/:id/{pay,discount,toggle-access,deadline}` | Cognito |
| DELETE | `/invoices/:id` | Cognito |
| GET | `/invoices/mobile/student/:studentId` | Mobile |
| GET/POST/DELETE | `/fee-structures[/:id]` | +Tenant |

**Transport**

| Method | Path | Auth |
|--------|------|------|
| GET/POST/DELETE | `/transport/buses` , `/transport/buses/:id` , `/transport/buses/:id/trip` , `/transport/buses/:id/students` | +Tenant |
| GET/POST/DELETE | `/transport/routes` , `/transport/routes/:id` | +Tenant |
| GET/POST/PUT/DELETE | `/transport/drivers[/:id]` , `/transport/supervisors[/:id]` | +Tenant |
| GET | `/transport/students` | +Tenant |
| POST | `/transport/mobile/location` | Mobile |
| GET | `/transport/mobile/bus-status` | Mobile |
| GET/PUT/POST | `/mobile/transport/driver/{dashboard,profile,location,attendance}` | Mobile |
| GET/POST/PUT | `/mobile/transport/supervisor/{dashboard,attendance,profile}` | Mobile |

**Communication, Reports & Misc**

| Method | Path | Auth |
|--------|------|------|
| GET/POST/DELETE | `/announcements[/:id]` | +Tenant (+Role(SUPER_ADMIN,TEACHER) create; SUPER_ADMIN delete) |
| GET/POST/POST/DELETE | `/notifications` , `/notifications/:id/read` , `/notifications/:id` | +Tenant |
| POST/DELETE | `/notifications/mobile/device-token` | Mobile |
| GET/POST | `/chat` , `/chat/contacts` , `/chat/:id/messages` | +Tenant |
| GET/POST | `/chat/mobile/*` (conversations, contacts, messages) , `/conversations` (alias) | Mobile / +Tenant |
| POST/GET | `/behavior` , `/behavior/{parent,teacher}` , `/behavior/mobile/*` | Cognito / Mobile |
| POST/GET | `/daily-reports` , `/daily-reports/mobile` | Cognito / Mobile |
| POST/GET/POST/DELETE | `/student-tasks` , `/student-tasks/:id/complete` , `/student-tasks/:id` | Cognito |
| GET/POST/PATCH | `/leaves` , `/leaves/:id/status` | Cognito |
| GET/POST/DELETE | `/schedules[/:id]` | Cognito |
| GET/POST/DELETE | `/results[/:id]` | +Tenant |
| GET/POST/PATCH/DELETE | `/credentials` , `/credentials/{generate,bulk-generate}` , `/credentials/:id/{toggle,reset-password}` , `/credentials/:id` | Cognito |
| GET/POST | `/archives` , `/archives/:id/restore` | Cognito |
| POST/GET/DELETE | `/zoom/meetings[/:meetingId]` | Cognito |

**AI Assistant**

| Method | Path | Auth |
|--------|------|------|
| POST | `/ai/chat` | Cognito |
| GET | `/ai/history` , `/ai/sessions` | Cognito |
| DELETE | `/ai/sessions/:sessionId` | Cognito |
| GET/POST/POST | `/ai/password-status` , `/ai/set-password` , `/ai/verify-password` | Cognito |

## Appendix C — User Manual (Quick Start by Role)

**School Admin (Web).** Sign in via Cognito → from the dashboard, create the academic structure
(years, grades, classes, subjects) → add students (or convert admissions) and attach parents →
generate mobile credentials and share them → manage attendance, finance, transport, and
announcements → use the AI assistant for quick queries.

**Teacher (Web/Mobile).** Sign in → select a class → mark attendance, set homework, enter exam
results, write behavior/daily reports, assign tasks, and message parents.

**Parent (Mobile).** Sign in with the credential provided by the school → view each child's
attendance, homework, results, fees, schedule, and behavior → track the school bus on the map →
chat with staff → manage profile and active devices.

**Student (Mobile).** Sign in → access the gamified dashboard for your grade band → play learning
games, earn points and levels, view homework and results, and use the study chatbot.

**Driver / Supervisor (Mobile).** Sign in → view route/roster → (driver) share live location and
record bus attendance; (supervisor) record per-student boarding.

## Appendix D — Glossary

| Term | Definition |
|------|------------|
| **Tenant** | An individual school whose data is isolated from all others within the shared system. |
| **Multi-tenancy** | One software instance serving many isolated tenants. |
| **RBAC** | Role-Based Access Control: permissions granted to roles, not individuals. |
| **AppCredential** | A mobile login record (login ID + password) linked to a person and a school. |
| **Device Session** | A server-side record of an active mobile login, enabling remote logout. |
| **Presigned URL** | A temporary, signed URL allowing a client to upload directly to S3. |
| **Converse API / Tool Use** | A Bedrock interface where the AI model can call backend-provided tools (here, database operations). |
| **Migration** | A versioned, applied change to the database schema. |
| **Overdue sweep** | The scheduled job that marks past-due unpaid invoices as `OVERDUE`. |
| **Room (Socket.IO)** | A named channel (e.g., `school:<id>`) used to scope real-time broadcasts. |

## Appendix E — Database Data Dictionary (Full Entity List)

The schema declares the following models (grouped by domain). Field-level detail for the key entities
appears in Chapter 4 (Table 4.1); the remaining entities follow the same conventions (UUID primary
keys, `schoolId` foreign keys, `Decimal(12,2)` money, and `createdAt`/`updatedAt` timestamps).

- **Core/Tenancy:** `School`, `User`, `AppCredential`, `DeviceSession`, `DeviceToken`,
  `SchoolSettings`, `ActivityLog`, `Archive`, `CalendarEvent`, `Expense`.
- **Academic structure:** `AcademicYear`, `Grade`, `SchoolClass`, `Subject`, `TeacherSubject`.
- **Admissions:** `Application`, `ApplicationFather`, `ApplicationMother`, `ApplicationGuardian`,
  `ApplicationResidence`, `ApplicationDocument`, `ApplicationInterview`, `ApplicationFee`,
  `ApplicationStatusLog`, `ApplicationContact`.
- **People:** `Student`, `Teacher`, `Parent`, `Driver`, `BusSupervisor`.
- **Attendance & academics:** `Attendance`, `Homework`, `HomeworkSubmission`, `Exam`, `ExamResult`,
  `Timetable`.
- **Finance:** `FeeStructure`, `Invoice`, `Payment`.
- **Transport:** `Bus`, `BusRoute`, `StudentBus`, `BusAttendance`.
- **Communication:** `Announcement`, `Notification`, `Conversation`, `Message`.
- **Engagement & reports:** `BehaviorReport`, `DailyReport`, `StudentTask`, `StudentTaskCompletion`,
  `StudentGameProgress`, `LeaveRequest`, `SchoolResult`, `AiChatMessage`.
- **Enumerations (24):** `Role`, `Gender`, `ApplicationStatus`, `DocumentStatus`, `StudentStatus`,
  `TeacherStatus`, `ContractType`, `PaymentMethod`, `FeeType`, `PaymentStatus`, `PaymentPlan`,
  `ExamType`, `AttendanceStatus`, `AttendanceType`, `NotificationChannel`, `NotificationType`,
  `AttendanceMode`, `BusStatus`, `HomeworkStatus`, `InvoiceStatus`, `LeaveStatus`,
  `ResidenceProofType`, `ApplicationType`, `MaritalStatus`, `BusAttendanceStatus`, `BehaviorType`.

<div style="page-break-after: always;"></div>

---

*End of document.*
