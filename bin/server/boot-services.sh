#!/usr/bin/env bash

# Boot the services that we want/need booted in order to run the web app.

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

boot_services() {
  services=("$@")

  docker compose up --detach --remove-orphans --no-build "${services[@]}"
}

boot_all() {
  # Default services, then the web-related ones (which are in the nondefault profile).
  boot_services && boot_services web nginx
}

# If images are missing (e.g. pruned, then a failed nightly rebuild), rebuild once and retry.
if ! boot_all; then
  echo "Boot failed; rebuilding images and retrying." >&2
  RAILS_ENV=production bin/build-docker
  boot_all
fi
