import type { NextFunction, Request, Response } from "express";
import { ForbiddenError } from "../../utils/AppError";

/**
 * Tenant scoping middleware.
 * 
 * Must run AFTER requireAuth. Extracts schoolId from the authenticated
 * user and attaches it to req.schoolId for all downstream controllers.
 * 
 * SUPER_ADMIN users bypass this check and can access all schools.
 * Regular users without a schoolId are rejected.
 */
export function tenantScope(req: Request, _res: Response, next: NextFunction): void {
  const user = req.user;

  if (!user) {
    throw new ForbiddenError("Authentication required before tenant scoping.");
  }

  // SUPER_ADMIN can see everything — but if they have a schoolId or pass one in headers/query, use it
  if (user.role === "SUPER_ADMIN") {
    const headerSchoolId = req.headers["x-school-id"] as string;
    const querySchoolId = req.query.schoolId as string;
    req.schoolId = headerSchoolId || querySchoolId || user.schoolId || null;
    return next();
  }

  // Regular users must have a schoolId
  if (!user.schoolId) {
    throw new ForbiddenError("Your account is not associated with any school. Please contact support.");
  }

  req.schoolId = user.schoolId;
  next();
}

