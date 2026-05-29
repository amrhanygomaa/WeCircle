import { Router } from "express";
import { getPayments, createPayment } from "./payment.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { roleGuard } from "../../core/http/middlewares/roleGuard";
import { Role } from "@prisma/client";

const router = Router();

router.get("/", requireAuth, tenantScope, getPayments);
router.post("/", requireAuth, tenantScope, roleGuard([Role.ADMIN, Role.SUPER_ADMIN]), createPayment);

export default router;
