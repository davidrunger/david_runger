ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-bookworm AS base

RUN test -n "$RUBY_VERSION"

WORKDIR /app

# Install base packages
RUN --mount=type=cache,sharing=private,target=/var/lib/apt/lists \
  --mount=type=cache,sharing=private,target=/var/cache/apt \
  apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  libjemalloc2 postgresql-client

ENV RAILS_ENV="production"
ARG GEMS_DIRECTORY=vendor/bundle

# Use jemalloc for memory savings.
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2


# BEGIN build step: Create throw-away build stage to reduce size of final image
# \/ \/ \/ \/ \/ \/ \/ \/ \/
FROM base AS build

# Install packages needed to build gems
RUN --mount=type=cache,sharing=private,target=/var/lib/apt/lists \
  --mount=type=cache,sharing=private,target=/var/cache/apt \
  apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential curl git libpq-dev unzip

# Configure bundler and install application gems
RUN \
  bundle config set --local clean 1 && \
  bundle config set --local deployment 1 && \
  bundle config set --local path /app/.cache/bundle && \
  bundle config set --local without development:test
COPY Gemfile Gemfile.lock .ruby-version ./
RUN --mount=type=cache,sharing=private,target=/app/.cache/bundle \
  mkdir vendor && \
  bundle install && \
  cp -ar /app/.cache/bundle "${GEMS_DIRECTORY}" && \
  bundle config set path "${GEMS_DIRECTORY}" && \
  bundle exec bootsnap precompile --gemfile

# Copy application code and compiled assets
COPY . .

ARG GIT_REV
ARG RAILS_MASTER_KEY

ENV GIT_REV=${GIT_REV} \
  RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
  DOCKER_BUILD="true"

# Build public/assets/, download public/vite/ and public/vite-admin/, and download skedjewel.
RUN VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION=true \
  bundle exec rails assets:precompile

# Precompile bootsnap code for faster boot times
RUN bin/bootsnap precompile app/ lib/
# ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
# END build step


# Return to base image for final stage of app image build
FROM base

# Copy built artifacts: gems, application code, compiled assets
COPY --from=build "${GEMS_DIRECTORY}" "${GEMS_DIRECTORY}"
COPY --from=build /app /app

ENTRYPOINT ["/app/bin/docker-entrypoint"]
