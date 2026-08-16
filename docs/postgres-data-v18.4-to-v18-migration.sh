# Make sure that PR to rename the PostgreSQL data volume from v18.4 to v18 is ready to merge.

# Check git status. Expect a clean working tree.
git status

# Check git HEAD.
git show

# Check the current PostgreSQL version.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT VERSION();'

# Check data (to have a point of comparison later).
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM items ORDER BY created_at DESC LIMIT 1;'

# Confirm that the old volume exists and that the destination volume does not.
docker volume ls --format '{{.Name}}' | grep -E '^david_runger_postgres-data-v18(\.4)?$'
docker volume inspect david_runger_postgres-data-v18.4
if docker volume inspect david_runger_postgres-data-v18 >/dev/null 2>&1; then
  echo 'The destination volume already exists; stop here.'
  exit 1
fi

# [OPTIONAL] Create an additional database backup in S3.
bin/server/back-up-db-to-s3.sh

# Switch to the new PostgreSQL data volume in docker-compose.yml.
sed -i'' 's/postgres-data-v18\.4:/postgres-data-v18:/g' docker-compose.yml

# Check git status.
git status

# View git diff. Expect only the volume name to have changed.
git diff -- docker-compose.yml

# Stop services that permit access to the database.
docker compose stop clock nginx web worker

# Create database backup on the server.
docker compose exec --no-TTY postgres pg_dumpall -U david_runger > backup.sql

# Check that the backup file is approximately the expected size.
ls -lh backup.sql

# Do a sanity check on the formatting of the backup file.
head -5 backup.sql | grep -q 'PostgreSQL' && echo 'Backup format looks correct'

# Bring down the database. The old data volume remains intact.
docker compose down postgres

# Bring up PostgreSQL with the new, empty volume.
docker compose up --detach --wait postgres

# Check that the new volume is mounted by the PostgreSQL container.
docker inspect "$(docker compose ps -q postgres)" --format '{{range .Mounts}}{{println .Name .Destination}}{{end}}'

# Check the PostgreSQL version.
docker compose exec postgres psql -U david_runger -c 'SELECT VERSION();'

# Restore data from the dump.
docker compose exec --no-TTY postgres psql -U david_runger < backup.sql

# Check data against the earlier result.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM items ORDER BY created_at DESC LIMIT 1;'

# Boot services.
bin/server/boot-services.sh

# Verify services.
bin/server/verify-expected-services.sh

# Check via the web interface that data is there.

# Delete the dump after the restore has been validated.
rm backup.sql

# Restore the temporary working-tree change to docker-compose.yml before deployment.
git restore -- docker-compose.yml

# Check git status. Expect a clean working tree.
git status

# Confirm that the running PostgreSQL container uses the new volume.
docker inspect "$(docker compose ps -q postgres)" --format '{{range .Mounts}}{{println .Name .Destination}}{{end}}'

# Merge the PR to update docker-compose.yml and wait for it to deploy.
#
# Check version after deployment.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT VERSION();'

# Check data is still good after deployment.
docker compose exec postgres psql -U david_runger david_runger_production -c 'SELECT COUNT(*) FROM users; SELECT * FROM items ORDER BY created_at DESC LIMIT 1;'

# Remove the old data volume only after the deployment has been validated.
docker volume rm david_runger_postgres-data-v18.4

# Check git status.
git status

# Check git HEAD.
git show
