#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

git fetch
git checkout "$GIT_REV"

current_commit=$(git rev-parse HEAD)

# Confirm that we were able to check out the intended commit.
if [ "$current_commit" != "$GIT_REV" ] ; then
  echo "Failed to check out $GIT_REV; at $current_commit instead."
  exit 1
fi

# Rebuild the app.
docker compose build \
  --build-arg "GIT_REV=$GIT_REV" \
  --build-arg "RUBY_VERSION=$(cat .ruby-version)" \
  --progress=plain

# Launch new Rails services.
docker compose up --detach clock nginx web worker

# Run release tasks.
docker compose exec web bin/rails runner bin/server/release-tasks.rb

# Check out and update main branch.
git checkout main
git reset --hard origin/main
