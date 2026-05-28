export const ENV = {
  API_URL: process.env.NEXT_PUBLIC_API_URL,
  APP_NAME: process.env.NEXT_PUBLIC_APP_NAME || "WeCircle",
  APP_URL: process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000",
};

if (!ENV.API_URL) {
  throw new Error(
    "Missing NEXT_PUBLIC_API_URL environment variable. Please define it in your .env.local file. Example: NEXT_PUBLIC_API_URL=http://localhost:5001/api"
  );
}
