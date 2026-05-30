import { Request, Response } from "express";
import { prisma } from "../../config/prisma";
import { asyncHandler } from "../../core/utils/asyncHandler";
import { z } from "zod";
import { getIO } from "../../config/websocket";
import { ValidationError, NotFoundError } from "../../core/utils/AppError";
import { requireSid } from "../../core/utils/tenant";

// ── Entity resolution ──────────────────────────────────────────────────────

/** Returns the polymorphic participant ID: Parent.id, Teacher.id, or User.id. */
async function resolveEntityId(userId: string, role?: string): Promise<string> {
  if (role === "PARENT") {
    const p = await prisma.parent.findFirst({ where: { userId }, select: { id: true } });
    if (p) return p.id;
  } else if (role === "TEACHER") {
    const t = await prisma.teacher.findFirst({ where: { userId }, select: { id: true } });
    if (t) return t.id;
  }
  return userId;
}

/** Converts a polymorphic entity ID back to a User.id for WebSocket routing. */
async function entityToUserId(entityId: string): Promise<string> {
  const p = await prisma.parent.findUnique({ where: { id: entityId }, select: { userId: true } });
  if (p) return p.userId;
  const t = await prisma.teacher.findUnique({ where: { id: entityId }, select: { userId: true } });
  if (t) return t.userId;
  return entityId;
}

type ParticipantInfo = {
  name: string;
  type: string;
  photo: string | null;
  userId: string;
};

/** Resolves display info for a conversation participant. */
async function resolveParticipantInfo(entityId: string): Promise<ParticipantInfo> {
  const [parent, teacher, user] = await Promise.all([
    prisma.parent.findUnique({
      where: { id: entityId },
      select: { photo: true, userId: true, user: { select: { fullName: true } } },
    }),
    prisma.teacher.findUnique({
      where: { id: entityId },
      select: { photo: true, userId: true, user: { select: { fullName: true } } },
    }),
    prisma.user.findUnique({
      where: { id: entityId },
      select: { fullName: true, role: true, school: { select: { name: true, logo: true } } },
    }),
  ]);

  if (parent) return { name: parent.user.fullName, type: "PARENT", photo: parent.photo ?? null, userId: parent.userId };
  if (teacher) return { name: teacher.user.fullName, type: "TEACHER", photo: teacher.photo ?? null, userId: teacher.userId };
  if (user) {
    const isAdmin = user.role === "SCHOOL_ADMIN" || user.role === "SUPER_ADMIN";
    return {
      name: isAdmin ? ((user.school?.name) ?? user.fullName) : user.fullName,
      type: user.role,
      photo: isAdmin ? ((user.school?.logo) ?? null) : null,
      userId: entityId,
    };
  }
  return { name: "Unknown", type: "UNKNOWN", photo: null, userId: entityId };
}

// ── GET /conversations ─────────────────────────────────────────────────────

export const listConversations = asyncHandler(async (req: Request, res: Response) => {
  const schoolId = requireSid(req);
  const userId = req.userId as string;
  const role = req.user?.role;

  const entityId = await resolveEntityId(userId, role);

  const conversations = await prisma.conversation.findMany({
    where: { schoolId, OR: [{ participant1Id: entityId }, { participant2Id: entityId }] },
    include: { messages: { orderBy: { createdAt: "desc" }, take: 1 } },
    orderBy: { lastMessageAt: "desc" },
  });

  const enriched = await Promise.all(
    conversations.map(async (conv) => {
      const otherId = conv.participant1Id === entityId ? conv.participant2Id : conv.participant1Id;
      const [participant, unreadCount] = await Promise.all([
        resolveParticipantInfo(otherId),
        prisma.message.count({ where: { conversationId: conv.id, senderId: { not: entityId }, readAt: null } }),
      ]);
      return { ...conv, ...participant, unreadCount, lastMessage: conv.messages[0] ?? null };
    })
  );

  res.json({ success: true, data: enriched });
});

// ── GET /:id/messages ──────────────────────────────────────────────────────

export const getMessages = asyncHandler(async (req: Request, res: Response) => {
  const schoolId = requireSid(req);
  const conversationId = req.params.id as string;
  const userId = req.userId as string;
  const role = req.user?.role;

  const entityId = await resolveEntityId(userId, role);

  const conv = await prisma.conversation.findFirst({ where: { id: conversationId, schoolId } });
  if (!conv) throw new NotFoundError("Conversation");

  // Mark incoming messages as read
  await prisma.message.updateMany({
    where: { conversationId, senderId: { not: entityId }, readAt: null },
    data: { readAt: new Date() },
  });

  const messages = await prisma.message.findMany({
    where: { conversationId },
    orderBy: { createdAt: "asc" },
  });

  res.json({ success: true, data: messages });
});

// ── POST /conversations (find or create) ───────────────────────────────────

export const findOrCreateConversation = asyncHandler(async (req: Request, res: Response) => {
  const schoolId = requireSid(req);
  const userId = req.userId as string;
  const role = req.user?.role;

  const { recipientId } = z.object({ recipientId: z.string().min(1) }).parse(req.body);
  const entityId = await resolveEntityId(userId, role);

  if (entityId === recipientId) throw new ValidationError("Cannot start a conversation with yourself");

  const [p1, p2] = [entityId, recipientId].sort();
  const pairKey = `${p1}:${p2}`;

  const existing = await prisma.conversation.findFirst({
    where: {
      schoolId,
      OR: [{ pairKey }, { participant1Id: entityId, participant2Id: recipientId }, { participant1Id: recipientId, participant2Id: entityId }],
    },
  });
  if (existing) return res.json({ success: true, data: existing });

  const conv = await prisma.conversation.create({
    data: { schoolId, participant1Id: p1, participant2Id: p2, pairKey },
  });

  res.status(201).json({ success: true, data: conv });
});

// ── POST /messages or /:id/messages (send) ────────────────────────────────

export const sendMessage = asyncHandler(async (req: Request, res: Response) => {
  const schoolId = requireSid(req);
  const userId = req.userId as string;
  const role = req.user?.role;

  const paramConvId = req.params.id as string | undefined;
  const { receiverId, conversationId: bodyConvId, content } = z
    .object({
      receiverId: z.string().optional(),
      conversationId: z.string().optional(),
      content: z.string().min(1),
    })
    .parse(req.body);

  const senderEntityId = await resolveEntityId(userId, role);
  const resolvedConvId = paramConvId || bodyConvId;
  let finalConvId: string;

  if (resolvedConvId) {
    const conv = await prisma.conversation.findFirst({ where: { id: resolvedConvId, schoolId } });
    if (!conv) throw new NotFoundError("Conversation");
    finalConvId = resolvedConvId;
  } else if (receiverId) {
    if (senderEntityId === receiverId) throw new ValidationError("Cannot message yourself");
    const [p1, p2] = [senderEntityId, receiverId].sort();
    const pairKey = `${p1}:${p2}`;
    const conv = await prisma.conversation.upsert({
      where: { pairKey },
      update: { lastMessageAt: new Date() },
      create: { schoolId, participant1Id: p1, participant2Id: p2, pairKey },
    });
    finalConvId = conv.id;
  } else {
    throw new ValidationError("Provide conversationId or receiverId");
  }

  const message = await prisma.message.create({
    data: { conversationId: finalConvId, senderId: senderEntityId, content },
  });

  await prisma.conversation.update({ where: { id: finalConvId }, data: { lastMessageAt: new Date() } });

  // WebSocket: notify both participants
  const conv = await prisma.conversation.findUnique({ where: { id: finalConvId } });
  const otherEntityId = conv!.participant1Id === senderEntityId ? conv!.participant2Id : conv!.participant1Id;
  const recipientUserId = await entityToUserId(otherEntityId);

  const io = getIO();
  io.to(`user:${recipientUserId}`).emit("message:new", message);
  io.to(`user:${userId}`).emit("chat:message", message);
  io.to(`school:${schoolId}`).emit("conversation:updated", finalConvId);

  // In-app notification for the recipient
  const sender = await prisma.user.findUnique({ where: { id: userId }, select: { fullName: true } });
  if (sender && recipientUserId !== userId) {
    await prisma.notification.create({
      data: {
        schoolId,
        recipientId: recipientUserId,
        title: "💬 رسالة جديدة",
        message: `${sender.fullName}: ${content.substring(0, 50)}`,
        type: "GENERAL",
        channel: "SYSTEM",
      },
    });
  }

  res.status(201).json({ success: true, data: message });
});

// ── GET /contacts ──────────────────────────────────────────────────────────

export const getContacts = asyncHandler(async (req: Request, res: Response) => {
  const schoolId = requireSid(req);
  const userId = req.userId as string;
  const role = req.user?.role;
  const query = (req.query.q as string) ?? "";

  const contacts: ParticipantInfo[] = [];

  // School admin is always available as a contact
  const adminUser = await prisma.user.findFirst({
    where: { schoolId, role: "SCHOOL_ADMIN" },
    select: { id: true, fullName: true, school: { select: { name: true, logo: true } } },
  });
  if (adminUser) {
    contacts.push({
      name: adminUser.school?.name ?? adminUser.fullName,
      type: "SCHOOL_ADMIN",
      photo: adminUser.school?.logo ?? null,
      userId: adminUser.id,
    });
  }

  if (role === "PARENT") {
    const parentId = req.parentId;
    if (parentId) {
      const students = await prisma.student.findMany({
        where: { OR: [{ fatherId: parentId }, { motherId: parentId }, { guardianId: parentId }] },
        include: {
          class: {
            include: {
              teacher: { include: { user: { select: { fullName: true } } } },
              teacherSubjects: { include: { teacher: { include: { user: { select: { fullName: true } } } } } },
            },
          },
        },
      });
      const teachersMap = new Map<string, ParticipantInfo>();
      students.forEach((s) => {
        const addTeacher = (t: any) => {
          if (t && !teachersMap.has(t.id)) {
            teachersMap.set(t.id, { name: t.user.fullName, type: "TEACHER", photo: t.photo ?? null, userId: t.userId });
          }
        };
        if (s.class?.teacher) addTeacher(s.class.teacher);
        s.class?.teacherSubjects?.forEach((ts) => addTeacher(ts.teacher));
      });
      contacts.push(...Array.from(teachersMap.values()));
    }
  } else if (role === "TEACHER") {
    const teacherId = req.teacherId;
    if (teacherId) {
      const teacher = await prisma.teacher.findUnique({
        where: { id: teacherId },
        include: {
          teacherSubjects: {
            include: {
              class: {
                include: {
                  students: {
                    include: {
                      father: { include: { user: { select: { fullName: true } } } },
                      mother: { include: { user: { select: { fullName: true } } } },
                    },
                  },
                },
              },
            },
          },
        },
      });
      const parentsMap = new Map<string, ParticipantInfo>();
      teacher?.teacherSubjects.forEach((ts) => {
        ts.class?.students.forEach((s) => {
          const addParent = (p: any) => {
            if (p && !parentsMap.has(p.id)) {
              parentsMap.set(p.id, { name: p.user.fullName, type: "PARENT", photo: p.photo ?? null, userId: p.userId });
            }
          };
          addParent(s.father);
          addParent(s.mother);
        });
      });
      contacts.push(...Array.from(parentsMap.values()));
    }
  } else {
    // Admin / SUPER_ADMIN: search all parents and teachers
    const [parents, teachers] = await Promise.all([
      prisma.parent.findMany({
        where: { schoolId, ...(query ? { user: { fullName: { contains: query, mode: "insensitive" } } } : {}) },
        take: 20,
        include: { user: { select: { fullName: true } } },
      }),
      prisma.teacher.findMany({
        where: { schoolId, ...(query ? { user: { fullName: { contains: query, mode: "insensitive" } } } : {}) },
        take: 20,
        include: { user: { select: { fullName: true } } },
      }),
    ]);
    parents.forEach((p) => contacts.push({ name: p.user.fullName, type: "PARENT", photo: p.photo ?? null, userId: p.userId }));
    teachers.forEach((t) => contacts.push({ name: t.user.fullName, type: "TEACHER", photo: t.photo ?? null, userId: t.userId }));
  }

  res.json({ success: true, data: contacts });
});
