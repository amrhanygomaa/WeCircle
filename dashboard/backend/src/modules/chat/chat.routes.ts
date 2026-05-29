import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import {
  listConversations,
  getMessages,
  findOrCreateConversation,
  sendMessage,
  getContacts,
} from "./chat.controller";

const router = Router();

// ── Web dashboard (Cognito JWT) ────────────────────────────────────────────
router.get("/", requireAuth, tenantScope, listConversations);
router.post("/", requireAuth, tenantScope, findOrCreateConversation);
router.get("/contacts", requireAuth, tenantScope, getContacts);
router.get("/:id/messages", requireAuth, tenantScope, getMessages);
router.post("/:id/messages", requireAuth, tenantScope, sendMessage);

// ── Mobile app (AppCredential JWT) ────────────────────────────────────────
// Mounted under /mobile/ to keep auth separate from web routes.
router.get("/mobile/conversations", requireMobileAuth, listConversations);
router.post("/mobile/conversations", requireMobileAuth, findOrCreateConversation);
router.get("/mobile/contacts", requireMobileAuth, getContacts);
router.get("/mobile/conversations/:id/messages", requireMobileAuth, getMessages);
router.post("/mobile/conversations/:id/messages", requireMobileAuth, sendMessage);
// Convenience send: create conversation + send in one call (body: {receiverId?, conversationId?, content})
router.post("/mobile/messages", requireMobileAuth, sendMessage);

export default router;
