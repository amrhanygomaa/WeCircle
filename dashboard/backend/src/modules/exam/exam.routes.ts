import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { prisma } from "../../config/prisma";
import {
  createExam,
  deleteExam,
  listExams,
  updateExam,
  saveExamResults,
  getExamResults,
  getStudentResults,
} from "./exam.controller";

const router = Router();

router.get("/", requireAuth, tenantScope, listExams);
router.post("/", requireAuth, tenantScope, createExam);
router.patch("/:id", requireAuth, tenantScope, updateExam);
router.delete("/:id", requireAuth, tenantScope, deleteExam);

// Exam results routes (web dashboard)
router.post("/:id/results", requireAuth, tenantScope, saveExamResults);
router.get("/:id/results", requireAuth, tenantScope, getExamResults);
router.get("/student/:studentId", requireAuth, tenantScope, getStudentResults);

// Mobile teacher endpoints
router.get("/mobile/teacher-classes", requireMobileAuth, async (req, res) => {
  const schoolId = req.schoolId;
  const teacherId = req.teacherId;
  if (!teacherId) return res.status(403).json({ success: false, message: "Teacher context required" });
  try {
    const teacherClasses = await prisma.teacherSubject.findMany({
      where: { teacherId, class: { schoolId: schoolId! } },
      select: { classId: true },
      distinct: ["classId"],
    });
    const classIds = teacherClasses.map((tc: any) => tc.classId);
    const data = await prisma.exam.findMany({
      where: { schoolId: schoolId!, classId: { in: classIds } },
      include: {
        subject: { select: { name: true } },
        class: { select: { id: true, name: true } },
        _count: { select: { results: true } },
      },
      orderBy: { date: "desc" },
      take: 30,
    });
    res.json({ success: true, data });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
});
router.post("/mobile/:id/results", requireMobileAuth, saveExamResults);
router.get("/mobile/:id/results", requireMobileAuth, getExamResults);
router.get("/mobile/student/:studentId", requireMobileAuth, getStudentResults);

export default router;

