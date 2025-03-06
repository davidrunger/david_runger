#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# Move to the application directory.
cd /root/david_runger

# Prune Docker.
docker system prune --all --force

# Rebuild Docker image(s).
RAILS_ENV=production bin/build-docker
