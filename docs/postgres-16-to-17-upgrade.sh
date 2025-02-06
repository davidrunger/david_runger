#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# Make sure that PR to update docker-compose.yml to Postgres 17 is ready to merge.

# Check git status.
git status

# Check version (expect PostgreSQL 16.3).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT VERSION();'

# Check data (to have a point of comparison later).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM text_log_entry_data ORDER BY created_at DESC LIMIT 1;'

# [ON LOCAL] Create database backup in S3.
bin/qr

# Update Postgres from 16.3 to 17.2 in docker-compose.yml.
sed -i 's/postgres:16.3-alpine/postgres:17.2-alpine/g' docker-compose.yml

# Switch to new Postgres data volume in docker-compose.yml.
sed -i 's/postgresql:/postgres-data-v17:/g' docker-compose.yml

# Check git status.
git status

# View git diff.
git diff

# Pull the new Postgres 17 image (to minimize downtime).
docker compose pull postgres

# Check that the Postgres 17 image is available.
docker images postgres

# Stop services that access the database.
docker compose stop clock nginx web worker

# Create database backup on server.
docker compose exec postgres pg_dumpall -U david_runger > backup.sql

# Check git status.
git status

# Check that the backup file is approximately the expected size.
ls -lah backup.sql

# Bring down the database.
docker compose down postgres

# Check Docker processes. Expect not to see the services just taken down.
docker ps

# Bring up the database (version 17).
docker compose up --detach postgres

# Check version (expect PostgreSQL 17.2).
docker compose exec postgres psql -U david_runger -c 'SELECT VERSION();'

# Restore data from dump.
docker compose exec --no-TTY postgres psql -U david_runger < backup.sql

# Check data.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM text_log_entry_data ORDER BY created_at DESC LIMIT 1;'

# Boot services.
bin/server/boot-services.sh

# Verify services.
bin/server/verify-expected-services.sh

# Check git status.
git status

# Delete dump.
rm backup.sql

# Undo changes to docker-compose.yml.
git checkout .

# Check git status.
git status

# Check git HEAD.
git show

# Remove old data volume.
docker volume rm david_runger_postgresql

# Merge PR to update Postgres version and reference postgres v17 volume in docker-compose.yml.
# Wait for it to deploy.

# Check version (expect PostgreSQL 17.2).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT VERSION();'

# Check data is still good.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM text_log_entry_data ORDER BY created_at DESC LIMIT 1;'

# Check git status.
git status

# Check git HEAD.
git show
