#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { NetworkStack } from '../lib/stacks/network-stack';
import { DatabaseStack } from '../lib/stacks/database-stack';
import { WECIRCLE_ENV } from '../lib/config';

const app = new cdk.App();

// ── Stack 1: Networking ──────────────────────────────────────────────────────
// Deploys first. Creates the VPC, subnet tiers, NAT Gateway, and all security
// groups that downstream stacks reference.
const network = new NetworkStack(app, 'WeCircleNetwork', {
  env: WECIRCLE_ENV,
  description: 'WeCircle VPC, subnets, NAT Gateway, security groups',
});

// ── Stack 2: Database ────────────────────────────────────────────────────────
// Depends on NetworkStack. Creates RDS PostgreSQL 16, Multi-AZ, with
// auto-generated credentials stored in Secrets Manager.
new DatabaseStack(app, 'WeCircleDatabase', {
  env: WECIRCLE_ENV,
  description: 'WeCircle RDS PostgreSQL 16 — Multi-AZ, isolated subnet',
  vpc: network.vpc,
  rdsSg: network.rdsSg,
});

// Tags applied to every resource in every stack.
cdk.Tags.of(app).add('Project', 'WeCircle');
cdk.Tags.of(app).add('ManagedBy', 'CDK');
cdk.Tags.of(app).add('Environment', 'production');
