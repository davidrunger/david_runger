# frozen_string_literal: true

Spring.watch(*%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
])
