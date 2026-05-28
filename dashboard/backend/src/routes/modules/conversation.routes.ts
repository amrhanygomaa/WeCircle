import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import {
  createConversation,
  getAvailableContacts,
  getConversations,
  getMessages,
  sendMessage,
} from "../../controllers/conversation.controller";

const router = Router();

router.get("/", requireAuth, tenantScope, getConversations);
router.get("/contacts", requireAuth, tenantScope, getAvailableContacts);
router.post("/", requireAuth, tenantScope, createConversation);
router.get("/:id/messages", requireAuth, tenantScope, getMessages);
router.post("/:id/messages", requireAuth, tenantScope, sendMessage);

export default router;
