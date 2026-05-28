import { Router } from "express";
import { getOverview } from "../../controllers/dashboard.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";

const router = Router();

router.get("/overview", requireAuth, tenantScope, getOverview);

export default router;
