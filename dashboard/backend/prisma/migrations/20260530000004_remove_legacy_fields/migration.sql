-- Migration: Remove legacy fields
--   Teacher.subject  — replaced by TeacherSubject many-to-many relation
--   Driver.idCopy    — replaced by idCopyFront / idCopyBack fields

ALTER TABLE "Teacher" DROP COLUMN IF EXISTS "subject";
ALTER TABLE "Driver"  DROP COLUMN IF EXISTS "idCopy";
