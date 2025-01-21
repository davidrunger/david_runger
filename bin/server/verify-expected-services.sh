#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

expected_running_services=(clock postgres redis-app redis-cache web worker)
expected_services_not_running=()
max_retries=30
retry_delay=2

check_services() {
  running_services=$(docker ps --filter='status=running' --format='table {{.Names}} {{.Status}}' | tail -n +2)
  expected_services_not_running=()

  for expected_service in "${expected_running_services[@]}" ; do
    # Make sure that the service is running and that the healthcheck (if there is one) is healthy.
    if ! grep -q -P "^david_runger-$expected_service-\d+ Up [^(]+ \(healthy\)$" <<< "$running_services" ; then
      echo "$expected_service is not running!"
      expected_services_not_running+=("$expected_service")
    fi
  done
}

for ((i = 1; i <= max_retries; i++)) ; do
  check_services

  if [ "${#expected_services_not_running[@]}" -eq 0 ] ; then
    echo 'All expected services are running.'
    exit 0
  else
    echo "Retrying... ($i/$max_retries)"
    sleep "$retry_delay"
  fi
done

echo "Some expected services are not running after $max_retries retry attempts."
exit 1
