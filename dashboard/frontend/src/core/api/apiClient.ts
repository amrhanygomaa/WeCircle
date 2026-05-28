import axios from "axios";
import { ENV } from "../config/env";
import { supabase } from "../../lib/supabase"; // Note: supabase auth abstraction later

export const api = axios.create({
  baseURL: ENV.API_URL,
});

// Attach Supabase auth token and disable browser caching to keep data 100% fresh
api.interceptors.request.use(async (config) => {
  const { data } = await supabase.auth.getSession();
  const token = data.session?.access_token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
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
