import axios, { InternalAxiosRequestConfig } from "axios";
import { ENV } from "../config/env";
import { userPool } from "../auth/cognito";

export const api = axios.create({
  baseURL: ENV.API_URL,
});

// Attach Cognito auth token and disable browser caching to keep data 100% fresh
api.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
  const cognitoUser = userPool.getCurrentUser();
  if (cognitoUser) {
    const token = await new Promise<string | null>((resolve) => {
      cognitoUser.getSession((err: any, session: any) => {
        if (err || !session.isValid()) {
          resolve(null);
        } else {
          resolve(session.getIdToken().getJwtToken());
        }
      });
    });

    if (token) {
      config.headers.Authorization = "Bearer "; // Remove quotes later
      // Quick fix for quotes:
      config.headers.Authorization = "Bearer " + token;
    }
  }

  // Prevent browser caching on localhost during development/navigation
  config.headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
  config.headers["Pragma"] = "no-cache";
  config.headers["Expires"] = "0";

  return config;
});

/**
 * Structured error returned by the backend.
 */
export interface ApiError {
  success: false;
  code: string;
  message: string;
  field?: string;
  errors?: Array<{ field: string; message: string }>;
}

/**
 * Extract a structured error from an Axios error response.
 */
export function extractApiError(error: unknown): ApiError {
  if (axios.isAxiosError(error) && error.response?.data) {
    return error.response.data as ApiError;
  }
  return {
    success: false,
    code: "UNKNOWN",
    message: error instanceof Error ? error.message : "An unexpected error occurred."
  };
}

export async function uploadToS3(file: File, folder: string = "uploads"): Promise<string> {
  const presignRes = await api.get('/storage/presign', { params: { fileName: file.name, fileType: file.type, folder } });
  const { presignedUrl, publicUrl } = presignRes.data;
  await axios.put(presignedUrl, file, { headers: { 'Content-Type': file.type } });
  return publicUrl;
}
