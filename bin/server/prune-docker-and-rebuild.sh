#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# To minimize risk of accidental DB deletion, continue only if all expected
# services are running.
expected_num_services=15
actual_num_services=$(docker ps --filter status=running --quiet | wc -l)

if [[ "$actual_num_services" -ne "$expected_num_services" ]] ; then
  echo "Expected $expected_num_services running Docker services, but found $actual_num_services. Exiting."
  exit 1
fi

# Move to the application directory.
cd /root/david_runger

# Prune Docker.
docker system prune --all --force

# Rebuild Docker image(s).
RAILS_ENV=production bin/build-docker
