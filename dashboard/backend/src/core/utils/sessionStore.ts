import { prisma } from "../../config/prisma";
import type { DeviceSession } from "@prisma/client";

export type { DeviceSession };

// ── Write ──────────────────────────────────────────────────────────────────

export async function addSession(
  session: Omit<DeviceSession, "createdAt" | "lastActiveAt">
): Promise<DeviceSession> {
  // Replace any existing session for the same entity + device (upsert by token)
  return prisma.deviceSession.upsert({
    where: { token: session.token },
    update: {
      isActive: true,
      deviceName: session.deviceName,
      location: session.location,
      ipAddress: session.ipAddress,
    },
    create: {
      id: session.id,
      token: session.token,
      credentialId: session.credentialId,
      schoolId: session.schoolId,
      parentId: session.parentId ?? null,
      teacherId: session.teacherId ?? null,
      driverId: session.driverId ?? null,
      studentId: session.studentId ?? null,
      deviceName: session.deviceName,
      location: session.location,
      ipAddress: session.ipAddress,
      isActive: session.isActive,
    },
  });
}

export async function updateSessionActivity(token: string): Promise<void> {
  await prisma.deviceSession.updateMany({
    where: { token },
    data: { lastActiveAt: new Date() },
  });
}

// ── Read ───────────────────────────────────────────────────────────────────

export async function isSessionActive(token: string): Promise<boolean> {
  const session = await prisma.deviceSession.findUnique({
    where: { token },
    select: { isActive: true },
  });
  return !!session?.isActive;
}

export async function getSessionByToken(
  token: string
): Promise<DeviceSession | null> {
  return prisma.deviceSession.findUnique({ where: { token } });
}

export async function getSessionsForParent(
  parentId: string
): Promise<DeviceSession[]> {
  return prisma.deviceSession.findMany({
    where: { parentId, isActive: true },
    orderBy: { lastActiveAt: "desc" },
  });
}

export async function getSessionsForTeacher(
  teacherId: string
): Promise<DeviceSession[]> {
  return prisma.deviceSession.findMany({
    where: { teacherId, isActive: true },
    orderBy: { lastActiveAt: "desc" },
  });
}

// ── Revoke ─────────────────────────────────────────────────────────────────

export async function revokeSession(
  sessionId: string,
  parentId: string
): Promise<boolean> {
  const { count } = await prisma.deviceSession.deleteMany({
    where: { id: sessionId, parentId },
  });
  return count > 0;
}

export async function revokeSessionForTeacher(
  sessionId: string,
  teacherId: string
): Promise<boolean> {
  const { count } = await prisma.deviceSession.deleteMany({
    where: { id: sessionId, teacherId },
  });
  return count > 0;
}

export async function revokeAllSessionsForParent(
  parentId: string,
  keepSessionId?: string
): Promise<void> {
  await prisma.deviceSession.deleteMany({
    where: {
      parentId,
      ...(keepSessionId ? { id: { not: keepSessionId } } : {}),
    },
  });
}

export async function revokeAllSessionsForTeacher(
  teacherId: string,
  keepSessionId?: string
): Promise<void> {
  await prisma.deviceSession.deleteMany({
    where: {
      teacherId,
      ...(keepSessionId ? { id: { not: keepSessionId } } : {}),
    },
  });
}
