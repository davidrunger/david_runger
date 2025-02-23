#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

if [ ! -v LOCAL_TEST ] && [ "$(git config user.email)" != '' ] ; then
  echo 'You probably want to run this with LOCAL_TEST=1 ?'
  exit 1
fi

if [[ -n $(git status --porcelain) ]] ; then
  echo 'The working directory is not clean. Aborting.'
  exit 1
fi

# Check out the GIT_REV target commit (unless testing locally).
if [ ! -v LOCAL_TEST ] ; then
  git fetch
  git checkout "$GIT_REV"

  current_commit=$(git rev-parse HEAD)

  # Confirm that we were able to check out the intended commit.
  if [ "$current_commit" != "$GIT_REV" ] ; then
    echo "Failed to check out $GIT_REV; at $current_commit instead."
    exit 1
  fi
fi

# Run the install script (unless testing locally).
if [ ! -v LOCAL_TEST ] ; then
  bin/server/install.sh
fi

# Export necessary env vars.
bin/server/export-env-vars-needed-by-docker

# Rebuild the app (for development if testing locally, otherwise for production).
if [ -v LOCAL_TEST ] ; then
  bin/build-docker development
else
  bin/build-docker production
fi

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

# Check out and update main branch (unless testing locally).
if [ ! -v LOCAL_TEST ] ; then
  git checkout main
  git reset --hard origin/main
fi

# Verify that all expected services are running.
bin/server/verify-expected-services.sh
