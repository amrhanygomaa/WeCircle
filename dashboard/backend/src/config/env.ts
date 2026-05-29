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
    "http://wecircle-frontend-035611741710.s3-website-us-east-1.amazonaws.com"
  ],
  supabaseUrl: requireEnv("SUPABASE_URL"),
  supabaseAnonKey: requireEnv("SUPABASE_ANON_KEY"),
  supabaseServiceRoleKey: requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
  supabaseJwtSecret: requireEnv("SUPABASE_JWT_SECRET"),
  databaseUrl: requireEnv("DATABASE_URL"),
  superAdminEmail: requireEnv("SUPER_ADMIN_EMAIL"),
  cognitoUserPoolId: requireEnv("COGNITO_USER_POOL_ID", "local"),
  cognitoClientId: requireEnv("COGNITO_CLIENT_ID", "local"),
  awsRegion: requireEnv("AWS_REGION", "us-east-1"),
  awsS3BucketName: requireEnv("AWS_S3_BUCKET_NAME", "local"),
};
