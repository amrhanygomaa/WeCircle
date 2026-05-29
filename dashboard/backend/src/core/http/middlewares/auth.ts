import type { NextFunction, Request, Response } from "express";
import { prisma } from "../config/prisma";
import { env } from "../config/env";
import jwt from "jsonwebtoken";
import { CognitoJwtVerifier } from "aws-jwt-verify";

const verifier = CognitoJwtVerifier.create({
  userPoolId: env.cognitoUserPoolId || process.env.COGNITO_USER_POOL_ID || "",
  tokenUse: "id",
  clientId: env.cognitoClientId || process.env.COGNITO_CLIENT_ID || "",
});

export async function requireAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith("Bearer ") ? authHeader.split(" ")[1] : null;

  if (!token) {
    res.status(401).json({ success: false, message: "Missing token" });
    return;
  }

  try {
    try {
      // 1. Try to verify the token as a custom AppCredential JWT token first
      const decoded = jwt.verify(token, env.jwtSecret || "secret") as any;
      if (decoded && decoded.id) {
        req.user = {
          id: decoded.id,
          cognitoId: "", // Custom credentials users do not have a Cognito native record
          email: decoded.loginId || "",
          role: decoded.role,
          schoolId: decoded.schoolId || null
        };
        req.userId = decoded.id;
        if (decoded.schoolId) req.schoolId = decoded.schoolId;
        
        // Attach role-specific IDs
        if (decoded.teacherId) (req as any).teacherId = decoded.teacherId;
        if (decoded.parentId) (req as any).parentId = decoded.parentId;
        if (decoded.studentId) (req as any).studentId = decoded.studentId;
        if (decoded.driverId) (req as any).driverId = decoded.driverId;
        if (decoded.supervisorId) (req as any).supervisorId = decoded.supervisorId;
        
        next();
        return;
      }
    } catch (jwtErr) {
      // Not a valid custom JWT, fall through to Cognito token verification
    }

    // 2. Fallback to Cognito User Token
    let cognitoPayload;
    try {
      cognitoPayload = await verifier.verify(token);
    } catch (cognitoErr: any) {
      console.error("Cognito Auth Error:", cognitoErr?.message);
      res.status(401).json({ success: false, message: "Unauthorized: Invalid or expired token" });
      return;
    }

    const email = cognitoPayload.email as string;
    if (!email) {
      res.status(401).json({ success: false, message: "Invalid token: Email missing" });
      return;
    }

    const dbUser = await prisma.user.findUnique({ 
      where: { email },
      include: {
        teacher: true,
        parent: true,
        student: true,
        driver: true,
        supervisor: true,
      }
    });
    
    if (!dbUser) {
      res.status(401).json({ success: false, message: "User not found in local database. Please sync your account." });
      return;
    }

    req.user = {
      id: dbUser.id,
      cognitoId: cognitoPayload.sub,
      email,
      role: dbUser.role,
      schoolId: dbUser.schoolId
    };
    req.userId = dbUser.id;
    if (dbUser.schoolId) {
      req.schoolId = dbUser.schoolId;
    }

    // Attach role-specific IDs from database relations
    if (dbUser.teacher) (req as any).teacherId = dbUser.teacher.id;
    if (dbUser.parent) (req as any).parentId = dbUser.parent.id;
    if (dbUser.student) (req as any).studentId = dbUser.student.id;
    if (dbUser.driver) (req as any).driverId = dbUser.driver.id;
    if (dbUser.supervisor) (req as any).supervisorId = dbUser.supervisor.id;

    next();
  } catch (err) {
    console.error("Middleware Error:", err);
    res.status(401).json({ success: false, message: "Unauthorized: System authentication error" });
  }
}

// Alias for convenience
export const auth = requireAuth;
