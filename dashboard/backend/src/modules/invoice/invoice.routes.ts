import { Router } from "express";
import { auth } from "../../core/http/middlewares/auth";
import { requireMobileAuth } from "../../core/http/middlewares/mobileAuth";
import {
  getInvoices,
  createInvoice,
  createBulkInvoices,
  payInvoice,
  deleteInvoice,
  applyDiscount,
  toggleInvoiceAccess,
  updateInvoiceDeadline,
  getMobileStudentInvoices
} from "./invoice.controller";

const router = Router();

router.get("/mobile/student/:studentId", requireMobileAuth, getMobileStudentInvoices);

router.use(auth);

router.get("/", getInvoices);
router.post("/", createInvoice);
router.post("/bulk", createBulkInvoices);
router.patch("/:id/pay", payInvoice);
router.patch("/:id/discount", applyDiscount);
router.patch("/:id/toggle-access", toggleInvoiceAccess);
router.patch("/:id/deadline", updateInvoiceDeadline);
router.delete("/:id", deleteInvoice);

export default router;
