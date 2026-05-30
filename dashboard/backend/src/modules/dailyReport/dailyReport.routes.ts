import { Router } from "express";
import { auth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { createDailyReport, getDailyReports } from "./dailyReport.controller";

const router = Router();

router.post("/mobile", requireMobileAuth, createDailyReport);
router.get("/mobile", requireMobileAuth, getDailyReports);

router.use(auth);

router.post("/", createDailyReport);
router.get("/", getDailyReports);

export default router;
