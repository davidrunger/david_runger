#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sidekiq/deploy'
Sidekiq::Deploy.mark!(ENV.fetch('GIT_REV')[0, 7])
