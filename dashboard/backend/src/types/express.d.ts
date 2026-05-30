import { Role } from "@prisma/client";

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        cognitoId: string;
        email: string;
        role: Role;
        schoolId: string | null;
      };
      /** Shortcut to req.user.id — set by auth middleware */
      userId?: string;
      /** Set by tenantScope middleware. null = SUPER_ADMIN (all schools). */
      schoolId: string | null;
      // ── Mobile entity IDs set by requireMobileAuth / requireAuth ──────────
      /** AppCredential ID of the authenticated mobile user */
      credentialId?: string;
      /** Student.id when the authenticated credential belongs to a student */
      studentId?: string;
      /** Teacher.id when the authenticated credential belongs to a teacher */
      teacherId?: string;
      /** Parent.id when the authenticated credential belongs to a parent */
      parentId?: string;
      /** Driver.id when the authenticated credential belongs to a driver */
      driverId?: string;
      /** BusSupervisor.id when the authenticated credential belongs to a supervisor */
      supervisorId?: string;
      /** Raw JWT token string (set by requireMobileAuth) */
      token?: string;
    }
  }
}

export {};
