import { Router } from "express";
import { getClasses, createClass, deleteClass } from "./class.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { roleGuard } from "../../core/http/middlewares/roleGuard";
import { Role } from "@prisma/client";

const router = Router();

router.get("/", requireAuth, tenantScope, getClasses);
router.post("/", requireAuth, tenantScope, roleGuard([Role.ADMIN, Role.SUPER_ADMIN]), createClass);
router.delete("/:id", requireAuth, tenantScope, roleGuard([Role.ADMIN, Role.SUPER_ADMIN]), deleteClass);

export default router;
