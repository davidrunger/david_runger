#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

# To minimize risk of accidental DB deletion, continue only if all expected
# services are running.
expected_num_services=16
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

# The daily Docker image rebuild can create host memory pressure, causing the
# worker container to swap. Recreate the worker after the build, so it starts
# fresh in RAM and its swap usage is reset. Shut down Grafana first, because
# it's often the largest memory consumer on the host, and we want to free that
# memory up for `worker` to claim instead.
docker compose rm -sf grafana
docker compose up -d --force-recreate --no-deps worker
# Give the worker a moment to boot and allocate its memory before Grafana
# (which is memory-hungry) comes back and competes for RAM.
sleep 15
docker compose up -d --no-deps grafana

# Wait for grafana to be healthy before reloading nginx.
grafana_healthy=false
for i in $(seq 1 30); do
  if docker compose exec -T grafana wget -qO- http://localhost:3000/api/health >/dev/null 2>&1; then
    grafana_healthy=true
    break
  fi
  sleep 2
done

if [[ "$grafana_healthy" == true ]]; then
  docker compose exec -T nginx nginx -s reload
else
  echo "Grafana did not become healthy within 60s; not reloading nginx." >&2
  exit 1
fi
