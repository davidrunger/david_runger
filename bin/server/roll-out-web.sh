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

# If web is not already running, then start it.
if ! docker compose ps -q web | grep -q . ; then
  docker compose up --detach --remove-orphans web
fi

old_container_id=$(docker ps --filter name=web --quiet | tail -1)

# Bring a new container online, running new code.
# (NGINX continues routing to the old container only.)
scale_web 2

# Wait for new container to be available.
new_container_id=$(docker ps --filter name=web --quiet | head -1)
new_container_ip=$(docker inspect --format '{{.NetworkSettings.Networks.david_runger_internal.IPAddress}}' "$new_container_id")
echo_iso8601 "Curling new container IP until success."
attempt=1
max_attempts=30
delay=2
url="http://$new_container_ip:3000/up"

while [ $attempt -le $max_attempts ] ; do
  echo_iso8601 "attempt=$attempt max_attempts=$max_attempts url=$url"

  # Capture both stdout and stderr, along with exit code
  set +e
  response=$(curl --silent --output /dev/null --write-out "%{http_code}\n%{errormsg}" "$url" 2>&1)
  exit_code=$?
  set -e

  # Parse response - last line is error message, second to last is status code
  error_msg=$(echo "$response" | tail -n1)
  status_code=$(echo "$response" | tail -n2 | head -n1)

  # Validate status code is a number and in range
  if [ $exit_code -eq 0 ] && [[ "$status_code" =~ ^[0-9]+$ ]] && [ "$status_code" -ge 200 ] && [ "$status_code" -lt 300 ] ; then
    echo_iso8601 "attempt=$attempt status=success status_code=$status_code"
    break
  else
    if [ $exit_code -eq 7 ] ; then
      echo_iso8601 "attempt=$attempt status=error error=connection_refused"
    elif [ $exit_code -eq 28 ] ; then
      echo_iso8601 "attempt=$attempt status=error error=connection_timeout"
    else
      echo_iso8601 "attempt=$attempt status=error status_code=$status_code error_msg=\"$error_msg\" exit_code=$exit_code"
    fi

    if [ $attempt -eq $max_attempts ] ; then
      echo_iso8601 "status=error message=\"all_retry_attempts_failed\""
      exit 1
    fi

    sleep $delay
    attempt=$((attempt + 1))
  fi
done

reload_nginx

# Remove the old container.
if [[ -n "$old_container_id" ]]; then
  echo_iso8601 "Removing the old container."
  docker stop "$old_container_id"
  docker rm "$old_container_id"
fi

scale_web 1

# Stop trying to route requests to the old container.
reload_nginx
