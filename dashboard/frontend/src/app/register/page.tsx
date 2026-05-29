"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { User, Mail, AlertCircle, Phone } from "lucide-react";
import { CognitoUserAttribute } from "amazon-cognito-identity-js";

import { api, extractApiError } from "@/core/api/apiClient";
import { userPool } from "@/core/auth/cognito";
import { useTranslation } from "@/core/i18n/i18n";
import { AuthShell } from "@/modules/auth/components/AuthShell";
import { GlassPasswordInput } from "@/modules/auth/components/GlassPasswordInput";

const registerSchema = z.object({
  fullName: z.string().min(3),
  email: z.string().email(),
  phone: z.string().optional(),
  password: z.string().min(6),
  confirmPassword: z.string().min(6)
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
});

export default function RegisterPage() {
  const { t } = useTranslation();
  const router = useRouter();
  
  const [generalError, setGeneralError] = useState("");
  const [successMsg, setSuccessMsg] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  
  const form = useForm<z.infer<typeof registerSchema>>({
    resolver: zodResolver(registerSchema),
    defaultValues: { fullName: "", email: "", phone: "", password: "", confirmPassword: "" }
  });

  const onSubmit = form.handleSubmit(async (values) => {
    setGeneralError("");
    setSuccessMsg("");
    setIsLoading(true);

    try {
      const attributeList = [
        new CognitoUserAttribute({ Name: 'email', Value: values.email }),
        new CognitoUserAttribute({ Name: 'role', Value: 'PARENT' }), // Default for self-signup
      ];

      userPool.signUp(values.email, values.password, attributeList, [], async (err, result) => {
        if (err) {
          setIsLoading(false);
          setGeneralError(err.message || "Registration failed");
          return;
        }
        
        // Notify backend about the new user
        try {
          await api.post("/auth/register", {
            fullName: values.fullName,
            email: values.email,
            phone: values.phone,
            password: values.password
          });
          setSuccessMsg("Registration successful! Please check your email to verify your account or login directly.");
          setTimeout(() => router.push("/login"), 3000);
        } catch (backendErr) {
          setGeneralError("Registered in Auth provider but failed to sync with database.");
        }
        setIsLoading(false);
      });
      
    } catch (err: unknown) {
      setGeneralError("An unexpected error occurred.");
      setIsLoading(false);
    }
  });

  return (
    <AuthShell variant="register" title={t('' as any)} subtitle={t('' as any)}>
      <div style={{ position: "relative" }}>
        
        <form onSubmit={onSubmit}>
          <div className="glass-input-group">
            <label>{t('' as any)}</label>
            <div className="glass-input-wrapper">
              <User className="glass-input-icon" size={18} />
              <input placeholder="John Doe" {...form.register("fullName")} />
            </div>
            {form.formState.errors.fullName && (
              <div className="field-error-inline error-shake">
                <AlertCircle size={14} />
                <span>{form.formState.errors.fullName.message}</span>
              </div>
            )}
          </div>

          <div className="glass-input-group">
            <label>{t('' as any)}</label>
            <div className="glass-input-wrapper">
              <Mail className="glass-input-icon" size={18} />
              <input placeholder="name@email.com" {...form.register("email")} />
            </div>
            {form.formState.errors.email && (
              <div className="field-error-inline error-shake">
                <AlertCircle size={14} />
                <span>{form.formState.errors.email.message}</span>
              </div>
            )}
          </div>

          <div className="glass-input-group">
            <label>{t('' as any)} (Optional)</label>
            <div className="glass-input-wrapper">
              <Phone className="glass-input-icon" size={18} />
              <input placeholder="+1234567890" {...form.register("phone")} />
            </div>
          </div>

          <div className="glass-input-group">
            <label>{t('' as any)}</label>
            <GlassPasswordInput placeholder="••••••••" {...form.register("password")}  />
            {form.formState.errors.password && (
              <div className="field-error-inline error-shake">
                <AlertCircle size={14} />
                <span>{form.formState.errors.password.message}</span>
              </div>
            )}
          </div>

          <div className="glass-input-group" style={{ marginBottom: "24px" }}>
            <label>{t('' as any)}</label>
            <GlassPasswordInput placeholder="••••••••" {...form.register("confirmPassword")}  />
            {form.formState.errors.confirmPassword && (
              <div className="field-error-inline error-shake">
                <AlertCircle size={14} />
                <span>{form.formState.errors.confirmPassword.message}</span>
              </div>
            )}
          </div>

          {generalError && <p className="error error-shake" style={{ marginBottom: "16px" }}>{generalError}</p>}
          {successMsg && <p style={{ color: "#22c55e", marginBottom: "16px", fontSize: "14px", background: "rgba(34, 197, 94, 0.1)", padding: "12px", borderRadius: "8px", border: "1px solid rgba(34, 197, 94, 0.3)" }}>{successMsg}</p>}
          
          <button type="submit" className="btn-glass-primary" disabled={isLoading}>
            {isLoading ? t('' as any) : t('' as any)}
          </button>
        </form>

        <p className="auth-bottom" style={{ color: "rgba(255,255,255,0.5)", marginTop: "24px", textAlign: "center" }}>
          {t('' as any)} <Link className="glass-link" href="/login" style={{ fontWeight: 700, color: "#fff" }}>{t('' as any)}</Link>
        </p>
      </div>
    </AuthShell>
  );
}
