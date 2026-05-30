-- Migration: Make Parent.schoolId non-nullable.
-- Every other tenant-scoped model requires schoolId; Parent is the one exception.
-- Strategy:
--   1. Derive schoolId from any linked student (fatherId / motherId / guardianId on Student).
--   2. Parents with no linked students and no schoolId are orphaned records — delete them.
--   3. Set NOT NULL constraint.

-- Step 1: Fill schoolId from linked students
UPDATE "Parent" p
SET "schoolId" = (
  SELECT s."schoolId"
  FROM   "Student" s
  WHERE  s."fatherId" = p."id"
      OR s."motherId" = p."id"
      OR s."guardianId" = p."id"
  LIMIT 1
)
WHERE p."schoolId" IS NULL;

-- Step 2: Remove any parents that are still orphaned (no students, no school)
DELETE FROM "Parent" WHERE "schoolId" IS NULL;

-- Step 3: Enforce NOT NULL
ALTER TABLE "Parent" ALTER COLUMN "schoolId" SET NOT NULL;
