import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { createHomework, deleteHomework, getHomeworkSubmissions, listHomework, submitHomework, updateHomework } from "./homework.controller";

const router = Router();

router.get("/", requireAuth, tenantScope, listHomework);
router.post("/", requireAuth, tenantScope, createHomework);
router.post("/:id/submit", requireAuth, tenantScope, submitHomework);
router.get("/:id/submissions", requireAuth, tenantScope, getHomeworkSubmissions);
router.patch("/:id", requireAuth, tenantScope, updateHomework);
router.delete("/:id", requireAuth, tenantScope, deleteHomework);

export default router;
