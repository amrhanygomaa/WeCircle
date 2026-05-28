import { Router } from "express";
import { getAttendance, createAttendance, markBulkAttendance } from "../../controllers/attendance.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";

const router = Router();

router.get("/", requireAuth, tenantScope, getAttendance);
router.post("/", requireAuth, tenantScope, createAttendance);
router.post("/bulk", requireAuth, tenantScope, markBulkAttendance);

export default router;
