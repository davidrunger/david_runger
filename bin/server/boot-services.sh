#!/usr/bin/env bash

# Boot the services that we want/need booted in order to run the web app.

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# NOTE: These aren't the only services that need to be booted, but, via
# `depends_on` declarations, these services will also cause all other necessary
# services to be booted.
docker compose up --detach clock nginx
