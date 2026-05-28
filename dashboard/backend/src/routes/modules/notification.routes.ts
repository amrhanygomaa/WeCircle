import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { listNotifications, markNotificationRead, sendManualNotification, deleteNotification } from "../../controllers/notification.controller";

const router = Router();

router.get("/", requireAuth, tenantScope, listNotifications);
router.post("/", requireAuth, tenantScope, sendManualNotification);
router.post("/:id/read", requireAuth, tenantScope, markNotificationRead);
router.delete("/:id", requireAuth, tenantScope, deleteNotification);

export default router;

