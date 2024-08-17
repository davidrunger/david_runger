#!/usr/bin/env bash

# Boot the services that we want/need booted in order to run the web app.

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

boot_services() {
  services=("$@")

  docker compose up --detach --remove-orphans "${services[@]}"
}

# Boot default services.
boot_services

# Boot web-related services (which are in nondefault group).
boot_services web nginx
