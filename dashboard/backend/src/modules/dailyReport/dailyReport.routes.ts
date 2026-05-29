import { Router } from "express";
import { auth } from "../../core/http/middlewares/auth";
import { createDailyReport, getDailyReports } from "./dailyReport.controller";

const router = Router();

router.use(auth);

router.post("/", createDailyReport);
router.get("/", getDailyReports);

export default router;
