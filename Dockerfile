ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-bookworm AS base

RUN test -n "$RUBY_VERSION"

WORKDIR /app

# Install base packages
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  curl libjemalloc2 netcat-traditional postgresql-client unzip && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development test"




# Create throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential git libpq-dev && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

ARG GIT_REV
ARG RAILS_MASTER_KEY

ENV GIT_REV=${GIT_REV} \
  MEMCACHED_PASSWORD="" \
  MEMCACHED_URL="memcached://dummy:11211" \
  RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
  REDIS_URL="redis://dummy:6379" \
  DOCKER_BUILD="true"

# Build public/assets/ and also download public/vite/ and public/vite-admin/
RUN VITE_RUBY_SKIP_ASSETS_PRECOMPILE_EXTENSION=true \
  bundle exec rails assets:precompile

# Precompile bootsnap code for faster boot times
RUN bin/bootsnap precompile app/ lib/




# Return to base image for final stage of app image build
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

# Use jemalloc for memory savings.
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

ENTRYPOINT ["/app/bin/docker-entrypoint"]
