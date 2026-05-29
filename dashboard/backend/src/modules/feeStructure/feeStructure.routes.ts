import { Router } from "express";
import { getFeeStructures, createFeeStructure, deleteFeeStructure } from "./feeStructure.controller";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";

const router = Router();

router.use(requireAuth, tenantScope);

router.get("/", getFeeStructures);
router.post("/", createFeeStructure);
router.delete("/:id", deleteFeeStructure);

export default router;
