import { Router } from "express";
import { getSettings, updateSettings } from "../../controllers/settings.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";

const router = Router();

router.get("/", requireAuth, tenantScope, getSettings);
router.patch("/", requireAuth, tenantScope, updateSettings);

export default router;
