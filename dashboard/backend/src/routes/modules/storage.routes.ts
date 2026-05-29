import { Router } from "express";
import { getPresignedUrl } from "../../controllers/storage.controller";
import { requireAuth } from "../../core/http/middlewares/auth";

const router = Router();

// Only authenticated users can request presigned URLs
router.get("/presign", requireAuth, getPresignedUrl);

export default router;
