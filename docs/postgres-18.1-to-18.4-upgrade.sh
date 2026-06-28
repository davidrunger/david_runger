# Make sure that PR to update docker-compose.yml to Postgres 18.4 is ready to merge.

# Check git status.
git status

# Check git HEAD.
git show

# Check version (expect PostgreSQL 18.1).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT VERSION();'

# Check data (to have a point of comparison later).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM items ORDER BY created_at DESC LIMIT 1;'

# [ON LOCAL] Create database backup in S3.
bin/qr

# Update Postgres from 18.1 to 18.4 in docker-compose.yml.
sed -i'' 's/postgres:18.1-alpine/postgres:18.4-alpine/g' docker-compose.yml

# Update the directory at which the Postgres volume is mounted.
sed -i'' 's|/var/lib/postgresql/data|/var/lib/postgresql|g' docker-compose.yml

# Switch to new Postgres data volume in docker-compose.yml.
sed -i'' 's/postgres-data-v18:/postgres-data-v18.4:/g' docker-compose.yml

# Check git status.
git status

# View git diff.
git diff

# Pull the new Postgres 18.4 image (to minimize downtime).
docker compose pull postgres

# Check that the Postgres 18.4 image is available.
docker images postgres

# Stop services that permit access to the database.
docker compose stop clock nginx web worker

# Create database backup on server.
docker compose exec postgres pg_dumpall -U david_runger > backup.sql

# Check git status.
git status

# Check that the backup file is approximately the expected size.
ls -lh backup.sql

# Do a sanity check on the formatting of the backup file.
head -5 backup.sql | grep -q "PostgreSQL" && echo "✓ Backup format looks correct"

# Bring down the database.
docker compose down postgres

# Check Docker processes. Expect not to see the stopped / down services.
docker ps

# Bring up the database (version 18).
docker compose up --detach postgres

# Check version (expect PostgreSQL 18.4).
docker compose exec postgres psql -U david_runger -c 'SELECT VERSION();'

# Restore data from dump.
docker compose exec --no-TTY postgres psql -U david_runger < backup.sql

# Check data.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM items ORDER BY created_at DESC LIMIT 1;'

# Boot services.
bin/server/boot-services.sh

# Verify services.
bin/server/verify-expected-services.sh

# Check via web interface that data is there!

# Check git status.
git status

# Delete dump.
rm backup.sql

# Undo changes to docker-compose.yml.
git checkout docker-compose.yml

# Check git status (expect no changes).
git status

# Remove old data volume.
docker volume rm david_runger_postgres-data-v18

# Merge PR to update Postgres version and reference postgres v18 volume in docker-compose.yml.
# Wait for it to deploy.

# Check version (expect PostgreSQL 18.4).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT VERSION();'

# Check data is still good.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM items ORDER BY created_at DESC LIMIT 1;'

# Check git status.
git status

# Check git HEAD.
git show
