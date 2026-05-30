import type { Environment } from 'aws-cdk-lib';

export const REGION = 'us-east-1';

// Account is resolved at synthesis time from the CDK bootstrap context.
// Pass --profile <name> or set AWS_PROFILE / CDK_DEFAULT_ACCOUNT.
export const WECIRCLE_ENV: Environment = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: REGION,
};

export const DB_CONFIG = {
  name: 'wecircle',
  port: 5432,
  // Start with t3.small; snapshot-restore to a larger class if needed.
  // Multi-AZ doubles RDS cost — set to false only for non-prod.
  multiAz: true,
  allocatedStorageGiB: 20,
  maxAllocatedStorageGiB: 100, // auto-scales in place, no downtime
  backupRetentionDays: 7,
};
