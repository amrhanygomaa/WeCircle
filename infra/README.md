# 🏗️ WeCircle Infrastructure — AWS Deployment Guide

## Architecture Overview

```
                    ┌─────────────────────────────────────┐
                    │           AWS Cloud                 │
                    │                                     │
  Users ──► Route53 ──► CloudFront ──► ALB               │
                    │         │         │                 │
                    │         │    ┌────┴──────────┐      │
                    │         │    │  ECS Fargate  │      │
                    │         │    │  ┌──────────┐ │      │
                    │         │    │  │ Backend  │ │      │
                    │         │    │  │  :5001   │ │      │
                    │         │    │  └──────────┘ │      │
                    │         │    │  ┌──────────┐ │      │
                    │         │    │  │ Frontend │ │      │
                    │         │    │  │  :3000   │ │      │
                    │         │    │  └──────────┘ │      │
                    │         │    └───────────────┘      │
                    │         │                           │
                    │    S3 (Assets)   Supabase (DB/Auth) │
                    │    ECR (Images)  Secrets Manager    │
                    └─────────────────────────────────────┘
```

## 📁 Files in this directory

```
infra/
└── aws/
    ├── ecs-task-definition.json    ← ECS Fargate task definition (backend)
    └── buildspec.yml               ← AWS CodeBuild pipeline spec
```

## 🚀 Deployment Steps

### Prerequisites
- AWS CLI configured: `aws configure`
- Docker installed
- ECR repositories created (see below)

### Step 1: Create ECR Repositories
```bash
aws ecr create-repository --repository-name wecircle-backend --region us-east-1
aws ecr create-repository --repository-name wecircle-frontend --region us-east-1
```

### Step 2: Create ECS Cluster
```bash
aws ecs create-cluster --cluster-name wecircle-cluster
```

### Step 3: Store Secrets in AWS Secrets Manager
```bash
# Store each secret individually
aws secretsmanager create-secret \
  --name wecircle/DATABASE_URL \
  --secret-string "your_database_url"

aws secretsmanager create-secret \
  --name wecircle/SUPABASE_URL \
  --secret-string "https://your-project.supabase.co"

aws secretsmanager create-secret \
  --name wecircle/SUPABASE_ANON_KEY \
  --secret-string "your_anon_key"

aws secretsmanager create-secret \
  --name wecircle/SUPABASE_SERVICE_ROLE_KEY \
  --secret-string "your_service_role_key"

aws secretsmanager create-secret \
  --name wecircle/SUPABASE_JWT_SECRET \
  --secret-string "your_jwt_secret"

# Store non-sensitive config in Parameter Store
aws ssm put-parameter \
  --name /wecircle/FRONTEND_URL \
  --value "https://your-frontend-domain.com" \
  --type String

aws ssm put-parameter \
  --name /wecircle/SUPER_ADMIN_EMAIL \
  --value "admin@your-domain.com" \
  --type String
```

### Step 4: Add GitHub Secrets
Go to `Settings > Secrets and variables > Actions` in your GitHub repo:
```
AWS_ACCESS_KEY_ID        ← IAM user access key
AWS_SECRET_ACCESS_KEY    ← IAM user secret key
VITE_SUPABASE_URL        ← Supabase project URL
VITE_SUPABASE_ANON_KEY   ← Supabase anon key
BACKEND_API_URL          ← https://api.your-domain.com
```

### Step 5: Deploy via GitHub Actions
Push to `main` branch → GitHub Actions auto-deploys.

## 💻 Local Development with Docker

```bash
# Copy env files
cp dashboard/backend/.env.example dashboard/backend/.env
cp dashboard/frontend/.env.example dashboard/frontend/.env

# Edit .env files with your real values, then:
docker-compose up --build
```

Services:
- Backend: http://localhost:5001
- Frontend: http://localhost:3000

## 🔐 IAM Permissions Required

The IAM user/role running deployments needs:
- `AmazonECR_FullAccess`
- `AmazonECS_FullAccess`
- `AmazonSSMReadOnlyAccess`
- `SecretsManagerReadWrite`

## 📊 Cost Estimate (us-east-1)

| Service | Spec | Monthly Est. |
|---------|------|-------------|
| ECS Fargate (backend) | 0.5 vCPU, 1GB | ~$15 |
| ECS Fargate (frontend) | 0.5 vCPU, 1GB | ~$15 |
| ECR | 2 repos, ~500MB | ~$0.05 |
| CloudFront | 10GB transfer | ~$1 |
| **Total** | | **~$31/mo** |
