#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

if [[ -n $(git status --porcelain) ]] ; then
  echo 'The working directory is not clean. Aborting.'
  exit 1
fi

git fetch
git checkout "$GIT_REV"

current_commit=$(git rev-parse HEAD)

# Confirm that we were able to check out the intended commit.
if [ "$current_commit" != "$GIT_REV" ] ; then
  echo "Failed to check out $GIT_REV; at $current_commit instead."
  exit 1
fi

# Run the install script.
bin/server/install.sh

# Rebuild the app.
bin/build-docker production

# Run release tasks.
bin/server/run-release-tasks

# If NGINX is not already running, then start it.
if ! docker compose ps -q nginx | grep -q . ; then
  docker compose up --detach --remove-orphans nginx
fi

# Copy fully built out public/ directory from web to nginx via app-public volume.
docker run --rm \
  --mount source=david_runger_app-public,target=/app-public \
  --entrypoint cp david_runger-web -r /app/public/. /app-public/

# Perform zero downtime, rolling deploy of web/nginx.
bin/server/roll-out-web.sh

# Launch fresh versions of all other services.
docker compose up --detach --remove-orphans

# Check out and update main branch.
git checkout main
git reset --hard origin/main

# Verify that all expected services are running.
bin/server/verify-expected-services.sh
