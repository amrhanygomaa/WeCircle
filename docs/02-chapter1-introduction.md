<!-- ============================================================
     CHAPTER 1 — INTRODUCTION
     ============================================================ -->

# Chapter 1 — Introduction

## 1.1 Overview

A modern school is, in operational terms, a small enterprise. It must process prospective-student
applications, enroll and classify students into grades and classes, schedule lessons, record daily
attendance, set and grade homework and examinations, bill and collect tuition and bus fees, operate
a fleet of school buses, and communicate continuously with parents. In many Egyptian schools these
functions are still handled with a mixture of paper forms, spreadsheets, and informal messaging
applications. Each function is managed in isolation, the same data is re-entered repeatedly, and
parents receive only the information that staff have time to relay manually.

**WeCircle** is a school management platform designed to unify these functions in a single,
integrated, multi-tenant system. The platform is composed of three cooperating components:

1. A **REST API backend** that owns the database and implements all business logic, security, and
   integrations.
2. A **web administration dashboard** used by school staff (administrators, accountants, admissions
   officers, and similar roles).
3. A **cross-platform mobile application** used by parents, students, teachers, bus drivers, and bus
   supervisors.

The term *multi-tenant* means that a single deployment of WeCircle can serve many independent
schools at once. Every record in the system is tagged with the identifier of the school that owns
it (`schoolId`), and the backend enforces that users of one school can never see or modify the data
of another. The platform is **Arabic-first**: its default language, currency (Egyptian Pound), and
working week (Sunday–Thursday) reflect the Egyptian educational context, while remaining
configurable per school.

The system is publicly reachable through its production endpoints—the API at
`https://api.wecircle.helpers-tech.com` and the dashboard at
`https://dashboard.wecircle.helpers-tech.com`—and the mobile application communicates with the same
API.

## 1.2 Problem Statement

The core problem WeCircle addresses can be stated as follows:

> *School operations in the target context are fragmented across disconnected manual tools, which
> causes data duplication and loss, weak financial oversight, slow and inconsistent
> parent communication, and an absence of a single authoritative record of each student's
> administrative, academic, and financial history.*

This general problem decomposes into several concrete pain points:

- **Disconnected data.** Admissions data lives on paper, attendance in a register, fees in a
  spreadsheet, and announcements in a messaging group. There is no single source of truth, so the
  same student is represented inconsistently across systems.
- **Weak financial control.** Without structured invoices, payment records, and overdue tracking,
  schools struggle to know who has paid, who is in arrears, and how much revenue is outstanding.
- **Limited parent visibility.** Parents cannot easily check their child's attendance, homework,
  grades, fees, or the location of the school bus, and instead depend on staff to relay information
  reactively.
- **No role separation.** Manual tools do not enforce who is allowed to see or change what, exposing
  sensitive student and financial data.
- **No real-time information.** Time-critical information—most notably the live position of a school
  bus—cannot be conveyed by manual means.

## 1.3 Motivation

Three factors motivated the development of WeCircle:

1. **A genuine, observed need.** Administrative overhead, fee-collection difficulties, and parent
   communication are widely reported challenges for schools in the region. A system that integrates
   these functions offers tangible operational value.
2. **The opportunity to engineer a complete, real product.** As a graduation project in multimedia
   and web/mobile application development, WeCircle provided an opportunity to design and build a
   full-stack system end to end—database, backend API, web client, and mobile client—rather than an
   isolated prototype, and to deploy it to live cloud infrastructure.
3. **An Arabic-first, context-specific design.** Many capable international systems are not tailored
   to the Egyptian context (Arabic right-to-left interfaces, the Egyptian Pound, the Sunday–Thursday
   week, and locally meaningful admissions documents such as national ID and residence proof).
   WeCircle was motivated by the value of building for this context directly.

## 1.4 Objectives

The project set out to achieve the following objectives. Each is later evaluated against the
delivered system in Chapter 7 (Table 7.1).

- **OBJ-1 — Unified multi-tenant platform.** Build a single backend that securely serves many
  schools, isolating each school's data.
- **OBJ-2 — Authentication and role-based access control.** Provide secure sign-in for staff (web)
  and end users (mobile), and restrict each role to the actions appropriate to it.
- **OBJ-3 — Core academic administration.** Implement management of schools, academic years, grades,
  classes, subjects, students, teachers, and parents.
- **OBJ-4 — Admissions pipeline.** Implement an applications workflow from initial enquiry through
  review, decision, and conversion of an accepted applicant into an enrolled student.
- **OBJ-5 — Attendance, homework, examinations, and timetables.** Implement daily/periodic
  attendance, homework with submissions, examinations with results, and class timetables.
- **OBJ-6 — Financial management.** Implement fee structures, invoices, payments, discounts, and
  automatic overdue detection.
- **OBJ-7 — School-bus transport with live tracking.** Implement buses, routes, driver/supervisor
  management, bus attendance, and real-time GPS tracking visible to parents.
- **OBJ-8 — Communication.** Implement announcements, notifications (with push), and one-to-one
  chat between staff and parents.
- **OBJ-9 — Parent and student mobile experience.** Deliver a mobile application that gives parents
  visibility into their children and gives students an engaging, gamified learning experience.
- **OBJ-10 — AI administrative assistant.** Provide an AI assistant that lets staff query and manage
  their school's data conversationally, scoped strictly to their own school.

## 1.5 Scope & Limitations

### 1.5.1 In scope

The scope of WeCircle is defined by the functionality actually implemented in the codebase: the
thirty-seven backend feature modules and their corresponding web and mobile interfaces, covering
authentication/RBAC, school and academic-structure management, admissions, students, teachers,
parents, attendance, homework, examinations and results, timetables, finance, transport with GPS,
communication, behavior and daily reports, student tasks and gamification, file storage, and the AI
assistant.

### 1.5.2 Limitations and exclusions

In the interest of an honest, defensible account, the following limitations are stated explicitly
and revisited in Chapters 6 and 7:

- **Payment gateway.** The finance module records invoices and payments but does not integrate an
  online payment gateway; payments are recorded by staff.
- **Notification channels.** SMS, WhatsApp, and email channels are modelled in the data layer
  (`SchoolSettings`, `NotificationChannel`) with template fields, but no external provider is wired;
  delivery in the current build is in-app/database, real-time (Socket.IO), and push (FCM, when
  configured).
- **Automated testing.** The project does not include an automated unit/integration test suite;
  quality is enforced through strict static type-checking and a manual, requirement-driven test plan
  (Chapter 6).
- **Security hardening.** Some credentials are stored without best-practice protection (for example,
  mobile passwords are hashed with unsalted SHA-256, and certain secrets are stored in plaintext);
  these are documented as known limitations with remediation proposed in Chapter 7.
- **Infrastructure.** The system is deployed to a single Amazon EC2 instance managed with the pm2
  process manager behind nginx; it is not yet provisioned through infrastructure-as-code and is
  single-region.

## 1.6 Significance

WeCircle is significant on two levels. **Operationally**, it offers a school a single authoritative
record per student spanning admission, academics, finance, transport, and communication; it improves
financial oversight through structured invoicing and overdue detection; and it increases
transparency for parents through a dedicated mobile application that includes real-time bus tracking.
**Academically**, the project demonstrates the end-to-end engineering of a non-trivial,
production-deployed, multi-tenant system across three clients and several cloud services, exercising
database design, API design, authentication and authorization, real-time communication, mobile
development, and applied AI.

## 1.7 Development Methodology

The project followed an **iterative and incremental** development methodology, aligned with Agile
principles and reflected directly in the project's version-control and continuous-integration
history.

- **Incremental delivery.** The system was built and refined module by module, with the application
  kept in a working, buildable state at the end of each increment.
- **Small, reviewable changes.** Work proceeded through small commits with descriptive messages,
  enabling review and traceability.
- **Continuous integration gate.** A GitHub Actions workflow type-checks and builds both the backend
  (`prisma generate` + `tsc`) and the frontend (`next build`) on every push to the main branch
  before deployment, acting as an automated quality gate.
- **Continuous deployment.** On a successful gate, the same workflow deploys the backend and the
  Next.js server to the production host and runs database migrations, so that the live system
  tracks the main branch.
- **Database evolution through migrations.** Schema changes are captured as versioned Prisma
  migrations and applied deterministically in production, preserving a history of the data model.

This methodology suited a small team building a broad system under time constraints: it favored
continuous, verifiable progress over heavyweight up-front specification, while the CI gate and
migration history provided discipline and reproducibility.

## 1.8 Report Organization

The remainder of this report is organized as follows:

- **Chapter 2 — Background & Literature Review** introduces the school-management domain and its key
  technologies, surveys comparable systems in the Egyptian/Arabic market, and performs a gap
  analysis that justifies WeCircle.
- **Chapter 3 — System Analysis** identifies stakeholders, specifies functional and non-functional
  requirements, presents a feasibility study, and models the system's behavior with use-case
  diagrams.
- **Chapter 4 — System Design** presents the system architecture, justifies the technology choices,
  and details the database design (ERD and data dictionary), class diagram, and the sequence,
  activity, and data-flow diagrams for the principal flows, together with the UI/UX design.
- **Chapter 5 — Implementation** describes the development environment, the structure of each
  component, and the concrete implementation of the backend, database, web dashboard, mobile app,
  and security, with annotated code excerpts and a discussion of challenges.
- **Chapter 6 — Testing & Evaluation** presents the testing strategy and levels, a sample
  test-case table, results, and performance notes.
- **Chapter 7 — Conclusion & Future Work** evaluates achievements against objectives and proposes
  enhancements.
- **References** and **Appendices** (screenshots, full API reference, user manual, glossary, and the
  full data dictionary) close the report.

<div style="page-break-after: always;"></div>
