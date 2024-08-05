#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

running_services=$(docker ps --filter='status=running' --format='table {{.Names}}' | tail +2)
expected_running_services=(certbot clock memcached nginx postgres redis web worker)
expected_services_not_running=()

for expected_service in "${expected_running_services[@]}"; do
  if ! grep -q -P "^david_runger-$expected_service-\d+$" <<< "$running_services" ; then
    echo "$expected_service is not running!"
    expected_services_not_running+=("$expected_service")
  fi
done

if [ "${#expected_services_not_running[@]}" -ne 0 ]; then
  exit 1
fi
