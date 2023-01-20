# frozen_string_literal: true

# `Isolator` is not available in production (per the Gemfile)
if Rails.env.in?(%w[development test])
  Isolator.configure do |config|
    config.raise_exceptions = true
  end
end
