import dotenv from "dotenv";

dotenv.config();

const requireEnv = (name: string, fallback?: string): string => {
  const value = process.env[name] || fallback;
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}. Add it to your .env file.`);
  }
  return value;
};

export const env = {
  port: Number(process.env.PORT || 5001),
  nodeEnv: process.env.NODE_ENV || "development",
  allowedOrigins: (process.env.ALLOWED_ORIGINS || process.env.FRONTEND_URL || "http://localhost:3000")
    .split(",")
    .map(o => o.trim())
    .filter(Boolean),
  jwtSecret: requireEnv("JWT_SECRET"),
  databaseUrl: requireEnv("DATABASE_URL"),
  superAdminEmail: requireEnv("SUPER_ADMIN_EMAIL"),
  cognitoUserPoolId: requireEnv("COGNITO_USER_POOL_ID"),
  cognitoClientId: requireEnv("COGNITO_CLIENT_ID"),
  awsRegion: requireEnv("AWS_REGION", "us-east-1"),
  awsS3BucketName: requireEnv("AWS_S3_BUCKET_NAME", "local"),
  // Optional — when set, the Socket.IO Redis adapter is enabled.
  // Injected by ECS task definition after WeCircleCache is deployed.
  redisUrl: process.env.REDIS_URL || null,
  // Optional — shared secret for the internal EventBridge cron endpoint.
  cronSecret: process.env.CRON_SECRET || null,
  // When true (default on a single instance), the overdue-invoice checker runs in-process
  // on an hourly interval. Set DISABLE_INPROCESS_CRON=true once an external scheduler
  // (EventBridge → /api/internal/cron/check-overdue) takes over, to avoid double-running.
  inProcessCron: process.env.DISABLE_INPROCESS_CRON !== "true",
  // Bedrock model for the AI assistant (Converse API + tool use). Override via BEDROCK_MODEL_ID.
  // Default: Amazon Nova Lite — on-demand in us-east-1, cheap, supports tool use.
  // For higher-quality Arabic, switch to "us.anthropic.claude-3-5-haiku-20241022-v1:0"
  // (requires enabling Anthropic model access + the cross-region inference profile).
  bedrockModelId: process.env.BEDROCK_MODEL_ID || "amazon.nova-lite-v1:0",
};
