"use client";

import React, { useState, useEffect, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Mail, AlertCircle, KeyRound, CheckCircle2 } from "lucide-react";
import { CognitoUser } from "amazon-cognito-identity-js";

import { userPool } from "@/core/auth/cognito";
import { useTranslation } from "@/core/i18n/i18n";
import { AuthShell } from "@/modules/auth/components/AuthShell";

const verifySchema = z.object({
  email: z.string().email("Please enter a valid email address."),
  code: z.string().min(4, "Code must be at least 4 characters."),
});

function VerifyForm() {
  const { t } = useTranslation();
  const router = useRouter();
  const searchParams = useSearchParams();
  
  const [generalError, setGeneralError] = useState("");
  const [successMsg, setSuccessMsg] = useState("");
  const [resendMsg, setResendMsg] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isResending, setIsResending] = useState(false);

  const form = useForm<z.infer<typeof verifySchema>>({
    resolver: zodResolver(verifySchema),
    defaultValues: { email: "", code: "" }
  });

  useEffect(() => {
    const emailParam = searchParams.get("email");
    if (emailParam) {
      form.setValue("email", emailParam);
    }
  }, [searchParams, form]);

  const onSubmit = form.handleSubmit(async (values) => {
    setGeneralError("");
    setSuccessMsg("");
    setResendMsg("");
    setIsLoading(true);

    try {
      const cognitoUser = new CognitoUser({
        Username: values.email,
        Pool: userPool,
      });

      cognitoUser.confirmRegistration(values.code, true, (err, result) => {
        setIsLoading(false);
        if (err) {
          setGeneralError(err.message || "Verification failed");
          return;
        }
        setSuccessMsg(t('auth_verification_success' as any));
        setTimeout(() => router.push("/login"), 3000);
      });
    } catch (err: unknown) {
      setGeneralError("An unexpected error occurred.");
      setIsLoading(false);
    }
  });

  const handleResend = async () => {
    const email = form.getValues("email");
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setGeneralError("Please enter a valid email address first to resend the code.");
      return;
    }

    setGeneralError("");
    setSuccessMsg("");
    setResendMsg("");
    setIsResending(true);

    try {
      const cognitoUser = new CognitoUser({
        Username: email,
        Pool: userPool,
      });

      cognitoUser.resendConfirmationCode((err, result) => {
        setIsResending(false);
        if (err) {
          setGeneralError(err.message || "Failed to resend code");
          return;
        }
        setResendMsg(t('auth_code_resent' as any));
      });
    } catch (err: unknown) {
      setGeneralError("An unexpected error occurred.");
      setIsResending(false);
    }
  };

  return (
    <form onSubmit={onSubmit}>
      <div className="glass-input-group">
        <label>{t('field_email' as any)}</label>
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

      <div className="glass-input-group" style={{ marginBottom: "24px" }}>
        <label>{t('field_verification_code' as any)}</label>
        <div className="glass-input-wrapper">
          <KeyRound className="glass-input-icon" size={18} />
          <input placeholder="123456" {...form.register("code")} />
        </div>
        {form.formState.errors.code && (
          <div className="field-error-inline error-shake">
            <AlertCircle size={14} />
            <span>{form.formState.errors.code.message}</span>
          </div>
        )}
      </div>

      {generalError && <p className="error error-shake" style={{ marginBottom: "16px" }}>{generalError}</p>}
      {successMsg && (
        <div style={{ color: "#22c55e", marginBottom: "16px", fontSize: "14px", background: "rgba(34, 197, 94, 0.1)", padding: "12px", borderRadius: "8px", border: "1px solid rgba(34, 197, 94, 0.3)", display: "flex", gap: "8px", alignItems: "center" }}>
          <CheckCircle2 size={16} />
          <span>{successMsg}</span>
        </div>
      )}
      {resendMsg && (
        <div style={{ color: "#3b82f6", marginBottom: "16px", fontSize: "14px", background: "rgba(59, 130, 246, 0.1)", padding: "12px", borderRadius: "8px", border: "1px solid rgba(59, 130, 246, 0.3)" }}>
          {resendMsg}
        </div>
      )}

      <button type="submit" className="btn-glass-primary" disabled={isLoading || isResending}>
        {isLoading ? t('auth_btn_loading' as any) : t('auth_btn_verify' as any)}
      </button>

      <button type="button" className="btn-glass-secondary" onClick={handleResend} disabled={isLoading || isResending} style={{ width: "100%", marginTop: "12px" }}>
        {isResending ? t('auth_btn_loading' as any) : t('auth_resend_code' as any)}
      </button>
    </form>
  );
}

export default function VerifyPage() {
  const { t } = useTranslation();
  return (
    <AuthShell variant="login" title={t('auth_verify_title' as any)} subtitle={t('auth_verify_subtitle' as any)}>
      <div style={{ position: "relative" }}>
        <Suspense fallback={<div style={{ color: "rgba(255,255,255,0.7)", textAlign: "center", padding: "20px" }}>Loading verification form...</div>}>
          <VerifyForm />
        </Suspense>

        <p className="auth-bottom" style={{ color: "rgba(255,255,255,0.5)", marginTop: "24px", textAlign: "center" }}>
          {t('auth_have_account' as any)} <Link className="glass-link" href="/login" style={{ fontWeight: 700, color: "#fff" }}>{t('nav_signin' as any)}</Link>
        </p>
      </div>
    </AuthShell>
  );
}
