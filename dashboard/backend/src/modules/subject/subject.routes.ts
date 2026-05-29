import { Router } from "express";
import { getSubjects, createSubject, deleteSubject, bulkCreateSubjects } from "./subject.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";

const router = Router();

router.get("/", requireAuth, tenantScope, getSubjects);
router.post("/", requireAuth, tenantScope, createSubject);
router.post("/bulk", requireAuth, tenantScope, bulkCreateSubjects);
router.delete("/:id", requireAuth, tenantScope, deleteSubject);

export default router;
