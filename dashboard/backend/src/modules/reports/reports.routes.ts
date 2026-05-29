import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { getReportsOverview } from "./reports.controller";

const router = Router();

router.get("/overview", requireAuth, tenantScope, getReportsOverview);

export default router;

