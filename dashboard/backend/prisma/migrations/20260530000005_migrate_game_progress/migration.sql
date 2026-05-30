-- Migration: Backfill StudentGameProgress then drop flat game columns on Student.
-- Phase 2 added the StudentGameProgress model; this migration moves the data
-- and removes the five legacy columns.

-- Step 1: Backfill one row per student per game (1–5) from the flat columns.
--   ON CONFLICT DO NOTHING keeps any rows that were already written by the app.
INSERT INTO "StudentGameProgress" ("id", "schoolId", "studentId", "gameId", "level", "points", "updatedAt")
SELECT
  gen_random_uuid()::text,
  s."schoolId",
  s."id",
  g."gameId",
  CASE g."gameId"
    WHEN 1 THEN s."game1Lvl"
    WHEN 2 THEN s."game2Lvl"
    WHEN 3 THEN s."game3Lvl"
    WHEN 4 THEN s."game4Lvl"
    WHEN 5 THEN s."game5Lvl"
  END,
  s."points",
  NOW()
FROM "Student" s
CROSS JOIN (VALUES (1),(2),(3),(4),(5)) AS g("gameId")
ON CONFLICT ("studentId", "gameId") DO NOTHING;

-- Step 2: Drop the now-redundant flat columns.
ALTER TABLE "Student"
  DROP COLUMN IF EXISTS "game1Lvl",
  DROP COLUMN IF EXISTS "game2Lvl",
  DROP COLUMN IF EXISTS "game3Lvl",
  DROP COLUMN IF EXISTS "game4Lvl",
  DROP COLUMN IF EXISTS "game5Lvl";
