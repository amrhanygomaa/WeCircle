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
};
