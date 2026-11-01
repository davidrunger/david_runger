if Rails.env.local? && !IS_DOCKER
  require 'prosopite/middleware/rack'
  Rails.configuration.middleware.use(Prosopite::Middleware::Rack)

  Rails.application.config.after_initialize do
    Prosopite.rails_logger = true
    Prosopite.raise = true
    Prosopite.display_query_count = true
    Prosopite.display_max_n_queries = 1
  end
end
