ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-bookworm AS base

RUN test -n "$RUBY_VERSION"

WORKDIR /app

# Install base packages
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  libjemalloc2 postgresql-client && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development test"

# Use jemalloc for memory savings.
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2


# BEGIN build step: Create throw-away build stage to reduce size of final image
# \/ \/ \/ \/ \/ \/ \/ \/ \/
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential curl git libpq-dev unzip && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
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
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

ENTRYPOINT ["/app/bin/docker-entrypoint"]
