import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import {
  listNotifications,
  markNotificationRead,
  sendManualNotification,
  deleteNotification,
  registerDeviceToken,
  unregisterDeviceToken,
} from "./notification.controller";

const router = Router();

// Mobile push-token registration (FCM). Mobile JWT auth — must be before requireAuth routes.
router.post("/mobile/device-token", requireMobileAuth, registerDeviceToken);
router.delete("/mobile/device-token", requireMobileAuth, unregisterDeviceToken);

router.get("/", requireAuth, tenantScope, listNotifications);
router.post("/", requireAuth, tenantScope, sendManualNotification);
router.post("/:id/read", requireAuth, tenantScope, markNotificationRead);
router.delete("/:id", requireAuth, tenantScope, deleteNotification);

export default router;

