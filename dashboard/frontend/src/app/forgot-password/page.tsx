"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Mail, AlertCircle } from "lucide-react";
import { CognitoUser } from "amazon-cognito-identity-js";

import { userPool } from "@/core/auth/cognito";
import { useTranslation } from "@/core/i18n/i18n";
import { AuthShell } from "@/modules/auth/components/AuthShell";

const forgotSchema = z.object({
  email: z.string().email(),
});

export default function ForgotPasswordPage() {
  const { t } = useTranslation();
  const router = useRouter();
  
  const [emailError, setEmailError] = useState("");
  const [generalError, setGeneralError] = useState("");
  const [success, setSuccess] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const form = useForm<z.infer<typeof forgotSchema>>({
    resolver: zodResolver(forgotSchema),
    defaultValues: { email: "" }
  });

  const onSubmit = form.handleSubmit(async (values) => {
    setEmailError("");
    setGeneralError("");
    setIsLoading(true);

    try {
      const cognitoUser = new CognitoUser({
        Username: values.email,
        Pool: userPool,
      });

      cognitoUser.forgotPassword({
        onSuccess: function (data) {
          setSuccess(true);
          setIsLoading(false);
          // Redirect to a password reset confirm page in a real app, or ask for code here
        },
        onFailure: function (err) {
          setGeneralError(err.message || "Failed to send reset email.");
          setIsLoading(false);
        },
      });
    } catch (err: unknown) {
      setGeneralError("An unexpected error occurred.");
      setIsLoading(false);
    }
  });

  return (
    <AuthShell variant="login" title={t('auth_forgot_title')} subtitle={t('auth_forgot_subtitle')}>
      <div style={{ position: "relative" }}>
        {success ? (
          <div className="glass-panel" style={{ padding: "24px", textAlign: "center" }}>
            <div style={{ width: 56, height: 56, borderRadius: '50%', background: 'rgba(34, 197, 94, 0.2)', color: '#22c55e', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <Mail size={28} />
            </div>
            <h3 style={{ fontSize: "18px", fontWeight: 700, color: "#fff", marginBottom: "8px" }}>
              {t('auth_check_email')}
            </h3>
            <p style={{ color: "rgba(255,255,255,0.7)", fontSize: "14px", lineHeight: 1.5, marginBottom: "24px" }}>
              {t('auth_check_email_desc')}
            </p>
            <Link href="/login" className="btn-glass-secondary" style={{ display: "block", textDecoration: "none", textAlign: "center" }}>
              {t('auth_back_login')}
            </Link>
          </div>
        ) : (
          <form onSubmit={onSubmit}>
            <div className="glass-input-group" style={{ marginBottom: "32px" }}>
              <label>{t('field_email_recover')}</label>
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

            {generalError && <p className="error error-shake" style={{ marginBottom: "16px" }}>{generalError}</p>}

            <button type="submit" className="btn-glass-primary" disabled={isLoading}>
              {isLoading ? t('auth_btn_loading') : t('btn_send_link')}
            </button>

            <Link href="/login" className="btn-glass-secondary" style={{ display: "block", textDecoration: "none", textAlign: "center", marginTop: "16px" }}>
              {t('auth_back_login')}
            </Link>
          </form>
        )}
      </div>
    </AuthShell>
  );
}
