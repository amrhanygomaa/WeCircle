import { Router } from "express";
import { auth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { createBehaviorReport, getBehaviorReports, getParentBehaviorReports, getTeacherBehaviorReports } from "./behavior.controller";

const router = Router();

router.post("/mobile", requireMobileAuth, createBehaviorReport);
router.get("/mobile/teacher", requireMobileAuth, getTeacherBehaviorReports);
router.get("/mobile/parent", requireMobileAuth, getParentBehaviorReports);

router.use(auth);

router.post("/", createBehaviorReport);
router.get("/", getBehaviorReports);
router.get("/parent", getParentBehaviorReports);
router.get("/teacher", getTeacherBehaviorReports);

export default router;
