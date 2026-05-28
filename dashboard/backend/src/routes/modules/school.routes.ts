import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { getMySchool, updateMySchool } from "../../controllers/school.controller";

const router = Router();

router.get("/me", requireAuth, tenantScope, getMySchool);
router.patch("/me", requireAuth, tenantScope, updateMySchool);

export default router;

