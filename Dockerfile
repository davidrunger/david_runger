ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-bookworm AS base

RUN test -n "$RUBY_VERSION"

WORKDIR /app

# Don't automatically delete packages after installing them. (We want to cache them via Docker.)
RUN rm /etc/apt/apt.conf.d/docker-clean

# Install base packages
RUN --mount=type=cache,sharing=private,target=/var/lib/apt/lists \
  --mount=type=cache,sharing=private,target=/var/cache/apt \
  apt-get update && \
  apt-get install --no-install-recommends -y \
  curl libjemalloc2 postgresql-client procps

ARG RAILS_ENV
RUN test -n "$RAILS_ENV"
ENV RAILS_ENV=${RAILS_ENV}

# Use jemalloc for memory savings.
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Set up for gem installation.
ARG GEMS_DIRECTORY=vendor/bundle
RUN bundle config set path "${GEMS_DIRECTORY}" && \
  bundle config set without development:test


# BEGIN build step: Create throw-away build stage to reduce size of final image
# \/ \/ \/ \/ \/ \/ \/ \/ \/
FROM base AS build

# Install packages needed to build gems
RUN --mount=type=cache,sharing=private,target=/var/lib/apt/lists \
  --mount=type=cache,sharing=private,target=/var/cache/apt \
  apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential git libpq-dev libyaml-dev unzip

# Download skedjewel binary.
ARG SKEDJEWEL_VERSION=v0.0.16
RUN curl --fail -L "https://github.com/davidrunger/skedjewel/releases/download/$SKEDJEWEL_VERSION/skedjewel-$SKEDJEWEL_VERSION-linux" > skedjewel && \
  mkdir -p /app/bin && \
  mv skedjewel /app/bin/ && \
  chmod a+x /app/bin/skedjewel

# Configure bundler and install application gems
RUN \
  bundle config set --local clean 1 && \
  bundle config set --local deployment 1 && \
  bundle config set --local path /app/.cache/bundle
COPY Gemfile Gemfile.lock .ruby-version ./
RUN --mount=type=cache,sharing=private,target=/app/.cache/bundle \
  bundle install && \
  mkdir vendor && \
  cp -ar /app/.cache/bundle "${GEMS_DIRECTORY}"
RUN bundle config set --local path "${GEMS_DIRECTORY}"

RUN bundle exec bootsnap precompile --gemfile

# Copy application code and compiled assets
COPY . .

ARG GIT_REV

# Build public/assets/, download public/vite/ and public/vite-admin/.
RUN DOCKER_BUILD=true \
  GIT_REV=${GIT_REV} \
  SECRET_KEY_BASE_DUMMY=1 \
  VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION=true \
  bundle exec rails assets:precompile > /dev/null

# Precompile bootsnap code for faster boot times
RUN bin/bootsnap precompile app/ lib/
# ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
# END build step


# Return to base image for final stage of app image build
FROM base

# Copy everything added to the app WORKDIR: gems, application code, skedjewel, compiled assets.
COPY --from=build /app /app

# Add GIT_REV env var permanently to the image
ARG GIT_REV
ENV GIT_REV=${GIT_REV}

# Add ENV var to indicate that this is a Docker-built image.
ENV DOCKER_BUILT=true

ENTRYPOINT ["/app/bin/docker-entrypoint"]
