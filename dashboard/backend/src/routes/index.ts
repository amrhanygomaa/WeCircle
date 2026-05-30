import { Router, Request, Response } from "express";
import { env } from "../config/env";
import { checkOverdueInvoices } from "../cron/checkOverdueInvoices";

import studentRoutes       from "../modules/student/student.routes";
import teacherRoutes       from "../modules/teacher/teacher.routes";
import classRoutes         from "../modules/class/class.routes";
import attendanceRoutes    from "../modules/attendance/attendance.routes";
import paymentRoutes       from "../modules/payment/payment.routes";
import announcementRoutes  from "../modules/announcement/announcement.routes";
import dashboardRoutes     from "../modules/dashboard/dashboard.routes";
import authRoutes          from "../modules/auth/auth.routes";
import storageRoutes       from "../modules/storage/storage.routes";
import admissionRoutes     from "../modules/admission/admission.routes";
import academicRoutes      from "../modules/academic/academic.routes";
import credentialRoutes    from "../modules/credential/credential.routes";
import invoiceRoutes       from "../modules/invoice/invoice.routes";
import transportRoutes     from "../modules/transport/transport.routes";
import settingsRoutes      from "../modules/settings/settings.routes";
import timetableRoutes     from "../modules/timetable/timetable.routes";
import subjectRoutes       from "../modules/subject/subject.routes";
import homeworkRoutes      from "../modules/homework/homework.routes";
import examRoutes          from "../modules/exam/exam.routes";
import parentRoutes        from "../modules/parent/parent.routes";
import userRoutes          from "../modules/user/user.routes";
import notificationRoutes  from "../modules/notification/notification.routes";
import reportsRoutes       from "../modules/reports/reports.routes";
import schoolRoutes        from "../modules/school/school.routes";
import resultRoutes        from "../modules/result/result.routes";
import zoomRoutes          from "../modules/zoom/zoom.routes";
import chatRoutes          from "../modules/chat/chat.routes";
import feeStructureRoutes  from "../modules/feeStructure/feeStructure.routes";
import archiveRoutes       from "../modules/archive/archive.routes";
import leaveRoutes         from "../modules/leave/leave.routes";
import scheduleRoutes      from "../modules/schedule/schedule.routes";
import behaviorRoutes      from "../modules/behavior/behavior.routes";
import dailyReportRoutes   from "../modules/dailyReport/dailyReport.routes";
import studentTaskRoutes   from "../modules/studentTask/studentTask.routes";
import aiRoutes            from "../modules/ai/ai.routes";
import mobileTransportRoutes from "../modules/mobileTransport/mobile.transport.routes";

const router = Router();

router.get("/health", (_req, res) => {
  res.json({ success: true, message: "API is healthy" });
});

// Internal endpoint triggered by the EventBridge Scheduler Lambda (R10).
// Not behind requireAuth — protected only by the X-Cron-Secret header.
router.post("/internal/cron/check-overdue", async (req: Request, res: Response) => {
  const secret = req.headers["x-cron-secret"];
  if (!env.cronSecret || secret !== env.cronSecret) {
    res.status(401).json({ success: false, message: "Unauthorized" });
    return;
  }
  await checkOverdueInvoices();
  res.json({ success: true, message: "Overdue check complete" });
});

router.use("/auth",            authRoutes);
router.use("/storage",         storageRoutes);
router.use("/dashboard",       dashboardRoutes);
router.use("/admissions",      admissionRoutes);
router.use("/academic",        academicRoutes);
router.use("/credentials",     credentialRoutes);
router.use("/students",        studentRoutes);
router.use("/teachers",        teacherRoutes);
router.use("/classes",         classRoutes);
router.use("/attendance",      attendanceRoutes);
router.use("/payments",        paymentRoutes);
router.use("/invoices",        invoiceRoutes);
router.use("/transport",       transportRoutes);
router.use("/announcements",   announcementRoutes);
router.use("/settings",        settingsRoutes);
router.use("/timetable",       timetableRoutes);
router.use("/subjects",        subjectRoutes);
router.use("/homework",        homeworkRoutes);
router.use("/exams",           examRoutes);
router.use("/parents",         parentRoutes);
router.use("/users",           userRoutes);
router.use("/notifications",   notificationRoutes);
router.use("/reports",         reportsRoutes);
router.use("/school",          schoolRoutes);
router.use("/results",         resultRoutes);
router.use("/zoom",            zoomRoutes);
router.use("/fee-structures",  feeStructureRoutes);
router.use("/chat",            chatRoutes);
router.use("/archives",        archiveRoutes);
router.use("/leaves",          leaveRoutes);
router.use("/schedules",       scheduleRoutes);
router.use("/behavior",        behaviorRoutes);
router.use("/daily-reports",   dailyReportRoutes);
router.use("/student-tasks",   studentTaskRoutes);
router.use("/ai",              aiRoutes);
router.use("/mobile/transport", mobileTransportRoutes);
// /conversations is an alias for /chat for web-dashboard backward compatibility
router.use("/conversations",   chatRoutes);

export default router;
