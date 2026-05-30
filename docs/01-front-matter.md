<!-- ============================================================
     FRONT MATTER
     ============================================================ -->

# WeCircle — School Management System

### Graduation Project Report

---

<div align="center">

**International Academy for Engineering and Media Science (IAEMS)**

**Faculty / Department of Mass Communication**

Bachelor's Degree in Mass Communication
Major in Multimedia and Web / Mobile Application Development

Graduation Project — Senior Year, Spring 2026

---

**Project Title**

**WeCircle: A Multi-Tenant School Management Platform
(REST API Backend · Web Admin Dashboard · Mobile Application)**

---

**Submitted by**

| Team Member | Student ID |
|-------------|------------|
| Maryam Khamis | `[ID: __________]` |
| Karim El-Saeed | `[ID: __________]` |
| Fadi Emad | `[ID: __________]` |
| Adham El-Shater | `[ID: __________]` |
| Jihad Haggag | `[ID: __________]` |
| Sandy Tharwat | `[ID: __________]` |

**Supervised by**

**Dr. Nabil Al-Ghamry**

---

Academic Year 2025–2026 — Spring Semester

</div>

<div style="page-break-after: always;"></div>

---

## Abstract

Schools in Egypt continue to manage admissions, attendance, fee collection, transport, and
parent communication through fragmented manual processes and informal messaging channels. This
fragmentation produces data loss, weak financial oversight, and limited visibility for parents.
**WeCircle** is a multi-tenant school management platform that consolidates these operations into a
single integrated system composed of three components: a REST API backend, a web administration
dashboard, and a cross-platform mobile application.

The backend is implemented in TypeScript on Node.js using the Express 5 web framework and the
Prisma 6 object–relational mapper over a PostgreSQL database. It exposes thirty-seven feature
modules covering authentication and role-based access control, school and academic-structure
management, admissions, students and classes, teachers and assignments, attendance, homework,
examinations and results, timetables, finance (fee structures, invoices, and payments), school-bus
transport with real-time GPS tracking, communication (announcements, notifications, and chat), and
an artificial-intelligence administrative assistant built on Amazon Bedrock. The web dashboard is
built with Next.js 16 and React 19 and authenticates staff through AWS Cognito. The mobile
application is built with Flutter and serves parents, students, teachers, drivers, and bus
supervisors, authenticating through backend-issued JSON Web Tokens derived from application
credentials. The platform enforces tenant isolation by `schoolId` and supports real-time updates
through Socket.IO.

The system was developed using an iterative, incremental methodology with a continuous-integration
gate that type-checks and builds all components on every change. It was evaluated through a manual,
requirement-driven test plan complemented by strict static type-checking. The result is a working,
internally consistent platform that demonstrates a complete school-operations lifecycle—from a
prospective student's admission application to enrollment, daily academic and financial management,
transport tracking, and parent engagement—within a single Arabic-first, multi-tenant architecture.

**Keywords:** school management system; multi-tenant SaaS; REST API; role-based access control;
Flutter; Next.js; Prisma; AWS Cognito; real-time tracking; educational technology.

<div style="page-break-after: always;"></div>

---

## الملخص (Arabic Abstract)

<div dir="rtl">

لا تزال المدارس في مصر تدير عمليات القبول والحضور وتحصيل المصروفات والنقل والتواصل مع أولياء الأمور
من خلال إجراءات يدوية متفرقة وقنوات مراسلة غير رسمية، مما يؤدي إلى فقدان البيانات وضعف الرقابة المالية
ومحدودية متابعة أولياء الأمور لأبنائهم. ومن هنا جاء مشروع **WeCircle**، وهو منصة متعددة المستأجرين
(Multi-Tenant) لإدارة المدارس تجمع هذه العمليات في نظام واحد متكامل يتكوّن من ثلاثة مكوّنات: واجهة
برمجة تطبيقات خلفية (REST API)، ولوحة تحكم إدارية على الويب، وتطبيق محمول يعمل على نظامي أندرويد و iOS.

تم بناء الواجهة الخلفية بلغة TypeScript على بيئة Node.js باستخدام إطار العمل Express وأداة الربط
الكائني Prisma فوق قاعدة بيانات PostgreSQL، وتضم سبعة وثلاثين وحدة وظيفية تشمل المصادقة والتحكم في
الصلاحيات حسب الدور، وإدارة المدرسة والهيكل الأكاديمي، والقبول، والطلاب والفصول، والمعلمين، والحضور،
والواجبات، والامتحانات والنتائج، والجداول الدراسية، والشؤون المالية، والنقل المدرسي مع التتبع اللحظي
لموقع الحافلة، والتواصل، ومساعد ذكاء اصطناعي إداري مبني على خدمة Amazon Bedrock. أما لوحة التحكم فقد
بُنيت باستخدام Next.js و React مع مصادقة الموظفين عبر AWS Cognito، بينما بُني التطبيق المحمول باستخدام
Flutter ليخدم أولياء الأمور والطلاب والمعلمين والسائقين والمشرفين، مع مصادقة قائمة على رموز JWT.

اعتُمد في التطوير منهجٌ تكراري تزايدي مدعوم ببوابة تكامل مستمر تتحقق من سلامة الشيفرة وبنائها عند كل
تعديل، وجرى تقييم النظام عبر خطة اختبار يدوية موجَّهة بالمتطلبات إلى جانب التحقق الثابت الصارم من
الأنواع. والنتيجة منصة عاملة ومتسقة تُغطّي دورة العمل المدرسية كاملة—من تقديم الطالب للالتحاق حتى
التسجيل والإدارة اليومية الأكاديمية والمالية وتتبّع النقل ومتابعة أولياء الأمور—ضمن معمارية واحدة
متعددة المستأجرين تدعم اللغة العربية أولاً.

**الكلمات المفتاحية:** نظام إدارة مدارس؛ منصة متعددة المستأجرين؛ واجهة REST؛ التحكم في الصلاحيات
حسب الدور؛ Flutter؛ Next.js؛ Prisma؛ AWS Cognito؛ التتبع اللحظي؛ تقنيات التعليم.

</div>

<div style="page-break-after: always;"></div>

---

## Acknowledgments

We extend our sincere gratitude to our supervisor, **Dr. Nabil Al-Ghamry**, for his guidance,
constructive feedback, and continuous encouragement throughout the development of this project. We
thank the **International Academy for Engineering and Media Science (IAEMS)** and the **Department
of Mass Communication** for providing the academic environment and resources that made this work
possible.

We are grateful to the teaching staff who shaped our understanding of software engineering,
multimedia, and application development over the course of our studies. Finally, we thank our
families and colleagues for their patience and support during the graduation-project semester.

`[Placeholder: add any additional acknowledgments, e.g., participating school(s) or testers.]`

<div style="page-break-after: always;"></div>

---

## Table of Contents

> The table of contents is generated automatically when the document is assembled and converted
> (see `docs/README.md`). The logical structure is:

1. **Front Matter** — Title Page · Abstract (EN) · الملخص (AR) · Acknowledgments · Lists
2. **Chapter 1 — Introduction**
3. **Chapter 2 — Background & Literature Review**
4. **Chapter 3 — System Analysis**
5. **Chapter 4 — System Design**
6. **Chapter 5 — Implementation**
7. **Chapter 6 — Testing & Evaluation**
8. **Chapter 7 — Conclusion & Future Work**
9. **References**
10. **Appendices** — A: Screenshots · B: Full API Reference · C: User Manual · D: Glossary ·
    E: Database Data Dictionary

<div style="page-break-after: always;"></div>

---

## List of Figures

| Figure | Title | Chapter |
|--------|-------|---------|
| 3.1 | Use-Case Diagram — School Admin / Super Admin | 3 |
| 3.2 | Use-Case Diagram — Teacher | 3 |
| 3.3 | Use-Case Diagram — Parent | 3 |
| 3.4 | Use-Case Diagram — Student | 3 |
| 3.5 | Use-Case Diagram — Driver / Bus Supervisor | 3 |
| 4.1 | System Architecture & Deployment Topology | 4 |
| 4.2 | Database Entity–Relationship Diagram (ERD) | 4 |
| 4.3 | Backend Class / Module Diagram | 4 |
| 4.4 | Sequence Diagram — Web (Cognito) Login & Synchronization | 4 |
| 4.5 | Sequence Diagram — Mobile Login (JWT + Device Session) | 4 |
| 4.6 | Sequence Diagram — Mark Attendance | 4 |
| 4.7 | Sequence Diagram — Issue & Pay Invoice | 4 |
| 4.8 | Sequence Diagram — Bus GPS Update → Parent Real-Time | 4 |
| 4.9 | Sequence Diagram — AI Assistant Tool-Use | 4 |
| 4.10 | Activity Diagram — Admission to Enrollment | 4 |
| 4.11 | Activity Diagram — Invoice Lifecycle | 4 |
| 4.12 | Context-Level Data-Flow Diagram (Level 0) | 4 |
| 4.13 | Level-1 Data-Flow Diagram | 4 |

## List of Tables

| Table | Title | Chapter |
|-------|-------|---------|
| 2.1 | Comparison of Existing School-Management Systems | 2 |
| 3.1 | Functional Requirements Catalogue | 3 |
| 3.2 | Non-Functional Requirements | 3 |
| 4.1 | Data Dictionary — Key Entities | 4 |
| 5.1 | Technology Stack & Versions | 5 |
| 6.1 | Sample Test Cases | 6 |
| 7.1 | Objectives vs. Achievements | 7 |
| B.1 | Full API Endpoint Reference | Appendix B |

<div style="page-break-after: always;"></div>

---

## List of Abbreviations

| Abbreviation | Meaning |
|--------------|---------|
| AI | Artificial Intelligence |
| API | Application Programming Interface |
| AWS | Amazon Web Services |
| CI/CD | Continuous Integration / Continuous Deployment |
| CORS | Cross-Origin Resource Sharing |
| CRUD | Create, Read, Update, Delete |
| DFD | Data-Flow Diagram |
| DM | Direct Message |
| ERD | Entity–Relationship Diagram |
| FCM | Firebase Cloud Messaging |
| GPS | Global Positioning System |
| HTTP(S) | HyperText Transfer Protocol (Secure) |
| IaC | Infrastructure as Code |
| IAM | Identity and Access Management |
| JWT | JSON Web Token |
| ORM | Object–Relational Mapping |
| OAuth | Open Authorization |
| PaaS / SaaS | Platform / Software as a Service |
| RBAC | Role-Based Access Control |
| REST | Representational State Transfer |
| S3 | (Amazon) Simple Storage Service |
| SDK | Software Development Kit |
| SIS / SMS | Student Information System / School Management System |
| SQL | Structured Query Language |
| TLS | Transport Layer Security |
| UAT | User Acceptance Testing |
| UI / UX | User Interface / User Experience |
| UUID | Universally Unique Identifier |
| WS | WebSocket |

<div style="page-break-after: always;"></div>
