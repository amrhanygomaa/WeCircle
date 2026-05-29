import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { listUsers, updateUserRole } from "./user.controller";

const router = Router();

router.get("/", requireAuth, tenantScope, listUsers);
router.patch("/:id/role", requireAuth, tenantScope, updateUserRole);

export default router;

