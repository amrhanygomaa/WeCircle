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
  refreshProfile: () => Promise<void>;
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

  const fetchProfile = useCallback(async () => {
    try {
      const { data } = await api.get("/auth/me");
      if (data.success) {
        const cognitoUser = userPool.getCurrentUser();
        let email = data.data.email;
        if (cognitoUser) {
          cognitoUser.getSession((err: any, session: any) => {
            if (!err && session.isValid()) {
              email = session.getIdToken().payload.email || data.data.email;
            }
          });
        }
        
        const userData: AuthUser = {
          id: data.data.id,
          email: email,
          fullName: data.data.fullName,
          schoolId: data.data.school?.id,
          role: data.data.role,
          school: data.data.school,
          avatarUrl: undefined
        };
        setUser(userData);
        connectSocket(userData.schoolId || null, userData.role || "USER", userData.id);
      }
    } catch (err: any) {
      if (err.response?.status !== 401) {
        console.error("Failed to fetch profile:", err);
      }
      setUser(null);
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
          fetchProfile();
        }
      });
    } else {
      setLoading(false);
    }
    
    // We don't have an auth state change listener in raw Cognito JS SDK like Supabase.
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
