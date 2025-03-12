if Rails.env.local? && !IS_DOCKER
  require 'prosopite/middleware/rack'
  Rails.configuration.middleware.use(Prosopite::Middleware::Rack)

  Rails.application.config.after_initialize do
    Prosopite.rails_logger = true
    Prosopite.raise = true
  end
end
