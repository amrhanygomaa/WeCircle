# WeCircle Project Structure

This repository is organized into three main layers representing a modern, AWS-first, AI-agent-friendly monolithic system.

## 1. Backend (`dashboard/backend/`)
A Node.js/Express application connecting to PostgreSQL via Prisma.
- **`src/core/`**: Infrastructure, middleware, error handling, config (e.g. `http/middlewares`, `utils`).
- **`src/modules/`**: Domain-driven feature sets. Each module encapsulates its controllers, routes, and services (e.g., `student`, `auth`).
- **`prisma/`**: Database schema and seed files.

## 2. Frontend (`dashboard/frontend/`)
A Next.js App Router application providing the Admin Dashboard.
- **`src/app/`**: Next.js App Router definitions. These are "thin" layers invoking modules.
- **`src/core/`**: Centralized API clients, routing constants, state, and configs.
- **`src/modules/`**: Domain-driven feature components (e.g., `auth`, `dashboard`, `students`).
- **`src/shared/`**: Reusable UI components, layouts, and utilities.

## 3. Mobile (`mobile/`)
A Flutter mobile application.
- **`lib/core/`**: Core services, API configuration, theming, and state management.
- **`lib/features/`**: High-level modules or screens.
- **`lib/shared/`**: Common UI widgets and animations.

## AWS Integration
- Hosted on EC2 (or Fargate).
- Relies exclusively on standard environment variables (no `.env.local` files containing secrets should be committed).
- Database is PostgreSQL running natively or via RDS in AWS Free Tier.
