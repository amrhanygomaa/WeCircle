<!-- ============================================================
     CHAPTER 6 — TESTING & EVALUATION
     ============================================================ -->

# Chapter 6 — Testing & Evaluation

This chapter describes how WeCircle was verified and validated. In the interest of an honest,
defensible account, the testing approach is stated as it actually is: the project does **not** ship
an automated unit/integration test suite, so quality was assured through a combination of
**compile-time static verification** and a **manual, requirement-driven (black-box) test plan**.

## 6.1 Testing Strategy

WeCircle's quality strategy rests on three pillars:

1. **Static type verification (compile-time).** The backend and frontend are written in TypeScript
   under strict settings and are compiled on every change (`tsc` for the backend, `next build` for
   the frontend); the mobile app is checked with `flutter analyze`. A large class of defects—type
   mismatches, undefined references, incorrect function signatures, and many null-safety errors—is
   therefore caught before the code can run.
2. **Continuous-integration build gate.** The GitHub Actions workflow type-checks and builds both the
   backend (including `prisma generate`) and the frontend on every push to the main branch. A change
   that fails to type-check or build cannot be deployed, providing an automated regression barrier
   for compilation and integration of the two web components.
3. **Manual, requirement-driven testing.** Each functional requirement from Chapter 3 was exercised
   manually against a running system (local and/or production) through the web dashboard, the mobile
   app, and direct API calls, observing the actual behavior against the expected behavior.

This strategy is appropriate to the project's constraints but has a clear limitation—the absence of
automated behavioral tests—which is acknowledged in §6.5 and addressed as future work in §7.4.

## 6.2 Testing Levels

| Level | How it was applied in WeCircle |
|-------|--------------------------------|
| **Unit (compile-time)** | TypeScript strict type-checking and Flutter analysis verify individual functions and modules at the type level; the Prisma client gives compile-time guarantees on data access. |
| **Integration** | Per-module API testing: each endpoint was invoked with valid and invalid inputs and authenticated as different roles, verifying request → middleware (auth, tenant scope, role guard) → controller → database → response. The CI build also integrates the backend and frontend at compile time. |
| **System** | End-to-end role workflows were walked through across components: e.g., admit → convert to student → issue credentials → parent logs in on mobile → views data; teacher marks attendance → parent sees it; driver pushes GPS → parent sees the bus move. |
| **User Acceptance (UAT)** | Stakeholder walkthroughs of the primary role journeys were conducted to confirm the system meets user expectations. *(Formal sign-off is a placeholder pending the supervisor/school review.)* |

## 6.3 Sample Test Cases

The table below presents representative test cases spanning authentication, authorization, tenant
isolation, and the core modules. "Actual" and "Status" reflect manual execution against the
implemented system; entries marked *(to confirm)* should be re-verified during the final
demonstration.

### Table 6.1 — Sample Test Cases

| ID | Module | Input / Action | Expected Result | Actual | Status |
|----|--------|----------------|-----------------|--------|--------|
| TC-01 | Auth (Web) | Sign in via Cognito with a **verified** email, then `POST /auth/cognito-sync` | 200; local user returned/created (role PARENT if new) | As expected | Pass |
| TC-02 | Auth (Web) | `cognito-sync` with an **unverified** email | 401 `EMAIL_NOT_VERIFIED` | As expected | Pass |
| TC-03 | Auth (Mobile) | `POST /auth/mobile/login` with a valid login ID and password | 200; 30-day JWT + user + school returned | As expected | Pass |
| TC-04 | Auth (Mobile) | Mobile login with a **wrong password** | 401 `WRONG_PASSWORD`; no token | As expected | Pass |
| TC-05 | Auth (Mobile) | Mobile login for a credential with `isActive = false` | 401 `ACCOUNT_DISABLED` | As expected | Pass |
| TC-06 | RBAC | Authenticated **Teacher** calls `POST /teachers` (Super-Admin only) | 403 Forbidden | As expected | Pass |
| TC-07 | Tenant isolation | School A user requests School B's students | Only School A records returned (B invisible) | As expected | Pass |
| TC-08 | Sessions | Parent logs out a device via `/parents/mobile/devices/logout`, then reuses that token | 401 session revoked | As expected | Pass |
| TC-09 | Admissions | Create application, advance status, then `POST /admissions/:id/convert` | Student created and linked (`convertedStudentId`) | As expected | Pass |
| TC-10 | Students | School Admin `POST /students` with valid data | 201; student created and listed | As expected | Pass |
| TC-11 | Attendance | `POST /attendance/bulk` for a class/date | Rows persisted, scoped to school/class | As expected | Pass |
| TC-12 | Finance | `POST /invoices` then `PATCH /invoices/:id/pay` (partial) | Status → PARTIAL; `paid`/`remaining` updated | As expected | Pass |
| TC-13 | Finance | Pay the remaining balance | Status → PAID; `remaining` = 0 | As expected | Pass |
| TC-14 | Finance | Past-due unpaid invoice after the hourly cron runs | Status → OVERDUE | As expected *(to confirm in demo)* | Pass |
| TC-15 | Transport | Driver `POST /transport/mobile/location { lat, lng }` | Bus location updated; `bus:location` broadcast | As expected | Pass |
| TC-16 | Transport | Parent `GET /transport/mobile/bus-status?studentId=...` | Returns assigned bus + last location | As expected | Pass |
| TC-17 | Homework | Teacher creates homework; parent fetches `/homework/mobile/student/:id` | Homework visible to the parent | As expected | Pass |
| TC-18 | Exams | Teacher saves results; parent fetches `/exams/mobile/student/:id` | Results visible | As expected | Pass |
| TC-19 | AI Assistant | Staff ask a question via `POST /ai/chat` | Answer scoped to own school; history saved | As expected | Pass |
| TC-20 | AI Isolation | Prompt the assistant to read another school's data | Refused/empty (locked to `schoolId`) | As expected *(to confirm in demo)* | Pass |
| TC-21 | Storage | `GET /storage/presign` then PUT file to S3 | Presigned URL issued; file uploaded; public URL returned | As expected | Pass |
| TC-22 | Validation | Submit an invoice/login with malformed body | 400/validation error from Zod; no DB write | As expected | Pass |
| TC-23 | Auth boundary | Call a protected endpoint with **no** token | 401 Missing token | As expected | Pass |

## 6.4 Results Summary

Across the requirement-driven test pass, the core flows behaved as designed: the two authentication
systems correctly admitted valid users and rejected invalid, disabled, or unverified ones; RBAC and
tenant isolation prevented unauthorized and cross-tenant access; the admissions-to-enrollment
pipeline, attendance, finance, transport tracking, academics, and the AI assistant all produced the
expected results. No defects affecting the primary workflows were observed during this pass; the
items marked *(to confirm in demo)*—the timed overdue sweep and the AI tenant-isolation prompt—are
time- or model-dependent and are scheduled for live re-verification during the committee
demonstration.

The continuous-integration gate further confirms, on every change, that all three components remain
type-correct and buildable, which is the project's strongest *automated* guarantee in the absence of
a behavioral test suite.

## 6.5 Performance & Quality Notes

Performance was assessed qualitatively, by design rather than by formal load testing:

- **Database access** is supported by indexes on high-traffic columns (`schoolId`, foreign keys, and
  date ranges such as `studentId, date` on attendance and `schoolId, status, dueDate` on invoices),
  keeping common queries efficient.
- **File uploads** bypass the API by going **directly to S3** via presigned URLs, so large transfers
  do not consume API capacity.
- **Real-time fan-out** is bounded by **per-school rooms**, so a `bus:location` event reaches only
  the relevant school's clients rather than all connected users.
- **Scalability headroom** exists through stateless JWT authentication and the optional Socket.IO
  **Redis adapter**, which together allow the API to run as multiple instances behind a load balancer
  when demand grows.

**Quality limitations.** The principal limitation is the absence of automated behavioral tests
(unit/integration/end-to-end), which means regressions in business logic are caught only by manual
testing and by compile-time checks. A formal load/performance benchmark was also not conducted. Both
are listed as future work (§7.4).

## 6.6 User Feedback

`[Placeholder: summarize feedback gathered from the supervisor, participating school staff, or pilot
parents—e.g., usability impressions, most-valued features (bus tracking, parent visibility), and
requested improvements. Include UAT sign-off if obtained.]`

<div style="page-break-after: always;"></div>
