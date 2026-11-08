#!/bin/sh -e

# This script (system-startup.sh in the david_runger repo) is not intended to be
# executed directly, but rather to be symlinked to `/etc/rc.local`, so that it's
# contents will be executed at system startup.

log_dir=/var/log/docker-startup
mkdir -p "$log_dir"
docker_startup_log="$log_dir/$(date -u +%Y%m%dT%H%M%SZ).log"

# Delete startup logs older than 90 days.
find "$log_dir" -name '*.log' -mtime +90 -delete || true

{
  # Log the script execution start time
  echo "Startup script executed at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  # Log current directory and user
  echo "Current directory: $(pwd)"
  echo "Current user: $(whoami)"
}  >> "$docker_startup_log"

# Wait for Docker to be active
while ! systemctl is-active --quiet docker; do
  echo "Waiting for Docker to start at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$docker_startup_log"
  sleep 1
done

# Change to the directory containing the docker-compose.yml file
cd "/$(whoami)/david_runger" || {
  echo "Failed to change directory to /$(whoami)/david_runger" >> "$docker_startup_log"
  exit 1
}

# Start the Docker services
bin/server/boot-services.sh >> "$docker_startup_log" 2>&1 &

exit 0
