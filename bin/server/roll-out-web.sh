#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

iso8601() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

echo_iso8601 () {
  message=$1
  echo "$(iso8601) $message"
}

reload_nginx() {
  echo_iso8601 'Reloading NGINX.'
  docker compose exec nginx nginx -s reload
}

scale_web() {
  scale=$1
  echo_iso8601 "Scaling web to $scale."
  docker compose up --detach --no-deps --scale web="$scale" --no-recreate --remove-orphans web
}

set -a
. .env.papertrail.local
set +a

old_container_id=$(docker ps --filter name=web --quiet | tail -1)

# Bring a new container online, running new code.
# (NGINX continues routing to the old container only.)
scale_web 2

# Wait for new container to be available.
new_container_id=$(docker ps --filter name=web --quiet | head -1)
new_container_ip=$(docker inspect --format '{{.NetworkSettings.Networks.david_runger_internal.IPAddress}}' "$new_container_id")
echo_iso8601 "Curling new container IP until success."
curl --silent --output /dev/null --retry-connrefused --retry 30 --retry-delay 1 --fail "http://$new_container_ip:3000/" || exit 1

# Start routing requests to the new container instead of the old.
reload_nginx

# Remove the old container.
echo_iso8601 "Removing the old container."
docker stop "$old_container_id"
docker rm "$old_container_id"

scale_web 1

# Stop trying to route requests to the old container.
reload_nginx
