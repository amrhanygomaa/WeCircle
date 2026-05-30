#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { NetworkStack } from '../lib/stacks/network-stack';
import { DatabaseStack } from '../lib/stacks/database-stack';
import { ComputeStack } from '../lib/stacks/compute-stack';
import { WECIRCLE_ENV } from '../lib/config';

const app = new cdk.App();

// ── Stack 1: Networking ──────────────────────────────────────────────────────
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
// ECR, ECS Fargate service, ALB, auto-scaling, GitHub OIDC deploy role.
// Optional HTTPS: pass -c certificateArn=arn:aws:acm:us-east-1:... to cdk deploy.
new ComputeStack(app, 'WeCircleCompute', {
  env: WECIRCLE_ENV,
  description: 'WeCircle ECS Fargate, ALB, ECR, GitHub OIDC deploy role',
  vpc: network.vpc,
  albSg: network.albSg,
  backendSg: network.backendSg,
  dbSecret: database.instance.secret!,
});

// Tags applied to every resource in every stack.
cdk.Tags.of(app).add('Project', 'WeCircle');
cdk.Tags.of(app).add('ManagedBy', 'CDK');
cdk.Tags.of(app).add('Environment', 'production');
