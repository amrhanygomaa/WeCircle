# WeCircle — Documentation Outline (Phase 2)

> Complete table of contents for the WeCircle graduation-project report, mapped to the required
> chapter structure. Each entry carries a one-line summary derived from the Phase 1 analysis
> (`00-analysis.md`). **Language:** English primary + Arabic abstract (bilingual). **Citations:**
> IEEE. **Target length:** 70–100 pages.
>
> **➡️ Phase-2 gate:** please confirm or amend this outline before I begin writing chapters (Phase 3).

---

## 0. File map (sorts in reading order under `docs/`)

| File | Contents |
|------|----------|
| `00-analysis.md` | Phase 1 system analysis (input, not part of the final report body) |
| `outline.md` | This outline (Phase 2) |
| `01-front-matter.md` | Title page, abstract (EN+AR), acknowledgments, TOC, lists of figures/tables/abbreviations |
| `02-chapter1-introduction.md` | Chapter 1 — Introduction |
| `03-chapter2-background.md` | Chapter 2 — Background & Literature Review |
| `04-chapter3-analysis.md` | Chapter 3 — System Analysis |
| `05-chapter4-design.md` | Chapter 4 — System Design |
| `06-chapter5-implementation.md` | Chapter 5 — Implementation |
| `07-chapter6-testing.md` | Chapter 6 — Testing & Evaluation |
| `08-chapter7-conclusion.md` | Chapter 7 — Conclusion & Future Work |
| `09-back-matter.md` | References (IEEE) + Appendices |
| `diagrams/` | Exported diagram images (`figure-X-Y-*.png/svg`) if `mmdc` is available |
| `WeCircle-Documentation.md` | Single assembled document (built last) |
| `README.md` | How to regenerate/convert + open-questions & placeholder list |

---

## Front Matter — `01-front-matter.md`

- **Title page** — Project title "WeCircle — School Management System", IAEMS / Mass Communication,
  degree, team (6 members + ID placeholders), supervisor Dr. Nabil Al-Ghamry, Spring 2026.
- **Abstract (English, ≤300 words)** — Problem, solution (3-component multi-tenant platform), methods
  (Express/Prisma/Next.js/Flutter, Cognito, AWS), and headline results.
- **الملخص (Arabic abstract)** — Faithful Arabic translation of the English abstract.
- **Acknowledgments** — Supervisor, academy, families (placeholder-friendly).
- **Table of Contents** — Auto-generated on assembly.
- **List of Figures** — All numbered Mermaid figures (see §Figures below).
- **List of Tables** — All numbered tables (see §Tables below).
- **List of Abbreviations** — API, JWT, RBAC, ERD, DFD, FCM, S3, SaaS, ORM, UUID, CRUD, SDK, OAuth, etc.

---

## Chapter 1 — Introduction — `02-chapter1-introduction.md`

- **1.1 Overview** — WeCircle as a multi-tenant platform connecting schools, staff, parents, students,
  and transport via one backend + web dashboard + mobile app.
- **1.2 Problem Statement** — Fragmented, paper/WhatsApp-based school operations (admissions,
  attendance, fees, transport, parent communication) lacking a unified, role-aware system.
- **1.3 Motivation** — Real demand for an Egypt-context (Arabic-first, EGP, Sun–Thu week) integrated
  school system spanning administration and parent engagement.
- **1.4 Objectives** — Numbered goals: unified RBAC platform, the 10 core feature domains, realtime
  bus tracking, parent mobile access, and an AI administrative assistant.
- **1.5 Scope & Limitations** — In scope: the modules implemented in code. Out of scope/limitations:
  no payment-gateway settlement, notifications channels modelled but not wired, single-region AWS,
  no automated tests.
- **1.6 Significance** — Operational efficiency for schools; transparency for parents; a defensible
  full-stack engineering artifact.
- **1.7 Development Methodology** — Iterative/Agile-style incremental delivery (phased migration,
  small reviewable commits, CI typecheck gate) — mapped to the real git/CI workflow.
- **1.8 Report Organization** — One-paragraph tour of Chapters 2–7.

---

## Chapter 2 — Background & Literature Review — `03-chapter2-background.md`

- **2.1 Domain Background** — School Management Information Systems (SIS/SMS): admissions→enrollment→
  academics→finance→communication lifecycle.
- **2.2 Key Concepts & Technologies** — REST APIs, multi-tenant SaaS, RBAC, JWT vs. Cognito identity,
  ORMs (Prisma), WebSockets/Socket.IO, cross-platform mobile (Flutter), cloud services (AWS Cognito/
  S3/Bedrock), push (FCM).
- **2.3 Survey of Existing Systems** — 4–5 comparable products (e.g., PowerSchool, Edmodo/Google
  Classroom, Skolaro/Fedena-class systems, ClassDojo, local Egyptian school systems) with a
  **comparison table** (Table 2.1) across features: admissions, fees, attendance, bus GPS, parent app,
  gamification, Arabic/multi-tenant, AI assistant.
- **2.4 Gap Analysis** — Where existing tools fall short for the target context, justifying WeCircle
  (Arabic-first, integrated transport GPS + parent app + admissions + AI admin assistant in one).

---

## Chapter 3 — System Analysis — `04-chapter3-analysis.md`

- **3.1 Stakeholders & Users** — The 10 roles (SUPER_ADMIN … PARENT) and their goals (from §6 of
  analysis).
- **3.2 Functional Requirements** — Numbered (FR-x) and grouped by module: Auth & RBAC, Schools/
  Settings, Admissions, Students/Classes/Academic, Teachers/Assignments, Attendance, Homework,
  Exams/Results, Timetable, Finance (fees/invoices/payments), Transport (+bus GPS), Communication
  (announcements/notifications/chat), Behavior/Daily reports/Tasks, Gamification, AI Assistant.
- **3.3 Non-Functional Requirements** — Performance, security, usability (Arabic RTL, responsive),
  scalability (Socket.IO Redis adapter, stateless JWT), reliability, maintainability (modular layout).
- **3.4 Feasibility Study** — Technical (proven stack, builds clean), operational (role-fit workflows),
  economic (managed AWS + single-EC2 cost profile).
- **3.5 Use-Case Diagrams** — One **use-case diagram per primary role** (Mermaid) + textual use-case
  descriptions for key scenarios: Admin onboards student & issues credentials; Teacher marks
  attendance; Accountant issues/collects invoice; Parent tracks bus; Student plays learning game.

---

## Chapter 4 — System Design — `05-chapter4-design.md`

- **4.1 System Architecture** — High-level **architecture diagram** (Mermaid): clients ↔ Express API ↔
  PostgreSQL/Prisma, with Cognito, S3, Bedrock, FCM, Socket.IO; deployment topology (EC2/pm2/nginx).
- **4.2 Technology-Choice Justification** — Why Express 5 + Prisma, Next.js 16, Flutter, Cognito,
  Bedrock, Socket.IO (mapped to NFRs).
- **4.3 Database Design** — Full **ERD** (Mermaid) of the ~45 models + a **data dictionary** (key
  tables: School, User, AppCredential, Student, Invoice, Payment, Bus, etc.) with field/type/constraint.
- **4.4 Class Diagram** — Backend module/domain class diagram (controllers/services/middleware +
  Prisma models) (Mermaid).
- **4.5 Sequence Diagrams** (Mermaid) — (a) Web login via Cognito + `cognito-sync`; (b) Mobile login
  (AppCredential JWT + device session); (c) Mark attendance; (d) Issue & pay invoice; (e) Bus GPS
  update → parent realtime; (f) AI assistant tool-use query.
- **4.6 Activity Diagrams** (Mermaid) — Admission → acceptance → convert-to-student; Invoice
  lifecycle (UNPAID→PARTIAL→PAID/OVERDUE).
- **4.7 Data-Flow Diagrams** (Mermaid) — Context (Level 0) + Level-1 DFD across major processes.
- **4.8 UI/UX Design** — Design principles (Arabic RTL, responsive, role-tailored, gamified student
  UIs), and screen/wireframe descriptions for dashboard + each mobile role (screenshot placeholders).

---

## Chapter 5 — Implementation — `06-chapter5-implementation.md`

- **5.1 Development Environment & Tools** — Node 24, TS, Prisma, Next.js, Flutter, Git/GitHub Actions,
  AWS, VS Code.
- **5.2 Project Structure** — The verified folder layouts (from §3 of analysis).
- **5.3 Backend Implementation** — API design (`/api`, response envelope), modular routing, middleware
  chain, error handling (`AppError`/`asyncHandler`), Zod validation, cron, Socket.IO rooms.
- **5.4 Authentication & RBAC** — Dual auth (Cognito + AppCredential JWT), `tenantScope`, `roleGuard`,
  device sessions; annotated snippets from `auth.ts`/`mobileAuth.ts`/`auth.controller.ts`.
- **5.5 Database Layer** — Prisma schema, migrations workflow, multi-tenant `schoolId` pattern, decimal
  money handling.
- **5.6 Web Dashboard Implementation** — Next.js App Router pages, TanStack Query, axios + Cognito
  interceptor, S3 presigned uploads, realtime client, i18n.
- **5.7 Mobile App Implementation** — Flutter structure, REST `api_service`/`chat_service`, role
  dashboards, gamified student modules, FCM push, local token storage.
- **5.8 Key Modules (deep dives)** — Admissions pipeline, Finance (invoices/payments + overdue cron),
  Transport GPS, AI assistant (Bedrock Converse + tool use).
- **5.9 Security Implementation** — Helmet/CORS/body limits, Cognito email-verification gate, JWT,
  tenant isolation, cron secret; with an honest note on hashing/plaintext weaknesses.
- **5.10 Representative Annotated Code Snippets** — 6–8 curated excerpts referenced by file:line.
- **5.11 Challenges & Solutions** — Supabase→AWS migration, multi-tenant isolation, dual auth
  reconciliation, realtime scaling (Redis adapter), schema evolution via migrations.

---

## Chapter 6 — Testing & Evaluation — `07-chapter6-testing.md`

- **6.1 Testing Strategy** — Stated honestly: **no automated suite present**; approach is manual,
  black-box, requirement-driven, plus the **CI typecheck/build gate** as a static-quality control and
  Flutter `analyze` + `tsc --strict` as compile-time verification.
- **6.2 Testing Levels** — Unit (compile/type checks), integration (manual API checks per module),
  system (end-to-end role workflows), UAT (stakeholder walkthroughs).
- **6.3 Sample Test-Cases Table** — `(ID, Module, Input, Expected, Actual, Status)` covering login
  (both systems), RBAC denial, attendance, invoice payment, bus GPS realtime, AI assistant, tenant
  isolation (Table 6.1).
- **6.4 Results Summary** — Pass/fail roll-up and defects observed.
- **6.5 Performance Notes** — Qualitative: indexed queries, Socket.IO rooms, presigned-URL offloading,
  single-instance vs. Redis-adapter scaling.
- **6.6 User Feedback** — Placeholder for supervisor/stakeholder feedback if collected.

---

## Chapter 7 — Conclusion & Future Work — `08-chapter7-conclusion.md`

- **7.1 Achievements vs. Objectives** — Objective-by-objective scorecard against Chapter 1.
- **7.2 Contributions** — Integrated Arabic-first multi-tenant SMS with transport GPS, parent app,
  admissions, and an AI admin assistant.
- **7.3 Limitations** — Security hardening (salted hashing, secret management), no payment gateway,
  notification channels not wired, single-region/no-IaC, no automated tests.
- **7.4 Future Enhancements** — Argon2/bcrypt + secrets manager, payment-gateway integration, real
  SMS/WhatsApp/email providers, full IaC + multi-AZ, automated test suite, analytics, offline mobile.

---

## Back Matter — `09-back-matter.md`

- **References** — IEEE-formatted: framework/tool docs (Express, Prisma, Next.js, React, Flutter, AWS
  Cognito/S3/Bedrock, Socket.IO, FCM, PostgreSQL), plus SMS-domain and comparison-system sources.
- **Appendix A — Screenshots** — Placeholders for dashboard + mobile screens.
- **Appendix B — Full API Reference** — The complete endpoint catalogue (from §5 of analysis).
- **Appendix C — User Manual** — Per-role quick-start (admin, teacher, parent, student, driver).
- **Appendix D — Glossary** — Domain + technical terms.
- **Appendix E — Database Data Dictionary (full)** — Extended table beyond Chapter 4's key subset.

---

## Figures (planned, numbered — all Mermaid; exported to `diagrams/` if `mmdc` available)

| Figure | Title | Chapter |
|--------|-------|---------|
| 2.1 | Feature comparison of existing systems (table, not diagram) | 2 |
| 3.1 | Use-case diagram — School Admin / Super Admin | 3 |
| 3.2 | Use-case diagram — Teacher | 3 |
| 3.3 | Use-case diagram — Parent | 3 |
| 3.4 | Use-case diagram — Student | 3 |
| 3.5 | Use-case diagram — Driver / Supervisor | 3 |
| 4.1 | System architecture & deployment topology | 4 |
| 4.2 | Database ERD | 4 |
| 4.3 | Backend class/module diagram | 4 |
| 4.4 | Sequence — Web (Cognito) login & sync | 4 |
| 4.5 | Sequence — Mobile login (JWT + device session) | 4 |
| 4.6 | Sequence — Mark attendance | 4 |
| 4.7 | Sequence — Issue & pay invoice | 4 |
| 4.8 | Sequence — Bus GPS update → parent realtime | 4 |
| 4.9 | Sequence — AI assistant tool-use | 4 |
| 4.10 | Activity — Admission to enrollment | 4 |
| 4.11 | Activity — Invoice lifecycle | 4 |
| 4.12 | Context DFD (Level 0) | 4 |
| 4.13 | Level-1 DFD | 4 |

## Tables (planned, numbered)

| Table | Title | Chapter |
|-------|-------|---------|
| 2.1 | Comparison of existing school-management systems | 2 |
| 3.1 | Functional requirements catalogue | 3 |
| 3.2 | Non-functional requirements | 3 |
| 4.1 | Data dictionary — key entities | 4 |
| 5.1 | Technology stack & versions | 5 |
| 6.1 | Sample test cases | 6 |
| 7.1 | Objectives vs. achievements | 7 |
| B.1 | Full API endpoint reference | Appendix |

---

### Confirmation requested

If this structure and the figure/table plan look right, reply to approve and I'll write Phase 3
(front matter → Chapter 7 → back matter, with all Mermaid diagrams), then assemble the single
`WeCircle-Documentation.md` and a `README.md`. Tell me of any chapter you want expanded, trimmed, or
reordered before I start.
