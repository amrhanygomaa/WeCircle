-- Migration: Type Message.senderId as a proper FK to User.
-- Pre-consolidation messages may store Teacher.id or Parent.id as senderId.
-- Step 1 remaps those to User.id; Step 2 deletes unmappable rows; Step 3 adds the FK.

-- Step 1a: Remap senderId = Teacher.id  →  Teacher.userId
UPDATE "Message" m
SET    "senderId" = t."userId"
FROM   "Teacher" t
WHERE  m."senderId" = t."id"
  AND  NOT EXISTS (SELECT 1 FROM "User" u WHERE u."id" = m."senderId");

-- Step 1b: Remap senderId = Parent.id  →  Parent.userId
UPDATE "Message" m
SET    "senderId" = p."userId"
FROM   "Parent" p
WHERE  m."senderId" = p."id"
  AND  NOT EXISTS (SELECT 1 FROM "User" u WHERE u."id" = m."senderId");

-- Step 2: Drop any remaining messages whose senderId is still not a valid User
DELETE FROM "Message"
WHERE NOT EXISTS (
  SELECT 1 FROM "User" u WHERE u."id" = "Message"."senderId"
);

-- Step 3: Add the FK constraint
ALTER TABLE "Message"
  ADD CONSTRAINT "Message_senderId_fkey"
  FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE CASCADE;
