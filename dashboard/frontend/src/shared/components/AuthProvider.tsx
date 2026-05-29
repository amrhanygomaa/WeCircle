"use client";

import { createContext, useContext, useEffect, useState, useCallback, ReactNode } from "react";
import { useRouter } from "next/navigation";
import { userPool, isCognitoConfigured } from "@/core/auth/cognito";
import { api } from "@/core/api/apiClient";
import { connectSocket, disconnectSocket } from "@/core/realtime/socketClient";

type AuthUser = { id: string; email: string | undefined; fullName: string; schoolId?: string | null; role?: string; school?: any; avatarUrl?: string };

interface AuthContextType {
  user: AuthUser | null;
  loading: boolean;
  logout: (reason?: string) => void;
  refreshProfile: (preloadedData?: any) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  const logout = useCallback((reason?: string) => {
    const cognitoUser = userPool.getCurrentUser();
    if (cognitoUser) {
      cognitoUser.signOut();
    }
    setUser(null);
    disconnectSocket();
    if (reason) alert(reason);
    router.push("/login");
  }, [router]);

  const fetchProfile = useCallback(async (preloadedData?: any) => {
    try {
      let profileData;
      
      if (preloadedData) {
        // Use pre-loaded data (from cognito-sync) — no need to call /auth/me
        profileData = preloadedData;
      } else {
        // Fetch from backend — requires valid token in middleware
        const { data } = await api.get("/auth/me");
        if (!data.success) {
          setUser(null);
          throw new Error("Profile fetch returned unsuccessful response");
        }
        profileData = data.data;
      }

      const cognitoUser = userPool.getCurrentUser();
      let email = profileData.email;
      if (cognitoUser) {
        cognitoUser.getSession((err: any, session: any) => {
          if (!err && session.isValid()) {
            email = session.getIdToken().payload.email || profileData.email;
          }
        });
      }
      
      const userData: AuthUser = {
        id: profileData.id,
        email: email,
        fullName: profileData.fullName,
        schoolId: profileData.school?.id,
        role: profileData.role,
        school: profileData.school,
        avatarUrl: undefined
      };
      setUser(userData);
      connectSocket(userData.schoolId || null, userData.role || "USER", userData.id);
    } catch (err: any) {
      if (err.response?.status !== 401) {
        console.error("Failed to fetch profile:", err);
      }
      setUser(null);
      setLoading(false);
      throw err; // Re-throw so callers (login page) can handle the error
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (!isCognitoConfigured) {
      setLoading(false);
      return;
    }

    const cognitoUser = userPool.getCurrentUser();
    if (cognitoUser) {
      cognitoUser.getSession((err: any, session: any) => {
        if (err || !session.isValid()) {
          setLoading(false);
        } else {
          // Catch errors silently on initial load - not being logged in is normal
          fetchProfile().catch(() => {});
        }
      });
    } else {
      setLoading(false);
    }
    
    // We don't have an auth state change listener in raw Cognito JS SDK.
    // Auth changes are triggered via login/logout calls manually.
  }, [fetchProfile]);

  return (
    <AuthContext.Provider value={{ user, loading, logout, refreshProfile: fetchProfile }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
