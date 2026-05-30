-- Migration: Drop legacy ADMIN enum value
-- Migrate any User rows with role=ADMIN to SCHOOL_ADMIN first, then
-- rebuild the enum without the legacy value.

-- Step 1: Patch any rows using the legacy value
UPDATE "User" SET "role" = 'SCHOOL_ADMIN' WHERE "role" = 'ADMIN';

-- Step 2: Rebuild the enum without ADMIN
--   Postgres does not support DROP VALUE on an enum, so we rename + recreate.
ALTER TYPE "Role" RENAME TO "Role_old";

CREATE TYPE "Role" AS ENUM (
  'SUPER_ADMIN',
  'SCHOOL_ADMIN',
  'ADMISSION_OFFICER',
  'STUDENT_AFFAIRS',
  'ACCOUNTANT',
  'BUS_SUPERVISOR',
  'DRIVER',
  'TEACHER',
  'STUDENT',
  'PARENT'
);

-- Step 3: Drop the column DEFAULT before changing type (Postgres can't auto-cast it)
ALTER TABLE "User" ALTER COLUMN "role" DROP DEFAULT;

-- Step 4: Migrate the column to the new enum type
ALTER TABLE "User" ALTER COLUMN "role" TYPE "Role" USING "role"::text::"Role";

-- Step 5: Restore the DEFAULT using the new enum type
ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT 'STUDENT'::"Role";

-- Step 6: Drop the old enum
DROP TYPE "Role_old";
