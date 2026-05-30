<!-- ============================================================
     CHAPTER 2 — BACKGROUND & LITERATURE REVIEW
     ============================================================ -->

# Chapter 2 — Background & Literature Review

## 2.1 Domain Background

A **School Management System (SMS)**—also referred to as a Student Information System (SIS) or
school Enterprise Resource Planning (ERP) system—is software that automates the administrative and
academic operations of an educational institution. Conceptually, an SMS supports the full lifecycle
of a student within a school:

1. **Admission** — a prospective student applies; the school collects the child's and guardians'
   data and supporting documents, reviews the application, and reaches a decision.
2. **Enrollment & classification** — an accepted applicant becomes an enrolled student assigned to a
   grade and class for a given academic year.
3. **Academic operations** — timetabling, attendance, homework, examinations, and results.
4. **Financial operations** — fee structures, invoicing, payment collection, and arrears tracking.
5. **Logistics** — school-bus routes, assignments, and attendance.
6. **Communication** — announcements, notifications, and direct messaging among staff and parents.

A well-designed SMS treats these not as isolated silos but as one connected dataset, so that—for
example—an accepted admission application becomes a student record without re-entry, a student's
class membership drives both attendance and timetable, and a fee structure produces invoices whose
unpaid balances are tracked automatically. WeCircle is designed around exactly this connectedness.

Two characteristics distinguish a modern, cloud-delivered SMS from earlier desktop software:

- **Multi-tenancy.** A single hosted instance serves many schools, each isolated from the others.
  This lowers per-school cost and centralizes maintenance, at the expense of requiring rigorous data
  isolation.
- **Multi-client access.** Staff typically work through a web dashboard, while parents and students
  increasingly expect a mobile application, including push notifications and real-time features such
  as bus tracking.

## 2.2 Key Concepts & Technologies

This section introduces the principal concepts and technologies on which WeCircle is built; their
specific selection is justified in Chapter 4.

- **Client–server architecture and REST APIs.** WeCircle separates a server (the backend, which owns
  the database and business logic) from clients (the web dashboard and mobile app). They communicate
  over HTTP using a **REST** (Representational State Transfer) style: resources such as students,
  invoices, and buses are exposed at URLs and manipulated with the HTTP verbs GET, POST, PUT, PATCH,
  and DELETE, exchanging JSON.

- **Relational databases and ORMs.** Persistent data is stored in **PostgreSQL**, a relational
  database. Rather than writing SQL by hand, the backend uses an **Object–Relational Mapper (ORM)**,
  **Prisma**, which defines the schema declaratively, generates a type-safe client, and manages
  schema evolution through versioned **migrations**.

- **Authentication and authorization.** *Authentication* establishes *who* a user is; *authorization*
  establishes *what* they may do. WeCircle uses **AWS Cognito**—a managed identity service—for staff
  on the web, and **JSON Web Tokens (JWT)** issued by the backend for mobile users. Authorization is
  enforced through **Role-Based Access Control (RBAC)**, in which each user holds a role and access
  is granted to roles rather than individuals.

- **Multi-tenant isolation.** Each record carries a `schoolId`, and middleware guarantees that a
  request can only touch records belonging to the requester's school. This is *logical* isolation
  within a shared database, as opposed to a separate database per tenant.

- **Real-time communication (WebSockets).** Some information, such as a bus's live location, must be
  pushed to clients the moment it changes. WeCircle uses **Socket.IO** (over WebSockets) to broadcast
  events to all users of a given school in real time.

- **Cross-platform mobile development.** The mobile application is built with **Flutter**, a
  framework that compiles a single Dart codebase to both Android and iOS, reducing duplicated effort.

- **Cloud services.** Beyond identity, the platform uses **Amazon S3** for file storage (documents
  and photos, uploaded directly from the client via presigned URLs), **Amazon Bedrock** for the AI
  assistant, and **Firebase Cloud Messaging (FCM)** for mobile push notifications.

- **Applied AI (tool-using assistant).** The AI assistant is built on a large language model accessed
  through Bedrock's *Converse* API with **tool use**: the model is given structured tools to query
  and modify the school's database, and the backend executes those tools on its behalf, strictly
  scoped to the caller's school.

## 2.3 Survey of Existing Systems

To position WeCircle, five existing systems relevant to the Egyptian and wider Arabic market were
reviewed. The descriptions below summarize each system's publicly described purpose and
capabilities; they are intended for comparative positioning, not as endorsements, and feature
availability reflects the systems' marketed capabilities rather than first-hand testing.

1. **Classera** — A MENA-region learning and school-management platform offering a learning
   management system, communication tools, and analytics, used by schools across the Arab world and
   available in Arabic. Its strength is the academic/LMS dimension and regional localization
   [see References, Chapter "References"].

2. **Fedena** — A widely deployed, originally open-source school ERP covering students, attendance,
   examinations, fees, and timetabling. It is commonly adopted by institutions in the Middle East and
   South Asia and is extensible through modules. Its strength is breadth of administrative coverage.

3. **Schoolizer / school-parent communication apps (Egyptian market)** — A class of locally marketed
   applications focused on connecting schools with parents (announcements, grades, attendance,
   payments) and on school discovery. Their strength is parent communication tailored to the local
   market.

4. **ClassDojo** — A globally popular classroom-communication and behavior-management application
   centered on parent engagement and positive-behavior points. It is included here because of its
   strong behavior and parent-engagement model, which is conceptually close to WeCircle's behavior
   reports and gamification, though it is not a full administrative SMS.

5. **Generic Egyptian school ERP / in-house systems** — Many Egyptian schools use bespoke or
   spreadsheet-augmented systems for fees and records. These represent the *status quo* WeCircle aims
   to replace: functional for finance and records, but typically lacking an integrated parent mobile
   app, real-time bus tracking, and unified multi-tenancy.

### Table 2.1 — Comparison of Existing School-Management Systems

| Capability | Classera | Fedena | Egyptian parent apps | ClassDojo | In-house / spreadsheets | **WeCircle** |
|------------|:--------:|:------:|:--------------------:|:---------:|:-----------------------:|:------------:|
| Admissions workflow (application → decision → enrollment) | Partial | Yes | Limited | No | Partial | **Yes** |
| Attendance (daily/periodic) | Yes | Yes | View-only | Partial | Partial | **Yes** |
| Homework & submissions | Yes | Yes | View-only | Partial | Rare | **Yes** |
| Exams & results | Yes | Yes | View-only | No | Partial | **Yes** |
| Fees, invoices & overdue tracking | Partial | Yes | View/pay | No | Yes | **Yes** |
| School-bus management | Limited | Limited | Limited | No | Rare | **Yes** |
| **Real-time bus GPS tracking for parents** | Rare | No | Some | No | No | **Yes** |
| Parent mobile application | Yes | Partial | Yes | Yes | Rare | **Yes** |
| Student gamified experience | Partial | No | No | Yes | No | **Yes** |
| One-to-one staff↔parent chat | Yes | Partial | Some | Messaging | No | **Yes** |
| Arabic-first / RTL & EGP context | Yes | Partial | Yes | Partial | Yes | **Yes** |
| Multi-tenant (many schools, one instance) | Yes | Yes | Yes | Yes | No | **Yes** |
| **Conversational AI admin assistant over school data** | No | No | No | No | No | **Yes** |

> *Legend:* "Yes" = a core, integrated capability; "Partial/Limited" = present but narrow or
> add-on; "View-only/View-pay" = parent-facing visibility without full management; "Rare/No" =
> typically absent. Entries reflect the systems' publicly described capabilities.

## 2.4 Gap Analysis

The survey reveals that the Egyptian/Arabic market is well served in *parts* of the lifecycle but
poorly served in *integration* of the whole:

- **Integration gap.** Established ERPs (e.g., Fedena) cover administration well but treat the parent
  mobile experience and transport tracking as weak or add-on areas. Parent-communication apps cover
  engagement well but are not authoritative systems of record for admissions, academics, and finance.
  Few systems unify *all* of admissions, academics, finance, transport, communication, and an
  engaging student experience in one product.
- **Real-time transport gap.** Real-time, parent-visible **bus GPS tracking** is rare. For parents,
  this is one of the highest-value features, and it is largely missing from the systems reviewed.
- **Student-engagement gap.** Administrative systems treat students as records, not users. WeCircle
  treats younger students as first-class users with a **gamified** mobile experience (points, levels,
  learning games), bridging administration and engagement.
- **Localization-plus-multi-tenancy gap.** While individual systems are either Arabic-localized *or*
  multi-tenant, WeCircle is designed from the ground up to be **both**—Arabic-first defaults
  (language, EGP, Sunday–Thursday week, national-ID and residence-proof admission documents) within a
  strictly isolated multi-tenant backend.
- **Intelligent administration gap.** None of the surveyed systems offer a **conversational AI
  assistant** that lets staff query and update their school's data in natural language, scoped to
  their own tenant. WeCircle's Bedrock-based assistant is a distinguishing capability.

These gaps justify WeCircle's design goal: not to introduce a single new feature, but to **integrate
the full school-operations lifecycle**—including the under-served areas of real-time transport,
student engagement, and intelligent administration—within one Arabic-first, multi-tenant platform
spanning web and mobile.

<div style="page-break-after: always;"></div>
