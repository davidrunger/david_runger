#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# Move to the application directory
cd /root/david_runger

# Clean up from previous runs
rm -rf tmp/backup

# Create backup
mkdir -p ./tmp/backup
docker compose run \
  --rm --volume "$(realpath tmp/backup):/tmp/backup" \
  postgres \
  sh -c "
    mkdir -p /tmp/backup && \
    pg_dump -U david_runger -h postgres -F t -w david_runger_production \
    > '/tmp/backup/export'
  "

# Send backup to S3
docker compose run \
  --rm --volume "$(realpath tmp/backup):/backup" \
  s3_db_backup

# Clean up
rm -rf tmp/backup
