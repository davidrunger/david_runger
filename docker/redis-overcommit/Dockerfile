# Original helper by bkuhl, vendored from:
# https://github.com/bkuhl/redis-overcommit-on-host/blob/09215f160d59a7289ab3f4734f235659cdb8d269/Dockerfile
FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

VOLUME /mnt

CMD echo 1 > /mnt/vm/overcommit_memory
