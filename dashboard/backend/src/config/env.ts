import dotenv from "dotenv";

dotenv.config();

const requireEnv = (name: string, fallback?: string): string => {
  const value = process.env[name] || fallback;
  if (!value && process.env.NODE_ENV !== "development") {
    throw new Error(`Missing critical environment variable: ${name}`);
  }
  return value || "";
};

export const env = {
  port: Number(process.env.PORT || 5001),
  nodeEnv: process.env.NODE_ENV || "development",
  allowedOrigins: [
    process.env.FRONTEND_URL || "http://localhost:3000",
    "http://wecircle-frontend-035611741710.s3-website-us-east-1.amazonaws.com",
    "https://wecircle.helpers-tech.com",
    "http://wecircle.helpers-tech.com",
    "http://52.90.177.139",
    "http://52.90.177.139:3000"
  ],
  jwtSecret: requireEnv("JWT_SECRET", process.env.SUPABASE_JWT_SECRET || "default-fallback-jwt-secret-key-wecircle"),
  databaseUrl: requireEnv("DATABASE_URL"),
  superAdminEmail: requireEnv("SUPER_ADMIN_EMAIL"),
  cognitoUserPoolId: requireEnv("COGNITO_USER_POOL_ID", "us-east-1_IvG7IexJJ"),
  cognitoClientId: requireEnv("COGNITO_CLIENT_ID", "2meppogljnsldj9iivqf6d1p02"),
  awsRegion: requireEnv("AWS_REGION", "us-east-1"),
  awsS3BucketName: requireEnv("AWS_S3_BUCKET_NAME", "local"),
};
