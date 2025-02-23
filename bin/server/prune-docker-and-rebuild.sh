#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# Move to the application directory.
cd /root/david_runger

# Prune Docker.
docker system prune --all --force

# Export necessary env vars.
. bin/server/export-env-vars-needed-by-docker

# Rebuild Docker image(s).
bin/build-docker production
