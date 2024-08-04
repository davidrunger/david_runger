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
docker compose build \
  --build-arg "GIT_REV=$GIT_REV" \
  --build-arg "RUBY_VERSION=$(cat .ruby-version)" \
  --build-arg "RAILS_ENV=production" \
  --progress=plain

# Launch new Rails services.
docker compose up --detach clock nginx web worker

# Run release tasks.
docker compose exec web bin/server/release-tasks

# Check out and update main branch.
git checkout main
git reset --hard origin/main
