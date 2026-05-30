import { Router } from "express";
import { getAttendance, createAttendance, markBulkAttendance } from "./attendance.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";

const router = Router();

router.get("/mobile", requireMobileAuth, getAttendance);
router.post("/mobile/bulk", requireMobileAuth, markBulkAttendance);

router.get("/", requireAuth, tenantScope, getAttendance);
router.post("/", requireAuth, tenantScope, createAttendance);
router.post("/bulk", requireAuth, tenantScope, markBulkAttendance);

export default router;
