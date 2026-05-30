# 🏗️ WeCircle Infrastructure — AWS Deployment Guide

## Architecture Overview

```
                    ┌──────────────────────────────────────────────┐
                    │                  AWS Cloud                   │
                    │                                              │
  Users ──► Route53 ──► CloudFront (web) ──► S3 static export     │
                    │                                              │
  API ──► Route53 ──► ALB (sticky sessions for Socket.IO)         │
                    │         │                                    │
                    │    ┌────┴──────────┐                         │
                    │    │  ECS Fargate  │                         │
                    │    │  Backend :5001│                         │
                    │    └──────┬────────┘                         │
                    │           │                                  │
                    │    ┌──────┴────────┬──────────┬──────────┐   │
                    │  RDS Postgres  ElastiCache  S3 (assets)  │   │
                    │  (Multi-AZ)    Redis        + CloudFront  │   │
                    │                                           │   │
                    │  Cognito (auth)  Secrets Manager          │   │
                    │  EventBridge (cron)  ECR (images)         │   │
                    └───────────────────────────────────────────┘
```

> **Current state (2026-05-29):** single EC2 + pm2 deployment (not ECS). The above is the
> **target architecture** to be provisioned via Terraform in Phase 4.

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
  --secret-string "postgresql://user:pass@your-rds-host:5432/wecircle"

aws secretsmanager create-secret \
  --name wecircle/JWT_SECRET \
  --secret-string "$(openssl rand -base64 48)"

aws secretsmanager create-secret \
  --name wecircle/GOOGLE_AI_API_KEY \
  --secret-string "your_gemini_api_key"

# Store non-sensitive config in Parameter Store
aws ssm put-parameter \
  --name /wecircle/FRONTEND_URL \
  --value "https://your-frontend-domain.com" \
  --type String

aws ssm put-parameter \
  --name /wecircle/SUPER_ADMIN_EMAIL \
  --value "admin@your-domain.com" \
  --type String

aws ssm put-parameter \
  --name /wecircle/COGNITO_USER_POOL_ID \
  --value "us-east-1_XXXXXXXXX" \
  --type String

aws ssm put-parameter \
  --name /wecircle/COGNITO_CLIENT_ID \
  --value "your_cognito_client_id" \
  --type String

aws ssm put-parameter \
  --name /wecircle/AWS_S3_BUCKET_NAME \
  --value "wecircle-storage-XXXXXXXXXXXX" \
  --type String
```

### Step 4: Add GitHub Secrets
Go to `Settings > Secrets and variables > Actions` in your GitHub repo:
```
AWS_ACCESS_KEY_ID        ← IAM user access key (or use OIDC — see Phase 4)
AWS_SECRET_ACCESS_KEY    ← IAM user secret key
EC2_HOST                 ← Production EC2 IP / hostname
EC2_SSH_KEY              ← Private key for ec2-user
JWT_SECRET               ← Same value stored in Secrets Manager
COGNITO_USER_POOL_ID     ← Cognito pool ID
COGNITO_CLIENT_ID        ← Cognito app client ID
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
