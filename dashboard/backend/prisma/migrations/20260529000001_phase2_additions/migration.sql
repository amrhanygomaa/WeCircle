-- DropIndex
DROP INDEX "Conversation_participant1Id_participant2Id_key";

-- AlterTable
ALTER TABLE "Expense" ALTER COLUMN "amount" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "ApplicationFee" ALTER COLUMN "amount" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "Teacher" ALTER COLUMN "salary" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "FeeStructure" ALTER COLUMN "amount" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "Invoice" ALTER COLUMN "totalAmount" SET DATA TYPE DECIMAL(12,2),
ALTER COLUMN "discount" SET DATA TYPE DECIMAL(12,2),
ALTER COLUMN "paid" SET DATA TYPE DECIMAL(12,2),
ALTER COLUMN "remaining" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "Payment" ALTER COLUMN "amount" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "Driver" ALTER COLUMN "salary" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "StudentBus" ALTER COLUMN "fees" SET DATA TYPE DECIMAL(12,2);

-- AlterTable
ALTER TABLE "Conversation" ADD COLUMN     "pairKey" TEXT;

-- CreateTable
CREATE TABLE "StudentGameProgress" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "gameId" INTEGER NOT NULL,
    "level" INTEGER NOT NULL DEFAULT 1,
    "points" INTEGER NOT NULL DEFAULT 0,
    "unlockedAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentGameProgress_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "StudentGameProgress_schoolId_idx" ON "StudentGameProgress"("schoolId");

-- CreateIndex
CREATE INDEX "StudentGameProgress_studentId_idx" ON "StudentGameProgress"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentGameProgress_studentId_gameId_key" ON "StudentGameProgress"("studentId", "gameId");

-- CreateIndex
CREATE INDEX "Attendance_schoolId_classId_date_idx" ON "Attendance"("schoolId", "classId", "date");

-- CreateIndex
CREATE INDEX "Invoice_schoolId_status_dueDate_idx" ON "Invoice"("schoolId", "status", "dueDate");

-- CreateIndex
CREATE UNIQUE INDEX "Conversation_pairKey_key" ON "Conversation"("pairKey");

-- CreateIndex
CREATE INDEX "Conversation_participant1Id_participant2Id_idx" ON "Conversation"("participant1Id", "participant2Id");

-- CreateIndex
CREATE INDEX "Message_senderId_idx" ON "Message"("senderId");

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentGameProgress" ADD CONSTRAINT "StudentGameProgress_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentGameProgress" ADD CONSTRAINT "StudentGameProgress_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

