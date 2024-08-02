#!/usr/bin/env bash

set -euo pipefail # exit on any error, don't allow undefined variables, pipes don't swallow errors

whoami
pwd
ls -lah
touch "/tmp/deploy-test-$(date)"
