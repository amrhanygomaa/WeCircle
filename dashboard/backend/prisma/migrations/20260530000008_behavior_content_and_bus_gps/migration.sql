-- Add rich content field to BehaviorReport (nullable JSON — no data loss)
ALTER TABLE "BehaviorReport" ADD COLUMN "content" JSONB;

-- Add GPS tracking fields to Bus (all nullable — no data loss)
ALTER TABLE "Bus" ADD COLUMN "lastLat"           DOUBLE PRECISION;
ALTER TABLE "Bus" ADD COLUMN "lastLng"           DOUBLE PRECISION;
ALTER TABLE "Bus" ADD COLUMN "locationUpdatedAt" TIMESTAMP(3);
