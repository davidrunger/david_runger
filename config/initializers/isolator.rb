# `Isolator` is not available in production (per the Gemfile)
if Rails.env.local? && !IS_DOCKER
  Isolator.configure do |config|
    config.raise_exceptions = true
  end
end
