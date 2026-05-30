import type { Environment } from 'aws-cdk-lib';

export const REGION = 'us-east-1';

// Production account — PINNED on purpose. WeCircle lives in 035611741710 only.
// Hard-pinning the account makes CDK refuse to synth/deploy if the active AWS
// profile points anywhere else (e.g. the wrong 204758922338 account that once
// leaked into cdk.context.json), instead of silently deploying to the wrong place.
export const ACCOUNT = '035611741710';

export const WECIRCLE_ENV: Environment = {
  account: ACCOUNT,
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
