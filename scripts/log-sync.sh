#!/bin/bash
set -euo pipefail

# Example cron entry to run every 30 minutes:
# */30 * * * * /path/to/log-sync.sh >> /var/log/log-sync.log 2>&1

BUCKET="malavika-internship-bucket-2026"
LOG_DIR="/var/log/apache2"
DATE=$(date +%Y-%m-%d)
PREFIX="logs/${DATE}/"
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

echo "[${TIMESTAMP}] Starting log sync to S3..."

if [ -f "${LOG_DIR}/access.log" ]; then
    echo "Copying access.log..."
    aws s3 cp "${LOG_DIR}/access.log" "s3://${BUCKET}/${PREFIX}access.log"
else
    echo "Warning: access.log not found."
fi

if [ -f "${LOG_DIR}/error.log" ]; then
    echo "Copying error.log..."
    aws s3 cp "${LOG_DIR}/error.log" "s3://${BUCKET}/${PREFIX}error.log"
else
    echo "Warning: error.log not found."
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Log sync completed."
