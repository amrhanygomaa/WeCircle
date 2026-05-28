import type { Metadata } from "next";
import "./globals.css";
import QueryProvider from "@/shared/components/QueryProvider";
import { AuthProvider } from "@/shared/components/AuthProvider";

import { DirManager } from "@/shared/components/DirManager";

export const metadata: Metadata = {
  title: "School Management",
  description: "Next-generation school management platform for modern educational institutions.",
  icons: {
    icon: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body suppressHydrationWarning>
        <QueryProvider>
          <AuthProvider>
            <DirManager />
            {children}
          </AuthProvider>
        </QueryProvider>
      </body>
    </html>
  );
}
