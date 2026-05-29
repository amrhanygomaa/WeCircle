-- CreateTable
CREATE TABLE "DeviceSession" (
    "id" TEXT NOT NULL,
    "credentialId" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "parentId" TEXT,
    "teacherId" TEXT,
    "driverId" TEXT,
    "studentId" TEXT,
    "token" TEXT NOT NULL,
    "deviceName" TEXT NOT NULL DEFAULT '',
    "location" TEXT NOT NULL DEFAULT '',
    "ipAddress" TEXT NOT NULL DEFAULT '',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastActiveAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DeviceSession_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DeviceSession_token_key" ON "DeviceSession"("token");

-- CreateIndex
CREATE INDEX "DeviceSession_credentialId_idx" ON "DeviceSession"("credentialId");

-- CreateIndex
CREATE INDEX "DeviceSession_schoolId_idx" ON "DeviceSession"("schoolId");

-- CreateIndex
CREATE INDEX "DeviceSession_parentId_idx" ON "DeviceSession"("parentId");

-- CreateIndex
CREATE INDEX "DeviceSession_teacherId_idx" ON "DeviceSession"("teacherId");

-- AddForeignKey
ALTER TABLE "DeviceSession" ADD CONSTRAINT "DeviceSession_credentialId_fkey" FOREIGN KEY ("credentialId") REFERENCES "AppCredential"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeviceSession" ADD CONSTRAINT "DeviceSession_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

