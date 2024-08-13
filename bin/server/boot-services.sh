#!/usr/bin/env bash

# Boot the services that we want/need booted in order to run the web app.

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# Boot default services.
docker compose up --detach --remove-orphans

# Boot web-related services (which are in nondefault group).
docker compose up --detach --remove-orphans web nginx
