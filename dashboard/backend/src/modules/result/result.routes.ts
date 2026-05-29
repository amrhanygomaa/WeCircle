import { Router } from "express";
import { requireAuth } from "../../core/http/middlewares/auth";
import { tenantScope } from "../../core/http/middlewares/tenantScope";
import { 
  listSchoolResults, 
  uploadSchoolResult, 
  deleteSchoolResult 
} from "./result.controller";

const router = Router();

router.use(requireAuth);
router.use(tenantScope);

router.get("/", listSchoolResults);
router.post("/", uploadSchoolResult);
router.delete("/:id", deleteSchoolResult);

export default router;
