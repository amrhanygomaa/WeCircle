#!/bin/bash
# WeCircle — daily Postgres backup to S3.
# Idempotent — safe to re-run. Writes the backup script to /usr/local/bin and
# registers it in crontab to run at 2 AM UTC every day.
#
# Run once on the EC2 box (after git pull):
#   bash /opt/wecircle/infra/aws/setup-db-backup.sh
#
# The backup script itself is at /usr/local/bin/wecircle-db-backup.sh
# Logs go to /var/log/wecircle-backup.log
set -euo pipefail

APP_DIR="/opt/wecircle"
BACKUP_SCRIPT="/usr/local/bin/wecircle-db-backup.sh"

# Read bucket from the live .env (the EC2 box IAM role handles AWS creds)
BUCKET=$(grep -oP 'AWS_S3_BUCKET_NAME=\K\S+' "$APP_DIR/dashboard/backend/.env" 2>/dev/null || true)
if [ -z "$BUCKET" ]; then
  echo "ERROR: AWS_S3_BUCKET_NAME not found in $APP_DIR/dashboard/backend/.env" >&2
  exit 1
fi
echo "Bucket: s3://$BUCKET/db-backups/"

cat > "$BACKUP_SCRIPT" <<'SCRIPT'
#!/bin/bash
set -euo pipefail
APP_DIR="/opt/wecircle"
ENV_FILE="$APP_DIR/dashboard/backend/.env"

BUCKET=$(grep -oP 'AWS_S3_BUCKET_NAME=\K\S+' "$ENV_FILE")
DB_URL=$(grep -oP 'DATABASE_URL=\K\S+' "$ENV_FILE")
DATE=$(date -u +%Y%m%d-%H%M)
DUMP_FILE="/tmp/wecircle-$DATE.dump"

echo "[BACKUP $(date -u)] Starting pg_dump..."
pg_dump "$DB_URL" --format=custom --no-password -f "$DUMP_FILE"

echo "[BACKUP] Uploading to s3://$BUCKET/db-backups/wecircle-$DATE.dump ..."
aws s3 cp "$DUMP_FILE" "s3://$BUCKET/db-backups/wecircle-$DATE.dump" \
  --region us-east-1 \
  --storage-class STANDARD_IA \
  --quiet

rm -f "$DUMP_FILE"

# Keep the newest 30 backups; delete the rest
TOTAL=$(aws s3 ls "s3://$BUCKET/db-backups/" --region us-east-1 | wc -l)
if [ "$TOTAL" -gt 30 ]; then
  DELETE_COUNT=$((TOTAL - 30))
  aws s3 ls "s3://$BUCKET/db-backups/" --region us-east-1 \
    | sort \
    | head -n "$DELETE_COUNT" \
    | awk '{print $4}' \
    | while read -r key; do
        aws s3 rm "s3://$BUCKET/db-backups/$key" --region us-east-1 --quiet
      done
  echo "[BACKUP] Pruned $DELETE_COUNT old backup(s)."
fi

echo "[BACKUP $(date -u)] Done — wecircle-$DATE.dump"
SCRIPT

chmod +x "$BACKUP_SCRIPT"

# Register in ec2-user crontab at 02:00 UTC (low-traffic window, avoids deploy at 01:xx)
( crontab -l 2>/dev/null | grep -v wecircle-db-backup; \
  echo "0 2 * * * $BACKUP_SCRIPT >> /var/log/wecircle-backup.log 2>&1" ) | crontab -

echo ""
echo "=== DB backup setup complete ==="
echo "Script  : $BACKUP_SCRIPT"
echo "Bucket  : s3://$BUCKET/db-backups/"
echo "Schedule: daily 02:00 UTC (crontab entry added for ec2-user)"
echo ""
echo "To test immediately (will create a real backup):"
echo "  bash $BACKUP_SCRIPT"
echo ""
echo "To verify crontab:"
echo "  crontab -l | grep backup"
