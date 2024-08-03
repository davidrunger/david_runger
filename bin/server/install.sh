#!/usr/bin/env bash

# This script can be executed on a server (repeatedly/idempotently) to set it up.

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

ln -sf "$HOME/david_runger/bin/server/startup.sh" /etc/rc.local
