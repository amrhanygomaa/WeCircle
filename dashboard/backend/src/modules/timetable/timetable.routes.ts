import { Router } from "express";
import { getTimetable, upsertTimetableSlot, deleteTimetableSlot, autoGenerateTimetable } from "./timetable.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { prisma } from "../../config/prisma";

const router = Router();

// Mobile parent — timetable for a specific student's class
router.get("/mobile/student", requireMobileAuth, async (req, res) => {
  const schoolId = req.schoolId;
  const parentId = req.parentId;
  const { studentId } = req.query;

  if (!studentId || typeof studentId !== "string") {
    return res.status(400).json({ success: false, message: "studentId required" });
  }

  try {
    const student = await prisma.student.findFirst({
      where: {
        id: studentId,
        schoolId: schoolId!,
        OR: [{ fatherId: parentId }, { motherId: parentId }, { guardianId: parentId }],
      },
      select: { classId: true },
    });

    if (!student?.classId) return res.json({ success: true, data: [] });

    const data = await prisma.timetable.findMany({
      where: { schoolId: schoolId!, classId: student.classId },
      include: {
        subject: true,
        teacher: { include: { user: { select: { fullName: true } } } },
      },
      orderBy: [{ day: "asc" }, { periodNumber: "asc" }],
    });

    res.json({ success: true, data });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Mobile teacher schedule — teacher sees their own timetable
router.get("/mobile/my-schedule", requireMobileAuth, async (req, res) => {
  const teacherId = req.teacherId;
  const schoolId = req.schoolId;
  if (!teacherId) return res.status(401).json({ success: false, message: "Unauthorized" });

  const data = await prisma.timetable.findMany({
    where: { schoolId: schoolId!, teacherId },
    include: {
      subject: true,
      class: true,
    },
    orderBy: [{ day: "asc" }, { periodNumber: "asc" }],
  });

  res.json({ success: true, data });
});

router.get("/", requireAuth, tenantScope, getTimetable);
router.post("/auto-generate", requireAuth, tenantScope, autoGenerateTimetable);
router.post("/", requireAuth, tenantScope, upsertTimetableSlot);
router.delete("/:id", requireAuth, tenantScope, deleteTimetableSlot);

export default router;
