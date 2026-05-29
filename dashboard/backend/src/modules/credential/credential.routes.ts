import { Router } from "express";
import { auth } from "../../core/http/middlewares/auth";
import {
  generateCredentials,
  bulkGenerateCredentials,
  getCredentials,
  toggleCredential,
  resetCredentialPassword,
  deleteCredential,
} from "./credential.controller";

const router = Router();

router.use(auth);

router.get("/", getCredentials);
router.post("/generate", generateCredentials);
router.post("/bulk-generate", bulkGenerateCredentials);
router.patch("/:id/toggle", toggleCredential);
router.patch("/:id/reset-password", resetCredentialPassword);
router.delete("/:id", deleteCredential);

export default router;
