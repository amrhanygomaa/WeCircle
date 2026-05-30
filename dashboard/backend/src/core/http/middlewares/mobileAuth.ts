import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { env } from "../../../config/env";
import { isSessionActive, updateSessionActivity } from "../../utils/sessionStore";

export interface MobileRequestUser {
  id: string; // AppCredential.id
  loginId: string;
  role: "STUDENT" | "TEACHER" | "PARENT" | "DRIVER";
  schoolId: string;
  parentId?: string | null;
  studentId?: string | null;
  teacherId?: string | null;
  driverId?: string | null;
}

export async function requireMobileAuth(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith("Bearer ") ? authHeader.split(" ")[1] : null;

  if (!token) {
    res.status(401).json({ success: false, message: "Authentication token missing" });
    return;
  }

  try {
    const decoded = jwt.verify(token, env.jwtSecret) as MobileRequestUser;

    // Verify the device session is still active for PARENT and TEACHER roles
    if (
      (decoded.role === "PARENT" && decoded.parentId) ||
      (decoded.role === "TEACHER" && decoded.teacherId)
    ) {
      if (!(await isSessionActive(token))) {
        res.status(401).json({ success: false, message: "Unauthorized: Session has been terminated or revoked" });
        return;
      }
      // Fire-and-forget: update last-active timestamp without blocking the request
      updateSessionActivity(token).catch(() => {});
    }

    req.user = {
      id: decoded.id,
      email: decoded.loginId,
      role: decoded.role as any,
      schoolId: decoded.schoolId,
      cognitoId: decoded.id,
    };
    req.userId = decoded.id;
    req.schoolId = decoded.schoolId;
    req.parentId  = decoded.parentId  ?? undefined;
    req.studentId = decoded.studentId ?? undefined;
    req.teacherId = decoded.teacherId ?? undefined;
    req.driverId  = decoded.driverId  ?? undefined;
    req.token     = token;

    next();
  } catch (err) {
    console.error("Mobile Auth Error:", err);
    res.status(401).json({ success: false, message: "Unauthorized: Invalid or expired token" });
  }
}

