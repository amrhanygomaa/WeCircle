import { InvoiceStatus, PaymentMethod } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { NotFoundError } from "../../core/utils/AppError";

// ── Pure calculation helpers ────────────────────────────────────────────────

export function calculateInvoiceStatus(
  totalAmount: number,
  discount: number,
  totalPaid: number
): { status: InvoiceStatus; remaining: number } {
  const netRequired = totalAmount - discount;
  const remaining = Math.max(0, netRequired - totalPaid);

  let status: InvoiceStatus = "UNPAID";
  if (netRequired === 0) status = "PAID"; // fully discounted
  else if (totalPaid >= netRequired) status = "PAID";
  else if (totalPaid > 0) status = "PARTIAL";

  return { status, remaining };
}

export function resolveDiscount(
  currentDiscount: number,
  totalAmount: number,
  discountAmount?: number,
  discountPercentage?: number
): number {
  if (discountPercentage !== undefined) return (totalAmount * discountPercentage) / 100;
  if (discountAmount !== undefined) return discountAmount;
  return currentDiscount;
}

// ── Credential helpers ──────────────────────────────────────────────────────

export async function setStudentAndParentCredentials(
  studentId: string,
  isActive: boolean
): Promise<{ studentCount: number; parentCount: number }> {
  const student = await prisma.student.findUnique({
    where: { id: studentId },
    include: { father: true, mother: true, guardian: true },
  });

  if (!student) return { studentCount: 0, parentCount: 0 };

  const { count: studentCount } = await prisma.appCredential.updateMany({
    where: { studentId },
    data: { isActive },
  });

  const parentIds = [student.father?.id, student.mother?.id, student.guardian?.id].filter(
    Boolean
  ) as string[];

  let parentCount = 0;
  if (parentIds.length > 0) {
    const result = await prisma.appCredential.updateMany({
      where: { parentId: { in: parentIds } },
      data: { isActive },
    });
    parentCount = result.count;
  }

  return { studentCount, parentCount };
}

// ── Invoice operations ──────────────────────────────────────────────────────

export async function recordPayment(
  invoiceId: string,
  schoolId: string,
  amount: number,
  method: PaymentMethod = PaymentMethod.CASH,
  notes?: string
) {
  const invoice = await prisma.invoice.findFirst({ where: { id: invoiceId, schoolId } });
  if (!invoice) throw new NotFoundError("Invoice not found");

  const payment = await prisma.payment.create({
    data: {
      schoolId,
      studentId: invoice.studentId,
      invoiceId: invoice.id,
      amount,
      feeType: invoice.feeType,
      paymentMethod: method,
      status: "PAID",
      notes,
      paidAt: new Date(),
    },
  });

  const allPayments = await prisma.payment.findMany({
    where: { invoiceId: invoice.id, status: "PAID" },
  });
  const totalPaid = allPayments.reduce((sum, p) => sum + Number(p.amount), 0);

  const { status, remaining } = calculateInvoiceStatus(
    Number(invoice.totalAmount),
    Number(invoice.discount),
    totalPaid
  );

  await prisma.invoice.update({
    where: { id: invoice.id },
    data: { status, paid: totalPaid, remaining },
  });

  if (status === "PAID") {
    await setStudentAndParentCredentials(invoice.studentId, true);
  }

  return { payment, invoiceStatus: status };
}

export async function applyInvoiceDiscount(
  invoiceId: string,
  schoolId: string,
  discountAmount?: number,
  discountPercentage?: number
) {
  const invoice = await prisma.invoice.findFirst({ where: { id: invoiceId, schoolId } });
  if (!invoice) throw new NotFoundError("Invoice not found");

  const finalDiscount = resolveDiscount(
    Number(invoice.discount),
    Number(invoice.totalAmount),
    discountAmount,
    discountPercentage
  );

  const { status, remaining } = calculateInvoiceStatus(
    Number(invoice.totalAmount),
    finalDiscount,
    Number(invoice.paid)
  );

  return prisma.invoice.update({
    where: { id: invoice.id },
    data: { discount: finalDiscount, remaining, status },
  });
}
