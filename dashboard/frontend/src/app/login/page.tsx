"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Mail, AlertCircle } from "lucide-react";
import { AuthenticationDetails, CognitoUser } from "amazon-cognito-identity-js";

import { api, extractApiError } from "@/core/api/apiClient";
import { userPool } from "@/core/auth/cognito";
import { useTranslation } from "@/core/i18n/i18n";
import { AuthShell } from "@/modules/auth/components/AuthShell";
import { GlassPasswordInput } from "@/modules/auth/components/GlassPasswordInput";
import { useAuth } from "@/shared/components/AuthProvider";

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  rememberMe: z.boolean().optional()
});

const GoogleIcon = () => (
  <svg viewBox="0 0 24 24" width="20" height="20"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4" /><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" /><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" /><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" /></svg>
);

export default function LoginPage() {
  const { t } = useTranslation();
  const router = useRouter();
  const { refreshProfile } = useAuth();
  const [emailError, setEmailError] = useState("");
  const [passwordError, setPasswordError] = useState("");
  const [generalError, setGeneralError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  
  const [rememberedEmail, setRememberedEmail] = useState("");

  useEffect(() => {
    const saved = localStorage.getItem('edu_remembered_email') || "";
    setRememberedEmail(saved);
  }, []);
  
  const form = useForm<z.infer<typeof loginSchema>>({
    resolver: zodResolver(loginSchema),
    defaultValues: { 
      email: rememberedEmail,
      rememberMe: !!rememberedEmail 
    }
  });

  useEffect(() => {
    if (rememberedEmail) {
      form.setValue("email", rememberedEmail);
      form.setValue("rememberMe", true);
    }
  }, [rememberedEmail, form]);

  const onSubmit = form.handleSubmit(async (values) => {
    setEmailError("");
    setPasswordError("");
    setGeneralError("");
    setIsLoading(true);

    if (values.rememberMe) {
      localStorage.setItem('edu_remembered_email', values.email);
    } else {
      localStorage.removeItem('edu_remembered_email');
    }

    try {
      const authenticationDetails = new AuthenticationDetails({
        Username: values.email,
        Password: values.password,
      });

      const cognitoUser = new CognitoUser({
        Username: values.email,
        Pool: userPool,
      });

      cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: async (result) => {
          // Tell our auth provider to load profile data based on this token
          await refreshProfile();
          router.push("/dashboard");
        },
        onFailure: (err) => {
          setIsLoading(false);
          setGeneralError(err.message || "Invalid credentials");
        }
      });
    } catch (err: unknown) {
      setGeneralError("An error occurred during sign in.");
      setIsLoading(false);
    }
  });

  return (
    <AuthShell variant="login" title={t('auth_login_title')} subtitle={t('auth_login_subtitle')}>
      <div style={{ position: "relative" }}>
        
        <form onSubmit={onSubmit}>
          <div className="glass-input-group">
            <label>{t('field_email')}</label>
            <div className="glass-input-wrapper">
              <Mail className="glass-input-icon" size={18} />
              <input placeholder="name@email.com" {...form.register("email")} />
            </div>
            {emailError && (
              <div className="field-error-inline error-shake">
                <AlertCircle size={14} />
                <span>{emailError}</span>
              </div>
            )}
          </div>

          <div className="glass-input-group">
            <label>{t('field_password')}</label>
            <GlassPasswordInput placeholder="••••••••" {...form.register("password")}  />
            {passwordError && (
              <div className="field-error-inline error-shake">
                <AlertCircle size={14} />
                <span>{passwordError}</span>
              </div>
            )}
          </div>

          <div className="remember-row" style={{ marginBottom: "24px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <label className="checkbox-row" style={{ color: "rgba(255,255,255,0.7)", display: "flex", alignItems: "center", gap: "8px" }}>
              <input type="checkbox" {...form.register("rememberMe")} />
              {t('btn_remember')}
            </label>
            <Link className="glass-link" style={{ fontSize: "14px" }} href="/forgot-password">{t('btn_forgot')}</Link>
          </div>

          {generalError && <p className="error error-shake" style={{ marginBottom: "16px" }}>{generalError}</p>}
          
          <button type="submit" className="btn-glass-primary" disabled={isLoading}>
            {isLoading ? t('btn_authorizing') : t('btn_authorize')}
          </button>
        </form>

        <p className="auth-bottom" style={{ color: "rgba(255,255,255,0.5)", marginTop: "24px", textAlign: "center" }}>
          {t('btn_no_account')} <Link className="glass-link" href="/register" style={{ fontWeight: 700, color: "#fff" }}>{t('btn_signup')}</Link>
        </p>
      </div>
    </AuthShell>
  );
}
