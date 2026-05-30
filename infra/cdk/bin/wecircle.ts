#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { NetworkStack }   from '../lib/stacks/network-stack';
import { DatabaseStack }  from '../lib/stacks/database-stack';
import { ComputeStack }   from '../lib/stacks/compute-stack';
import { CacheStack }     from '../lib/stacks/cache-stack';
import { CdnStack }       from '../lib/stacks/cdn-stack';
import { SchedulerStack } from '../lib/stacks/scheduler-stack';
import { WECIRCLE_ENV }   from '../lib/config';

const app = new cdk.App();

// ── Stack 1: Networking ──────────────────────────────────────────────────────
// Deploy first — all other stacks depend on it.
const network = new NetworkStack(app, 'WeCircleNetwork', {
  env: WECIRCLE_ENV,
  description: 'WeCircle VPC, subnets, NAT Gateway, security groups',
});

// ── Stack 2: Database ────────────────────────────────────────────────────────
const database = new DatabaseStack(app, 'WeCircleDatabase', {
  env: WECIRCLE_ENV,
  description: 'WeCircle RDS PostgreSQL 16 — Multi-AZ, isolated subnet',
  vpc: network.vpc,
  rdsSg: network.rdsSg,
});

// ── Stack 3: Compute ─────────────────────────────────────────────────────────
// ECR, ECS Fargate, ALB, GitHub OIDC deploy role.
// After deploying WeCircleCache, set cacheDeployed: true in cdk.json and
// redeploy this stack to activate the REDIS_URL env var in the task.
const compute = new ComputeStack(app, 'WeCircleCompute', {
  env: WECIRCLE_ENV,
  description: 'WeCircle ECS Fargate, ALB, ECR, OIDC deploy role',
  vpc: network.vpc,
  albSg: network.albSg,
  backendSg: network.backendSg,
  dbSecret: database.instance.secret!,
});

// ── Stack 4: Cache ───────────────────────────────────────────────────────────
// ElastiCache Redis — Socket.IO adapter (R7).
// After deploy: set cacheDeployed: true in cdk.json, then redeploy WeCircleCompute.
new CacheStack(app, 'WeCircleCache', {
  env: WECIRCLE_ENV,
  description: 'WeCircle ElastiCache Redis 7 — Socket.IO adapter',
  vpc: network.vpc,
  redisSg: network.redisSg,
});

// ── Stack 5: CDN ─────────────────────────────────────────────────────────────
// S3 + CloudFront for Next.js static frontend export.
// Optional custom domain: cdk deploy -c frontendCertificateArn=arn:aws:acm:...
new CdnStack(app, 'WeCircleCdn', {
  env: WECIRCLE_ENV,
  description: 'WeCircle CloudFront CDN + S3 for frontend static export',
});

// ── Stack 6: Scheduler ───────────────────────────────────────────────────────
// EventBridge Scheduler fires the hourly cron Lambda (R10).
// Prereq: aws ssm put-parameter --name /wecircle/CRON_SECRET --value "..." --type SecureString
new SchedulerStack(app, 'WeCircleScheduler', {
  env: WECIRCLE_ENV,
  description: 'WeCircle EventBridge Scheduler — hourly overdue invoice check',
  albDnsName: compute.alb.loadBalancerDnsName,
});

// Tags applied to every resource across all stacks.
cdk.Tags.of(app).add('Project', 'WeCircle');
cdk.Tags.of(app).add('ManagedBy', 'CDK');
cdk.Tags.of(app).add('Environment', 'production');
